#include "script_component.hpp"
params [
    ["_desiredRole","recon",[""]],
    ["_isRespawn",false,[true]]
];

// THE ROLE, from wherever the unit keeps it - the database, the profile or
// the mission's Dynamic_Roles - see FUNC(role). Arrays are COPIED before
// anything appends to them: the record is shared with every reader.
private _roleConfig = [_desiredRole] call FUNC(role);
private _defaultLoadout = +(_roleConfig getOrDefault ["defaultLoadout", []]);

if (_isRespawn) then {
        // ONE SYSTEM DRESSES THE RESPAWN. If the respawn addon's own template
        // is restoring gear, this leaves the man alone - two dressers strip each
        // other and the player arrives naked. Otherwise the saved loadout, and
        // where nothing was ever saved (a fresh unit has no saved loadout on it),
        // the ROLE's loadout - never the empty one loadLoadout answers with.
        //
        // It used to ask the ALiVE adapter the same question. The question
        // outlived ALiVE; the addon that does the restoring is the one that
        // knows the answer now.
        // Guarded the way the curator and ACRE calls below are: respawn is not
        // in this addon's requiredAddons, and a build without it dresses the
        // man here rather than not at all.
        private _managed = !isNil QEFUNC(respawn,gearManaged) && {call EFUNC(respawn,gearManaged)};

        if (!_managed) then {
            if (player call EFUNC(gear,hasSavedLoadout)) then {
                [player, [player] call EFUNC(gear,loadLoadout)] call EFUNC(gear,applyLoadout);
            } else {
                player setUnitLoadout _defaultLoadout;
            };
        };
        if (player call ghostD_players_fnc_isCurator) then {
            if (!isNil "ghostD_curator_fnc_assignZeus") then {[player,true] call ghostD_curator_fnc_assignZeus};
            if (!isNil "acre_api_fnc_godModeConfigureAccess") then {[true,true] call acre_api_fnc_godModeConfigureAccess};
            [player,true] call admp_fnc_grantAdminAccess;
        } else {
            if (!isNil "ghostD_curator_fnc_assignZeus") then {[player,false] call ghostD_curator_fnc_assignZeus};
            if (!isNil "acre_api_fnc_godModeConfigureAccess") then {[false,false] call acre_api_fnc_godModeConfigureAccess};
        };  
} else {
    player setUnitLoadout _defaultLoadout;
    
    private _weapons = +(_roleConfig getOrDefault ["arsenalWeapons", []]);
    private _magazines = +(_roleConfig getOrDefault ["arsenalMagazines", []]);
    private _items = +(_roleConfig getOrDefault ["arsenalItems", []]);
    private _backpacks = +(_roleConfig getOrDefault ["arsenalBackpacks", []]);

    //merge the shared Common_Arsenal (config\arsenal) plus the role's group arsenal
    //(groupArsenal property, e.g. "Arsenal_Reaper") - any array named items* counts as items
    private _arsenalSources = [missionConfigFile >> "Common_Arsenal"];
    private _groupArsenal = _roleConfig getOrDefault ["groupArsenal", ""];
    if (_groupArsenal isNotEqualTo "" && {isClass (missionConfigFile >> _groupArsenal)}) then {
        _arsenalSources pushBack (missionConfigFile >> _groupArsenal);
    };
    {
        {
            private _name = toLower configName _x;
            switch (true) do {
                case (_name isEqualTo "weapons"): {_weapons append getArray _x};
                case (_name isEqualTo "magazines"): {_magazines append getArray _x};
                case (_name isEqualTo "backpacks"): {_backpacks append getArray _x};
                case (_name select [0,5] isEqualTo "items"): {_items append getArray _x};
            };
        } forEach configProperties [_x, "isArray _x", false];
    } forEach _arsenalSources;

    [player,true,false] call ace_arsenal_fnc_removeVirtualItems;
    {
        [player,_x,false] call ace_arsenal_fnc_addVirtualItems;
    } forEach [_weapons,_magazines,_items,_backpacks];
    private _roleName = _roleConfig getOrDefault ["name", _desiredRole];
    [_roleName,_defaultLoadout] call ace_arsenal_fnc_addDefaultLoadout;

    private _roleTraits = _roleConfig getOrDefault ["traits", []];
    {
        _x params ["_trait","_value"];

        // TYPE FIRST, VALUE SECOND, AND NOT WITH &&. getAllUnitTraits returns
        // traits of MIXED type - audibleCoef and camouflageCoef are NUMBERS, the
        // rest are booleans - so the value can only be looked at once the type
        // is known.
        //
        // `_value isEqualType true && _value` throws: && evaluates its right
        // side whatever the left side said, and a number there is
        // "&&: Type Number, expected Bool,code" on the first numeric trait.
        // `&& {_value}` is correct but reads as a pointless code block to a
        // linter. Two statements say the same thing and argue with nobody.
        if !(_value isEqualType true) then {continue};

        if (_value) then {
            player setUnitTrait [_trait,false];
        };
    } forEach (getAllUnitTraits player);

    // PAC OWNS THE SKILLS. Every trait or variable a PAC skill can set is
    // skipped here - medic, engineer, EOD, isLeader, isJFO, whatever the
    // unit's skills declare - and PAC puts them on after this (the hook at
    // the end). Everything else the role carries - tile access, nets, DRA
    // flags - is not a skill and stays the role's. Without the pac addon
    // the role applies the lot, as before.
    private _pacOwned = if (!isNil "ghostD_pac_fnc_managedNames") then {[] call ghostD_pac_fnc_managedNames} else {[]};

    {
        _x params ["_trait","_value",["_custom","false"]];
        if ((toLower _trait) in _pacOwned) then {continue};
        if (_value in ["true","false"]) then {_value = call compile _value};
        player setUnitTrait [_trait,_value,call compile _custom];
    } forEach _roleTraits;

    private _customVariables = _roleConfig getOrDefault ["customVariables", []];
    _customVariables = _customVariables select {!((toLower (_x # 0)) in _pacOwned)};
    {
        player setVariable [_x,nil,true];
    } forEach (missionNamespace getVariable ["YMF_myCustomVariables",[]]);

    YMF_myCustomVariables = [];
    {
        _x params ["_variable","_value","_global"];
        if (_value in ["true","false"]) then {_value = call compile _value};
        player setVariable [_variable,_value,call compile _global];
        YMF_myCustomVariables pushBack _variable;
    } forEach _customVariables;
    player setVariable ["YMF_role",_desiredRole,true];

    if (player call ghostD_players_fnc_isCurator) then {
        if (!isNil "ghostD_curator_fnc_assignZeus") then {[player,true] call ghostD_curator_fnc_assignZeus};
        if (!isNil "acre_api_fnc_godModeConfigureAccess") then {[true,true] call acre_api_fnc_godModeConfigureAccess};
        [player,true] call admp_fnc_grantAdminAccess;
    } else {
        if (!isNil "ghostD_curator_fnc_assignZeus") then {[player,false] call ghostD_curator_fnc_assignZeus};
        if (!isNil "acre_api_fnc_godModeConfigureAccess") then {[false,false] call acre_api_fnc_godModeConfigureAccess};
    };

    /* rank stuff ------------------------------------------------------------------------------------------------------ */
    [player, 'BIS'] call EFUNC(players,setRank);

    // PAC goes on after the role, not under it: the role's traits and rank are
    // the defaults, and a PAC assignment (skills and rank) is what the unit actually carries. Guarded, because the
    // pac addon is optional.
    if (!isNil "ghostD_pac_fnc_applyOnClient") then {[] call ghostD_pac_fnc_applyOnClient};
    if (!isNil "ghostD_pac_fnc_leaderNotice") then {[_isRespawn] call ghostD_pac_fnc_leaderNotice};

    /* Name Stuff ------------------------------------------------------------------------------------------------------- */
    call (missionNamespace getVariable ["ghost_w28fixes_fnc_player_set_name", {}]);

    player call EFUNC(gear,saveLoadout);
};

//re-tune radios to the joined group's nets - runs for BOTH a fresh join and a respawn.
//getRadioChannel keys off the player's current squad, so this re-applies for whatever group was joined.
//The squad name is read from groupId (group player), but the server creates, names (setGroupIdGlobal)
//and joins the group in the same frame it remote-executes this function, so the client can still be
//looking at its previous group when the tuning runs - worst case for the first player into an empty
//squad, whose group is built from scratch. Wait for the new name to replicate before reading it,
//with a wall-clock deadline so anyone outside the configured squads still falls back to the defaults.
private _squadNames = (([] call FUNC(orbat)) # 0) apply {toUpper (_x select 0)};
private _deadline = diag_tickTime + 10;

if (EGVAR(patches,usesACRE)) then {
    [{
        params ["_squadNames","_deadline"];
        ([] call acre_api_fnc_isInitialized) && {
            ((toUpper (groupId (group player))) in _squadNames) || {diag_tickTime > _deadline}
        }
    }, {
        INFO_1("GearRadio","Setting up ACRE radio channels for %1...",player);
        [player] call EFUNC(players,setRadioChannel);
        [ghostFR_radio_acreActiveRadio] call EFUNC(players,setActiveRadio);
    }, [_squadNames,_deadline]] call CBA_fnc_waitUntilAndExecute;
};

if (EGVAR(patches,usesTFAR)) then {
    [{
        params ["_squadNames","_deadline"];
        private _r = call TFAR_fnc_activeSwRadio;
        (!isNil "_r" && {_r isEqualType "" && _r isNotEqualTo ""}) && {
            ((toUpper (groupId (group player))) in _squadNames) || {diag_tickTime > _deadline}
        }
    }, {
        INFO_1("GearRadio","Setting up TFAR radio channels for %1...",player);
        [player] call EFUNC(players,setRadioChannel);
        [ghostFR_radio_tfarActiveRadio] call EFUNC(players,setActiveRadio);
    }, [_squadNames,_deadline]] call CBA_fnc_waitUntilAndExecute;
};
