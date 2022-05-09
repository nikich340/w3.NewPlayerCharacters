function NR_Notify(message : String, optional duration : float)
{
	if (duration < 1.0)
		duration = 5.0;
    theGame.GetGuiManager().ShowNotification(message, 3000.0);
    LogChannel('NR_MOD', message);
}
quest function NR_Notify_Quest(message : String, optional duration : float) {
	 NR_Notify(message, duration);
}

function NR_Debug(message : String, optional duration : float)
{
	if (duration < 1.0)
		duration = 5.0;
    //theGame.GetGuiManager().ShowNotification("[NR_DEBUG] " + message, 3000.0);
    LogChannel('NR_DEBUG', message);
}

class NR_PlayerManager extends CPeristentEntity {
	public saved var savedPlayerName : String;
	default          savedPlayerName = "Geralt";

	public saved var headName : name;
	public saved var hairstyleName : name;
	public saved var           appearanceTemplates : array<String>;
	public saved var appearanceTemplateIsDepotPath : array<bool>;

	default headName = 'head_0';
	default hairstyleName = 'Long Loose Hairstyle';

	//public var spawnedTime					: float;
	public saved var geraltSavedItems  : array<name>;

	public var inStoryScene : Bool;
	default    inStoryScene = false;

	public var playerChangeRequested : Bool;
	default    playerChangeRequested = false;

	public saved var geraltDataSaved : Bool;
	default          geraltDataSaved = false;

