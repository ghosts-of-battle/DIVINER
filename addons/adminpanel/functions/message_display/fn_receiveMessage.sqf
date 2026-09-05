/*
    Author: TheTimidShade

    Description:
        Local call to save/display message when player receives a message from another player

        Messages are stored in the format:
        [
            "SenderID",     // Steam64 ID
            "SentAt",        // In game time in format HH:MM
            "SenderName",
            "ReceiverName",
            "Message text"
        ]

    Parameters:
        0: ARRAY - Message array in above format
        
    Returns:
        NOTHING
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

params [
    ["_messageData", [], [[]], [5]]
];

if (_messageData isEqualTo []) exitWith {};

admp_message_display_history_local pushBack _messageData; // add message to history

_messageData params ["_senderID", "_sentAt", "_senderName", "_receiverName", "_message"];

// The recipient is already implied by the message arriving here, so the panel carries the sender and the text -
// the full FROM/TO record stays in the message list, which is what admp_fnc_loadMessageList reads.
[
    format ["ADMIN MESSAGE - %1", _senderName],
    _message,
    [1, 0.776, 0.102, 1]
] call EFUNC(notify,notify);

if (!isNull (uiNamespace getVariable ['admp_messageDisplayVar', displayNull])) then {[] call admp_fnc_loadMessageList;};
