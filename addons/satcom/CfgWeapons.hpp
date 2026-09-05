// The mast as a carried item. CBA_MiscItem so it lives in the arsenal's items
// list and can go in a uniform, vest or backpack like any other piece of kit.

class CfgWeapons {
    class CBA_MiscItem;
    class CBA_MiscItem_ItemInfo;

    class GVAR(item): CBA_MiscItem {
        scope = 2;
        scopeArsenal = 2;
        scopeCurator = 2;
        displayName = "SatCom Mast";
        author = QAUTHOR;
        descriptionShort = "Deployable satellite uplink mast. Plant it, connect a radio to it, and long-range traffic stops caring about terrain.";
        picture = QPATHTOF(data\satcom_icon.paa);
        model = "\a3\Props_F_Enoch\Military\Equipment\BatteryPack_01_Closed_F.p3d";
        editorCategory = "EdCat_Equipment";
        editorSubcategory = "EdSubcat_InventoryItems";

        class ItemInfo: CBA_MiscItem_ItemInfo {
            // Heavy on purpose: a mast is a two-hands, one-trip item.
            mass = 25;
        };
    };
};
