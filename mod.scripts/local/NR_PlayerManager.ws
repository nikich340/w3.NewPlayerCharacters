/* G - geralt slot, R - replacer slot */
enum ENR_AppearanceSlots {
    ENR_GSlotUnknown,
    ENR_GSlotHair,
    ENR_GSlotHead,
    ENR_GSlotArmor,
    ENR_GSlotGloves,
    ENR_GSlotPants,
    ENR_GSlotBoots,

    ENR_RSlotHair,
    ENR_RSlotBody,
    ENR_RSlotTorso,
    ENR_RSlotArms,
    ENR_RSlotGloves,
    ENR_RSlotDress,
    ENR_RSlotLegs,
    ENR_RSlotShoes,
    ENR_RSlotMisc
}

enum ENR_PlayerType {
	ENR_PlayerUnknown, 		// 0
	ENR_PlayerGeralt, 		// 1
	ENR_PlayerCiri, 		// 2
	ENR_PlayerWitcher, 		// 3
	ENR_PlayerWitcheress,	// 4
	ENR_PlayerSorceress		// 5
}

function NR_Notify(message : String, optional seconds : float)
{
	if (seconds < 1.f)
		seconds = 3.f;
    theGame.GetGuiManager().ShowNotification(message, seconds * 1000.f, false);
    NRD(message);
}
quest function NR_Notify_Quest(message : String, optional seconds : float) {
	NR_Notify(message, seconds);
}

function NRD(message : String)
{
    LogChannel('NR_DEBUG', "(" + FloatToStringPrec(theGame.GetEngineTimeAsSeconds(), 3) + "): " + message);
}

function NRE(message : String)
{
    //theGame.GetGuiManager().ShowNotification(message, 5000.0);
    LogChannel('NR_ERROR', "(" + FloatToStringPrec(theGame.GetEngineTimeAsSeconds(), 3) + "): " + message);
}

function NR_stringByItemUID(itemId : SItemUniqueId) : String {
	var inv : CInventoryComponent;
	inv = thePlayer.GetInventory();

	if ( inv.IsIdValid(itemId) )
		return NameToString( inv.GetItemName(itemId) );
	else
		return "<invalid>";
}

class NR_AppearanceSet {
	public var headName : name;
	public var appearanceTemplates : array<String>;
	public var appearanceTemplateIsDepotPath : array<bool>;
	public var appearanceItems : array<String>;
	public var appearanceItemIsDepotPath : array<bool>;
}

