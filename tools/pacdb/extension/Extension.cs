// ghostd_pacdb - the Arma 3 side of TAC//PAC's database. Windows (.dll) and
// Linux (.so) from the same source: NativeAOT, see ghostd_pacdb.csproj and
// build-linux.sh.
//
// TWO BACKENDS, ONE VOCABULARY. The mod hands the extension one address
// ("configure", from its CBA server setting 'Service URL'):
//
//   mongodb+srv://... / mongodb://...   TALKS TO MONGODB DIRECTLY - Atlas, or
//                                       any Mongo - with the driver built in.
//                                       Nothing else has to run anywhere: a
//                                       rented game server that can run
//                                       nothing beside Arma (user, 2026-09-05)
//                                       still gets its database.
//   http://... / https://...            talks to the pacdb service over HTTP
//                                       (tools/pacdb/service), which holds the
//                                       Mongo password so the game never sees it.
//
// Both answer the same verbs - get key, list prefix, put.begin/chunk/end key,
// ping - through the callback Arma registered, in chunks small enough for
// Arma's buffer, on a thread: a server frame never waits on the network.
// Documents are the same shape either way: real BSON fields, _id = the key.
//
// SERVER ONLY. The mod calls it from the server and nowhere else; a client
// never loads it. KNOW WHAT A CBA SETTING IS: a server setting is sent to
// every client, so a connection string in it is on every player's machine.
// tools/pacdb/README.md says how to make that string worthless off the
// server: a database user with rights on this one database only, and
// Atlas's IP allowlist holding the game server's address alone.
//
// Exports (stdcall on Windows; on x64 Linux every convention is the one ABI):
//   RVExtensionVersion(char* output, int outputSize)
//   RVExtension(char* output, int outputSize, const char* function)
//   RVExtensionArgs(char* output, int outputSize, const char* function, const char** argv, int argc) -> int
//   RVExtensionRegisterCallback(int (*callback)(const char* name, const char* function, const char* data))
//
// THE NAME IS LOWER CASE - ghostd_pacdb - because a Linux server looks the
// file up by the exact name the script gives, and Linux mod folders are
// commonly lower-cased in transit. Windows does not care.

using System.Net.Http.Headers;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.Json;
using MongoDB.Bson;
using MongoDB.Bson.IO;
using MongoDB.Driver;

namespace GhostD.PacDb;

// unsafe is confined to the members that touch pointers: the async work must
// not be in an unsafe context (C# forbids await there).
public static class Extension
{
    const string Name = "ghostd_pacdb";
    const string Version = "0.4.0";
    const int Chunk = 7000;

    static unsafe class Cb { public static delegate* unmanaged[Stdcall]<IntPtr, IntPtr, IntPtr, int> Ptr; }
    static readonly HttpClient Http = new() { Timeout = TimeSpan.FromSeconds(15) };
    static string _url = "";
    static string _apiKey = "";
    static bool _configured;
    static string _source = "nothing";

    // the direct backend - made on first use from a mongodb:// address
    static readonly object MongoLock = new();
    static IMongoCollection<BsonDocument>? _mongo;
    static string _mongoFor = "";
    static readonly JsonWriterSettings Plain = new() { OutputMode = JsonOutputMode.RelaxedExtendedJson };

    // put.* assembly state - one put at a time, which is all the mod ever does
    static readonly object PutLock = new();
    static string _putUnit = "";
    static string[]? _putChunks;

    // ---------------------------------------------------------------- exports --

    [UnmanagedCallersOnly(EntryPoint = "RVExtensionVersion", CallConvs = new[] { typeof(CallConvStdcall) })]
    public static void RVExtensionVersion(IntPtr output, int outputSize) => Write(output, outputSize, Version);

    [UnmanagedCallersOnly(EntryPoint = "RVExtensionRegisterCallback", CallConvs = new[] { typeof(CallConvStdcall) })]
    public static unsafe void RVExtensionRegisterCallback(IntPtr callback)
        => Cb.Ptr = (delegate* unmanaged[Stdcall]<IntPtr, IntPtr, IntPtr, int>)callback;