	//private var sceneChoices : array<int>;
	//private var  currentChoice : int;
	//default currentChoice = 0;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//spawnedTime = theGame.GetEngineTimeAsSeconds();
		NR_Debug("wasSpawned! this: " + this);
		AddTimer('OnPlayerSpawned', 0.2f);
		super.OnSpawned( spawnData );
	}

	function OnDialogOptionSignal( type: EStorySceneSignalType, index: int ) {
		if (type == SSST_Accept) {
			//sceneChoices.PushBack(index);
		} else if (type == SSST_Highlight) {
			//currentChoice = index;
		}
	}
	/*function GetCustomInventoryFor(playerCode : String) : CInventoryComponent {
		var           i : int;
		var invTemplate : CEntityTemplate;
		var     newInv  : CInventoryComponent;

		for (i = 0; i < invNames.Size(); i += 1) {
			if (invNames[i] == playerCode) {
				return invComponents[i];
			}
		}

		newInv = new CInventoryComponent in this;
		invTemplate = (CEntityTemplate)LoadResource("preview_inventory_gryphon_4");
		newInv.InitInvFromTemplate( invTemplate );
		
		invComponents.PushBack( newInv );
		invNames.PushBack( playerCode );
	}*/
	function GetCurrentPlayerName() : String {
		var replacer : NR_ReplacerWitcher;

		replacer = NR_GetWitcherReplacer();
		if ( replacer ) {
			return replacer.replacerName;
		} else if ( (W3ReplacerCiri)thePlayer ) {
			return "Ciri";
		} else {
			return "Geralt";
		}
	}
	function IsReplacerActive() : Bool {
		var playerName : String;

		playerName = GetCurrentPlayerName();
		return (playerName != "Geralt" && playerName != "Ciri");
	}
	timer function OnPlayerSpawned( delta : float, id : int ) {
		var curPlayerName : String;

		curPlayerName = GetCurrentPlayerName();
		NR_Debug("Cur player: " + curPlayerName + ", saved player: " + savedPlayerName);

		if ( !thePlayer.HasChildAttachment( this ) )
			CreateAttachment(thePlayer);

		if ( curPlayerName != savedPlayerName ) {
			// FROM GERALT
			if ( savedPlayerName == "Geralt" ) {
				// TO CUSTOM PLAYER
				//if ( curPlayerName != "Geralt" ) {
				LoadPlayerData();
				///NR_FixReplacer( 0.0, 0 );
				//}
			// FROM REPLACER
			} else {
				// TO GERALT & have saved items
				if ( curPlayerName == "Geralt" && geraltDataSaved ) {
					// OK, we asked for it - restore mounted items
					if ( FactsQuerySum("NR_PlayerChangeRequested") > 0 ) {
						NR_FixPlayer( 0.0, 0 );
					// BAD, it was auto-reset to Geralt after World change(?)
					} else {
						NR_ChangePlayer( savedPlayerName );
						return;
					}
				}
				// TO ANOTHER REPLACER
				///} else if ( curPlayerName != "Geralt" ) {
				///	NR_FixReplacer( 0.0, 0 );
				///}
			}
		}
		// WAS CUSTOM REPLACER - Reset appearance templates always
		if ( savedPlayerName != "Geralt" && savedPlayerName != "Ciri" ) {
			LoadAppearanceTemplates(/*unloadTemplates*/ true);
		}
		// CUSTOM REPLACER - APPLY FIX ALWAYS
		if ( IsReplacerActive() ) {
			NR_FixReplacer( 0.0, 0 );
		}
		FactsRemove("NR_PlayerChangeRequested");
		savedPlayerName = curPlayerName;
	}
	function SetInStoryScene(val : Bool) {
		inStoryScene = val;
	}
	function NR_stringById(itemId : SItemUniqueId) : String {
		var inv : CInventoryComponent;
		inv = thePlayer.GetInventory();

		if ( inv.IsIdValid(itemId) )
			return NameToString( inv.GetItemName(itemId) );
		else
			return "<invalid>";
	}
	function NR_DebugPrintData() {
		var i : int;
		for (i = 0; i < geraltSavedItems.Size(); i += 1) {
			NR_Debug("NR_SavedEquipment[" + ((EEquipmentSlots)i) + "]" + geraltSavedItems[i]);
		}
	}
	function LoadPlayerData() {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var headManager : CHeadManagerComponent;

		// not Geralt
		//if ( NR_GetWitcherReplacer() )
		//	return;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		geraltSavedItems[EES_Mask] = headManager.GetCurHeadName();

		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'hair' );
		
		for( i = 0; i < ids.Size(); i += 1 )
		{
			if (inv.IsItemMounted(ids[i])) {
				geraltSavedItems[EES_Hair] = inv.GetItemName(ids[i]);
				break;
			}
		}
	}
	function UpdateHead(newHeadName : name) {
		var headManager : CHeadManagerComponent;

		headName = newHeadName;
		if (!IsReplacerActive())
			return;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		/*if ( headManager.GetCurHeadName() != headName ) {
			NR_geraltSavedHeadName = headManager.GetCurHeadName();
		}*/
		NR_Debug("Head Set: " + headName);
		thePlayer.RememberCustomHead( headName );
		headManager.BlockGrowing( true );
		headManager.SetCustomHead( headName );
	}
	function UpdateHair(newHairstyleName : name) {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var ret : Bool;

		hairstyleName = newHairstyleName;
		if (!IsReplacerActive())
			return;

		inv = thePlayer.GetInventory();
		if (!inv) {
			NR_Debug("Restore head: NULL!");
		}
		ids = inv.GetItemsByCategory( 'hair' );
		
		for( i = 0; i < ids.Size(); i += 1 )
		{
			inv.RemoveItem(ids[i], 1);	
		}

		NR_Debug("Hair Set: " + hairstyleName);
		ids = inv.AddAnItem( hairstyleName );
		ret = inv.MountItem(ids[0]);
		NR_Debug("Hair Mount: " + ret);
	}
	function RestoreHead() {
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));

		if (!headManager) {
			NR_Debug("Restore head: NULL!");
			return;
		}

		thePlayer.ClearRememberedCustomHead();
		headManager.BlockGrowing( false );
		//headManager.RemoveCustomHead();
		headManager.SetCustomHead( geraltSavedItems[EES_Mask] );
		NR_Debug("Restore head: " + geraltSavedItems[EES_Mask]);
	}
	function RestoreHair() {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var ret : Bool;

		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'hair' );
		
		for( i = 0; i < ids.Size(); i += 1 )
		{
			inv.RemoveItem(ids[i], 1);	
		}

		NR_Debug("Restore hair: " + geraltSavedItems[EES_Hair]);
		ids = inv.AddAnItem( geraltSavedItems[EES_Hair] );
		ret = inv.MountItem(ids[0]);
		NR_Debug("Hair RMount: " + ret + ", " + inv.IsIdValid(ids[0]) + ", "  + inv.GetItemName(ids[0]));
	}
	function RestoreEquipment() {
		var inv  : CInventoryComponent;
		var i : int;
		var id : SItemUniqueId;
		inv = thePlayer.GetInventory();

		for ( i = EES_Armor; i <= EES_Gloves; i += 1 ) {
			NR_Debug("RestoreEquipment[" + (EEquipmentSlots)i + "]" + geraltSavedItems[i]);
			id = inv.GetItemId( geraltSavedItems[i] );
			if ( inv.IsIdValid( id ) ) {
				inv.MountItem( id );
			} else {
				NR_Debug("Unable to mount gerlat item: " + geraltSavedItems[i]);
				id = inv.GetItemId( GetDefaultItemByCategory(CategoryBySlot((EEquipmentSlots) i)) );
				if ( inv.IsIdValid( id ) )
					inv.MountItem( id );
			}
		}
	}
	function SlotByCategory(category : name) : EEquipmentSlots {
		if (category == 'armor') {
			return EES_Armor;
		} else if (category == 'gloves') {
			return EES_Gloves;
		} else if (category == 'pants') {
			return EES_Pants;
		} else if (category == 'boots') {
			return EES_Boots;
		} else if (category == 'head') {
			return EES_Mask;
		} else if (category == 'hair') {
			return EES_Hair;
		} else {
			return EES_InvalidSlot;
		}
	}
	function CategoryBySlot(slot : EEquipmentSlots) : name {
		if (slot == EES_Armor) {
			return 'armor';
		} else if (slot == EES_Gloves) {
			return 'gloves';
		} else if (slot == EES_Pants) {
			return 'pants';
		} else if (slot == EES_Boots) {
			return 'boots';
		} else if (slot == EES_Mask) {
			return 'head';
		} else if (slot == EES_Hair) {
			return 'hair';
		} else {
			return 'UNKNOWN CATEGORY';
		}
	}
	function GetDefaultItemByCategory(category : name) : name {
		if (category == 'armor') {
			return 'Body torso medalion';
		} else if (category == 'gloves') {
			return 'Body palms 01';
		} else if (category == 'pants') {
			return 'Body underwear 01';
		} else if (category == 'boots') {
			return 'Body feet 01';
		} else {
			return 'UNKNOWN ITEM';
		}
	}
	function RemoveSavedItem(id : SItemUniqueId) {
		var inv  : CInventoryComponent;
		var category : name;
		inv = thePlayer.GetInventory();

		category = inv.GetItemCategory(id);
		NR_Debug("NR_UpdateRemoveMountedItem : " + category);

		geraltSavedItems[ SlotByCategory(category) ] = GetDefaultItemByCategory(category);
	}
	function UpdateSavedItem(id : SItemUniqueId) {
		var inv  : CInventoryComponent;
		var itemName, category : name;
		inv = thePlayer.GetInventory();

		if (!inv.IsIdValid(id))
			return;

		category = inv.GetItemCategory(id);
		itemName = inv.GetItemName(id);
		NR_Debug("UpdateSavedItem : " + itemName);
		if ( inv.IsItemMounted(id) && (category == 'armor' || category == 'gloves' 
			|| category == 'pants' || category == 'boots') )
		{
			inv.UnmountItem(id, true);
		}

		if (inStoryScene)
			return;

		geraltSavedItems[ SlotByCategory(category) ] = itemName;
	}
	function UnmountEquipment() {
		var inv  : CInventoryComponent;
		var ids  : array<SItemUniqueId>;
		var i    : int;
		var equippedOnSlot : EEquipmentSlots;

		inv = thePlayer.GetInventory();
		inv.GetAllItems(ids);
		NR_Debug("UnmountEquipment: inv = " + ids.Size());

		for (i = 0; i < ids.Size(); i += 1) {
			if ( !inv.IsItemMounted(ids[i]) )
				continue;

			equippedOnSlot = GetWitcherPlayer().GetItemSlot( ids[i] );
			NR_Debug("UnmountEquip: " + inv.GetItemName(ids[i]) + " slot = " + equippedOnSlot);

			if ( NR_GetWitcherReplacer().NR_IsSlotDenied(equippedOnSlot) ) {
				NR_GetWitcherReplacer().UnequipItemFromSlot( equippedOnSlot );
				//NR_Debug("Unequip denied item: " + NR_stringById(ids[i]));
			}

			if ( equippedOnSlot == EES_Armor || equippedOnSlot == EES_Gloves ||
				 equippedOnSlot == EES_Boots || equippedOnSlot == EES_Pants ||
				(inv.ItemHasTag(ids[i], 'Body') && StrStartsWith(NR_stringById(ids[i]), "Body")) )
			{
				UpdateSavedItem( ids[i] );
				NR_Debug("Unmount: " + NR_stringById(ids[i]));
			}
		}

		/*GetItemEquippedOnSlot( EES_Armor, item );
		if ( inv.IsIdValid(item) ) {
			inv.UnmountItem(item, true);
		}
		GetItemEquippedOnSlot( EES_Gloves, item );
		if ( inv.IsIdValid(item) ) {
			inv.UnmountItem(item, true);
		}
		GetItemEquippedOnSlot( EES_Pants, item );
		if ( inv.IsIdValid(item) ) {
			inv.UnmountItem(item, true);
		}
		GetItemEquippedOnSlot( EES_Boots, item );
		if ( inv.IsIdValid(item) ) {
			inv.UnmountItem(item, true);
		}*/
	}
	function UpdateAppearanceTemplate(templateName : String, slot : EEquipmentSlots, isDepotPath : bool) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                   i : int;
		var u16 : Uint16;
		var u8 : Int8;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			/* UNLOAD OLD if not empty */
			if (appearanceTemplates[slot] != "") {
				template = (CEntityTemplate)LoadResource( appearanceTemplates[slot], appearanceTemplateIsDepotPath[slot] );
				if (template) {
					appearanceComponent.ExcludeAppearanceTemplate(template);
					NR_Debug("EXCLUDE: template: " + appearanceTemplates[slot]);
				}
			}

			appearanceTemplates[slot] = templateName;
			appearanceTemplateIsDepotPath[slot] = isDepotPath;

			/* LOAD NEW if not empty AND if replacer is active */
			if (appearanceTemplates[slot] != "" && IsReplacerActive()) {
				template = (CEntityTemplate)LoadResource( appearanceTemplates[slot], appearanceTemplateIsDepotPath[slot] );
				if (template) {
					//template.coloringEntries[0].colorShift1.hue = u16;
					//template.coloringEntries[0].colorShift1.luminance = u8;
					appearanceComponent.IncludeAppearanceTemplate(template);
					NR_Debug("INCLUDE: template: " + appearanceTemplates[slot]);
				} else {
					NR_Debug("ERROR: can't load template: " + appearanceTemplates[slot]);
				}
			}
		} else {
			NR_Debug("ERROR: AppearanceComponent not found!");
		}
	}
	function LoadAppearanceTemplates(unloadTemplates : bool) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                   i : int;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			for (i = 0; i < appearanceTemplates.Size(); i += 1) {
				if (appearanceTemplates[i] == "")
					continue;

				template = (CEntityTemplate)LoadResource( appearanceTemplates[i], appearanceTemplateIsDepotPath[i] );
				if (template) {
					if (unloadTemplates)
						appearanceComponent.ExcludeAppearanceTemplate(template);
					else
						appearanceComponent.IncludeAppearanceTemplate(template);
				}
			}
		} else {
			NR_Debug("ERROR: AppearanceComponent not found!");
		}
	}
	function ResetAppearanceHeadHair() {
		var i : int;
		/* Set all slots to nothing, will unload if any template was loaded */
		for (i = 0; i < appearanceTemplates.Size(); i += 1) {
			if (appearanceTemplates[i] == "")
				continue;

			UpdateAppearanceTemplate("", i, false);
		}

		UpdateHead('head_0');                /* set default head */
		UpdateHair('Long Loose Hairstyle');  /* set default hair */
	}
	timer function NR_FixReplacer( delta : float, id : int ) {
		NR_Debug("NR_FixReplacer: Head = " + headName + ", hair name = " + hairstyleName + ", templatesN = " + IntToString(appearanceTemplates.Size()));
		UnmountEquipment();
		UpdateHead(headName);       /* set saved head */
		UpdateHair(hairstyleName);  /* set saved hair */
		LoadAppearanceTemplates(/*unloadTemplates*/ false);
		geraltDataSaved = true;
	}
	timer function NR_FixPlayer( delta : float, id : int ) {
		RestoreEquipment();
		RestoreHead();
		RestoreHair();
		LoadAppearanceTemplates(/*unloadTemplates*/ true);
		geraltDataSaved = false;
	}
}