statemachine class NR_PlayerManager {
	protected saved var m_savedPlayerType : ENR_PlayerType;
	default          m_savedPlayerType = ENR_PlayerGeralt;

	protected saved var 		m_headName 	: name;
	//protected saved var m_hairstyleName : name;
	public saved var           m_appearanceTemplates : array<String>;
	public saved var    m_appearanceTemplateIsLoaded : array<bool>;
	public saved var m_appearanceTemplateIsDepotPath : array<bool>;
	public saved var           	   m_appearanceItems : array<String>;
	public saved var 	 m_appearanceItemIsDepotPath : array<bool>;
	public saved var 				m_appearanceSets : array<NR_AppearanceSet>;


	protected var  					m_showAppearanceInfo : bool;
	protected var  					   m_headPreviewName : name;
	protected var    		m_appearancePreviewTemplates : array<String>;
	protected var    			m_appearancePreviewItems : array<String>;
	default m_showAppearanceInfo = false;

	protected saved	var m_magicDataMaps : array<NR_Map>;
	const 			var ST_Universal	: int;
	default 			ST_Universal 	= 5; // EnumGetMax(ESignType); 

	default m_headPreviewName = '';
	default 	   m_headName = 'head_0';
	//default m_hairstyleName = 'Long Loose Hairstyle';

	protected saved var m_geraltSavedItems  : array<name>;
	protected saved var m_geraltDataSaved : Bool;
	default          m_geraltDataSaved = false;

	protected var m_sceneSelector 	: NR_SceneSelector;
	protected var stringsStorage 	: NR_LocalizedStringStorage;
	protected var inStoryScene 		: Bool;
	default    inStoryScene 		= false;	

	protected var m_playerChangeRequested 	: Bool;
	default    m_playerChangeRequested 		= false;

	// once is called after entity created //
	public function Init() {
		m_geraltSavedItems.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		m_appearanceTemplates.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		m_appearanceTemplateIsLoaded.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		m_appearanceTemplateIsDepotPath.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
	}

	// run on every game load
	public latent function OnStarted() {
		var template : CEntityTemplate;

		NRD("OnStarted: " + this);

		// scene stuff //
		m_appearancePreviewTemplates.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		//m_appearanceTemplatesPreviewTemp.Resize( EnumGetMax('ENR_AppearanceSlots') + 1 );
		template = (CEntityTemplate)LoadResourceAsync("nr_scene_selector");
		if (!template) {
			NRE("!m_sceneSelector template");
		}
		m_sceneSelector = (NR_SceneSelector)theGame.CreateEntity(template, thePlayer.GetWorldPosition());
		NRD("OnSpawned: m_sceneSelector loaded.");
		if ( !m_sceneSelector ) {
			NRE("!m_sceneSelector");
		}

		template = (CEntityTemplate)LoadResource("nr_strings_storage");
		stringsStorage = (NR_LocalizedStringStorage)theGame.CreateEntity(template, thePlayer.GetWorldPosition());
		NRD("OnSpawned: stringsStorage loaded.");
		if (!stringsStorage) {
			NRE("!stringsStorage");
		}

		//GotoState('PlayerChange'); -> in replacers.OnSpawned()
	}
	// once is called on entity created, then is always called on game loaded //
	/*event OnSpawned( spawnData : SEntitySpawnData )
	{
		NRD("OnSpawned: " + this);
		OnStarted();
		super.OnSpawned( spawnData );
	}*/

	// return map containing saved magic setups //
	public function GetMagicDataMaps(out map : array<NR_Map>, out wasLoaded : bool) {
		var 	   i : int;

		NRD("GetMagicDataMaps: " + m_magicDataMaps.Size());
		wasLoaded = true;
		if (m_magicDataMaps.Size() < 6) {
			NRD("Init m_magicDataMaps");
			// init maps //
			m_magicDataMaps.Resize(6);
			for (i = 0; i <= ST_Universal; i += 1) {
				m_magicDataMaps[i] = new NR_Map in this;
			}
			wasLoaded = false;
		}
		map = m_magicDataMaps;
	}

	// makes manager know that player change was initiated //
	public function SetPlayerChangeRequested(isRequested : bool) {
		m_playerChangeRequested = isRequested;
	}

	// scene (preview) stuff functions //
	public function OnDialogOptionSelected(index : int) {
		var 			i : int;
		var 		 slot : int;
		var 	  changes : bool = false;
		var	  forceUnload : bool = false;

		if (!IsReplacerActive())
			return;

		// unload all preview templates & items
		ResetAllAppearancePreviewTemplates();
		m_sceneSelector.GetTemplatesToUpdate(index, IsFemale(), m_appearancePreviewTemplates, m_appearancePreviewItems, m_headPreviewName);
		forceUnload = m_sceneSelector.ForceUnloadSlotTemplates(index, IsFemale());
		NRD("OnDialogOptionSelected: index = " + index + ", dataIndex = " + m_sceneSelector.GetPreviewDataIndex() + ", forceUnload = " + forceUnload);
		// unload saved and load preview
		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			NRD("OnDialogOptionSelected: slot = " + slot + ", preview = [" + m_appearancePreviewTemplates[slot] + "]");
			if (m_appearancePreviewTemplates[slot] != "" || forceUnload) {
				NRD("OnDialogOptionSelected: load preview[" + slot + "] = " + m_appearancePreviewTemplates[slot]);
				if (m_appearanceTemplateIsLoaded[slot]) {
					// unload saved
					ExcludeAppearanceTemplate(m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot]);
					m_appearanceTemplateIsLoaded[slot] = false;
				}
				changes = true;
				// load preview
				IncludeAppearanceTemplate(m_appearancePreviewTemplates[slot], true);
			} else if (m_appearanceTemplates[slot] != "" && !m_appearanceTemplateIsLoaded[slot]) {
				NRD("OnDialogOptionSelected: load saved[" + slot + "] = " + m_appearancePreviewTemplates[slot]);
				changes = true;
				// load saved
				IncludeAppearanceTemplate(m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot]);
				m_appearanceTemplateIsLoaded[slot] = true;
			}
			// else do nothing
		}
		// load preview items
		for (i = 0; i < m_appearancePreviewItems.Size(); i += 1) {
			changes = true;
			IncludeAppearanceTemplate(m_appearancePreviewItems[i], true);
		}
		// load preview head
		if (IsNameValid(m_headPreviewName)) {
			NRD("OnDialogOptionSelected: load preview HEAD = " + NameToString(m_headPreviewName));
			changes = true;
			LoadHead(m_headPreviewName);
		// or load saved if no valid preview head and loaded != saved
		} else if (thePlayer.GetRememberedCustomHead() != m_headName) {
			changes = true;
			LoadHead(m_headName);
		}
		//NR_Notify("PreviewHead = " + m_headPreviewName + ", Cur: " + GetCurrentHeadName() + ", Remembered: " + thePlayer.GetRememberedCustomHead() + ", Saved: " + m_headName);

		// update notify info
		//if (changes) {
		//	UpdateAppearanceInfo();
		//}
	}
	// scene (preview) stuff functions //
	public function OnDialogOptionAccepted(index : int) {
		var slots : array<ENR_AppearanceSlots>;
		var paths : array<String>;
		var 	i : int;
		var	  forceUnload : bool = false;

		if (!IsReplacerActive())
			return;

		forceUnload = m_sceneSelector.ForceUnloadSlotTemplates(index, IsFemale());
		NRD("OnDialogOptionAccepted: " + index + ", forceUnload = " + forceUnload);
		if (m_sceneSelector.SaveOnAccept(index, IsFemale())) {
			NRD("Accept: save");
			// put preview to saved
			if (SaveAllAppearancePreviewTemplates(forceUnload)) {
				UpdateAppearanceInfo();
			}
		}

		m_sceneSelector.ResetPreviewDataIndex();
	}
	// scene (preview) stuff functions //
	public function SetPreviewDataIndex(data_index : int, choice_offset : int) {
		m_sceneSelector.SetPreviewDataIndex(data_index, choice_offset);
	}

	// scene (preview) stuff functions //
	public function ClearAppearanceSlot(slot : ENR_AppearanceSlots) {
		if (slot == ENR_GSlotHead) {
			if (IsFemale())
				UpdateHead('nr_h_01_wa__yennefer');	/* set default yennefer head */
			else
				UpdateHead('head_0');	/* set default geralt head */
			UpdateAppearanceInfo();
			return;
		}
		if (m_appearanceTemplates[slot] != "") {
			if (m_appearanceTemplateIsLoaded[slot]) {
				ExcludeAppearanceTemplate(m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot]);
				m_appearanceTemplateIsLoaded[slot] = false;
			}

			m_appearanceTemplates[slot] = "";
			UpdateAppearanceInfo();
		}
	}

	// scene (preview) stuff functions //
	public function SaveAppearanceSet() {
		var set : NR_AppearanceSet;
		set = new NR_AppearanceSet in this;
		set.appearanceTemplates = m_appearanceTemplates;
		set.appearanceTemplateIsDepotPath = m_appearanceTemplateIsDepotPath;
		set.appearanceItems = m_appearanceItems;
		set.appearanceItemIsDepotPath = m_appearanceItemIsDepotPath;
		set.headName = m_headName;

		m_appearanceSets.PushBack(set);
		thePlayer.DisplayHudMessage( GetLocStringById(2115940097) + IntToString(m_appearanceSets.Size()) );
		FactsSet("nr_appearance_sets", m_appearanceSets.Size());
	}

	// scene (preview) stuff functions //
	public function LoadAppearanceSet(setIndex : int) {
		var 	i 		: int;
		var 	slot 	: int;

		if (setIndex < 0 || setIndex >= m_appearanceSets.Size())
			return;

		ResetAllAppearanceHeadHair();
		m_appearanceTemplates = m_appearanceSets[setIndex].appearanceTemplates;
		m_appearanceTemplateIsDepotPath = m_appearanceSets[setIndex].appearanceTemplateIsDepotPath;
		m_appearanceItems = m_appearanceSets[setIndex].appearanceItems;
		m_appearanceItemIsDepotPath = m_appearanceSets[setIndex].appearanceItemIsDepotPath;
		LoadAppearanceTemplates();
		UpdateHead(m_appearanceSets[setIndex].headName);
		UpdateAppearanceInfo();
	}

	// scene (preview) stuff functions //
	public function RemoveAppearanceSet(setIndex : int) {
		if (setIndex < 0 || setIndex >= m_appearanceSets.Size())
			return;

		m_appearanceSets.Erase(setIndex);
	}

	// scene (preview) stuff functions //
	public function ClearItemSlot(item_index : int) {
		if (item_index == -1) {
			for (item_index = m_appearanceItems.Size() - 1; item_index >= 0; item_index -= 1) {
				UpdateAppearanceItem("", true, item_index);
			}
			UpdateAppearanceInfo();
		} else if (item_index > 0 && item_index <= m_appearanceItems.Size()) {
			UpdateAppearanceItem("", true, item_index - 1);
			UpdateAppearanceInfo();
		}
	}

	// scene (preview) stuff functions //
	public function GetTemplateFriendlyName(templateName : String) : String {
		if (templateName == "")
			return "<font color='#500000'>[" + GetLocStringById(1070947) + "]</font>";  // "<Empty slot>"
		else
			return StrBeforeLast( StrAfterLast(templateName, "/"), "." );
	}

	// scene (preview) stuff functions //
	public function ShowAppearanceInfo() {
		m_showAppearanceInfo = true;
		UpdateAppearanceInfo();
	}

	// scene (preview) stuff functions //
	public function HideAppearanceInfo() {
		m_showAppearanceInfo = false;
		theGame.GetGuiManager().ShowNotification("", 1.f);
	}

	// scene (preview) stuff functions //
	public function UpdateAppearanceInfo() {
		var 		i : int;
		var SLOT_STR, NBSP, BR : String;
		var 	text : String;

		if (!m_showAppearanceInfo)
			return;

		// <img src='img://" + GetItemIconPathByName + "' height='" + GetNotificationFontSize() + "' width='" + GetNotificationFontSize() + "' vspace='-10' />&nbsp;
		BR = "<br>";
		NBSP = "&nbsp;";
		SLOT_STR = GetLocStringById(2115940105);
		text = "<font color = '22'>" + GetLocStringById(2115940117) + ":" + NBSP + GetCurrentPlayerTypeName() + BR;
		text += "<font color='#000080'>(" + GetLocStringById(2115940106) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotBody]) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940107) + ")</font>" + NBSP + "=" + NBSP + NameToString(m_headName) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940108) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotHair]) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940109) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotTorso]) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940110) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotArms]) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940111) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotGloves]) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940112) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotDress]) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940113) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotLegs]) + BR; 
		text += "<font color='#000080'>(" + GetLocStringById(2115940114) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[ENR_RSlotShoes]) + BR; 
		text += "<font color='#003000'>(" + GetLocStringById(2115940115) + ")</font>" + NBSP + "=" + NBSP + IntToString(m_appearanceItems.Size()) + NBSP + GetLocStringById(1084753) + BR; 
		for (i = 0; i < m_appearanceItems.Size(); i += 1) {
			text += NBSP + NBSP + "<font color='#003000'>" + IntToString(i + 1) + ".</font>" + NBSP + GetTemplateFriendlyName(m_appearanceItems[i]) + BR; 
		}
		text += "</font>";
		NR_Notify(text, /* seconds */ 600.f);
	}

	// Helper function (when player type changed from scene and female<->non-female) //
	function SetDefaultAppearance(type : ENR_PlayerType) {
		switch (type) {
			case ENR_PlayerWitcher:
				ResetAllAppearanceHeadHair();
				UpdateHead('nr_h_01_ma__eskel');
				//UpdateHair('NR Eskel Hairstyle');
				UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
				break;
			case ENR_PlayerWitcheress:
				ResetAllAppearanceHeadHair();
				UpdateHead('nr_h_01_wa__edna');
				//UpdateHair('NR Rosa Hairstyle');
				UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/c_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotHair, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
				//UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
				UpdateAppearanceItem(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*isDepotPath*/ true, /*itemIndex*/ -1);
				UpdateAppearanceItem(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*isDepotPath*/ true, /*itemIndex*/ -1);
		
			case ENR_PlayerSorceress:
				ResetAllAppearanceHeadHair();
				UpdateHead('nr_h_01_wa__yennefer');
				//UpdateHair('NR Yennefer Hairstyle');
				UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/c_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotHair, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
				UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
				UpdateAppearanceItem(/*path*/ "characters/models/main_npc/yennefer/pendant_01_wa__yennefer.w2ent", /*isDepotPath*/ true, /*itemIndex*/ -1);
				break;
			default:
				break;
		}
	}

	// Helper function //
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

	// Helper function //
	function GetCurrentPlayerTypeName() : String {
		var replacer : NR_ReplacerWitcher;

		replacer = NR_GetWitcherReplacer();
		if ( replacer ) {
			return GetLocStringById( replacer.GetNameID() );
		} else if ( (W3ReplacerCiri)thePlayer ) {
			return GetLocStringById( 488030 );  // 320820
		} else {
			return GetLocStringById( 1085744 );
		}
	}

	// False if vanilla Geralt/Ciri player template is used, True otherwise //
	public function IsReplacerActive() : Bool {
		var playerType : ENR_PlayerType;

		playerType = GetCurrentPlayerType();
		return (playerType != ENR_PlayerGeralt && playerType != ENR_PlayerCiri);
	}

	// True if current player/replacer has female gender //
	public function IsFemale() : Bool {
		return IsFemaleType(m_savedPlayerType);
	}

	// Helper function //
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

	// Helper function //
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

	// Helper function //
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

	// Helper function //
	public function IsFemaleType(playerType : ENR_PlayerType) : Bool {
		return playerType != ENR_PlayerGeralt && playerType != ENR_PlayerWitcher;
	}

	// Main postponed function to fix player appearance on spawning (in any case) //
	public function OnPlayerSpawned() {
		var 				i : int;
		var currentPlayerType : ENR_PlayerType;

		NRD("OnPlayerSpawned: start");
		/*if ( !thePlayer ) {
			AddTimer('OnPlayerSpawned', 0.25f);
			return;
		}*/

		currentPlayerType = GetCurrentPlayerType();
		NRD("OnPlayerSpawned: Cur player: " + currentPlayerType + ", saved player: " + m_savedPlayerType);

		//if ( !thePlayer.HasChildAttachment( this ) )
		//	CreateAttachment(thePlayer);

		for (i = ENR_RSlotHair; i < ENR_RSlotMisc; i += 1) {
			m_appearanceTemplateIsLoaded[i] = false;
		}

		if ( currentPlayerType != m_savedPlayerType ) {
			// FROM GERALT
			if ( m_savedPlayerType == ENR_PlayerGeralt ) {
				// TO CUSTOM PLAYER
				//if ( currentPlayerType != "Geralt" ) {
				SavePlayerData();
				///NR_FixReplacer( 0.0, 0 );
				//}
			// FROM REPLACER
			} else {
				// TO GERALT & have saved items
				if ( currentPlayerType == ENR_PlayerGeralt && m_geraltDataSaved ) {
					// OK, we asked for it - restore mounted items
					/// TODO check if ( FactsQuerySum("nr_player_change_requested") > 0 ) {
					if ( m_playerChangeRequested ) {
						NR_FixPlayer();
					// BAD, it was auto-reset to Geralt after World change(?)
					} else {
						NRD("Player change to Geralt without request!");
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
		// WAS CUSTOM REPLACER - Reset appearance templates always TODO Check?
		if ( m_savedPlayerType != ENR_PlayerGeralt && m_savedPlayerType != ENR_PlayerCiri ) {
			UnloadAppearanceTemplates();
		}
		// CUSTOM REPLACER - APPLY FIX ALWAYS
		if ( IsReplacerActive() ) {
			NR_FixReplacer();
		}
		/// TODO FactsRemove("nr_player_change_requested");
		m_playerChangeRequested = false;
		m_savedPlayerType = currentPlayerType;

		// update facts
		FactsRemove("nr_player_female");
		FactsRemove("nr_player_type");
		FactsRemove("nr_speech_switch");
		
		FactsAdd("nr_player_type", (int)m_savedPlayerType);
		if (IsFemaleType(m_savedPlayerType)) {
			FactsAdd("nr_player_female", 1);
		}
		if (FactsQuerySum("nr_speech_manual_control") < 1) {
			FactsAdd("nr_speech_switch", (int)IsFemaleType(m_savedPlayerType));
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

	public function UpdateInventoryTemplateAppearance(template : CEntityTemplate) {
		var templateResource : CEntityTemplate;
		var extraTemplateResources : array<CEntityTemplate>;
		var       i, j : int;

		for (i = ENR_RSlotHair; i < ENR_RSlotMisc; i += 1) {
			if (m_appearanceTemplates[i] == "")
				continue;
			templateResource = (CEntityTemplate)LoadResource( m_appearanceTemplates[i], m_appearanceTemplateIsDepotPath[i] );
			if (templateResource)
				extraTemplateResources.PushBack(templateResource);
		}

		for (i = 0; i < m_appearanceItems.Size(); i += 1) {
			if (m_appearanceItems[i] == "")
				continue;
			templateResource = (CEntityTemplate)LoadResource( m_appearanceItems[i], m_appearanceItemIsDepotPath[i] );
			if (templateResource)
				extraTemplateResources.PushBack(templateResource);
		}

		for (i = 0; i < template.appearances.Size(); i += 1) {
			// clear old templates - because CEntityTemplate seems to be cached
			template.appearances[i].includedTemplates.Clear();
			for (j = 0; j < extraTemplateResources.Size(); j += 1) {
				template.appearances[i].includedTemplates.PushBack(extraTemplateResources[j]);
			}
		}
	}

	// Saves main geralt equipment items + hair + head (when changing type from Geralt) //
	function SavePlayerData() {
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

	// Load replacer head item //
	function LoadHead(newHeadName : name) {
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		NRD("LoadHead: " + newHeadName);
		thePlayer.RememberCustomHead( newHeadName );
		headManager.BlockGrowing( true );
		headManager.SetCustomHead( newHeadName );
	}

	// Get current head name from player //
	function GetCurrentHeadName() : name {
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		return headManager.GetCurHeadName();
	}

	// Updates saved replacer head item and load it //
	function UpdateHead(newHeadName : name) {
		m_headName = newHeadName;
		if (!IsReplacerActive())
			return;

		LoadHead(m_headName);
	}

	// Removes geralt hair item (part of NR_FixPlayer) <- to use c_ app template for replacers //
	function RemoveHair(/* newHairstyleName : name */) {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var ret : Bool;

		//m_hairstyleName = newHairstyleName;
		if (!IsReplacerActive())
			return;

		inv = thePlayer.GetInventory();
		if (!inv) {
			NRD("Restore head: NULL!");
		}
		ids = inv.GetItemsByCategory( 'hair' );
		
		for( i = 0; i < ids.Size(); i += 1 )
		{
			if ( inv.IsItemMounted(ids[i]) )
				inv.UnmountItem(ids[i]);
			inv.RemoveItem(ids[i], 1);
		}

		/*
		NRD("Hair Set: " + m_hairstyleName);
		if ( !IsNameValid(m_hairstyleName) )
			return;
			
		ids = inv.AddAnItem( m_hairstyleName );
		ret = inv.MountItem(ids[0]);
		NRD("Hair Mount: " + ret);
		*/
	}

	// Mounts geralt saved head item (part of NR_FixPlayer) //
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

	// Mounts geralt saved hair item (part of NR_FixPlayer) //
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

		if ( !IsNameValid(m_geraltSavedItems[ENR_GSlotHair]) )
			m_geraltSavedItems[ENR_GSlotHair] = 'Long Loose Hairstyle';
		NRD("Restore hair: " + m_geraltSavedItems[ENR_GSlotHair]);
		ids = inv.AddAnItem( m_geraltSavedItems[ENR_GSlotHair] );
		ret = inv.MountItem(ids[0]);
		NRD("Hair RMount: " + ret + ", " + inv.IsIdValid(ids[0]) + ", "  + inv.GetItemName(ids[0]));
	}

	// Mounts all geralt saved equipment items (part of NR_FixPlayer) //
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

	// Returns default item names for geralt (part of RemoveSavedItem) //
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

	// Removes geralt saved equippment item (when replacer: to mount default item correctly later) <- from Inventory //
	function RemoveSavedItem(id : SItemUniqueId) {
		var inv  : CInventoryComponent;
		var category : name;
		inv = thePlayer.GetInventory();

		category = inv.GetItemCategory(id);
		NRD("NR_UpdateRemoveMountedItem : " + category);

		m_geraltSavedItems[ ENRSlotByCategory(category) ] = GetDefaultItemByCategory(category);
	}

	// Updates geralt saved equippment item (when replacer: to mount it correctly later) <- from Inventory //
	function UpdateSavedItem(id : SItemUniqueId) {
		var inv  : CInventoryComponent;
		var itemName, category : name;
		inv = thePlayer.GetInventory();

		if (!inv.IsIdValid(id))
			return;

		category = inv.GetItemCategory(id);
		itemName = inv.GetItemName(id);
		NRD("UpdateSavedItem : " + itemName + " (" + category + "), inStoryScene = " + inStoryScene);
		if ( inv.IsItemMounted(id) && (category == 'armor' || category == 'gloves' 
			|| category == 'pants' || category == 'boots') )
		{
			inv.UnmountItem(id, true);
		}

		if (inStoryScene)
			return;

		m_geraltSavedItems[ ENRSlotByCategory(category) ] = itemName;
	}

	// Saves and unmounts all geralt equipment items (part of NR_FixReplacer) //
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
			
			if ( NR_GetWitcherReplacer().NR_IsSlotDenied(equippedOnSlot) ) {
				NR_GetWitcherReplacer().UnequipItemFromSlot( equippedOnSlot );
				//NRD("Unequip denied item: " + NR_stringByItemUID(ids[i]));
			}

			appearanceSlot = EEquipmentSlotToENRSlot( equippedOnSlot );
			if ( appearanceSlot == ENR_GSlotArmor || appearanceSlot == ENR_GSlotGloves ||
				 appearanceSlot == ENR_GSlotBoots || appearanceSlot == ENR_GSlotPants ||
				(inv.ItemHasTag(ids[i], 'Body') && StrStartsWith(NR_stringByItemUID(ids[i]), "Body")) )
			{
				UpdateSavedItem( ids[i] );
				NRD("Unmount: " + NR_stringByItemUID(ids[i]) + ", name: " + inv.GetItemName(ids[i]) + " slot = " + equippedOnSlot);
			}
		}
	}

	// Load template (if templateName != "") //
	function IncludeAppearanceTemplate(templateName : String, isDepotPath : bool) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                   i : int;

		if (templateName == "")
			return;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			/* LOAD */
			template = (CEntityTemplate)LoadResource( templateName, isDepotPath );
			if (template) {
				appearanceComponent.IncludeAppearanceTemplate(template);
				NRD("INCLUDE: template: " + templateName);
			} else {
				NRD("ERROR: can't load template: " + templateName);
			}
		} else {
			NRE("ERROR: AppearanceComponent not found!");
		}
	}

	// Unload template (if templateName != "") //
	function ExcludeAppearanceTemplate(templateName : String, isDepotPath : bool) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                   i : int;

		if (templateName == "")
			return;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			/* UNLOAD */
			template = (CEntityTemplate)LoadResource( templateName, isDepotPath );
			if (template) {
				appearanceComponent.ExcludeAppearanceTemplate(template);
				NRD("EXCLUDE: template: " + templateName);
			} else {
				NRD("ERROR: can't load template: " + templateName);
			}
		} else {
			NRE("ERROR: AppearanceComponent not found!");
		}
	}

	// All templates added to preview (and loaded) overwrite saved templates data //
	function SaveAllAppearancePreviewTemplates(forceUnload : bool) : bool {
		var 	i 		: int;
		var 	slot 	: int;
		var anyChanges	: bool;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearancePreviewTemplates[slot] == "") {
				if (forceUnload && m_appearanceTemplates[slot] != "") {
					m_appearanceTemplates[slot] = "";
					m_appearanceTemplateIsLoaded[slot] = false;
					m_appearanceTemplateIsDepotPath[slot] = false;
					anyChanges = true;
				}
				continue;
			}
			
			anyChanges = true;
			m_appearanceTemplates[slot] = m_appearancePreviewTemplates[slot];
			m_appearanceTemplateIsLoaded[slot] = true;
			m_appearanceTemplateIsDepotPath[slot] = true;

			m_appearancePreviewTemplates[slot] = "";
		}

		for (i = 0; i < m_appearancePreviewItems.Size(); i += 1) {
			anyChanges = true;
			ExcludeAppearanceTemplate(m_appearancePreviewItems[i], true);  // avoid twice-loaded template
			UpdateAppearanceItem(m_appearancePreviewItems[i], true, -1);
		}
		m_appearancePreviewItems.Clear();

		if (IsNameValid(m_headPreviewName)) {
			anyChanges = true;
			m_headName = m_headPreviewName;
		}
		m_headPreviewName = '';

		return anyChanges;
	}

	// Unload all PREVIEW templates //
	function ResetAllAppearancePreviewTemplates() {
		var 	slot : int;
		var 	i 	 : int;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearancePreviewTemplates[slot] == "")
				continue;

			ExcludeAppearanceTemplate(m_appearancePreviewTemplates[slot], true);
			m_appearancePreviewTemplates[slot] = "";
		}
		for (i = 0; i < m_appearancePreviewItems.Size(); i += 1) {
			ExcludeAppearanceTemplate(m_appearancePreviewItems[i], true);
		}
		m_appearancePreviewItems.Clear();
		m_headPreviewName = '';
	}

	// Updates template in given slot: Exclude old + Include new (if new != "") //
	function UpdateAppearanceTemplate(templateName : String, slot : ENR_AppearanceSlots, isDepotPath : bool) {
		if (IsReplacerActive() && m_appearanceTemplateIsLoaded[slot]) {
			ExcludeAppearanceTemplate(m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot]);
			m_appearanceTemplateIsLoaded[slot] = false;
		}

		m_appearanceTemplates[slot] = templateName;
		m_appearanceTemplateIsDepotPath[slot] = isDepotPath;

		if (IsReplacerActive() && m_appearanceTemplates[slot] != "" && !m_appearanceTemplateIsLoaded[slot]) {
			IncludeAppearanceTemplate(m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot]);
			m_appearanceTemplateIsLoaded[slot] = true;
		}
	}

	// Updates template ITEM (slot == ENR_RSlotMisc) in given slot: Exclude old + Include new (if new != "") //
	// itemIndex: defines if given template should be appended (-1) or replace existing [0; itemCount - 1]
	function UpdateAppearanceItem(templateName : String, isDepotPath : bool, itemIndex : int) {
		if (itemIndex < 0 || itemIndex >= m_appearanceItems.Size()) {
			// CREATE cell
			m_appearanceItems.PushBack(templateName);
			m_appearanceItemIsDepotPath.PushBack(isDepotPath);
			itemIndex = m_appearanceItems.Size() - 1;
			FactsAdd("nr_appearance_item_" + IntToString(itemIndex + 1), 1);
		} else {
			// UNLOAD cell
			if (m_appearanceItems[itemIndex] != "") {
				ExcludeAppearanceTemplate(m_appearanceItems[itemIndex], m_appearanceItemIsDepotPath[itemIndex]);
			}
			m_appearanceItems[itemIndex] = templateName;
			m_appearanceItemIsDepotPath[itemIndex] = isDepotPath;
		}

		if (m_appearanceItems[itemIndex] == "") {
			// REMOVE cell //
			m_appearanceItems.Erase(itemIndex);
			m_appearanceItemIsDepotPath.Erase(itemIndex);
			itemIndex = m_appearanceItems.Size();
			if (FactsDoesExist("nr_appearance_item_" + IntToString(itemIndex + 1)))
				FactsRemove("nr_appearance_item_" + IntToString(itemIndex + 1));
		} else {
			// LOAD cell //
			IncludeAppearanceTemplate(m_appearanceItems[itemIndex], m_appearanceItemIsDepotPath[itemIndex]);
		}
	}

	// Includes all saved appearance templates (on player reload) //
	function LoadAppearanceTemplates() {
		var slot : int;
		var i	 : int;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearanceTemplates[slot] != "" && !m_appearanceTemplateIsLoaded[slot]) {
				IncludeAppearanceTemplate(m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot]);
				m_appearanceTemplateIsLoaded[slot] = true;
			}
		}
		for (i = 0; i < m_appearanceItems.Size(); i += 1) {
			IncludeAppearanceTemplate(m_appearanceItems[i], m_appearanceItemIsDepotPath[i]);
		}
	}

	// Excludes all saved appearance templates (on player reload) //
	function UnloadAppearanceTemplates() {
		var slot : int;
		var i	 : int;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearanceTemplates[slot] != "") {
				ExcludeAppearanceTemplate(m_appearanceTemplates[slot], m_appearanceTemplateIsDepotPath[slot]);
				m_appearanceTemplateIsLoaded[slot] = false;
			}
		}
		for (i = 0; i < m_appearanceItems.Size(); i += 1) {
			ExcludeAppearanceTemplate(m_appearanceItems[i], m_appearanceItemIsDepotPath[i]);
		}
	}

	// Resets ALL saved templates + head + hair (used before applying new character set, manually from scene) //
	function ResetAllAppearanceHeadHair() {
		var slot, item_index : int;
		/* Set all slots to nothing, will unload if any template was loaded */
		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearanceTemplates[slot] == "")
				continue;

			UpdateAppearanceTemplate("", slot, true);
		}
		for (item_index = m_appearanceItems.Size() - 1; item_index >= 0; item_index -= 1) {
			UpdateAppearanceItem("", true, item_index);
		}
		NRD("ResetAllAppearanceHeadHair: m_appearanceItems size = " + m_appearanceItems.Size());

		if (IsFemale())
			UpdateHead('nr_h_01_wa__yennefer');	/* set default yennefer head */
		else
			UpdateHead('head_0');	/* set default geralt head */
		RemoveHair();			/* set no hair item */
	}

	// Fixes replacer appearance (on loading, after type changing) //
	public function NR_FixReplacer() {
		var witcher : NR_ReplacerWitcher;
		// change displayName hack
		witcher = NR_GetWitcherReplacer();
		if (stringsStorage) {
			//witcher.displayName = stringsStorage.GetLocalizedStringByKey(witcher.replacerName);
		} else {
			NRE("NR_FixReplacer: !stringsStorage");
		}

		NRD("NR_FixReplacer: Head = " + m_headName + ", templatesN = " + IntToString(m_appearanceTemplates.Size()));
		UnmountEquipment();
		RemoveHair();			/* saves and remove geralt hair */
		UpdateHead(m_headName);	/* saves and replace geralt head */
		LoadAppearanceTemplates();  /* load saved replacer templates */
		m_geraltDataSaved = true;
	}

	// Fixes player appearance (after type chaning only) //
	public function NR_FixPlayer() {
		RestoreEquipment();
		RestoreHead();
		RestoreHair();
		UnloadAppearanceTemplates();
		m_geraltDataSaved = false;
	}
}

