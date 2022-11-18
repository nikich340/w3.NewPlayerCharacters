function NR_Notify(message : String, optional duration : float)
{
	if (duration < 1.f || duration > 10.f)
		duration = 3.f;
    theGame.GetGuiManager().ShowNotification(message, duration * 1000.f);
    LogChannel('NR_MOD', message);
}
quest function NR_Notify_Quest(message : String, optional duration : float) {
	 NR_Notify(message, duration);
}

function NRD(message : String)
{
    LogChannel('NR_DEBUG', message);
}

function NRE(message : String)
{
    theGame.GetGuiManager().ShowNotification(message, 3000.0);
    LogChannel('NR_ERROR', message);
}

function NR_stringById(itemId : SItemUniqueId) : String {
	var inv : CInventoryComponent;
	inv = thePlayer.GetInventory();

	if ( inv.IsIdValid(itemId) )
		return NameToString( inv.GetItemName(itemId) );
	else
		return "<invalid>";
}

/* G - geralt slot, R - replacer slot */
enum ENR_AppearanceSlots {
	ENR_GSlotUnknown,
	ENR_GSlotHair,
	ENR_GSlotHead,
	ENR_GSlotArmor,
	ENR_GSlotGloves,
	ENR_GSlotPants,
	ENR_GSlotBoots,

	ENR_RSlotBody,
	ENR_RSlotTorso,
	ENR_RSlotDress,
	ENR_RSlotArms,
	ENR_RSlotGloves,
	ENR_RSlotLegs,
	ENR_RSlotShoes,
	ENR_RSlotMisc1,
	ENR_RSlotMisc2,
	ENR_RSlotMisc3,
	ENR_RSlotMisc4,
	ENR_RSlotMisc5,
	ENR_RSlotMisc6,
	ENR_RSlotMisc7,
	ENR_RSlotMisc8,
	ENR_RSlotMisc9,
	ENR_RSlotMisc10,
	ENR_RSlotMisc11,
	ENR_RSlotMisc12,
	ENR_RSlotMisc13,
	ENR_RSlotMisc14,
	ENR_RSlotMisc15
}

enum ENR_PlayerType {
	ENR_PlayerUnknown, 		// 0
	ENR_PlayerGeralt, 		// 1
	ENR_PlayerCiri, 		// 2
	ENR_PlayerWitcher, 		// 3
	ENR_PlayerWitcheress,	// 4
	ENR_PlayerSorceress		// 5
}

class NR_PlayerManager extends CPeristentEntity {
	public saved var m_savedPlayerType : ENR_PlayerType;
	default          m_savedPlayerType = ENR_PlayerGeralt;

	public saved var m_headName : name;
	public saved var m_hairstyleName : name;
	public saved var           m_appearanceTemplates : array<String>;
	public saved var m_appearanceTemplateIsDepotPath : array<bool>;

	default m_headName = 'head_0';
	default m_hairstyleName = 'Long Loose Hairstyle';

	public saved var m_geraltSavedItems  : array<name>;
	public saved var m_geraltDataSaved : Bool;
	default          m_geraltDataSaved = false;

	public var stringsStorage : NR_LocalizedStringStorage;
	public var inStoryScene : Bool;
	default    inStoryScene = false;

	public var playerChangeRequested : Bool;
	default    playerChangeRequested = false;

	//private var sceneChoices : array<int>;
	//private var  currentChoice : int;
	//default currentChoice = 0;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var template : CEntityTemplate;

		//spawnedTime = theGame.GetEngineTimeAsSeconds();
		NRD("wasSpawned! this: " + this);
		template = (CEntityTemplate) LoadResource("nr_strings_storage");
		stringsStorage = (NR_LocalizedStringStorage)theGame.CreateEntity(template, thePlayer.GetWorldPosition());
		if (!stringsStorage) {
			NRE("!stringsStorage");
		}