function NR_GetPlayerManager() : NR_PlayerManager
{
	var nrManagerTemplate : CEntityTemplate;
	var nrManager         : NR_PlayerManager;
	nrManager = (NR_PlayerManager)theGame.GetEntityByTag('nr_player_manager'); //(NR_PlayerManager)EntityHandleGet( nrPlayerManagerHandle );

	if ( !nrManager ) {
		nrManagerTemplate = (CEntityTemplate)LoadResource("nr_player_manager");
		nrManager = (NR_PlayerManager)theGame.CreateEntity(nrManagerTemplate, thePlayer.GetWorldPosition(),,,,,PM_Persist);
		nrManager.AddTag('nr_player_manager');
		nrManager.CreateAttachment(thePlayer);
		nrManager.geraltSavedItems.Resize( EnumGetMax('EEquipmentSlots') + 1 );
		nrManager.appearanceTemplates.Resize( EnumGetMax('EEquipmentSlots') + 1 );
		nrManager.appearanceTemplateIsDepotPath.Resize( EnumGetMax('EEquipmentSlots') + 1 );
		//EntityHandleSet( nrPlayerManagerHandle, nrManager );

		NR_Debug("PlayerManager created!");
	} else {
		NR_Debug("PlayerManager found!");
		if ( !thePlayer.HasChildAttachment( nrManager ) )
			nrManager.CreateAttachment(thePlayer);
	}

	return nrManager;
}