    [UnmanagedCallersOnly(EntryPoint = "RVExtension", CallConvs = new[] { typeof(CallConvStdcall) })]
    public static void RVExtension(IntPtr output, int outputSize, IntPtr function)
        => Write(output, outputSize, Marshal.PtrToStringUTF8(function) == "version" ? Version : "use RVExtensionArgs");

    [UnmanagedCallersOnly(EntryPoint = "RVExtensionArgs", CallConvs = new[] { typeof(CallConvStdcall) })]
    public static unsafe int RVExtensionArgs(IntPtr output, int outputSize, IntPtr function, IntPtr argv, int argc)
    {
        var fn = Marshal.PtrToStringUTF8(function) ?? "";
        var args = new string[argc];
        for (var i = 0; i < argc; i++)
            args[i] = Unquote(Marshal.PtrToStringUTF8(((IntPtr*)argv)[i]) ?? "");

        Configure();

        switch (fn)
        {
            case "ping":
                Task.Run(() => Send("ping", "ok " + Version + (_configured ? " -> " + Describe() + " (from " + _source + ")" : " (NOT CONFIGURED: set the CBA setting 'Database' to a mongodb+srv:// connection string, or a pacdb service URL)")));
                break;

            // THE MOD HANDS THE ADDRESS OVER - from its CBA server setting, which
            // a rented game server can take where it cannot take a file or an
            // environment variable. Wins over whatever Configure() found.
            case "configure":
                if (args.Length < 1 || args[0].Length == 0) { Write(output, outputSize, "error: configure needs url [key]"); return 1; }
                _url = args[0].TrimEnd('/');
                _apiKey = args.Length > 1 ? args[1] : "";
                _configured = true;
                _source = "the mod's CBA setting";
                Write(output, outputSize, "ok");
                return 0;

            // WHERE THIS SERVER CALLS OUT FROM, and whether TLS works at all.
            // Off unless the admin turns the CBA setting on - it is a request to
            // a third party, and most boots have no use for one.
            case "netcheck":
                Task.Run(NetCheck);
                break;

            case "get":
                if (args.Length < 1) { Write(output, outputSize, "error: get needs a key"); return 1; }
                var unit = args[0];
                Task.Run(() => Get(unit));
                break;

            case "list":
                var prefix = args.Length > 0 ? args[0] : "";
                Task.Run(() => List(prefix));
                break;

            case "put.begin":
                if (args.Length < 2 || !int.TryParse(args[1], out var n)) { Write(output, outputSize, "error: put.begin needs key, n"); return 1; }
                lock (PutLock) { _putUnit = args[0]; _putChunks = new string[n]; }
                break;

            case "put.chunk":
                if (args.Length < 2 || !int.TryParse(args[0], out var idx)) { Write(output, outputSize, "error: put.chunk needs i, text"); return 1; }
                lock (PutLock)
                {
                    if (_putChunks == null || idx < 0 || idx >= _putChunks.Length) { Write(output, outputSize, "error: put.chunk out of order"); return 1; }
                    _putChunks[idx] = args[1];
                }
                break;

            case "put.end":
                string putUnit; string body;
                lock (PutLock)
                {
                    if (_putChunks == null) { Write(output, outputSize, "error: put.end without put.begin"); return 1; }
                    putUnit = _putUnit;
                    body = string.Concat(_putChunks.Select(c => c ?? ""));
                    _putChunks = null;
                }
                Task.Run(() => Put(putUnit, body));
                break;

            default:
                Write(output, outputSize, "error: unknown function " + fn);
                return 1;
        }

        Write(output, outputSize, "queued");
        return 0;
    }

    // ------------------------------------------------------------------ work --

