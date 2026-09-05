#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_hackSetting

Description:
    One hacking tuning value. Reads whatever the Hacking Settings module
    published, falling back to the shipped default when no module is placed - so
    every caller can just ask, and none of them needs to know the module is
    optional.

Parameters:
    _key : STRING - the published global name, e.g. QGVAR(cfg_hack_time).

Returns:
    ANY - the value.

Author:
    Ghost
---------------------------------------------------------------------------- */
params ["_key"];

private _defaults = createHashMapFromArray [
    [QGVAR(cfg_hack_time), HACK_TIME_DEF],
    [QGVAR(cfg_hack_range), HACK_RANGE_DEF],
    [QGVAR(cfg_hack_cooldown), HACK_COOLDOWN_DEF],
    [QGVAR(cfg_abandon_timeout), HACK_ABANDON_DEF],
    [QGVAR(cfg_local_picture_radius), HACK_PICTURE_DEF],
    [QGVAR(cfg_emitter_hack_response_chance), HACK_RESPONSE_DEF],
    [QGVAR(cfg_package_share), HACK_PACKAGE_SHARE_DEF],
    [QGVAR(cfg_intel_lifetime), INTEL_LIFETIME_DEF],
    [QGVAR(cfg_intel_alpha), INTEL_ALPHA_DEF],
    [QGVAR(cfg_intel_fade), false],
    [QGVAR(cfg_combat_interrupts), false],
    [QGVAR(cfg_circle_radii), INTEL_RADII_DEF],
    [QGVAR(cfg_circle_offset), INTEL_OFFSET_DEF]
];

missionNamespace getVariable [_key, _defaults getOrDefault [_key, 0]]
