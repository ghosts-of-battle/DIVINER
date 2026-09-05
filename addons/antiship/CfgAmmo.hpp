// Kh-72 Burevestnik. A ship-killer: one of these is meant to end a hull, so the
// warhead is heavier than anything in the air-to-air or artillery families.
//
// Built on the Scalpel rather than a bomb because it has to LOOK like a cruise
// missile in flight - model, trail and sound come with the lineage. It does not
// use the parent's guidance: FUNC(fly) flies it, so everything that would steer
// it is zeroed.

class CfgAmmo {
    class M_Scalpel_AT;

    class GVAR(missile): M_Scalpel_AT {
        author = QAUTHOR;
        displayName = "Kh-72 Burevestnik";

        hit = 12000;
        indirectHit = 2600;
        indirectHitRange = 22;

        // Flown by script. Anything here that steers, seeks or self-destructs is
        // a second opinion the guidance loop would have to fight.
        manualControl = 0;
        maneuvrability = 0;
        trackLead = 0;
        trackOversteer = 0;
        initTime = 0;
        thrustTime = 0;
        thrust = 0;
        maxSpeed = 1200;
        airFriction = 0;
        sideAirFriction = 0;
        fuseDistance = 0;

        // Long enough to cross open water at the ranges a coastal battery works
        // at, and no longer.
        timeToLive = 200;

        cost = 50000;
    };
};