state Idle in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		NRD("Idle: OnEnterState");
	}

	event OnLeaveState( nextStateName : name )
	{
	}
}

state Startup in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		WaitAndCheck();
	}

	entry function WaitAndCheck() {
		NRD("Startup: WaitAndCheck");
		parent.OnStarted();
		while (thePlayer.GetComponentsCountByClassName( 'CAppearanceComponent' ) < 1) {
			Sleep(0.05f);
		}
		parent.OnPlayerSpawned();
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
	}
}

state PlayerChange in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		WaitAndCheck();
	}

	entry function WaitAndCheck() {
		NRD("PlayerChange: WaitAndCheck");
		Sleep(0.25f);
		parent.OnPlayerSpawned();
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
	}
}

state FixReplacer in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		WaitAndCheck();
	}

	entry function WaitAndCheck() {
		NRD("FixReplacer: WaitAndCheck");
		Sleep(0.3f);
		parent.NR_FixReplacer();
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
	}
}

function NR_GetPlayerManager() : NR_PlayerManager
{
	//var nrManagerTemplate : CEntityTemplate;

	/*if ( !theGame.nr_playerManager ) {
		//nrManagerTemplate = (CEntityTemplate)LoadResource("nr_player_manager");
		//theGame.nr_playerManager = (NR_PlayerManager)theGame.CreateEntity(nrManagerTemplate, thePlayer.GetWorldPosition(),,,,,PM_Persist);
		theGame.nr_playerManager = new NR_PlayerManager in theGame;
		theGame.nr_playerManager.Init();
		//EntityHandleSet( nrPlayerManagerHandle, nrManager );
		NRD("PlayerManager created!");
	} else {
		NRD("PlayerManager found!");
	}*/
	if ( !theGame.nr_playerManager ) {
		NRE("NR_GetPlayerManager: !theGame.nr_playerManager");
	}
	NRD("NR_GetPlayerManager: " + theGame.nr_playerManager);

	return theGame.nr_playerManager;
}

