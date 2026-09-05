#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ghostD_hacking_fnc_packageEntries

Description:
    Every entry in one intel package, read out of mission config.

    THE MISSION WRITES THE INTEL. This is the whole change from what came
    before: the old products asked ALiVE where its air defence and its camps
    were and drew a circle round the answer, so the intelligence a hack produced
    was whatever the simulation happened to contain. A mission maker could not
    write a document, could not hand over a photograph, and could not decide
    that breaking into THIS terminal tells you about THAT dockyard.

    A package is a class in the mission's own config:

        class Ghost_IntelPackages {
            class dockyard {
                name = "PORT SURVEY";          // what the app calls the folder
                class entries {
                    class berths {
                        title = "BERTHS 4-7";
                        text  = "Two coastal freighters alongside...";
                        image = "images\intel\berths.paa";   // optional
                    };
                    class manifest {
                        title = "CARGO MANIFEST";
                        text  = "...";
                    };
                };
            };
        };

    ORDER IS CONFIG ORDER, and it matters: a hack yields a SHARE of a package,
    taken from the top, so the entries a mission maker considers the meat go
    first and the colour goes last. Somebody who breaks in once and never comes
    back should still have got the thing worth knowing.

    AN IMAGE IS OPTIONAL AND A TEXT IS NOT. An entry with neither is skipped
    with a warning - it would arrive in the app as a blank row and read as a
    bug, which it would be.

    IT ASKS missionConfigFile ONLY. Packages are mission content; putting them
    in the addon would make them ours, and the point is that they are not.

Parameters:
    _package : STRING - the package class name.

Returns:
    ARRAY - [[id, title, text, image], ...] in config order. Empty if the
            package does not exist.

Author:
    YonV
---------------------------------------------------------------------------- */
params [["_package", "", [""]]];

if (_package isEqualTo "") exitWith { [] };

private _cfg = missionConfigFile >> "Ghost_IntelPackages" >> _package;

if !(isClass _cfg) exitWith {
    WARNING_1("intel package '%1' is not in the mission's Ghost_IntelPackages",_package);
    []
};

private _out = [];

{
    private _id = configName _x;
    private _title = getText (_x >> "title");
    private _text = getText (_x >> "text");
    private _image = getText (_x >> "image");

    if (_title isEqualTo "" && _text isEqualTo "" && _image isEqualTo "") then {
        WARNING_2("intel package '%1': entry '%2' has no title, text or image - skipped",_package,_id);
    } else {
        _out pushBack [_id, _title, _text, _image];
    };
} forEach ("true" configClasses (_cfg >> "entries"));

_out