		AddTimer('OnPlayerSpawned', 0.2f);
		super.OnSpawned( spawnData );
	}

	function OnDialogOptionSelected(index : int) {
		NR_Notify("OnDialogOptionSelected: " + index);
	}

	function SetDefaultAppearance(type : ENR_PlayerType) {
		switch (type) {
			case ENR_PlayerWitcher:
				ResetAllAppearanceHeadHair();
				UpdateHead('nr_head_eskel');
				UpdateHair('NR Eskel Hairstyle');
				UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
				break;
			case ENR_PlayerWitcheress:
				ResetAllAppearanceHeadHair();
				UpdateHead('nr_head_rosa');
				UpdateHair('NR Rosa Hairstyle');
				UpdateAppearanceTemplate(/*path*/ "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
				//UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc2, /*isDepotPath*/ true);
		
			case ENR_PlayerSorceress:
				ResetAllAppearanceHeadHair();
				UpdateHead('nr_head_yennefer');
				UpdateHair('NR Yennefer Hairstyle');
				UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\pendant_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
				break;
			default:
				break;
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
	function GetCurrentPlayerType() : ENR_PlayerType {
		var replacer : NR_ReplacerWitcher;

		replacer = NR_GetWitcherReplacer();
		if ( replacer ) {
			return replacer.GetReplacerType();
		} else if ( (W3ReplacerCiri)thePlayer ) {
			return ENR_PlayerCiri;
		} else {
			return ENR_PlayerGeralt;
		}
	}
	public function IsReplacerActive() : Bool {
		var playerType : ENR_PlayerType;

		playerType = GetCurrentPlayerType();
		return (playerType != ENR_PlayerGeralt && playerType != ENR_PlayerCiri);
	}

	public function IsFemale() : Bool {
		return IsFemaleType(m_savedPlayerType);
	}

	public function IsFemaleType(playerType : ENR_PlayerType) : Bool {
		return playerType != ENR_PlayerGeralt && playerType != ENR_PlayerWitcher;
	}

	timer function OnPlayerSpawned( delta : float, id : int ) {
		var 				i : int;
		var currentPlayerType : ENR_PlayerType;

		currentPlayerType = GetCurrentPlayerType();
		NRD("Cur player: " + currentPlayerType + ", saved player: " + m_savedPlayerType);

		if ( !thePlayer.HasChildAttachment( this ) )
			CreateAttachment(thePlayer);

		if ( currentPlayerType != m_savedPlayerType ) {
			// FROM GERALT
			if ( m_savedPlayerType == ENR_PlayerGeralt ) {
				// TO CUSTOM PLAYER
				//if ( currentPlayerType != "Geralt" ) {
				LoadPlayerData();
				///NR_FixReplacer( 0.0, 0 );
				//}
			// FROM REPLACER
			} else {
				// TO GERALT & have saved items
				if ( currentPlayerType == ENR_PlayerGeralt && m_geraltDataSaved ) {
					// OK, we asked for it - restore mounted items
					if ( FactsQuerySum("nr_player_change_requested") > 0 ) {
						NR_FixPlayer( 0.0, 0 );
					// BAD, it was auto-reset to Geralt after World change(?)
					} else {
						NR_Notify("BAD! Player change to Geralt without request!");
						NR_ChangePlayer( m_savedPlayerType );
						return;
					}
				}
				// TO ANOTHER REPLACER
				///} else if ( currentPlayerType != "Geralt" ) {
				///	NR_FixReplacer( 0.0, 0 );
				///}
			}
		}
		// WAS CUSTOM REPLACER - Reset appearance templates always
		if ( m_savedPlayerType != ENR_PlayerGeralt && m_savedPlayerType != ENR_PlayerCiri ) {
			LoadAppearanceTemplates(/*unloadTemplates*/ true);
		}
		// CUSTOM REPLACER - APPLY FIX ALWAYS
		if ( IsReplacerActive() ) {
			NR_FixReplacer( 0.0, 0 );
		}
		FactsRemove("nr_player_change_requested");
		m_savedPlayerType = currentPlayerType;

		// update facts
		FactsRemove("nr_player_female");
		FactsRemove("nr_player_type");
		
		FactsAdd("nr_player_type", (int)m_savedPlayerType);
		if (IsFemaleType(m_savedPlayerType)) {
			FactsAdd("nr_player_female", 1);
		}
	}
	function SetInStoryScene(val : Bool) {
		inStoryScene = val;
	}
	function NR_DebugPrintData() {
		var i : int;
		for (i = 0; i < m_geraltSavedItems.Size(); i += 1) {
			NRD("NR_SavedEquipment[" + ((ENR_AppearanceSlots)i) + "]" + m_geraltSavedItems[i]);
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
		m_geraltSavedItems[ENR_GSlotHead] = headManager.GetCurHeadName();

		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'hair' );
		
		for( i = 0; i < ids.Size(); i += 1 )
		{
			if (inv.IsItemMounted(ids[i])) {
				m_geraltSavedItems[ENR_GSlotHair] = inv.GetItemName(ids[i]);
				break;
			}
		}
	}
	function UpdateHead(newHeadName : name) {
		var headManager : CHeadManagerComponent;

		m_headName = newHeadName;
		if (!IsReplacerActive())
			return;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		/*if ( headManager.GetCurm_headName() != m_headName ) {
			NR_geraltSavedm_headName = headManager.GetCurm_headName();
		}*/
		NRD("Head Set: " + m_headName);
		thePlayer.RememberCustomHead( m_headName );
		headManager.BlockGrowing( true );
		headManager.SetCustomHead( m_headName );
	}
	function UpdateHair(newHairstyleName : name) {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var ret : Bool;

		m_hairstyleName = newHairstyleName;
		if (!IsReplacerActive())
			return;

		inv = thePlayer.GetInventory();
		if (!inv) {
			NRD("Restore head: NULL!");
		}
		ids = inv.GetItemsByCategory( 'hair' );
		
		for( i = 0; i < ids.Size(); i += 1 )
		{
			inv.RemoveItem(ids[i], 1);	
		}

		NRD("Hair Set: " + m_hairstyleName);
		ids = inv.AddAnItem( m_hairstyleName );
		ret = inv.MountItem(ids[0]);
		NRD("Hair Mount: " + ret);
	}
	function RestoreHead() {
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));

		if (!headManager) {
			NRD("Restore head: NULL!");
			return;
		}

		thePlayer.ClearRememberedCustomHead();
		headManager.BlockGrowing( false );
		//headManager.RemoveCustomHead();
		headManager.SetCustomHead( m_geraltSavedItems[ENR_GSlotHead] );
		NRD("Restore head: " + m_geraltSavedItems[ENR_GSlotHead]);
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

		NRD("Restore hair: " + m_geraltSavedItems[ENR_GSlotHair]);
		ids = inv.AddAnItem( m_geraltSavedItems[ENR_GSlotHair] );
		ret = inv.MountItem(ids[0]);
		NRD("Hair RMount: " + ret + ", " + inv.IsIdValid(ids[0]) + ", "  + inv.GetItemName(ids[0]));
	}
	function RestoreEquipment() {
		var inv  : CInventoryComponent;
		var i : int;
		var id : SItemUniqueId;
		inv = thePlayer.GetInventory();

		for ( i = ENR_GSlotArmor; i <= ENR_GSlotBoots; i += 1 ) {
			NRD("RestoreEquipment[" + (ENR_AppearanceSlots)i + "]" + m_geraltSavedItems[i]);
			id = inv.GetItemId( m_geraltSavedItems[i] );
			if ( inv.IsIdValid( id ) ) {
				inv.MountItem( id );
			} else {
				NRD("Unable to mount gerlat item: " + m_geraltSavedItems[i]);
				id = inv.GetItemId( GetDefaultItemByCategory(CategoryByENRSlot((ENR_AppearanceSlots) i)) );
				if ( inv.IsIdValid( id ) )
					inv.MountItem( id );
			}
		}
	}
	public function ENRSlotByCategory(category : name) : ENR_AppearanceSlots {
		if (category == 'armor') {
			return ENR_GSlotArmor;
		} else if (category == 'gloves') {
			return ENR_GSlotGloves;
		} else if (category == 'pants') {
			return ENR_GSlotPants;
		} else if (category == 'boots') {
			return ENR_GSlotBoots;
		} else if (category == 'head') {
			return ENR_GSlotHead;
		} else if (category == 'hair') {
			return ENR_GSlotHair;
		} else {
			return ENR_GSlotUnknown;
		}
	}
	public function CategoryByENRSlot(slot : ENR_AppearanceSlots) : name {
		if (slot == ENR_GSlotArmor) {
			return 'armor';
		} else if (slot == ENR_GSlotGloves) {
			return 'gloves';
		} else if (slot == ENR_GSlotPants) {
			return 'pants';
		} else if (slot == ENR_GSlotBoots) {
			return 'boots';
		} else if (slot == ENR_GSlotHead) {
			return 'head';
		} else if (slot == ENR_GSlotHair) {
			return 'hair';
		} else {
			return 'UNKNOWN CATEGORY';
		}
	}
	public function EEquipmentSlotToENRSlot(slot : EEquipmentSlots) : ENR_AppearanceSlots {
		if (slot == EES_Armor) {
			return ENR_GSlotArmor;
		} else if (slot == EES_Gloves) {
			return ENR_GSlotGloves;
		} else if (slot == EES_Pants) {
			return ENR_GSlotPants;
		} else if (slot == EES_Boots) {
			return ENR_GSlotBoots;
		} else {
			return ENR_GSlotUnknown;
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
		NRD("NR_UpdateRemoveMountedItem : " + category);

		m_geraltSavedItems[ ENRSlotByCategory(category) ] = GetDefaultItemByCategory(category);
	}
	function UpdateSavedItem(id : SItemUniqueId) {
		var inv  : CInventoryComponent;
		var itemName, category : name;
		inv = thePlayer.GetInventory();

		if (!inv.IsIdValid(id))
			return;

		category = inv.GetItemCategory(id);
		itemName = inv.GetItemName(id);
		NRD("UpdateSavedItem : " + itemName);
		if ( inv.IsItemMounted(id) && (category == 'armor' || category == 'gloves' 
			|| category == 'pants' || category == 'boots') )
		{
			inv.UnmountItem(id, true);
		}

		if (inStoryScene)
			return;

		m_geraltSavedItems[ ENRSlotByCategory(category) ] = itemName;
	}
	function UnmountEquipment() {
		var inv  : CInventoryComponent;
		var ids  : array<SItemUniqueId>;
		var i    : int;
		var equippedOnSlot : EEquipmentSlots;
		var appearanceSlot : ENR_AppearanceSlots;

		inv = thePlayer.GetInventory();
		inv.GetAllItems(ids);
		NRD("UnmountEquipment: inv = " + ids.Size());

		for (i = 0; i < ids.Size(); i += 1) {
			if ( !inv.IsItemMounted(ids[i]) )
				continue;

			equippedOnSlot = GetWitcherPlayer().GetItemSlot( ids[i] );
			NRD("UnmountEquip: " + inv.GetItemName(ids[i]) + " slot = " + equippedOnSlot);

			if ( NR_GetWitcherReplacer().NR_IsSlotDenied(equippedOnSlot) ) {
				NR_GetWitcherReplacer().UnequipItemFromSlot( equippedOnSlot );
				//NRD("Unequip denied item: " + NR_stringById(ids[i]));
			}

			appearanceSlot = EEquipmentSlotToENRSlot( equippedOnSlot );
			if ( appearanceSlot == ENR_GSlotArmor || appearanceSlot == ENR_GSlotGloves ||
				 appearanceSlot == ENR_GSlotBoots || appearanceSlot == ENR_GSlotPants ||
				(inv.ItemHasTag(ids[i], 'Body') && StrStartsWith(NR_stringById(ids[i]), "Body")) )
			{
				UpdateSavedItem( ids[i] );
				NRD("Unmount: " + NR_stringById(ids[i]));
			}
		}
	}
	function UpdateAppearanceTemplate(templateName : String, slot : ENR_AppearanceSlots, isDepotPath : bool) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                   i : int;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			/* UNLOAD OLD if not empty */
			if (m_appearanceTemplates[slot] != "") {
				template = (CEntityTemplate)LoadResource( m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot] );
				if (template) {
					appearanceComponent.ExcludeAppearanceTemplate(template);
					NRD("EXCLUDE: template: " + m_appearanceTemplates[slot]);
				}
			}

			m_appearanceTemplates[slot] = templateName;
			m_appearanceTemplateIsDepotPath[slot] = isDepotPath;

			/* LOAD NEW if not empty AND if replacer is active */
			if (m_appearanceTemplates[slot] != "" && IsReplacerActive()) {
				template = (CEntityTemplate)LoadResource( m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot] );
				if (template) {
					//template.coloringEntries[0].colorShift1.hue = u16;
					//template.coloringEntries[0].colorShift1.luminance = u8;
					appearanceComponent.IncludeAppearanceTemplate(template);
					NRD("INCLUDE: template: " + m_appearanceTemplates[slot]);
				} else {
					NRD("ERROR: can't load template: " + m_appearanceTemplates[slot]);
				}
			}
		} else {
			NRD("ERROR: AppearanceComponent not found!");
		}
	}
	function LoadAppearanceTemplates(unloadTemplates : bool) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                i, j : int;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			for (i = 0; i < m_appearanceTemplates.Size(); i += 1) {
				if (m_appearanceTemplates[i] == "")
					continue;

				NRD("Loadm_appearanceTemplates[" + i + "] = " + m_appearanceTemplates[i] + ", unload = " + unloadTemplates);
			
				template = (CEntityTemplate)LoadResource( m_appearanceTemplates[i], m_appearanceTemplateIsDepotPath[i] );
				if (template) {
					if (unloadTemplates)
						appearanceComponent.ExcludeAppearanceTemplate(template);
					else
						appearanceComponent.IncludeAppearanceTemplate(template);
				} else {
					NRD("Loadm_appearanceTemplates[" + i + "] ERROR template!");
				}
			}
		} else {
			NRD("ERROR: AppearanceComponent not found!");
		}
	}
	function ResetAllAppearanceHeadHair() {
		var i : int;
		/* Set all slots to nothing, will unload if any template was loaded */
		for (i = (int)ENR_RSlotBody; i < m_appearanceTemplates.Size(); i += 1) {
			if (m_appearanceTemplates[i] == "")
				continue;

			UpdateAppearanceTemplate("", i, false);
		}

		UpdateHead('head_0');                /* set default head */
		UpdateHair('Long Loose Hairstyle');  /* set default hair */
	}
	timer function NR_FixReplacer( delta : float, id : int ) {
		var witcher : NR_ReplacerWitcher;
		// change displayName hack
		witcher = NR_GetWitcherReplacer();
		if (stringsStorage) {
			//witcher.displayName = stringsStorage.GetLocalizedStringByKey(witcher.replacerName);
		} else {
			NRE("NR_FixReplacer: !stringsStorage");
		}

		NRD("NR_FixReplacer: Head = " + m_headName + ", hair name = " + m_hairstyleName + ", templatesN = " + IntToString(m_appearanceTemplates.Size()));
		UnmountEquipment();
		UpdateHead(m_headName);       /* set saved head */
		UpdateHair(m_hairstyleName);  /* set saved hair */
		LoadAppearanceTemplates(/*unloadTemplates*/ false);
		m_geraltDataSaved = true;
	}
	timer function NR_FixPlayer( delta : float, id : int ) {
		RestoreEquipment();
		RestoreHead();
		RestoreHair();
		LoadAppearanceTemplates(/*unloadTemplates*/ true);
		m_geraltDataSaved = false;
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
		nrManager.m_geraltSavedItems.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		nrManager.m_appearanceTemplates.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		nrManager.m_appearanceTemplateIsDepotPath.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		//EntityHandleSet( nrPlayerManagerHandle, nrManager );

		NRD("PlayerManager created!");
	} else {
		NRD("PlayerManager found!");
		if ( !thePlayer.HasChildAttachment( nrManager ) )
			nrManager.CreateAttachment(thePlayer);
	}

	return nrManager;
}

