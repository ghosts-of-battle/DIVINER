class CfgDifficultyPresets {

    defaultPreset = QUOTE(Difficulty_GHOST);

    class Difficulty_GHOST {
        displayName = "Ghosts of Battle";

        description = "Custom Ghosts of Battle settings.";
        optionDescription = "Custom Ghosts of Battle settings.";

        levelAI = QGVAR(LevelAI);

        class Options {
              /* Simulation */
            reducedDamage = 0;  // Reduced damage

            /* Situational awareness */
            groupIndicators = 0; // Group indicators (0 = never, 1 = limited distance, 2 = always)
            friendlyTags = 0;  // Friendly name tags (0 = never, 1 = limited distance, 2 = always)
            enemyTags = 0;   // Enemy name tags (0 = never, 1 = limited distance, 2 = always)
            detectedMines = 0;  // Detected mines (0 = never, 1 = limited distance, 2 = always)
            commands = 0;   // Commands (0 = never, 1 = fade out, 2 = always)
            waypoints = 1;   // Waypoints (0 = never, 1 = fade out, 2 = always)
            tacticalPing = 0;  // Tactical ping (0 = disable, 1 = enable)

            /* Personal awareness */
            weaponInfo = 2;   // Weapon info (0 = never, 1 = fade out, 2 = always)
            stanceIndicator = 2; // Stance indicator (0 = never, 1 = fade out, 2 = always)
            staminaBar = 1;   // Stamina bar
            weaponCrosshair = 0; // Weapon crosshair
            visionAid = 0;   // Vision aid

            /* View */
            thirdPersonView = 1; // 3rd person view (0 = disabled, 1 = enabled, 2 = enabled for vehicles only (Since  Arma 3 v1.99))
            cameraShake = 1;  // Camera shake

            /* Multiplayer */
            scoreTable = 1;   // Score table
            deathMessages = 0;  // Killed by
            vonID = 0;    // VoN ID

            /* Misc */
            mapContent = 0;   // Extended map content
            autoReport = 0;   // (former autoSpot) Automatic reporting of spotted enemied by players only. This doesn't have any effect on AIs.
            multipleSaves = 0;  // Multiple saves
        };
    };
};
