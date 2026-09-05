#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {
            "ghostD_common",
            "ghostD_notify",
            "cba_main"
        };
        author = QAUTHOR;
        authors[] = {"DomT602", "YONV"};
        VERSION_CONFIG;
    };
};

class CfgFunctions {
    class DT {
        tag = "DT";
        class viewDistance {
            file = QPATHTOF(functions);
            class changeSingleValue {};
            class changeViewByHotkey {};
            class focusedZoom {};
            class getActiveUAV {};
            class getInMan {};
            class getOutMan {};
            class getVarByVehicle {};
            class incrementDistance {};
            class initFocusedBoost {};
            class initViewDistance {};
            class initZoomBoost {};
            class openViewDistanceMenu {};
            class opticsSwitch {};
            class terrainGridChanged {};
            class viewEditChanged {};
            class viewSliderChanged {};
            class zoomEditChanged {};
            class zoomSliderChanged {};
        };
    };
};

#include "CfgEventHandlers.hpp"
#include "DT_viewDistanceMenu.hpp"