exec function nrPlayer(playerType : ENR_PlayerType) {
	NR_ChangePlayer(playerType);
}

exec function nrLoad(templateName : String, slot : ENR_AppearanceSlots, optional isDepotPath : bool) {
	if (isDepotPath)
		NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot, /*isDepotPath*/ true);
	else
		NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot, /*isDepotPath*/ false);
}
// nrLoad(dlc\ep1\data\items\bodyparts\geralt_items\trunk\common_light\armor_stand\t_02_mg__wedding_suit_armor_stand.w2ent, ENR_GSlotArmor, true)
// nrLoad(dlc\bob\data\items\bodyparts\geralt_items\trunk\armor_vampire\armor_stand\q704_t_01a_mg__vampire_armor_stand.w2ent, ENR_GSlotArmor, true)

exec function nrUnload(slot : ENR_AppearanceSlots, optional isDepotPath : bool) {
	if (isDepotPath)
		NR_GetPlayerManager().UpdateAppearanceTemplate("", slot, /*isDepotPath*/ true);
	else
		NR_GetPlayerManager().UpdateAppearanceTemplate("", slot, /*isDepotPath*/ false);
}

exec function nrHead(m_headName : name) {
	NR_GetPlayerManager().UpdateHead(m_headName);
}

exec function nrHair(m_hairstyleName : name) {
	NR_GetPlayerManager().UpdateHair(m_hairstyleName);
}