exec function nrPlayer(playerType : int) {
	NR_ChangePlayer((int)playerType);
}

exec function nrLoad(templateName : String, slot : ENR_AppearanceSlots, optional isDepotPath : bool) {
	if (isDepotPath)
		NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot, /*isDepotPath*/ true);
	else
		NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot, /*isDepotPath*/ false);
}
// nrLoad(dlc/ep1/data/items/bodyparts/geralt_items/trunk/common_light/armor_stand/t_02_mg__wedding_suit_armor_stand.w2ent, ENR_GSlotArmor, true)
// nrLoad(dlc/bob/data/items/bodyparts/geralt_items/trunk/armor_vampire/armor_stand/q704_t_01a_mg__vampire_armor_stand.w2ent, ENR_GSlotArmor, true)

exec function nrUnload(slot : ENR_AppearanceSlots, optional isDepotPath : bool) {
	if (isDepotPath)
		NR_GetPlayerManager().UpdateAppearanceTemplate("", slot, /*isDepotPath*/ true);
	else
		NR_GetPlayerManager().UpdateAppearanceTemplate("", slot, /*isDepotPath*/ false);
}

exec function nrHead(m_headName : name) {
	NR_GetPlayerManager().UpdateHead(m_headName);
}

/*exec function nrHair(m_hairstyleName : name) {
	NR_GetPlayerManager().UpdateHair(m_hairstyleName);
}*/

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

	NRD("NR_ChangePlayer -> " + playerType);
	manager = NR_GetPlayerManager();
	manager.SetPlayerChangeRequested( true );
	manager.GotoState('PlayerChange');

	// for quests
	FactsAdd("nr_player_change_" + playerType, 1);
	
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
		NRE("ERROR! Unknown player type: " + playerType);
		return;
	}
	// cheaty thePlayer.abilityManager.RestoreStat(BCS_Vitality);
	thePlayer.Debug_ReleaseCriticalStateSaveLocks();
}

