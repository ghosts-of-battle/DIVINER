#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_pac_fnc_radioKeys

Description:
    THE RADIO PLAN'S VOCABULARY: every ghostFR_radio_* global the mod
    reads, by the part after the prefix, with the value a machine holds
    when nobody has written one. The structure's "radio" section is this
    map - config_radio.hpp in the database - and FUNC(radioApply) writes
    the globals from it; FUNC(radioFromMission) reads them back off a
    mission that still ships the file.

    The defaults are "no plan": empty channel lists, stock power, channel
    one everywhere. They exist so a bare read (gear's setupRadios,
    players' getRadioChannel) never hits nil on a mission whose plan is
    still on its way from the server.

Parameters:
    None

Returns:
    [[key, default], ...] <ARRAY>

Author:
    YonV
---------------------------------------------------------------------------- */

[
    // which radio is which tier
    ["srRadios", []],
    ["mrRadios", []],
    ["lrRadios", []],
    ["acreActiveRadio", "ACRE_PRC148"],
    // transmit power, mW (-1 = ACRE stock)
    ["srPower", -1],
    ["mrPower", -1],
    ["lrPower", -1],
    // ACRE preset plumbing
    ["acreNoProgram", []],
    ["acreLabelField", []],
    ["acreChannelCount", []],
    // the three plans
    ["srChannels", []],
    ["srGroups", []],
    ["srSquadChannel", []],
    ["srBlockSize", 16],
    ["mrChannels", []],
    ["lrChannels", []],
    ["lrSatChannel", 1],
    ["lrLocalChannel", 1],
    // LONG RANGE, PER PLATOON (2026-09-09). [[platoonId, channel], ...]. Long
    // range used to be one channel for the whole task force, which is right for
    // a detachment net and wrong the moment two platoons want to talk among
    // themselves. A platoon with no row here falls to lrDefault, which is how
    // it behaved before, so a plan that does not use this is unchanged.
    ["lrPlatoonChannel", []],
    // before a man has joined a squad
    ["srFallback", 1],
    ["mrDefault", 1],
    ["lrDefault", 1],
    // TFAR
    ["tfarActiveRadio", "TFAR_pnr1000a"],
    ["tfarSrFreqs", []],
    ["tfarLrFreqs", []],
    ["tfarNets", []],
    ["tfarSwFallback", 0],
    ["tfarLrFallback", 0]
]