exec function nrReset() {
	NR_GetPlayerManager().ResetAllAppearanceHeadHair();
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

function NR_UpdateHair(m_hairstyleName : name) {
	NR_GetPlayerManager().UpdateHair(m_hairstyleName);
}

function NR_UpdateAppearanceTemplate(templateName : String, slot : ENR_AppearanceSlots, isDepotPath : bool, unloadTemplate : bool) {
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

function NR_ChangePlayer(playerType : ENR_PlayerType) {
	var manager    : NR_PlayerManager;

	manager = NR_GetPlayerManager();
	manager.playerChangeRequested = true;
	manager.AddTimer('OnPlayerSpawned', 0.3f, false, , , true);

	FactsAdd("nr_player_change_requested", 1);

	if (playerType == ENR_PlayerGeralt) {
		theGame.ChangePlayer( "Geralt" );
	} else if (playerType == ENR_PlayerCiri) {
		theGame.ChangePlayer( "Ciri" );
	} else if (playerType == ENR_PlayerWitcher) {
		theGame.ChangePlayer( "nr_replacer_witcher" );
	} else if (playerType == ENR_PlayerWitcheress) {
		theGame.ChangePlayer( "nr_replacer_witcheress" );
	} else if (playerType == ENR_PlayerSorceress) {
		theGame.ChangePlayer( "nr_replacer_sorceress" );
	} else {
		NR_Notify("ERROR! Unknown player type: " + playerType);
		return;
	}
	thePlayer.abilityManager.RestoreStat(BCS_Vitality);
	thePlayer.Debug_ReleaseCriticalStateSaveLocks();
}

// nrPlayer("nr_replacer_witcher");        <- console
// NR_ChangePlayer("nr_replacer_witcher"); <- scripts/quest/scene block
exec function toGeralt() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		NR_ChangePlayer(ENR_PlayerGeralt);
	}
}
exec function toCiri() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		NR_ChangePlayer(ENR_PlayerCiri);
	}
}