    const string NotConfigured = "not configured: set the CBA server setting 'Database' (Addon Options > Ghosts of Battle PAC > Service) to a mongodb+srv:// connection string (or a pacdb service URL), or GHOSTD_PACDB_URL in the server's environment, or pacdb.json in the server's root";

    static bool IsMongo => _url.StartsWith("mongodb://", StringComparison.OrdinalIgnoreCase) || _url.StartsWith("mongodb+srv://", StringComparison.OrdinalIgnoreCase);

    // The address without its password, for the log.
    static string Describe()
    {
        if (!IsMongo) return _url;
        var at = _url.IndexOf('@');
        var scheme = _url.IndexOf("://", StringComparison.Ordinal) + 3;
        return at > scheme ? _url[..scheme] + "..." + _url[at..] + " (direct)" : _url + " (direct)";
    }

    static IMongoCollection<BsonDocument> Mongo()
    {
        lock (MongoLock)
        {
            if (_mongo != null && _mongoFor == _url) return _mongo;
            var settings = MongoClientSettings.FromConnectionString(_url);
            settings.ConnectTimeout = TimeSpan.FromSeconds(15);
            settings.ServerSelectionTimeout = TimeSpan.FromSeconds(15);
            var client = new MongoClient(settings);
            _mongo = client.GetDatabase("ghostd").GetCollection<BsonDocument>("pac");
            _mongoFor = _url;
            return _mongo;
        }
    }

    static async Task Get(string unit)
    {
        try
        {
            if (!_configured) { Send("get.error", NotConfigured); return; }
            string? text;
            if (IsMongo)
            {
                var doc = await Mongo().Find(Builders<BsonDocument>.Filter.Eq("_id", unit)).FirstOrDefaultAsync();
                if (doc is null) { Send("get.end", "empty"); return; }
                if (doc.TryGetValue("json", out var legacy) && legacy.IsString) text = legacy.AsString;   // documents written before fields
                else { doc.Remove("_id"); doc.Remove("updatedAt"); text = doc.ToJson(Plain); }
            }
            else
            {
                using var req = new HttpRequestMessage(HttpMethod.Get, $"{_url}/pac/{Uri.EscapeDataString(unit)}");
                req.Headers.Add("X-Api-Key", _apiKey);
                using var res = await Http.SendAsync(req);
                if (res.StatusCode == System.Net.HttpStatusCode.NotFound) { Send("get.end", "empty"); return; }
                if (!res.IsSuccessStatusCode) { Send("get.error", $"HTTP {(int)res.StatusCode}"); return; }
                text = await res.Content.ReadAsStringAsync();
            }
            var n = (text.Length + Chunk - 1) / Chunk;
            Send("get.begin", n.ToString());
            for (var i = 0; i < n; i++)
                Send("get.chunk", $"{i}|{text.Substring(i * Chunk, Math.Min(Chunk, text.Length - i * Chunk))}");
            Send("get.end", "ok");
        }
        catch (Exception e) { Send("get.error", e.Message); }
    }

    // The keys under a prefix, as a JSON array in one callback (a unit's role
    // and order lists are a few dozen short strings at most).
    static async Task List(string prefix)
    {
        try
        {
            if (!_configured) { Send("list.error", NotConfigured); return; }
            if (IsMongo)
            {
                var filter = Builders<BsonDocument>.Filter.Regex("_id", new BsonRegularExpression("^" + System.Text.RegularExpressions.Regex.Escape(prefix)));
                var docs = await Mongo().Find(filter).Project(Builders<BsonDocument>.Projection.Include("_id")).ToListAsync();
                var keys = docs.Select(d => d["_id"].AsString).OrderBy(s => s, StringComparer.Ordinal).ToArray();
                Send("list", JsonSerializer.Serialize(keys, ExtJson.Default.StringArray));
                return;
            }
            using var req = new HttpRequestMessage(HttpMethod.Get, $"{_url}/pac?prefix={Uri.EscapeDataString(prefix)}");
            req.Headers.Add("X-Api-Key", _apiKey);
            using var res = await Http.SendAsync(req);
            if (!res.IsSuccessStatusCode) { Send("list.error", $"HTTP {(int)res.StatusCode}"); return; }
            Send("list", await res.Content.ReadAsStringAsync());
        }
        catch (Exception e) { Send("list.error", e.Message); }
    }

