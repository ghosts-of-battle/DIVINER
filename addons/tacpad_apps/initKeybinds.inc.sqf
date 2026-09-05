// TROOPS IN CONTACT, ON A KEY.
//
// UNBOUND BY DEFAULT, DELIBERATELY (user, 2026-09-01: "leave the key empty let
// the player set it"). This is the loudest thing in the suite - it marks the
// map, alerts the whole side and files a thread on the command net - and a
// default chord is a chord somebody fires by accident on their first mission.
// [0, [false, false, false]] is CBA's own KEYBIND_NULL; its addKeybind filters
// any bind at or below DIK_ESCAPE out of the active list, so the action appears
// in Configure Addons > Ghosts of Battle with no key against it and does
// nothing until a key is put there.
//
// SAME CODE PATH AS THE MAP BUTTON - see FUNC(ticSend), which is where the
// send, the command-net check and the shared cooldown live. Pressing this with
// the map open and pressing the cell on the map are the same action.
//
// LOUD ON REFUSAL. The cell on the map draws its own reasons - NO COMMAND NET
// CONFIGURED, SENT - 12s - because it is being looked at. A key has no screen,
// so a refusal has to say itself.
[
    "Ghosts of Battle",
    QGVAR(ticKey),
    ["Troops In Contact", "Files a contact report from where you stand: marks the map, alerts your side and files the thread on the command net. The same button that is under the reader on the map screen. Unbound by default."],
    {
        [true] call FUNC(ticSend);
        true
    },
    {false},
    [0, [false, false, false]]
] call CBA_fnc_addKeybind;
