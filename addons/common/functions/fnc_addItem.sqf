/*

 * \ghost_common\functions\common\fn_addItem.sqf
 * by YonV
 *
 * add item to unit/vehicle
 *
 * Arguments:
 * 0: unit   - <OBJECT>
 * 1: item   - <STRING>
 * 2: amount  - <NUMBER>
 * 3: priority  - <ARRAY> [0 = Cargo, 1 = Uniform, 2 = Vest, 3 = Backpack]
 * 4: overflow  - <BOOLEAN> [Default = true]
 *
 * Return:
 * 0: addToUnit - <BOOLEAN>
 * 1: addToGround - <BOOLEAN>
 *
 * Examples:
 * [player, "ACE_EarPlugs", 1, [3,2,1], true] call EFUNC(common,addItem);
 * [truck1, "ACE_EarPlugs", 1] call EFUNC(common,addItem);
 *
 */

// -------------------------------------------------------------------------------------------------

private _unit     = param [0, objNull, [objNull]];
private _item     = param [1, "", [""]];
private _amount   = param [2, 1, [0]];
private _priority = param [3, [0], [[]]];
private _overflow = param [4, false, [true]];

// -------------------------------------------------------------------------------------------------

if (isNull _unit) exitWith {[false,false]};
if (_item isEqualTo "") exitWith {[false,false]};
if (_amount < 1) exitWith {[false,false]};

if (_priority isEqualTo []) then {_priority = [1,2,3];};

// -------------------------------------------------------------------------------------------------

private _added = false;
private _addToUnit = false;
private _addToGround = false;

for "_i" from 1 to _amount do {

    _added = false;

    // ADD TO CONTAINER
    {
        switch (_x) do {
            case 0: {
                if ( (_unit canAdd _item) && (!_added) ) then {
                    _unit addItemCargoGlobal [_item, 1];
                    _addToUnit = true;
                    _added = true;
                };
            };
            case 1: {
                if ( (uniform _unit != "") && (_unit canAddItemToUniform _item) && (!_added) ) then {
                    _unit addItemToUniform _item;
                    _addToUnit = true;
                    _added = true;
                };
            };
            case 2: {
                if ( (vest _unit != "") && (_unit canAddItemToVest _item) && (!_added) ) then {
                    _unit addItemToVest _item;
                    _addToUnit = true;
                    _added = true;
                };
            };
            case 3: {
                if ( (backpack _unit != "") && (_unit canAddItemToBackpack _item) && (!_added) ) then {
                    _unit addItemToBackpack _item;
                    _addToUnit = true;
                    _added = true;
                };
            };
            default {};
        };
    } forEach _priority;

    // IF CONTAINER IS FULL
    if ( (!_added) && (_overflow) ) then {

        if (!isNull objectParent _unit) exitWith {
            [_addToUnit, _addToGround]
        };
        if (
            (surfaceIsWater (position _unit)) &&
            (((getPosASL _unit)-(getPosATL _unit)) select 0 < -1.5)
        ) exitWith {
            [_addToUnit, _addToGround]
        };

        private _gwh = nearestObject [_unit, "GroundWeaponHolder"];
        private _pos = [0,0,0];

        if ((isNull _gwh) || (_unit distance _gwh > 3)) then {

            _gwh = createVehicle ["GroundWeaponHolder", [0,0,0], [], 0, "CAN_COLLIDE"];
            _pos = (getPosATL _unit) findEmptyPosition [0, 3, "GroundWeaponHolder"];

            if (_pos isEqualTo []) then {
                _pos = (getPosASL _unit);
            } else {
                _pos = (ATLToASL _pos);
            };

            _gwh setPosASL _pos;

        };

        _gwh addItemCargoGlobal [_item, 1];
        _gwh setVectorUp surfaceNormal (position _gwh);

        _addToGround = true;

    };

};

[_addToUnit, _addToGround];
