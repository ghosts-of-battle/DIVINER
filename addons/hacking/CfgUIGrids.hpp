// THE HANDSET, IN THE GAME'S OWN LAYOUT EDITOR.
//
// It was positioned by ghost's bespoke drag-and-save - EFUNC(common,hudPos) and
// a keybind to move it - which meant learning a ghost-specific way to move a
// ghost-specific thing, and it knew nothing about where the player had already
// put the rest of their screen. Options > Game > Layout is where every other
// overlay in the game is placed, so it is where this is placed.
//
// The registry is CfgUIGrids >> IGUI, in two halves: Presets carries the default
// geometry, Variables is the entry the editor LISTS. The preview is required -
// an entry without one draws on that screen but never appears in the list to be
// picked. See addons/hud/gui.hpp, which learned all of this the hard way.
//
// MOVE ONLY, canResize = 0. The handset is a piece of art with a screen
// rectangle measured as a fraction of it; let a player stretch one axis and the
// glass slides off the bezel. saveToProfile[] = {0,1} is x and y and nothing
// else.

class CfgUIGrids {
    class IGUI {
        class Presets {
            class Arma3 {
                class Variables {
                    grid_ghost_scanner[] = {
                        {
                            "(safeZoneX + safeZoneW * 0.845)",
                            "(safeZoneY + safeZoneH * 0.42)",
                            "(safeZoneH * 0.391 * 0.602 * (safeZoneW / safeZoneH) / (safeZoneW / safeZoneH))",
                            "(safeZoneH * 0.391)"
                        },
                        "(((safeZoneW / safeZoneH) min 1.2) / 40)",
                        "((((safeZoneW / safeZoneH) min 1.2) / 1.2) / 25)"
                    };
                };
            };
        };

        class Variables {
            class grid_ghost_scanner {
                displayName = "Ghost EW Scanner";
                description = "The hand-held EW scanner. Move only - the screen is measured off the art, so it cannot be stretched.";
                preview = QPATHTOF(ui\igui_preview.paa);
                saveToProfile[] = {0, 1};
                canResize = 0;
            };
        };
    };
};
