#include "script_component.hpp"
/*
 * Author: CPL.Brostrom.A -- Tinkered with by YonV
 * This function writes the Ghosts of Battle orientation diary records.
 *
 * Arguments:
 * None
 *
 * Example:
 * call ymf_fnc_Doc_mission_Info
 */

if !(player diarySubjectExists "gobinfo") then {
    player createDiarySubject ["gobinfo","GOB Info"];
};
// Load diary records (NOTE! The load order is reversed. So the top will be at the bottom after load.)

player createDiaryRecord["gobinfo",
    ["Logistics",
        "<font size='16'>Supply Crates (Zeus / staging)</font><br/>
        <br/>
        GOB / REAPER / NOMAD / TALON / GHOST / WRAITH Resupply - rifle ammo (Mk327, XM891, Mk367 6.5, EPR - blue and IR tracers), shotgun, anti-drone EMP, 40mm, MG belts, sniper rounds and M67s.<br/>
        CCP - full medic resupply mirroring the medic role loadout.<br/>
        Infantry Medical - squad self-aid basics.<br/>
        Launcher boxes - Titan AA, Titan AT, NLAW, Spike, MAAWS.<br/>
        <br/>
        Every vehicle carries a ToolKit, 4 first aid bags, VS-17 panels and a basic mag stash in 5.56, 6.5 and 7.62."
    ]
];

player createDiaryRecord["gobinfo",
    ["Radio Plan",
        "<font size='16'>PRC-148 (personal, active radio on spawn)</font><br/>
        REAPER - Block 1 / NOMAD - Block 2 / TALON - Block 3 / GHOST - Block 4 / WRAITH - Block 5<br/>
        <br/>
        <font size='16'>PRC-152 (medium) - each element defaults to its own net</font><br/>
        Ch 1 - Local<br/>
        Ch 2/3 - REAPER / REAPER Alt<br/>
        Ch 4/5 - NOMAD / NOMAD Alt<br/>
        Ch 6/7 - TALON / TALON Alt<br/>
        Ch 8/9 - GHOST / GHOST Alt<br/>
        Ch 10/11 - WRAITH / WRAITH Alt<br/>
        Ch 12 - AIR2GND<br/>
        <br/>
        <font size='16'>PRC-117F (long)</font><br/>
        Ch 1 - DETNET (default)<br/>
        Ch 2 - FIRES<br/>
        Ch 3 - AIR<br/>
        Ch 4 - AIR2GND"
    ]
];

player createDiaryRecord["gobinfo",
    ["Detachment",
        "<font size='16'>Ghosts of Battle</font><br/>
        <br/>
        Five elements: <font color='#ff4444'>REAPER</font> (M4A4), <font color='#4488ff'>NOMAD</font> (MX), <font color='#44cc44'>TALON</font> (SPAR), <font color='#bb66ff'>GHOST</font> (HK433), <font color='#ddcc44'>WRAITH</font> (SCAR-L) - 10 slots each.<br/>
        <br/>
        Roles per element:<br/>
        Team Lead - command, all specialist gear, restricted slot.<br/>
        Assistant Team Lead - 2IC, runs the net if the TL drops, senior scout, trail element.<br/>
        Medical - casualty care, full ACE medic.<br/>
        Demo / C-UAS - breaching, demolitions, counter-UAS.<br/>
        JFO / Strike - terminal attack control, designators, drone whitelist.<br/>
        ISR - recon UAS operator.<br/>
        Recon x4 - the gun line.<br/>
        <br/>
        Select a role from the group menu; gear comes from the ACE arsenal whitelist (common + element + role)."
    ]
];
