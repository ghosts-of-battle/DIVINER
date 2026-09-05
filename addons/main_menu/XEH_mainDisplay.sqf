#include "script_component.hpp"
/*
 * Author: YonV
 * Names and colours the main menu quick connect buttons, points them at
 * whatever the settings say, and removes the ones with nowhere to go.
 *
 * A SCRIPT, NOT A PREP'D FUNCTION, and deliberately - the same shape as
 * XEH_multiplayerDisplay beside it. The config handler runs inside
 * "with uiNamespace do", so a FUNC() there is a variable lookup in a namespace
 * the functions are not in; COMPILE_SCRIPT compiles this file by path and asks
 * nothing of any namespace. Nothing in here calls out to a FUNC for the same
 * reason.
 *
 * WHAT THIS REPLACED. Three buttons in RscDisplayMain.hpp, each with its name in
 * a text property and its whole connection in a config string:
 *
 *     onButtonClick = "connectToServer ['104.243.43.232', 2302, 'Ghosts'];";
 *
 * Moving a server meant editing the config and shipping a PBO, and a unit
 * running its own servers could not use the menu without forking the mod.
 *
 * NO ADDRESS MEANS NO BUTTON. An empty address is not a broken setting, it is a
 * slot pointed at nothing - a unit with one server, or ours before the others
 * are up. A button that connects nowhere is worse than no button, so it is
 * hidden rather than left to fail on click. A port of 0 does the same.
 *
 * READ FROM THE PROFILE. See FUNC(cacheServers): preInit has not run when this
 * display is drawn, so the CBA settings do not exist yet and profileNamespace is
 * where the values are. The fallback below is the shipped three, so a player who
 * has never reached a mission still gets working buttons on first launch.
 *
 * Arguments:
 * 0: Main menu display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_display"];

TRACE_1("Main menu display",_display);

#define GHOST_RED [ARR_4(0.8,0.263,0.192,1)]
#define QUICK_CONNECT_SHIPPED [\
    [ARR_5("Ghosts Training Server","104.243.43.232",2402,"Gh0sts",GHOST_RED)],\
    [ARR_5("Ghosts Operations Server","104.243.43.232",2302,"Gh0sts",GHOST_RED)],\
    [ARR_5("Ghosts Development Server","104.243.43.232",2502,"Gh0sts",GHOST_RED)]\
]

private _servers = profileNamespace getVariable [QGVAR(servers), QUICK_CONNECT_SHIPPED];

// A profile written by an older build, or by hand, can hold anything at all.
if (!(_servers isEqualType []) || {count _servers < 3}) then {
    _servers = QUICK_CONNECT_SHIPPED;
};

// Index is the button, left to right, and that is the only thing the two sides
// have to agree on - see FUNC(cacheServers). Paired here rather than left to two
// lists in the same order.
{
    _x params ["_idc", "_slot"];

    private _button = _display displayCtrl _idc;

    if (!isNull _button) then {
        (_servers param [_slot, [], [[]]]) params [
            ["_name", ""], ["_address", ""], ["_port", 0], ["_password", ""],
            ["_colour", GHOST_RED]
        ];

        if (_address isEqualTo "" || _port isEqualTo 0) then {
            _button ctrlShow false;
            _button ctrlEnable false;
        } else {
            // An empty name leaves the config's own text alone rather than
            // blanking the button - a server with no name is still a server.
            if (_name isNotEqualTo "") then {
                _button ctrlSetText _name;
            };

            // The background only. The hover colour stays Arma's own - a button
            // that has to be told what it turns into as well as what it is has
            // two settings where one will do.
            _button ctrlSetBackgroundColor _colour;

            // The click carries the values the button was drawn with rather than
            // reading them again, so a button always does what it said it would.
            _button setVariable [QGVAR(target), [_address, _port, _password]];

            _button ctrlAddEventHandler ["ButtonClick", {
                params ["_ctrl"];
                (_ctrl getVariable [QGVAR(target), []]) params [
                    ["_serverAddress", ""], ["_serverPort", 0], ["_serverPassword", ""]
                ];

                if (_serverAddress isEqualTo "" || _serverPort isEqualTo 0) exitWith {};

                connectToServer [_serverAddress, _serverPort, _serverPassword];
            }];

            _button ctrlShow true;
            TRACE_3("Quick connect button",_name,_address,_port);
        };
    };
} forEach [
    [IDC_QUICKCONNECT_LEFT, 0],
    [IDC_QUICKCONNECT_CENTRE, 1],
    [IDC_QUICKCONNECT_RIGHT, 2]
];

nil