exec function toEskel() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_eskel');
		manager.UpdateHair('NR Eskel Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher);
	}
}

exec function toLambert() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_lambert');
		manager.UpdateHair('NR Lambert Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\secondary_npc\lambert\body_01_ma__lambert.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

exec function toTriss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss');
		manager.UpdateHair('NR Triss Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\triss\body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toYen() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\pendant_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toEmhyr() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_emhyr');
		manager.UpdateHair('NR Emhyr Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\emhyr\body_01_ma__emhyr.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\common\man_average\body\g_01_ma__body.w2ent", /*slot*/ ENR_RSlotGloves, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

// removefact(q705_yen_first_met)
// playScene(dlc\bob\data\quests\main_quests\quest_files\q705_epilog\scenes\q705_20a_yen_visit_vineyard.w2scene)

exec function toYenJoke2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\trunk\bare\t_01_mg__body_medalion.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\gloves\bare\g_01_mg__body.w2ent", /*slot*/ ENR_RSlotGloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\legs\casual_non_combat\l_02_mg__casual_skellige_pants.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\shoes\common_heavy\s_02_mg__common_heavy_lvl4.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

// naked Geralt paths!
exec function toYenJoke3() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\trunk\bare\t_01_mg__body_medalion.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\gloves\bare\g_01_mg__body.w2ent", /*slot*/ ENR_RSlotGloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\legs\bare\l_01_mg__body_underwear.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items\bodyparts\geralt_items\shoes\bare\s_01_mg__body.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

exec function toTrissDLC() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss_dlc');
		manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\b_01_wa__triss_dlc.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\c_01_wa__triss_dlc.w2ent", /*slot*/ ENR_GSlotHair, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toYenn() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.UpdateHair('NR Yennefer Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\pendant_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\yennefer\l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}

exec function toTrisss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss_dlc');
		manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\b_01_wa__triss_dlc.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlc6\data\characters\models\main_npc\triss\c_01_wa__triss_dlc.w2ent", /*slot*/ ENR_GSlotHair, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}
exec function toTrisss2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss');
		manager.UpdateHair('NR Triss Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters\models\main_npc\triss\body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}

exec function toRosa() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_rosa');
		manager.UpdateHair('NR Rosa Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/nr_rosa_body_test.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc2, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
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
			NRD("YEAH IT FUCKING WORKS!" + myClass);
		} else if (npc) {
			NRD("No it doesn't work..." + npc);
		} else {
			NRD("What the hell???");
		}
	}
}*/