function NR_OnGameStarted(theGameObject : CR4Game) {
	if ( !theGameObject.nr_playerManager ) {
		theGameObject.nr_playerManager = new NR_PlayerManager in theGameObject;
		theGameObject.nr_playerManager.Init();
		NRD("theGame.OnGameStarted: PlayerManager created.");
	}
	NRD("theGame.OnGameStarted: PlayerManager startup.");
	theGameObject.nr_playerManager.GotoState('Startup');
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
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher);
	}
}

exec function toLambert() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_lambert');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/lambert/body_01_ma__lambert.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

exec function toTriss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_wa__triss');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/c_01_wa__triss.w2ent", /*slot*/ ENR_RSlotHair, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toYen() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.RemoveHair();
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/pendant_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toEmhyr() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_emhyr');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/emhyr/body_01_ma__emhyr.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/common/man_average/body/g_01_ma__body.w2ent", /*slot*/ ENR_RSlotGloves, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

// removefact(q705_yen_first_met)
// playScene(dlc/bob/data/quests/main_quests/quest_files/q705_epilog/scenes/q705_20a_yen_visit_vineyard.w2scene)

exec function toYenJoke2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/trunk/bare/t_01_mg__body_medalion.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/gloves/bare/g_01_mg__body.w2ent", /*slot*/ ENR_RSlotGloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/legs/casual_non_combat/l_02_mg__casual_skellige_pants.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/shoes/common_heavy/s_02_mg__common_heavy_lvl4.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

