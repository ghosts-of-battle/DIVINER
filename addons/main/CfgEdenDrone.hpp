// ---------------------------------------------------------------------------
// Custom Eden attribute control for the Ghost drone / EW modules:
//   ghost_DroneFactionChoice   - single-select faction dropdown, populated at
//                                panel-open from the factions that own drones.
//                                The module reads it to derive the side.
//
// The class lists are the class picker below (ghost_ClassPick_*): a selection
// window with side and faction filters and a typed override, so a class name
// is looked up rather than remembered. The stored value is still the
// comma-separated string every module already reads.
//
// Same technique as ALiVE's ALiVE_FactionChoice / ALiVE_AAUnitChoiceMulti:
// a BI attribute-template base (Combo) whose list is
// filled dynamically by an attributeLoad SQF handler. NO ALiVE dependency -
// the handlers live in this addon (ghost_main) and read plain CfgVehicles /
// CfgFactionClasses, so the drone modules keep requiring only ghost_main.
//
// This file is #included INSIDE `class Cfg3DEN >> class Attributes` (see
// CfgEden.hpp) - HEMTT forbids re-opening `class Cfg3DEN` in a second file, so
// there is exactly one Cfg3DEN and this is a fragment of its Attributes body.
// The engine ctrl* classes it inherits from are forward-declared at TOP-LEVEL
// scope in CfgEden.hpp (declaring them inside Attributes shadows BI's global
// ctrl* classes and breaks BI attributes that chain through ctrlStatic - a
// hard-won ALiVE lesson).
// ---------------------------------------------------------------------------

class Combo;   // BI Combo attribute template (title + combo at IDC 100)

// ---- faction dropdown -------------------------------------------
class ghost_DroneFactionChoice: Combo {
    attributeLoad = "[_this, _value] call ghostD_common_fnc_edenDroneFactionLoad";
    attributeSave = "call ghostD_common_fnc_edenDroneFactionSave";
};

// ---------------------------------------------------------------------------
// THE CLASS PICKER. Every module field that takes class names - launchers,
// missiles, decoys, drones, shells - used to be a comma-separated edit box,
// and a class name is a thing you look up, not a thing you know. This is the
// selection window ALiVE gives its own fields (ALiVE_AAUnitChoiceMulti), built
// on the same substrate: an inline controls group with a title, two filter
// strips, a multi-select listbox and a free-text override for whatever the
// list does not surface. Ours filters by SIDE and by FACTION, which is the
// question a mission maker is actually asking - "what does OPFOR have".
//
// SUBSTRATE RULES (ALiVE's, verified): type = 15 must be explicit or Eden
// never descends into `class controls`; `controls` is lower-case; the empty
// VScrollbar/HScrollbar classes silence the RPT; the listbox is style
// 16 + 0x20 (frame + multi) and a subclass that re-opens List must say so
// again or the multi bit drops silently. IDC contract: 100 list, 101 title,
// 102 override edit, 103 its label, 1200/1210 filter strip A, 1201/1211
// filter strip B.
//
// THE HANDLERS LIVE ON THE CONTROL, NOT THE ATTRIBUTE. Eden honours
// attributeLoad/attributeSave only on the control class an attribute names
// through `control = "..."`; per-attribute overrides are ignored. So there is
// one variant class per (kind, side lock, single/multi) and the attribute
// says `control = "ghost_ClassPick_Uav"` and nothing else. The handlers are
// ghost_common's, compiled by CBA at preStart, so they exist in Eden.
//
// The wire format is a plain comma-separated string of class names, which is
// exactly what every read site already splits, so no module changed.
// ---------------------------------------------------------------------------