    static async Task Put(string unit, string json)
    {
        try
        {
            if (!_configured) { Send("put.error", NotConfigured); return; }
            if (IsMongo)
            {
                // REAL FIELDS, the way the service stores them: the JSON parsed
                // into BSON, _id the key, updatedAt the write - so the site
                // shows and edits the document as a document.
                var doc = BsonDocument.Parse(json);
                doc.Remove("_id"); doc.Remove("updatedAt");
                doc.InsertAt(0, new BsonElement("_id", unit));
                doc.Add("updatedAt", DateTime.UtcNow);
                await Mongo().ReplaceOneAsync(Builders<BsonDocument>.Filter.Eq("_id", unit), doc, new ReplaceOptions { IsUpsert = true });
                Send("put.end", "ok");
                return;
            }
            using var req = new HttpRequestMessage(HttpMethod.Put, $"{_url}/pac/{Uri.EscapeDataString(unit)}");
            req.Headers.Add("X-Api-Key", _apiKey);
            req.Content = new StringContent(json, Encoding.UTF8);
            req.Content.Headers.ContentType = new MediaTypeHeaderValue("application/json");
            using var res = await Http.SendAsync(req);
            Send(res.IsSuccessStatusCode ? "put.end" : "put.error", res.IsSuccessStatusCode ? "ok" : $"HTTP {(int)res.StatusCode}");
        }
        catch (Exception e) { Send("put.error", e.Message); }
    }

    // --------------------------------------------------------------- plumbing --

    [DllImport("kernel32", CharSet = CharSet.Unicode)] static extern IntPtr GetModuleHandleW(string name);
    [DllImport("kernel32", CharSet = CharSet.Unicode)] static extern unsafe int GetModuleFileNameW(IntPtr module, char* buffer, int size);

    // Where this library is - the mod folder, which is where Arma loads
    // extensions from. Windows only: on Linux the server's root is the place
    // to keep pacdb.json, and that is looked at everywhere.
    static unsafe string OwnDirectory()
    {
        if (!OperatingSystem.IsWindows()) return "";
        try
        {
            var h = GetModuleHandleW("ghostd_pacdb_x64.dll");
            if (h == IntPtr.Zero) h = GetModuleHandleW("ghostd_pacdb.dll");
            if (h != IntPtr.Zero)
            {
                var buf = stackalloc char[1024];
                var n = GetModuleFileNameW(h, buf, 1024);
                if (n > 0) return Path.GetDirectoryName(new string(buf, 0, n)) ?? "";
            }
        }
        catch { }
        return "";
    }

    // NOTHING ABOUT THE SERVER IS IN THE MOD. Before the mod's "configure",
    // the address comes from the machine the server runs on: environment
    // variables first, then a pacdb.json in the server's root (the process's
    // folder or working directory), then - Windows - beside the DLL.
    static void Configure()
    {
        if (_configured) return;
        try
        {
            var envUrl = Environment.GetEnvironmentVariable("GHOSTD_PACDB_URL") ?? "";
            if (envUrl.Length > 0)
            {
                _url = envUrl.TrimEnd('/');
                _apiKey = Environment.GetEnvironmentVariable("GHOSTD_PACDB_KEY") ?? "";
                _configured = true;
                _source = "the environment";
                return;
            }
            var path = "";
            foreach (var dir in new[] { AppContext.BaseDirectory, Environment.CurrentDirectory, OwnDirectory() })
            {
                if (string.IsNullOrEmpty(dir)) continue;
                var candidate = Path.Combine(dir, "pacdb.json");
                if (File.Exists(candidate)) { path = candidate; break; }
            }
            if (path.Length == 0) return;
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            _url = doc.RootElement.GetProperty("url").GetString()?.TrimEnd('/') ?? "";
            _apiKey = doc.RootElement.TryGetProperty("apiKey", out var k) ? k.GetString() ?? "" : "";
            // a key from the environment still wins over one in the file
            var envKey = Environment.GetEnvironmentVariable("GHOSTD_PACDB_KEY") ?? "";
            if (envKey.Length > 0) _apiKey = envKey;
            _configured = _url.Length > 0;
            if (_configured) _source = "pacdb.json at " + path;
        }
        catch { _configured = false; }
    }

