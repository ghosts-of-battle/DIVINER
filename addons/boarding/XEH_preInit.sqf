#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// The boarding points, one entry per module: [object, module, range, title].
// Declared at PREINIT because module functions run BETWEEN preInit and
// postInit - a list built in postInit would be created after the modules had
// already tried to add themselves to it.
GVAR(points) = [];

ADDON = true;