class ghost_ClassPick_Base: ctrlControlsGroupNoScrollbars {
    type  = 15;
    style = 0;
    idc   = -1;
    x = 0;
    y = 0;
    w = "130 * (pixelW * pixelGrid * 0.5)";
    h = "58 * (pixelH * pixelGrid * 0.5)";
    colorBackground[] = {0, 0, 0, 0};
    colorText[]       = {1, 1, 1, 1};
    text   = "";
    font   = "RobotoCondensed";
    sizeEx = "pixelH * pixelGrid * 2.2";
    class VScrollbar {};
    class HScrollbar {};
    class controls {
        class Title: ctrlStatic {
            idc      = 101;
            type     = 0;
            style    = 1;
            x        = 0;
            y        = 0;
            w        = "48 * (pixelW * pixelGrid * 0.5)";
            h        = "5 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 0.9};
            text     = "Classes:";
            font     = "RobotoCondensed";
            sizeEx   = "pixelH * pixelGrid * 2.2";
            tooltip  = "Tick classes in the list. Ctrl+click toggles one row, Shift+click a range, a plain click replaces the selection. Cycle the Side and Faction filters to narrow the list; ticks on hidden rows are kept. The override field takes comma-separated class names the list does not show.";
            tooltipColorShade[] = {0, 0, 0, 1};
            tooltipColorText[]  = {1, 1, 1, 1};
            tooltipColorBox[]   = {0, 0, 0, 1};
        };
        class FilterALabel: ctrlStatic {
            idc      = 1200;
            type     = 0;
            style    = 0;
            x        = "48 * (pixelW * pixelGrid * 0.5)";
            y        = 0;
            w        = "65 * (pixelW * pixelGrid * 0.5)";
            h        = "4 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0.5};
            colorText[]       = {1, 0.62, 0, 1};
            text     = "Side: All";
            font     = "RobotoCondensed";
            sizeEx   = "pixelH * pixelGrid * 1.8";
            tooltip  = "Filter by side. Next > cycles All / BLUFOR / OPFOR / Independent / Civilian / no side.";
            tooltipColorShade[] = {0, 0, 0, 1};
            tooltipColorText[]  = {1, 1, 1, 1};
            tooltipColorBox[]   = {0, 0, 0, 1};
        };
        class FilterANext: ctrlButton {
            idc      = 1210;
            type     = 1;
            style    = 2;
            x        = "115 * (pixelW * pixelGrid * 0.5)";
            y        = 0;
            w        = "15 * (pixelW * pixelGrid * 0.5)";
            h        = "4 * (pixelH * pixelGrid * 0.5)";
            text     = "Next >";
            default  = 0;
            colorBackground[]        = {1, 0.62, 0, 0.6};
            colorBackgroundDisabled[]= {0.4, 0.4, 0.4, 0.5};
            colorBackgroundActive[]  = {1, 0.62, 0, 1};
            colorFocused[]           = {1, 0.62, 0, 1};
            colorBackgroundFocused[] = {1, 0.62, 0, 1};
            colorText[]              = {1, 1, 1, 1};
            colorDisabled[]          = {1, 1, 1, 0.25};
            colorBorder[]            = {0, 0, 0, 1};
            borderSize               = 0;
            offsetX = 0; offsetY = 0; offsetPressedX = 0; offsetPressedY = 0;
            colorShadow[] = {0, 0, 0, 0};
            soundEnter[]  = {"", 0, 0};
            soundPush[]   = {"", 0, 0};
            soundClick[]  = {"", 0, 0};
            soundEscape[] = {"", 0, 0};
            font     = "RobotoCondensed";
            sizeEx   = "pixelH * pixelGrid * 1.6";
        };
        class FilterBLabel: FilterALabel {
            idc      = 1201;
            y        = "5 * (pixelH * pixelGrid * 0.5)";
            text     = "Faction: All";
            tooltip  = "Filter by faction within the chosen side. Next > cycles every faction that owns something in the list.";
        };
        class FilterBNext: FilterANext {
            idc      = 1211;
            y        = "5 * (pixelH * pixelGrid * 0.5)";
        };
        class List: ctrlListBox {
            idc = 100;
            type = 5;            // CT_LISTBOX
            style = 16 + 0x20;   // ST_FRAME + LB_MULTI
            x = "4 * (pixelW * pixelGrid * 0.5)";
            y = "10 * (pixelH * pixelGrid * 0.5)";
            w = "126 * (pixelW * pixelGrid * 0.5)";
            h = "42 * (pixelH * pixelGrid * 0.5)";
            color[]                  = {1, 0.62, 0, 1};
            colorActive[]            = {0, 0, 0, 0.5};
            colorFocused[]           = {0, 0, 0, 0.5};
            colorHover[]             = {0, 0, 0, 0.5};
            colorText[]              = {1, 1, 1, 1};
            colorBackground[]        = {0, 0, 0, 0.5};
            colorSelect[]            = {0, 0, 0, 1};
            colorSelect2[]           = {0, 0, 0, 1};
            colorSelectBackground[]  = {1, 0.62, 0, 1};
            colorSelectBackground2[] = {1, 0.62, 0, 1};
            colorDisabled[]          = {1, 1, 1, 0.25};
            shadow                   = 0;
            colorShadow[]            = {0, 0, 0, 0};
            tooltip  = "Ctrl+click toggles a row, Shift+click selects a range, a plain click replaces the selection. Ticks on rows hidden by a filter are kept.";
            tooltipColorShade[] = {0, 0, 0, 1};
            tooltipColorText[]  = {1, 1, 1, 1};
            tooltipColorBox[]   = {0, 0, 0, 1};
            font     = "RobotoCondensed";
            sizeEx   = "pixelH * pixelGrid * 2.0";
            rowHeight = "pixelH * pixelGrid * 2.4";
            period   = 1.2;
            soundSelect[] = {"", 0, 0};
            maxHistoryDelay = 1.0;
            class ListScrollBar {
                color[]         = {1, 1, 1, 0.6};
                colorActive[]   = {1, 1, 1, 1};
                colorDisabled[] = {1, 1, 1, 0.3};
                arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
                arrowFull  = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
                border     = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
                thumb      = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
            };
        };
        class OverrideLabel: ctrlStatic {
            idc      = 103;
            type     = 0;
            style    = 1;
            x        = 0;
            y        = "53 * (pixelH * pixelGrid * 0.5)";
            w        = "48 * (pixelW * pixelGrid * 0.5)";
            h        = "5 * (pixelH * pixelGrid * 0.5)";
            colorBackground[] = {0, 0, 0, 0};
            colorText[]       = {1, 1, 1, 0.7};
            text     = "Also (typed):";
            font     = "RobotoCondensed";
            sizeEx   = "pixelH * pixelGrid * 2.2";
            tooltip  = "Comma-separated class names the list does not show. Added to the ticked rows when the attribute is saved.";
            tooltipColorShade[] = {0, 0, 0, 1};
            tooltipColorText[]  = {1, 1, 1, 1};
            tooltipColorBox[]   = {0, 0, 0, 1};
        };
        class Override: ctrlEdit {
            idc      = 102;
            type     = 2;
            style    = 0;
            x        = "48 * (pixelW * pixelGrid * 0.5)";
            y        = "53 * (pixelH * pixelGrid * 0.5)";
            w        = "82 * (pixelW * pixelGrid * 0.5)";
            h        = "5 * (pixelH * pixelGrid * 0.5)";
            text     = "";
            colorBackground[] = {0, 0, 0, 0.5};
            colorText[]       = {1, 1, 1, 1};
            colorSelection[]  = {1, 0.62, 0, 0.6};
            colorDisabled[]   = {1, 1, 1, 0.25};
            font     = "RobotoCondensed";
            sizeEx   = "pixelH * pixelGrid * 1.8";
            autocomplete = "";
            canModify = 1;
        };
    };
};