exec function nrPlayer(playerName : String) {
	NR_ChangePlayer(playerName);
}

exec function nrLoad(templateName : String, slot : EEquipmentSlots, optional isDepotPath : bool) {
	if (isDepotPath)
		NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot, /*isDepotPath*/ true);
	else
		NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot, /*isDepotPath*/ false);
}
// nrLoad(dlc\ep1\data\items\bodyparts\geralt_items\trunk\common_light\armor_stand\t_02_mg__wedding_suit_armor_stand.w2ent, EES_Armor, true)
// nrLoad(dlc\bob\data\items\bodyparts\geralt_items\trunk\armor_vampire\armor_stand\q704_t_01a_mg__vampire_armor_stand.w2ent, EES_Armor, true)

exec function nrUnload(slot : EEquipmentSlots, optional isDepotPath : bool) {
	if (isDepotPath)
		NR_GetPlayerManager().UpdateAppearanceTemplate("", slot, /*isDepotPath*/ true);
	else
		NR_GetPlayerManager().UpdateAppearanceTemplate("", slot, /*isDepotPath*/ false);
}

exec function nrHead(headName : name) {
	NR_GetPlayerManager().UpdateHead(headName);
}

exec function nrHair(hairstyleName : name) {
	NR_GetPlayerManager().UpdateHair(hairstyleName);
}

