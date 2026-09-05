class CtrlMenuStrip;
class Display3DEN {
    class Controls {
        class MenuStrip: CtrlMenuStrip {
            class Items {
                items[] += {QUOTE(PREFIX)};
                class PREFIX {
                    text = GHOST_TOOLBAR;
                    items[] += {
                        QGVAR(Wiki)
                    };
                };
                class GVAR(Wiki) {
                    text = GHOST_TOOLBAR_WIKI;
                    picture = "\a3\3DEN\Data\Controls\ctrlMenu\link_ca.paa";
                    weblink = "https://wiki.Ghosts of Battle.com/";
                    opensNewWindow = 1;
                };
            };
        };
    };
};