// naked Geralt paths!
exec function toYenJoke3() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/trunk/bare/t_01_mg__body_medalion.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/gloves/bare/g_01_mg__body.w2ent", /*slot*/ ENR_RSlotGloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/legs/bare/l_01_mg__body_underwear.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/shoes/bare/s_01_mg__body.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

exec function toTrissDLC() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss_dlc');
		//manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/b_01_wa__triss_dlc.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/c_01_wa__triss_dlc.w2ent", /*slot*/ ENR_GSlotHair, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toYenn() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		//manager.UpdateHair('NR Yennefer Hairstyle');
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/pendant_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}

exec function toTrisss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_wa__triss');
		//manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/b_01_wa__triss_dlc.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/c_01_wa__triss_dlc.w2ent", /*slot*/ ENR_GSlotHair, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}
exec function toTrisss2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss');
		//manager.UpdateHair('NR Triss Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}

exec function toRosa() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_rosa');
		//manager.RemoveHair(); -> not required!
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/h_00_mg__rosa.w2ent", /*slot*/ ENR_GSlotHead, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/bob/data/characters/models/main_npc/oriana/body_01_wa__oriana.w2ent", /*slot*/ ENR_RSlotDress, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/ep1/data/characters/models/secondary_npc/shani/c_01_wa__shani_hair.w2ent", /*slot*/ ENR_RSlotHair, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent", /*slot*/ ENR_RSlotGloves, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/nr_rosa_body_test.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc2, /*isDepotPath*/ true);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toDress(num : int) {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (!manager) {
		NRE("No manager!");
		return;
	}
	if (num == 1) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_03_wa__bob_woman_noble.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_03_wa__bob_woman_noble_px.w2ent", /*slot*/ ENR_RSlotDress, /*isDepotPath*/ true);
	} else if (num == 2) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px.w2ent", /*slot*/ ENR_RSlotDress, /*isDepotPath*/ true);
	} else if (num == 3) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p01.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p01.w2ent", /*slot*/ ENR_RSlotDress, /*isDepotPath*/ true);
	} else if (num == 4) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p02.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p02.w2ent", /*slot*/ ENR_RSlotDress, /*isDepotPath*/ true);
	} else if (num == 5) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p03.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p03.w2ent", /*slot*/ ENR_RSlotDress, /*isDepotPath*/ true);
	} else if (num == 6) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/body_01_wa__oriana.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/body_01_wa__oriana.w2ent", /*slot*/ ENR_RSlotDress, /*isDepotPath*/ true);
	}
}