exec function nrReset() {
	NR_GetPlayerManager().ResetAppearanceHeadHair();
}

/*exec function nrUpdate() {
	NR_UpdatePlayer();
}*/

exec function pc_reset()
{
	thePlayer.OnCombatActionEnd();
    thePlayer.OnCombatActionEndComplete();
    thePlayer.RaiseForceEvent('ForceIdle');
    thePlayer.GetRootAnimatedComponent().RaiseBehaviorForceEvent( 'ForceIdle' );
    thePlayer.ActionCancelAll();
    thePlayer.SetBIsCombatActionAllowed( true );
}

/*	var manager    : NR_PlayerManager;

	manager = NR_GetPlayerManager();
	manager.Update
}

function NR_UpdateHair(hairstyleName : name) {
	NR_GetPlayerManager().UpdateHair(hairstyleName);
}

function NR_UpdateAppearanceTemplate(templateName : String, slot : EEquipmentSlots, isDepotPath : bool, unloadTemplate : bool) {
	NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot, isDepotPath, unload);
}*/

/* CALL this function after any changes in replacer appearance */
/* The only case when it's not needed - if you call ChangePlayer after changes 
* NR_GetPlayerManager().OnPlayerSpawned(0.0, 0);

function NR_UpdatePlayer() {
	var manager    : NR_PlayerManager;
	manager = NR_GetPlayerManager();

	NR_GetPlayerManager().OnPlayerSpawned(0.0, 0);
}*/

