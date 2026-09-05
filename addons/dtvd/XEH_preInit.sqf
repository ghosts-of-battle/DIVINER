#include "\a3\editor_f\Data\Scripts\dikCodes.h"

DT_viewDistance_isACEEnabled = isClass (configFile >> "CfgPatches" >> "ace_main");

[
    "DT_viewDistanceEnabled",
    "CHECKBOX",
    ["Enable View Distance Management","Allow the DT View Distance Manager to manage your view distance and terrain grid."],
    ["Ghosts View Distance","View Distance"],
    true,nil,
    DT_fnc_initViewDistance
] call CBA_fnc_addSetting;
[["Ghosts View Distance","View Distance"],"openViewDistanceMenu","Open view distance menu",DT_fnc_openViewDistanceMenu,"",[DIK_BACKSLASH,[false,false,false]]] call CBA_fnc_addKeybind;

[
    "DT_viewDistanceMax",
    "SLIDER",
    ["Max View Distance","Select the max view distance players may use."],
    ["Ghosts View Distance","View Distance"],
    [200,40000,12000,0],
    1
] call CBA_fnc_addSetting;

[
    "DT_terrainGridMax",
    "LIST",
    ["Max Terrain Grid","Select the max terrain grid players may use."],
    ["Ghosts View Distance","View Distance"],
    [[50,25,12.5,6.25,3.125],["50 (Smoothest)","25 (Default)","12.5","6.25","3.125 (Best Quality)"],0],
    1
] call CBA_fnc_addSetting;

[
    "DT_automaticObjectSync",
    "CHECKBOX",
    ["Automatically sync object distance","Automatically sync changes to the object view distance slider to match the selected terrain view distance slider."],
    ["Ghosts View Distance","View Distance"],
    true
] call CBA_fnc_addSetting;

[
    "DT_notificationsEnabled",
    "CHECKBOX",
    ["Enable Notifications","Enable notifications when you change the view distance by a hotkey."],
    ["Ghosts View Distance","View Distance"],
    true
] call CBA_fnc_addSetting;

[
    "DT_scopeBoostEnabled",
    "CHECKBOX",
    ["Enable Scope Zoom Boost","When you zoom in through a scope, your current view and object view distance is boosted by the configured value."],
    ["Ghosts View Distance","View Distance"],
    false,nil,
    DT_fnc_initZoomBoost
] call CBA_fnc_addSetting;

[
    "DT_focusedBoostEnabled",
    "CHECKBOX",
    ["Enable Focused Zoom Boost","When you focus your view (hold right click etc), your current view and object view distance is boosted by the configured value."],
    ["Ghosts View Distance","View Distance"],
    false,nil,
    DT_fnc_initFocusedBoost
] call CBA_fnc_addSetting;

[
    "DT_incrementValue",
    "SLIDER",
    ["Distance Increment Value","Select the distance you want added or subtracted when the selected hotkey is pressed."],
    ["Ghosts View Distance","View Distance"],
    [100,1000,500,0]
] call CBA_fnc_addSetting;
[["Ghosts View Distance","View Distance"],"incrementHotkeyAdd","Increment distance hotkey",{[DT_incrementValue,true] call DT_fnc_incrementDistance},"",[DIK_RBRACKET,[false,true,false]],true] call CBA_fnc_addKeybind;
[["Ghosts View Distance","View Distance"],"incrementHotkeyRemove","Decrement distance hotkey",{[DT_incrementValue,false] call DT_fnc_incrementDistance},"",[DIK_LBRACKET,[false,true,false]],true] call CBA_fnc_addKeybind;

[
    "DT_viewDistanceHotkey1",
    "SLIDER",
    ["Change view hotkey 1","Select the view and object distance you would like to be changed to when pressing the selected hotkey."],
    ["Ghosts View Distance","View Distance"],
    [200,DT_viewDistanceMax,3000 min DT_viewDistanceMax,0]
] call CBA_fnc_addSetting;
[["Ghosts View Distance","View Distance"],"viewHotkey1","View distance hotkey 1",{[DT_viewDistanceHotkey1,"1"] call DT_fnc_changeViewByHotkey},"",[DIK_BACKSLASH,[true,false,false]]] call CBA_fnc_addKeybind;

[
    "DT_viewDistanceHotkey2",
    "SLIDER",
    ["Change view hotkey 2","Select the view and object distance you would like to be changed to when pressing the selected hotkey."],
    ["Ghosts View Distance","View Distance"],
    [200,DT_viewDistanceMax,6000 min DT_viewDistanceMax,0]
] call CBA_fnc_addSetting;
[["Ghosts View Distance","View Distance"],"viewHotkey2","View distance hotkey 2",{[DT_viewDistanceHotkey2,"2"] call DT_fnc_changeViewByHotkey},"",[DIK_BACKSLASH,[false,true,false]]] call CBA_fnc_addKeybind;

[
    "DT_viewDistanceHotkey3",
    "SLIDER",
    ["Change view hotkey 3","Select the view and object distance you would like to be changed to when pressing the selected hotkey."],
    ["Ghosts View Distance","View Distance"],
    [200,DT_viewDistanceMax,9000 min DT_viewDistanceMax,0]
] call CBA_fnc_addSetting;
[["Ghosts View Distance","View Distance"],"viewHotkey3","View distance hotkey 3",{[DT_viewDistanceHotkey3,"3"] call DT_fnc_changeViewByHotkey},"",[DIK_BACKSLASH,[false,false,true]]] call CBA_fnc_addKeybind;
