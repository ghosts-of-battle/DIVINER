// pacdb-service - the PAC store and config as documents in MongoDB (or a
// folder of files, for testing the pipe without a database). The game never
// sees this: the ghostd_pacdb extension on the server speaks to it over HTTP,
// and so do the tools on an admin's PC (pac_sync.py, push_config.py).
//
// ONE DOCUMENT, WHOLE. The store is the same JSON the panel exports, stored
// as a string, keyed by unitId. No schema in the database to keep in step
// with the mod: a newer PAC's document is a newer PAC's document. Diffing,
// backing up and restoring stay trivial, and the mod's own merge (import)
// is the merge.

using System.Text;
using MongoDB.Bson;
using MongoDB.Driver;

var builder = WebApplication.CreateBuilder(args);
// Secrets live in appsettings.Local.json (git-ignored), never in the repo copy.
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: false);
var cfg = builder.Configuration;

IStore store = (cfg["Store"] ?? "mongo").ToLowerInvariant() switch
{
    "mongo"     => new MongoStore(cfg["Mongo:ConnectionString"] ?? "mongodb://localhost:27017", cfg["Mongo:Database"] ?? "ghostd", cfg["Mongo:Collection"] ?? "pac"),
    _           => new FileStore(cfg["File:Directory"] ?? "./data"),
};
var apiKey = cfg["ApiKey"] ?? "";

var app = builder.Build();

// The one gate: a shared key in a header. Loopback deployments can leave it
// empty; anything reachable from outside should not.
app.Use(async (ctx, next) =>
{
    if (apiKey.Length > 0 && ctx.Request.Headers["X-Api-Key"] != apiKey)
    {
        ctx.Response.StatusCode = 401;
        await ctx.Response.WriteAsync("bad api key");
        return;
    }
    await next();
});

app.MapGet("/health", () => Results.Text("ok " + store.Name));

app.MapGet("/pac/{unit}", async (string unit) =>
{
    var json = await store.Get(unit);
    return json is null ? Results.NotFound() : Results.Text(json, "application/json", Encoding.UTF8);
});

// The keys under a prefix - how the mod finds every order document.
app.MapGet("/pac", async (string? prefix) => Results.Json(await store.List(prefix ?? "")));

app.MapDelete("/pac/{unit}", async (string unit) => await store.Delete(unit) ? Results.NoContent() : Results.NotFound());

app.MapPut("/pac/{unit}", async (string unit, HttpRequest req) =>
{
    using var reader = new StreamReader(req.Body, Encoding.UTF8);
    var json = await reader.ReadToEndAsync();
    if (json.Length == 0) return Results.BadRequest("empty body");
    await store.Put(unit, json);
    return Results.NoContent();
});

app.Logger.LogInformation("pacdb-service up, store = {Store}", store.Name);
app.Run();

// ------------------------------------------------------------------ stores --

interface IStore
{
    string Name { get; }
    Task<string?> Get(string unit);
    Task Put(string unit, string json);
    Task<string[]> List(string prefix);
    Task<bool> Delete(string unit);
}

// A folder of <unit>.json, plus a dated copy on every put. The zero-setup
// choice, and the one to test the pipe with before a database is involved.
sealed class FileStore : IStore
{
    readonly string _dir;
    public FileStore(string dir) { _dir = dir; Directory.CreateDirectory(dir); Directory.CreateDirectory(Path.Combine(dir, "history")); }
    public string Name => "file";
    static string Safe(string unit) => string.Concat(unit.Select(c => char.IsLetterOrDigit(c) || c is '-' or '_' ? c : '_'));

    public async Task<string?> Get(string unit)
    {
        var p = Path.Combine(_dir, Safe(unit) + ".json");
        return File.Exists(p) ? await File.ReadAllTextAsync(p, Encoding.UTF8) : null;
    }

    public async Task Put(string unit, string json)
    {
        var p = Path.Combine(_dir, Safe(unit) + ".json");
        var tmp = p + ".tmp";
        await File.WriteAllTextAsync(tmp, json, Encoding.UTF8);
        File.Move(tmp, p, overwrite: true);                       // never a half-written current file
        await File.WriteAllTextAsync(Path.Combine(_dir, "history", $"{Safe(unit)}-{DateTime.UtcNow:yyyyMMdd-HHmmss}.json"), json, Encoding.UTF8);
    }

    public Task<string[]> List(string prefix) => Task.FromResult(
        Directory.GetFiles(_dir, "*.json").Select(f => Path.GetFileNameWithoutExtension(f)).Where(n => n.StartsWith(Safe(prefix))).OrderBy(n => n).ToArray());

    public Task<bool> Delete(string unit)
    {
        var p = Path.Combine(_dir, Safe(unit) + ".json");
        if (!File.Exists(p)) return Task.FromResult(false);
        File.Delete(p); return Task.FromResult(true);
    }

}

// MongoDB: one document per key, stored as REAL FIELDS - the JSON the mod
// sends is parsed into BSON, so the database's own site shows and edits the
// document as a document, not as an escaped string. _id and updatedAt are the
// service's; everything else is the mod's and goes back out exactly as fields.
sealed class MongoStore : IStore
{
    static readonly MongoDB.Bson.IO.JsonWriterSettings Plain = new() { OutputMode = MongoDB.Bson.IO.JsonOutputMode.RelaxedExtendedJson };
    readonly IMongoCollection<BsonDocument> _col;
    public MongoStore(string conn, string db, string col) => _col = new MongoClient(conn).GetDatabase(db).GetCollection<BsonDocument>(col);
    public string Name => "mongo";

    public async Task<string?> Get(string unit)
    {
        var doc = await _col.Find(Builders<BsonDocument>.Filter.Eq("_id", unit)).FirstOrDefaultAsync();
        if (doc is null) return null;
        if (doc.TryGetValue("json", out var legacy) && legacy.IsString) return legacy.AsString;   // documents written before fields
        doc.Remove("_id"); doc.Remove("updatedAt");
        return doc.ToJson(Plain);
    }

    public Task Put(string unit, string json)
    {
        var doc = BsonDocument.Parse(json);
        doc.Remove("_id"); doc.Remove("updatedAt");
        doc.InsertAt(0, new BsonElement("_id", unit));
        doc.Add("updatedAt", DateTime.UtcNow);
        return _col.ReplaceOneAsync(Builders<BsonDocument>.Filter.Eq("_id", unit), doc, new ReplaceOptions { IsUpsert = true });
    }

    public async Task<string[]> List(string prefix)
    {
        var filter = Builders<BsonDocument>.Filter.Regex("_id", new BsonRegularExpression("^" + System.Text.RegularExpressions.Regex.Escape(prefix)));
        var docs = await _col.Find(filter).Project(Builders<BsonDocument>.Projection.Include("_id")).ToListAsync();
        return docs.Select(d => d["_id"].AsString).OrderBy(s => s).ToArray();
    }

    public async Task<bool> Delete(string unit)
        => (await _col.DeleteOneAsync(Builders<BsonDocument>.Filter.Eq("_id", unit))).DeletedCount > 0;
}