function NR_ChangePlayer(playerName : String) {
	var manager    : NR_PlayerManager;

	manager = NR_GetPlayerManager();
	manager.playerChangeRequested = true;
	manager.AddTimer('OnPlayerSpawned', 0.3f, false, , , true);

	FactsAdd("NR_PlayerChangeRequested", 1);

	if (playerName == "Geralt") {
		theGame.ChangePlayer( "Geralt" );
		thePlayer.Debug_ReleaseCriticalStateSaveLocks();

	} else if (playerName == "Ciri") {
		theGame.ChangePlayer( "Ciri" );
		thePlayer.Debug_ReleaseCriticalStateSaveLocks();

	} else if (playerName == "nr_replacer_witcher") {
		theGame.ChangePlayer( "nr_replacer_witcher" );
		thePlayer.Debug_ReleaseCriticalStateSaveLocks();

	} else if (playerName == "nr_replacer_witcheress") {
		theGame.ChangePlayer( "nr_replacer_witcheress" );
		thePlayer.Debug_ReleaseCriticalStateSaveLocks();

	} else if (playerName == "nr_replacer_sorceress") {
		theGame.ChangePlayer( "nr_replacer_sorceress" );
		thePlayer.Debug_ReleaseCriticalStateSaveLocks();

	} else {
		NR_Notify("ERROR! unknown player name: " + playerName);
		//theGame.ChangePlayer( playerName );
		//thePlayer.Debug_ReleaseCriticalStateSaveLocks();
	}
}

exec function toApp(app : name) {
	thePlayer.ApplyAppearance(app);
}

/*
enum EEquipmentSlots
{
	EES_InvalidSlot, // 0
	EES_SilverSword, // 1
	EES_SteelSword,  // 2
	EES_Armor,       // 3   <- use EES_Armor as slot for main character template
	EES_Boots,       // 4
	EES_Pants,       // 5
	EES_Gloves,	     // 6
	EES_Petard1,     // 7
	EES_Petard2,     // 8
	EES_RangedWeapon,// 9
	EES_Quickslot1,  // 10
	EES_Quickslot2,  // 11
EES_Unused,          // 12
	EES_Hair,        // 13   <- use EES_Hair as slot for hair/head accessories
	EES_Potion1,     // 14
	EES_Potion2,     // 15
	EES_Mask,        // 16
	EES_Bolt,        // 17
...
}
*/

// nrPlayer("nr_replacer_witcher");        <- console
// NR_ChangePlayer("nr_replacer_witcher"); <- scripts/quest/scene block
exec function toGeralt() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		NR_ChangePlayer("Geralt");
	}
}
exec function toCiri() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		NR_ChangePlayer("Ciri");
	}
}

exec function toEskel() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_eskel');
		manager.UpdateHair('NR Eskel Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcher");
	}
}

exec function toLambert() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_lambert');
		manager.UpdateHair('NR Lambert Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\secondary_npc\lambert\body_01_ma__lambert.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcher"); // change player type in the last queue
	}
}

exec function toTriss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss');
		manager.UpdateHair('NR Triss Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\triss\body_01_wa__triss.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcheress"); // change player type in the last queue
	}
}

exec function toYen() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\pendant_01_wa__yennefer.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\b_03_wa_yennefer.w2ent", /*slot*/ EES_Hair, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\l_02_wa__yennefer.w2ent", /*slot*/ EES_Pants, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcheress"); // change player type in the last queue
	}
}

exec function toEmhyr() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_emhyr');
		manager.UpdateHair('NR Emhyr Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\emhyr\body_01_ma__emhyr.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\common\man_average\body\g_01_ma__body.w2ent", /*slot*/ EES_Gloves, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcher"); // change player type in the last queue
	}
}

// removefact(q705_yen_first_met)
// playScene(dlc\bob\data\quests\main_quests\quest_files\q705_epilog\scenes\q705_20a_yen_visit_vineyard.w2scene)

