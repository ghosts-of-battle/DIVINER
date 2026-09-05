class CfgFunctions {
    // THE PORTED PANEL, UNDER ITS ORIGINAL TAG. Every one of these files calls
    // its neighbours as admp_fnc_<name>, so the tag is kept and the sixty-seven
    // files are the mission's own, unedited - which makes a fix upstream a
    // re-copy rather than a merge. Ghost additions are PREP'd in XEH_PREP.hpp
    // under the usual ghost_adminpanel_fnc_ names, so it is always clear which
    // half of this addon is which - and which half is GPL.
    class admp {
        class admin {
            file = "z\ghostD\addons\adminpanel\functions\admin";
            class ban {};
            class compileAndExec {};
            class createZeusModule {};
            class executeOnMachine {};
            class grantAdminAccess {};
            class kick {};
            class loadPreviousCode {};
            class setPlayerRank {};
            class toggleServerLock {};
            class toggleSpectator {};
            class toggleZeus {};
            class updateCuratorEditableObjects {};
            class updateServerStats {};
        };
        class main {
            file = "z\ghostD\addons\adminpanel\functions\main";
            class LBSelectionChanged {};
            class displayClosed {};
            class displayOpened {};
            class getPlayerList {};
            class handleClientVars {};
            class handleSpectatorAdminpanel {};
            class isAdmin {};
            class panelButtonPressed {};
            class playerFromSelection {};
            class playerSetup {};
            class refresh {};
            class refreshPIPcam {};
            class setReturnValue {};
            class updatePlayerList {};
            class updateRankCombo {};
            class updateToggleControls {};
        };
        class map {
            file = "z\ghostD\addons\adminpanel\functions\map";
            class centreMapOnPlayer {};
            class getMarkerInfo {};
            class handleMapClick {};
            class playerFromMapClick {};
            class updateMapMarkers {};
            class updateMarker {};
            class updateSelectedMarker {};
        };
        class medical {
            file = "z\ghostD\addons\adminpanel\functions\medical";
            class Healall {};
            class fullHeal {};
            class getPlayerMedicalInfo {};
            class updatePlayerMedicalInfo {};
            class wakeUp {};
        };
        class message_display {
            file = "z\ghostD\addons\adminpanel\functions\message_display";
            class loadMessageList {};
            class messageDisplayOpened {};
            class messageHistorySelection {};
            class populateRecipientList {};
            class receiveMessage {};
            class sendMessage {};
        };
        class mission {
            file = "z\ghostD\addons\adminpanel\functions\mission";
            class endMission {};
            class logPlayerShots {};
            class populateEndingList {};
        };
        class playerinfo {
            file = "z\ghostD\addons\adminpanel\functions\playerinfo";
            class applySkills {};
            class assignGroup {};
            class getPlayerInfo {};
            class loadPlayerSkills {};
            class populateSkillCombos {};
            class updatePlayerInfo {};
        };
        class utility {
            file = "z\ghostD\addons\adminpanel\functions\utility";
            class arsenal {};
            class ghost {};
            class godmode {};
            class infiniteAmmo {};
            class toggleLocalFiredEH {};
            class toggleRoleAccess {};
        };
        class vehicle {
            file = "z\ghostD\addons\adminpanel\functions\vehicle";
            class forceDismount {};
            class rearmVehicle {};
            class refuelVehicle {};
            class repairVehicle {};
            class vehicleUnstuck {};
        };
    };
};
