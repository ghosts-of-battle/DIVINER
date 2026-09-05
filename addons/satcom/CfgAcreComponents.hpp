// The antenna ACRE2 sees when a radio is connected to the deployed mast.
//
// Ignored outright when ACRE2 is not loaded - an unknown config class costs
// nothing - which is what lets this addon stay useful as a plain deployable prop
// on a server without it.
//
// The height is the whole point: a mast this tall is not modelling a physical
// pole, it is telling ACRE's propagation model to stop caring about the hill
// between you and the other end. That is what makes it satellite comms rather
// than a taller whip.

class CfgAcreComponents {
    class ACRE_BaseAntenna;

    class GVAR(antenna): ACRE_BaseAntenna {
        name = "Ghost SatCom Mast";
        shortName = "SatCom";
        connector = 1;
        height = 5000;
        binaryGainFile = "\idi\acre\addons\sys_antenna\binary\groundspike_2430cm_mast_gain.aba";
        compatibleRadios[] = {"ACRE_PRC148", "ACRE_PRC152", "ACRE_PRC117F"};
    };
};
