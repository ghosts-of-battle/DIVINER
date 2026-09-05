/*
    Author: TheTimidShade

    Description:
        Called when a message is selected from the message history list
        Loads the message data in the message viewer

    Parameters:
        NONE
        
    Returns:
        NOTHING
*/

#include "\z\ghostD\addons\adminpanel\script_component.hpp"

disableSerialization;


// get display
private _message_display = uiNamespace getVariable ['admp_messageDisplayVar', displayNull];

// get controls
private _sender_display = _message_display displayCtrl IDC_ADMINMESSAGE_MESSAGE_VIEWER_SENDER;
private _receiver_display = _message_display displayCtrl IDC_ADMINMESSAGE_MESSAGE_VIEWER_RECEIVER;
private _message_text_display = _message_display displayCtrl IDC_ADMINMESSAGE_MESSAGE_VIEWER_MESSAGE_TEXT;
private _message_history_list = _message_display displayCtrl IDC_ADMINMESSAGE_MESSAGE_VIEWER_HISTORY_LIST;

private _selectedMessageIndex = _message_history_list lbValue (lbCurSel _message_history_list);

private _messageData = admp_message_display_history_local#_selectedMessageIndex;

_messageData params ["_senderID", "_sentAt", "_senderName", "_receiverName", "_message"];

_sender_display ctrlSetText "FROM: " + _senderName;
_receiver_display ctrlSetText "TO: " + _receiverName;
_message_text_display ctrlSetText _message;
