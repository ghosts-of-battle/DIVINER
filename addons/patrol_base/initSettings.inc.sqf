// CBA settings for the Patrol Base system. Category: Ghosts of Battle > Patrol Base.

[
    QGVAR(enabled),
    "CHECKBOX",
    ["Enabled", "Enable the patrol base system."],
    ["Ghosts of Battle", "Patrol Base"],
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(maxCount),
    "SLIDER",
    ["Max patrol bases", "How many patrol bases may exist at once."],
    ["Ghosts of Battle", "Patrol Base"],
    [1, 10, 3, 0, true],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(kitCount),
    "SLIDER",
    ["Kits required", "How many Patrol Base Kits must be dropped within range to build one base."],
    ["Ghosts of Battle", "Patrol Base"],
    [1, 10, 4, 0, true],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(kitRange),
    "SLIDER",
    ["Kit gather range (m)", "Radius the dropped kits must lie within to count."],
    ["Ghosts of Battle", "Patrol Base"],
    [1, 30, 5, 1, true],
    1
] call CBA_fnc_addSetting;

[
    QGVAR(beaconClass),
    "EDITBOX",
    ["Base object", "Class spawned at the base on deploy - it marks the location and carries the Unbuild action. Defaults to ghost's own SatCom mast; if that class is not loaded it falls back to the vanilla SatelliteAntenna_01_Black_F rather than spawning nothing."],
    ["Ghosts of Battle", "Patrol Base"],
    "ghostD_satcom_deployed",
    1
] call CBA_fnc_addSetting;

[
    QGVAR(onDeployCode),
    "EDITBOX",
    ["On-deploy init (SQF)", "SQF run on the server after a base is built. Passed: [_beacon, _pos, _name, _side, _builder]. Blank = nothing."],
    ["Ghosts of Battle", "Patrol Base"],
    "params ['_base', '_pos', '_name']; [_base, 15] remoteExec ['YMF_fnc_addStagingZone', 0, true]; [_base, _name, west] call Rev_tp_fnc_addPoint;",
    1
] call CBA_fnc_addSetting;

[
    QGVAR(onUndeployCode),
    "EDITBOX",
    ["On-undeploy init (SQF)", "SQF run on the server while the base beacon still exists (before it is deleted). Passed: [_beacon, _pos, _name, _side]. Blank = nothing."],
    ["Ghosts of Battle", "Patrol Base"],
    "params ['_object']; [_object] remoteExec ['YMF_fnc_removeStagingZone', 0]; [_object] call Rev_tp_fnc_deletePoint;",
    1
] call CBA_fnc_addSetting;
