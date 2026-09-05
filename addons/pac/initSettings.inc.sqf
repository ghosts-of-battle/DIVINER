// CBA Settings [ADDON: ghostD_pac] - category "Ghosts of Battle PAC" (user, 2026-09-05)
//
// THE ONE EXCEPTION to "TAC//PAC has no CBA settings" (user, 2026-09-05:
// "that needs to be in cba, a lot of hosted servers do not give the right to
// create files", "this will run on a hosted server"): where the database is.
// A rented game server lets an admin set a server setting - in game from
// Addon Options while logged in, or in the server's cba_settings.sqf - and
// can run nothing beside Arma. So the ghostd_pacdb extension carries the
// MongoDB driver itself: the setting takes the Atlas connection string and
// the server talks to the database directly, nothing else running anywhere.
// (An http:// address instead means the pacdb service, for a unit that runs
// one; the key is only for that.) The server hands the value to the
// extension at boot (FUNC(svcConfigure)); left empty, the extension falls
// back to GHOSTD_PACDB_URL / GHOSTD_PACDB_KEY in the server's environment,
// then pacdb.json in its root.
//
// KNOW WHAT A CBA SETTING IS: server settings are sent to every client, so
// the connection string here is on every player's machine. Make it worthless
// off the server: an Atlas database user with rights on this one database
// only (readWrite on ghostd), and Atlas Network Access allowing the game
// server's IP alone - tools/pacdb/README.md.

[
    QGVAR(serviceUrl), "EDITBOX",
    ["Database", "The MongoDB connection string - mongodb+srv://user:password@cluster.../ from Atlas (Database > Connect > Drivers) - the server talks to it directly, nothing else runs. Or http://host:8085 for a pacdb service. Used with sync = ""service"" in the mission's CfgGFA_PAC; read once, at mission start. Empty: the server's GHOSTD_PACDB_URL, or pacdb.json in its root."],
    ["Ghosts of Battle PAC", "Service"],
    "",
    true,
    {},
    true
] call CBA_fnc_addSetting;

// TEST AS A STEAM ID IN THE EDITOR. getPlayerUID is "" in the editor and in
// singleplayer, so a tester's own record never matches a real Steam-id record
// (user, 2026-09-05). Put your 17-digit Steam id here and, in the editor, you
// ARE that operator - the database's record for you loads and your edits land
// on it. Empty (the default), and the editor uses a throwaway per-profile id.
// Ignored in a real multiplayer game, where getPlayerUID is your Steam id.
[
    QGVAR(testUid), "EDITBOX",
    ["Test as Steam id (editor only)", "Editor and singleplayer have no Steam id. Put yours here (17 digits) to test as your real operator - the database record for you loads. Empty = a throwaway test id. Does nothing in multiplayer."],
    ["Ghosts of Battle PAC", "Service"],
    "",
    true
] call CBA_fnc_addSetting;

[
    QGVAR(serviceKey), "EDITBOX",
    ["Service key", "Only for an http:// pacdb service: the X-Api-Key it expects. Leave empty with a mongodb+srv:// connection string."],
    ["Ghosts of Battle PAC", "Service"],
    "",
    true,
    {},
    true
] call CBA_fnc_addSetting;
