
class EMM_mainMenu_CfgMenus {
    class VN {
        class menus {
            class MainMenu;
            class MultiplayerVN: MainMenu {
                items[] = {"ghost", "ServerBrowser", "SOGPrairieFire", "MikeForce", "Exit"};

                class ServerBrowser;
                class ghost: ServerBrowser {
                    action = QUOTE(call (uiNamespace getVariable QQFUNC(join)));
                    text = "Ghosts of Battle";
                };
            };
        };
    };
};