exec function toYenJoke2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\trunk\bare\t_01_mg__body_medalion.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\gloves\bare\g_01_mg__body.w2ent", /*slot*/ EES_Gloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\legs\casual_non_combat\l_02_mg__casual_skellige_pants.w2ent", /*slot*/ EES_Pants, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\shoes\common_heavy\s_02_mg__common_heavy_lvl4.w2ent", /*slot*/ EES_Boots, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcher"); // change player type in the last queue
	}
}

// naked Geralt paths!
exec function toYenJoke3() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\trunk\bare\t_01_mg__body_medalion.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\gloves\bare\g_01_mg__body.w2ent", /*slot*/ EES_Gloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\legs\bare\l_01_mg__body_underwear.w2ent", /*slot*/ EES_Pants, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\shoes\bare\s_01_mg__body.w2ent", /*slot*/ EES_Boots, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcher"); // change player type in the last queue
	}
}

exec function toTrissDLC() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss_dlc');
		manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\b_01_wa__triss_dlc.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\c_01_wa__triss_dlc.w2ent", /*slot*/ EES_Hair, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcheress"); // change player type in the last queue
	}
}

exec function toYenn() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\pendant_01_wa__yennefer.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\b_03_wa_yennefer.w2ent", /*slot*/ EES_Hair, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\l_02_wa__yennefer.w2ent", /*slot*/ EES_Pants, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_sorceress"); // change player type in the last queue
	}
}

exec function toTrisss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss_dlc');
		manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\b_01_wa__triss_dlc.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\c_01_wa__triss_dlc.w2ent", /*slot*/ EES_Hair, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_sorceress"); // change player type in the last queue
	}
}

exec function toRosa() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAppearanceHeadHair();
		manager.UpdateHead('nr_head_rosa');
		manager.UpdateHair('NR Rosa Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent", /*slot*/ EES_Unused, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ EES_Armor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ EES_Gloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ EES_Pants, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ EES_Boots, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*slot*/ EES_Quickslot1, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*slot*/ EES_Quickslot2, /*isDepotPath*/ true);
		NR_ChangePlayer("nr_replacer_witcheress"); // change player type in the last queue
	}
}

exec function toPos0() {
	thePlayer.TeleportWithRotation(Vector(527.0978, 71.24042, 34.09809), EulerAngles(0.0, 35.83441, 0.0));
}
exec function toPos1() {
	thePlayer.TeleportWithRotation(Vector(519.2852, 73.1901, 33.33126), EulerAngles(0.0, 265.1475, 0.0));
}
function playSceneF(path : string, optional input : string) {
	var scene : CStoryScene;
    var null: String;

    if (input == null) {
		input = "Input";
	}
	
    // -> SET SCENE PATH
    scene = (CStoryScene)LoadResource(path, true);
    theGame.GetStorySceneSystem().PlayScene(scene, input);
}
exec function toScene0() {
	playSceneF("quests\prologue\quest_files\q001_beggining\scenes\q001_5_wake_up.w2scene");
}
exec function toScene1() {
	playSceneF("quests\sidequests\skellige\quest_files\sq204_forest_spirit\scenes\sq204_03b_cs_leshy_appear.w2scene");
}
exec function yensc(optional input : String) {
	playSceneF("dlc\bob\data\quests\main_quests\quest_files\q705_epilog\scenes\q705_20a_yen_visit_vineyard.w2scene");
}
exec function tosc(path : String, optional input : String) {
	playSceneF(path, input);
}
/*exec function hackClass() {
	var template : CEntityTemplate;
	var entity   : CEntity;
	var   npc : CNewNPC;
	var myClass : NR_ReplacerInventory;

	template = (CEntityTemplate) LoadResource( "triss" );
	if (template) {
		template.entityClass = 'NR_ReplacerInventory';
		entity = theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
		npc = (CNewNPC) entity;
		myClass = (NR_ReplacerInventory) npc;
		if (myClass) {
			NR_Debug("YEAH IT FUCKING WORKS!" + myClass);
		} else if (npc) {
			NR_Debug("No it doesn't work..." + npc);
		} else {
			NR_Debug("What the hell???");
		}
	}
}*/