    // ---- netcheck ---------------------------------------------------------
    // The address Atlas will see, and a verdict on TLS, from one host over both
    // schemes. THE PLAIN-HTTP LEG IS THE POINT: it is the only probe that still
    // answers when TLS is the thing that is broken, so the pair separates "no
    // route out" from "no certificate store" without guessing.
    //
    // An IPv4-only reflector on purpose. ifconfig.me answers on whichever
    // protocol the request used, and an IPv6 address is not what goes in an
    // Atlas access-list entry.
    const string Reflector = "api.ipify.org";

    static async Task NetCheck()
    {
        var ip = "unknown";
        var plain = "";
        try
        {
            ip = (await Http.GetStringAsync("http://" + Reflector)).Trim();
        }
        catch (Exception e) { plain = Innermost(e); }

        var tls = "";
        try
        {
            var over = (await Http.GetStringAsync("https://" + Reflector)).Trim();
            if (ip == "unknown") ip = over;
        }
        catch (Exception e) { tls = Innermost(e); }

        // One line the mod logs as it is. The verdict is spelled out rather than
        // left to the reader: this is read in an .rpt by somebody whose database
        // will not connect.
        var verdict = (plain.Length == 0, tls.Length == 0) switch
        {
            (true, true)  => "http ok, https ok - this server's network and TLS are both fine",
            (true, false) => "http ok, https FAILED (" + tls + ") - TLS is broken on this machine, which is why the database will not connect",
            (false, true) => "http FAILED (" + plain + "), https ok",
            _             => "http FAILED (" + plain + "), https FAILED (" + tls + ") - no outbound web access from this server",
        };
        Send("netcheck", "ip=" + ip + " | " + verdict);
    }

    // The message that actually says what went wrong - the outer ones are
    // wrappers, and Arma truncates a long callback string.
    static string Innermost(Exception e)
    {
        while (e.InnerException != null) e = e.InnerException;
        var m = e.Message.Replace("\r", " ").Replace("\n", " ").Trim();
        return m.Length > 160 ? m[..160] : m;
    }

    static unsafe void Send(string function, string data)
    {
        if (Cb.Ptr == null) return;
        var name = Marshal.StringToCoTaskMemUTF8(Name);
        var fn = Marshal.StringToCoTaskMemUTF8(function);
        var d = Marshal.StringToCoTaskMemUTF8(data);
        try { Cb.Ptr(name, fn, d); }
        finally { Marshal.FreeCoTaskMem(name); Marshal.FreeCoTaskMem(fn); Marshal.FreeCoTaskMem(d); }
    }

    // Arma hands string args wrapped in quotes with inner quotes doubled.
    static string Unquote(string s)
        => s.Length >= 2 && s[0] == '"' && s[^1] == '"' ? s[1..^1].Replace("\"\"", "\"") : s;

    static void Write(IntPtr output, int outputSize, string text)
    {
        var bytes = Encoding.UTF8.GetBytes(text);
        var n = Math.Min(bytes.Length, outputSize - 1);
        Marshal.Copy(bytes, 0, output, n);
        Marshal.WriteByte(output, n, 0);
    }
}

// System.Text.Json without reflection, for the one array the extension writes itself.
[System.Text.Json.Serialization.JsonSerializable(typeof(string[]))]
internal partial class ExtJson : System.Text.Json.Serialization.JsonSerializerContext { }
