// AI SKILL, AS SETTINGS RATHER THAN A SCRIPT (user, 2026-09-09: "add a simple
// editor to AI skill should be a set of cba settings ... just cba for ai skill").
//
// This replaces config\config_skill.hpp - a block of SQF the mission compiled
// and handed over, which meant changing how hard the AI shoot was a text editor,
// a mission repack and a server restart. Every number it set is a slider here,
// and the whole thing is edited in the CBA settings menu by whoever is running
// the night.
//
// WHAT THE OLD BLOCK DID, and therefore what these are:
//   - nine base skills, set on every AI
//   - spotting cut at night, and cut much harder when the AI has no NVGs -
//     which is the single biggest thing that makes AI feel fair after dark
//   - machinegunners and snipers given better aim than the rest
//
// STILL BEHIND "AI Setting". Index 0 - Arma Default - writes no skill at all
// and none of this is read; that has not changed and is still the default.
//
// A NUMBER PER SLIDER, 0 to 1, because that is setSkill's range. The comment on
// each says which way is "better AI", since three of them are inverted.

private _skill = [_YMFsettings, "AI Skill"];

// [key, title, tooltip, default]
private _fnc_slider = {
    params ["_key", "_title", "_tip", "_default"];
    [
        _key, "SLIDER", [_title, _tip], _skill,
        [0, 1, _default, 2, false],
        true, {}, true
    ] call CBA_fnc_addSetting;
};

// ---- the nine, set on every AI --------------------------------------------
[QEGVAR(Settings,aiGeneral),        "General",         "Overall competence. Higher is better AI.", 0.90] call _fnc_slider;
[QEGVAR(Settings,aiCommanding),     "Commanding",      "How well it leads and passes contacts on. Higher is better AI.", 0.75] call _fnc_slider;
[QEGVAR(Settings,aiCourage),        "Courage",         "How long before it breaks. Higher is better AI.", 0.75] call _fnc_slider;
[QEGVAR(Settings,aiAimingSpeed),    "Aiming speed",    "How fast it swings onto a target. Higher is better AI.", 0.62] call _fnc_slider;
[QEGVAR(Settings,aiAimingAccuracy), "Aiming accuracy", "How closely it hits what it aims at. Higher is better AI - this is the one that makes them feel like snipers.", 0.50] call _fnc_slider;
[QEGVAR(Settings,aiAimingShake),    "Aiming shake",    "Weapon sway. INVERTED: higher means MORE shake and worse AI.", 0.36] call _fnc_slider;
[QEGVAR(Settings,aiReloadSpeed),    "Reload speed",    "Higher is better AI.", 0.75] call _fnc_slider;
[QEGVAR(Settings,aiSpotTime),       "Spot time (day)", "How quickly it notices you in daylight. Higher is better AI.", 1.00] call _fnc_slider;
[QEGVAR(Settings,aiSpotDistance),   "Spot distance (day)", "How far it can notice you in daylight. Higher is better AI.", 1.00] call _fnc_slider;

// ---- after dark ------------------------------------------------------------
// THE ONE THAT MATTERS MOST. An AI with no night vision that still spots at
// daylight range is what makes a night op feel rigged; the old block dropped it
// to 0.015, which is the difference between a stealth mission and a shooting
// gallery.
[
    QEGVAR(Settings,aiNightApplies), "CHECKBOX",
    ["Cut spotting at night", "Use the two pairs below once the moon is low. Off means the daylight numbers apply all night."],
    _skill, true, true, {}, true
] call CBA_fnc_addSetting;

[QEGVAR(Settings,aiNightSpotTime),        "Night spot time - has NVGs",     "Used after dark when the AI is wearing night vision.", 0.52] call _fnc_slider;
[QEGVAR(Settings,aiNightSpotDistance),    "Night spot distance - has NVGs", "Used after dark when the AI is wearing night vision.", 0.52] call _fnc_slider;
[QEGVAR(Settings,aiBlindSpotTime),        "Night spot time - no NVGs",      "Used after dark when the AI has nothing to see with. Low on purpose.", 0.015] call _fnc_slider;
[QEGVAR(Settings,aiBlindSpotDistance),    "Night spot distance - no NVGs",  "Used after dark when the AI has nothing to see with. Low on purpose.", 0.015] call _fnc_slider;

// ---- the two trades that are meant to be better -----------------------------
[
    QEGVAR(Settings,aiRoleApplies), "CHECKBOX",
    ["Machinegunners and snipers shoot better", "Gives those two the numbers below instead of the general ones. Off means every AI shoots the same."],
    _skill, true, true, {}, true
] call CBA_fnc_addSetting;

[QEGVAR(Settings,aiMgAimingSpeed),        "MG aiming speed",       "Machinegunners only.", 0.82] call _fnc_slider;
[QEGVAR(Settings,aiMgAimingAccuracy),     "MG aiming accuracy",    "Machinegunners only.", 0.82] call _fnc_slider;
[QEGVAR(Settings,aiMgAimingShake),        "MG aiming shake",       "Machinegunners only. INVERTED: higher is worse AI.", 0.35] call _fnc_slider;
[QEGVAR(Settings,aiSniperAimingSpeed),    "Sniper aiming speed",   "Snipers only.", 0.60] call _fnc_slider;
[QEGVAR(Settings,aiSniperAimingAccuracy), "Sniper aiming accuracy","Snipers only. This is the one to turn down first if they feel unfair.", 0.95] call _fnc_slider;
[QEGVAR(Settings,aiSniperAimingShake),    "Sniper aiming shake",   "Snipers only. INVERTED: higher is worse AI.", 0.10] call _fnc_slider;
