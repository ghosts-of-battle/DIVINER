#include "script_component.hpp"
/*
 * Author: veteran29
 * Handle chat message.
 *
 * Arguments:
 * 0: Channel <NUMBER>
 * 1: N/A
 * 2: N/A
 * 3: Sent text <STRING>
 * 4: Person sending the message <OBJECT>
 *
 * Return Value:
 * Should message be blocked <BOOL>
 *
 * Example:
 * call ghostD_chat_fnc_handleChatMessage
 *
 * Public: No
 */

params [["_channel", -1], "", ["_from", ""], ["_text", ""], ["_sender", objNull]];
if (_text == "") exitWith {false};

// Admin debug commands are swallowed before any chat handling - see
// ghostD_common_fnc_debugCommand. Ordinary chat falls straight through.
if ([_text, _sender] call EFUNC(common,debugCommand)) exitWith {true};

if (GVAR(allowGlobalChat) || {!(_channel in RESTRICTED_CHANNELS)}) exitWith {false};

if (_sender getVariable [QEGVAR(common,isAdmin), false]) exitWith {
    [format ["(ADMIN) %1", _from], _text]
};

if (!isNull getAssignedCuratorLogic _sender) exitWith {
    [format ["(ZEUS) %1", _from], _text]
};

if (_sender isEqualTo player) exitWith {
    ["Chat", "Global and side chat is disabled, your message is visible only to administrators and zeuses!", [1, 0.8, 0.3, 1]] call EFUNC(notify,notify);
    playSound "3DEN_notificationWarning";

    false // return, player always sees his own message
};

isNull getAssignedCuratorLogic player // show all messages to zeus
&& !(player getVariable [QEGVAR(common,isAdmin), false]) // show all messages to admin