// The single-select shape: same window, one row at a time (no LB_MULTI).
class ghost_ClassPick_Base_Single: ghost_ClassPick_Base {
    class controls: controls {
        class Title: Title {};
        class FilterALabel: FilterALabel {};
        class FilterANext: FilterANext {};
        class FilterBLabel: FilterBLabel {};
        class FilterBNext: FilterBNext {};
        class List: List { style = 16; };
        class OverrideLabel: OverrideLabel {};
        class Override: Override {};
    };
};

// ---- variants: [display, kind, varName, title, sideLock, single, _value] ----
// kind: "vehicle" (every scope-2 land/air/sea vehicle and static weapon),
// "uav" (isUav > 0), "static" (static weapons), "ammo" (shells, rockets,
// missiles, bombs - Type/Source filters instead of Side/Faction).
// sideLock: -1 free, else 0 OPFOR / 1 BLUFOR / 2 Independent, strip fixed.
class ghost_ClassPick_Vehicle: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'vehicle', '', 'Vehicle classes:', -1, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Static: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'static', '', 'Static weapon classes:', -1, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Static_West: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'static', '', 'BLUFOR launcher classes:', 1, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Static_East: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'static', '', 'OPFOR launcher classes:', 0, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Static_Guer: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'static', '', 'Independent launcher classes:', 2, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Uav: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'uav', '', 'Drone classes:', -1, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Uav_West: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'uav', '', 'BLUFOR drone classes:', 1, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Uav_East: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'uav', '', 'OPFOR drone classes:', 0, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Uav_Guer: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'uav', '', 'Independent drone classes:', 2, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Uav_Single: ghost_ClassPick_Base_Single {
    attributeLoad = "[_this, 'uav', '', 'Airframe class:', -1, true, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, true] call ghostD_common_fnc_edenClassPickSave";
};
class ghost_ClassPick_Ammo: ghost_ClassPick_Base {
    attributeLoad = "[_this, 'ammo', '', 'Shell classes:', -1, false, _value] call ghostD_common_fnc_edenClassPickLoad";
    attributeSave = "[_this, false] call ghostD_common_fnc_edenClassPickSave";
};