exec function toRosa2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_rosa');
		//manager.UpdateHair('');
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/ep1/data/characters/models/secondary_npc/shani/c_01_wa__shani.w2ent", /*slot*/ ENR_RSlotMisc3, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/bob/data/characters/models/main_npc/vivienne_de_tabris/vivienne_de_tabris.w2ent", /*slot*/ ENR_RSlotBody, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/nr_rosa_body_test.w2ent", /*slot*/ ENR_GSlotArmor, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs, /*isDepotPath*/ true);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc1, /*isDepotPath*/ true);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc2, /*isDepotPath*/ true);
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
	playSceneF("quests/prologue/quest_files/q001_beggining/scenes/q001_5_wake_up.w2scene");
}
exec function toScene1() {
	playSceneF("quests/sidequests/skellige/quest_files/sq204_forest_spirit/scenes/sq204_03b_cs_leshy_appear.w2scene");
}
exec function yensc(optional input : String) {
	playSceneF("dlc/bob/data/quests/main_quests/quest_files/q705_epilog/scenes/q705_20a_yen_visit_vineyard.w2scene");
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

exec function nr_fix1() {
	var entity : CEntity;

	entity = theGame.GetEntityByTag('nr_player_manager');
	if (entity) {
		entity.BreakAttachment();
		entity.Destroy();
		NR_Notify("Found. Fixed.");
	} else {
		NR_Notify("NOT Found.");
	}
}
