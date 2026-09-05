class CfgAmmo {
    class HelicopterExploSmall;

    // THE INTERCEPTION. A flash and a bang where the round died and nothing
    // else - hit 1, a five-metre indirect radius that scratches paint. The
    // model is a tracer so nothing is drawn but the effect. Drongo's DAPSblast,
    // under this mod's name so the two can coexist.
    class GVAR(blast): HelicopterExploSmall {
        model = "\A3\Weapons_f\Data\bullettracer\tracer_white";
        caliber = 0;
        CraterEffects = "GrenadeCrater";
        CraterWaterEffects = "ImpactEffectsWaterExplosion";
        directionalExplosion = 0;
        explosionAngle = 60;
        explosionDir = "explosionDir";
        explosionEffects = "HERocketExplosion";
        explosionEffectsDir = "explosionDir";
        explosionSoundEffect = "DefaultExplosion";
        explosionType = "explosive";
        hit = 1;
        indirectHit = 1;
        indirectHitRange = 5;
    };

    // THE RF BURST'S FLASH. The same effect, smaller, on the emitter itself:
    // the crew's cue and the only visible sign the burst happened.
    class GVAR(pulse): GVAR(blast) {
        explosionEffects = "GrenadeExplosion";
        indirectHitRange = 0;
        indirectHit = 0;
        hit = 0;
    };
};
