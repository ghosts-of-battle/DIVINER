#include "script_component.hpp"

if (!hasInterface) exitWith {};

// The keys. postInit, not preInit, because CBA_fnc_addKeybind wants the
// keybinding system up - and every key here is a player action anyway.
#include "initKeybinds.inc.sqf"

// Full-size apps a tile or a reader hand-off opens. Anything not registered is
// a no-op rather than an error, so a tile for an app that does not exist yet
// sits there inert instead of throwing.
["comms", FUNC(appComms)] call EFUNC(tacpad,registerApp);

["squad", FUNC(appSquad)] call EFUNC(tacpad,registerApp);
["weather", FUNC(appWeather)] call EFUNC(tacpad,registerApp);

// The other three tiles. Every tile on the band now opens something - a tile
// that logs "no app registered" and does nothing is the exact failure this
// suite has spent the week chasing.

// The whole sweep on one page - the tile band's sixth tile opens it.
["scanner", FUNC(appScanner)] call EFUNC(tacpad,registerApp);

// Drones and jamming are two different things with a page each - the DRONES
// tile opens one, the JAM tile the other. The scanner stays the whole-sweep
// view.
["drones", FUNC(appDrones)] call EFUNC(tacpad,registerApp);
["jam", FUNC(appJamming)] call EFUNC(tacpad,registerApp);

// TAC//SUPPORT - ALiVE combat support fronted through the adapter, gated by
// a messaging tag rather than a role tree.

// The player's own clock, off the band.
["timer", FUNC(appTimer)] call EFUNC(tacpad,registerApp);
["radio", FUNC(appRadio)] call EFUNC(tacpad,registerApp);

// A message arriving while the map is open should show up in the docked reader.
//
// BOTH EVENTS. This listened to `received` only, which is traffic addressed to
// this player - and a message filed to a shared channel reaches its own sender
// on the QUIET path, as `indexRefreshed`. So sending to a channel updated
// nothing on screen until something else forced a redraw.
{
    [_x, {
        if (!isNull (findDisplay IDD_MAP)) then {
            ["reader"] call EFUNC(tacpad,rebuild);
        };
    }] call CBA_fnc_addEventHandler;
} forEach [QEGVAR(messaging,received), QEGVAR(messaging,indexRefreshed)];

// The map closing drops the reader back to the list. A thread left open across
// two map opens is a panel showing something the player has forgotten they
// asked for.
addMissionEventHandler ["Map", {
    params ["_opened"];
    if (!_opened) then {
        GVAR(readerThread) = "";

        // THE SHELL'S VARIABLE, not this addon's. The line below it already had
        // it right; this one was clearing ghost_tacpad_apps_appGroup, which
        // nothing reads, and leaving the shell still holding a deleted control.
        uiNamespace setVariable [QEGVAR(tacpad,appGroup), controlNull];

        // And nothing is the open app, so no refresh loop comes back with the
        // map next time - see EFUNC(tacpad,openApp).
        uiNamespace setVariable [QEGVAR(tacpad,appCurrent), ""];
    };
}];

// The intrusion suite, reached from its own tile. It is the interface now -
// hacking's own dialog is gone, and with it fnc_themeTablet, which existed only
// to repaint that dialog in the suite's colours after hacking announced it.
["hack", FUNC(appHack)] call EFUNC(tacpad,registerApp);

// TAC//INTEL - the files a hack recovered, filed against the side that
// recovered them. See EFUNC(hacking,productPackage).
["intel", FUNC(appIntel)] call EFUNC(tacpad,registerApp);

// TAC//SUPPORT, a board over Simplex Support Services rather than a second
// implementation of one.
//
// NOT REGISTERED AT ALL WITHOUT SIMPLEX. It is a front end and nothing else -
// with the mod absent there is no support to call, so an app saying so is a
// door onto an empty room. The tile goes with it, in FUNC(tileData).
if (EGVAR(patches,usesSimplex)) then {
    ["support", FUNC(appSupport)] call EFUNC(tacpad,registerApp);
};
["settings", FUNC(appSettings)] call EFUNC(tacpad,registerApp);

// Each client publishes its own radio channel, because neither ACRE nor TFAR
// will answer for anybody but the caller - see FUNC(radioState). Five seconds is
// slower than a man can retune and far slower than it matters.
[LINKFUNC(radioPublish), 5, []] call CBA_fnc_addPerFrameHandler;
