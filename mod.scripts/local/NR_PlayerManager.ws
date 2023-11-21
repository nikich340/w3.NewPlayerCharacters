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
	public var appearanceItems : array<String>;
}

statemachine class NR_PlayerManager {
	protected saved var m_savedPlayerType : ENR_PlayerType;
	default          m_savedPlayerType = ENR_PlayerGeralt;

	protected saved var 				 m_headNames : array< name >;
	public saved var           m_appearanceTemplates : array< array<String> >;
	public 		 var    m_appearanceTemplateIsLoaded : array< array<bool> >;
	public saved var           	   m_appearanceItems : array< array<String> >;
	public 		 var        m_appearanceItemIsLoaded : array< array<bool> >;
	public saved var 				m_appearanceSets : array< array<NR_AppearanceSet> >;
	public saved var 				m_displayNameIDs : array< int >;

	protected var  				 m_canShowAppearanceInfo : bool;
	protected var  			   m_appearanceInfoTextExtra : String;
	protected var  					m_appearanceInfoText : String;
	protected var  					   m_headPreviewName : name;
	protected var    		m_appearancePreviewTemplates : array<String>;
	protected var    			m_appearancePreviewItems : array<String>;

	protected saved	var m_magicDataMaps : array<NR_Map>;
	protected saved	var m_activeSceneBlocks : NR_Map;
	protected saved var m_dataFormatVersion : int;
	default 			m_dataFormatVersion = -1;
	const 			var ST_Universal	: int;
	default 			ST_Universal 	= 5; // EnumGetMax(ESignType);

	protected saved var m_typeChangeLocked : bool;
	default  			m_typeChangeLocked = false;

	protected saved var m_geraltSavedItems  : array<name>;
	protected saved var m_geraltDataSaved : Bool;
	default          m_geraltDataSaved = false;

	protected var m_sceneSelector 	: NR_SceneSelector;
	protected var m_installedDLC 	: array<name>;
	protected var m_stringsStorage 	: NR_LocalizedStringStorage;
	protected var inStoryScene 		: Bool;
	default    inStoryScene 		= false;	

	protected var m_playerChangeRequested 	: Bool;
	default    m_playerChangeRequested 		= false;

	// DEBUG
	public var m_debugLatentObject : CObject;

	// once is called after entity created //
	public function Init() {
		var i, j, typesCount, slotsCount : int;

		m_dataFormatVersion = 1;
		typesCount = EnumGetMax('ENR_PlayerType') + 1;
		slotsCount = EnumGetMax('ENR_AppearanceSlots') + 1;
		m_geraltSavedItems.Resize( slotsCount );
		
		m_appearanceSets.Resize( 2 );
		m_headNames.Resize( typesCount );
		m_appearanceItems.Resize( typesCount );
		m_appearanceItemIsLoaded.Resize( typesCount );
		m_appearanceTemplates.Resize( typesCount );
		m_appearanceTemplateIsLoaded.Resize( typesCount );

		for (i = 0; i < typesCount; i += 1) {
			m_appearanceTemplates[i].Resize( slotsCount );
			m_appearanceTemplateIsLoaded[i].Resize( slotsCount );
			m_headNames[i] = 'head_0';
		}

		// Witcher - Vesemir
		m_headNames[ENR_PlayerWitcher] = 'nr_h_01_mb__vesemir';
		m_appearanceTemplates[ENR_PlayerWitcher][ENR_RSlotBody] = "characters/models/main_npc/vesemir/body_01__vesemir.w2ent";
		m_appearanceTemplates[ENR_PlayerWitcher][ENR_RSlotHair] = "characters/models/main_npc/vesemir/c_01_mb__vesemir.w2ent";

		// Witcheress - Rosa var Attre
		m_headNames[ENR_PlayerWitcheress] = 'nr_h_01_wa__edna';
		m_appearanceTemplates[ENR_PlayerWitcheress][ENR_RSlotHair] = "characters/models/common/woman_average/hair/c_09_wa__hair_01.w2ent";
		m_appearanceTemplates[ENR_PlayerWitcheress][ENR_RSlotTorso] = "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_t3d_02_wa__skellige_warrior_woman_coloring_9.w2ent";
		m_appearanceTemplates[ENR_PlayerWitcheress][ENR_RSlotArms] = "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_a_01_wa__skellige_warrior_woman_coloring_3.w2ent";
		m_appearanceTemplates[ENR_PlayerWitcheress][ENR_RSlotGloves] = "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent";
		m_appearanceTemplates[ENR_PlayerWitcheress][ENR_RSlotLegs] = "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_l2_06_wa__novigrad_citizen_coloring_6.w2ent";
		m_appearanceTemplates[ENR_PlayerWitcheress][ENR_RSlotShoes] = "dlc/dlcnewreplacers/data/entities/colorings/dlc_main/nr_s_05_wa__novigrad_citizen_coloring_23.w2ent";
		m_appearanceItems[ENR_PlayerWitcheress].PushBack( "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent" );
		m_appearanceItems[ENR_PlayerWitcheress].PushBack( "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent" );

		// Sorceress - Triss
		m_headNames[ENR_PlayerSorceress] = 'nr_h_01_wa__triss';
		m_appearanceTemplates[ENR_PlayerSorceress][ENR_RSlotBody] = "characters/models/main_npc/triss/body_03_wa__triss.w2ent";
		m_appearanceTemplates[ENR_PlayerSorceress][ENR_RSlotHair] = "characters/models/main_npc/triss/c_01_wa__triss.w2ent";
		m_appearanceTemplates[ENR_PlayerSorceress][ENR_RSlotShoes] = "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_s_01_wa__novigrad_prostitute_coloring_10.w2ent";
		m_appearanceItems[ENR_PlayerSorceress].PushBack( "characters/models/crowd_npc/novigrad_citizen_woman/items/i_31_wa__novigrad_citizen.w2ent" );
		

		m_displayNameIDs.Resize( typesCount );
		m_displayNameIDs[ENR_PlayerUnknown] = 318188;
		m_displayNameIDs[ENR_PlayerGeralt] = 318188;
		m_displayNameIDs[ENR_PlayerCiri] = 320820;
		m_displayNameIDs[ENR_PlayerWitcher] = 452675;
		m_displayNameIDs[ENR_PlayerWitcheress] = 2115940101;
		m_displayNameIDs[ENR_PlayerSorceress] = 358190;
		m_activeSceneBlocks = new NR_Map in this;
	}

	// run on every game load (load non-saved data)
	public latent function OnStarted() {
		var template : CEntityTemplate;
		var 	   i : int;

		NRD("OnStarted: " + this);

		// scene stuff //
		m_appearancePreviewTemplates.Resize( EnumGetMax('ENR_AppearanceSlots') );
		template = (CEntityTemplate)LoadResourceAsync("nr_scene_selector");
		if (!template) {
			NRE("!m_sceneSelector template");
		}
		m_sceneSelector = (NR_SceneSelector)theGame.CreateEntity(template, thePlayer.GetWorldPosition());
		NRD("OnSpawned: m_sceneSelector loaded.");
		if ( !m_sceneSelector ) {
			NRE("!m_sceneSelector");
		}
		m_installedDLC.Clear();
		for (i = 0; i < m_sceneSelector.m_customDLCInfo.Size(); i += 1) {
			// if dlc is installed and enabled - try fast way
			if (theGame.GetDLCManager().IsDLCAvailable(m_sceneSelector.m_customDLCInfo[i].m_dlcID)) {
				m_installedDLC.PushBack(m_sceneSelector.m_customDLCInfo[i].m_dlcID);
				continue;
			}

			// if dlc is installed but not enabled - try slow way
			template = (CEntityTemplate)LoadResourceAsync(m_sceneSelector.m_customDLCInfo[i].m_dlcCheckTemplatePath, /*depot*/ true);
			if (template) {
				m_installedDLC.PushBack(m_sceneSelector.m_customDLCInfo[i].m_dlcID);
			}
		}

		template = (CEntityTemplate)LoadResourceAsync("nr_localizedstrings_storage");
		m_stringsStorage = (NR_LocalizedStringStorage)theGame.CreateEntity(template, thePlayer.GetWorldPosition());
		NRD("OnSpawned: m_stringsStorage loaded.");
		if (!m_stringsStorage) {
			NRE("!m_stringsStorage");
		}
	}

	public function SetSceneBlockActive(questPath : name, sceneBlockId : int, active : bool) {
		var key : String;
		key = NameToString(questPath) + ":" + IntToString(sceneBlockId);

		m_activeSceneBlocks.setI(key, (int)active);
	}

	public function IsSceneBlockActive(questPath : name, sceneBlockId : int) : bool {
		var key : String;
		key = NameToString(questPath) + ":" + IntToString(sceneBlockId);

		return m_activeSceneBlocks.getI(key, 0) == 1;
	}

	// check if dlc installed - use pre-checked array
	public function NR_IsDLCInstalled(dlcName : name) : bool {
		return m_installedDLC.Contains(dlcName);
	}

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

	public function GetDataFormatVersion() : int {
		return m_dataFormatVersion;
	}

	// makes manager know that player change was initiated //
	public function SetPlayerChangeRequested(isRequested : bool) {
		m_playerChangeRequested = isRequested;
	}

	// scene (preview) stuff functions //
	public function OnDialogOptionSelected(index : int) {
		var 					i : int;
		var 		 		 slot : int;
		var 	  		  changes : bool = false;
		var	 forceUnloadAllExceptHair : bool = false;
		var   	   forceUnloadAll : bool = false;

		if (!IsReplacerActive())
			return;

		// unload all preview templates & items
		ResetAllAppearancePreviewTemplates();
		m_sceneSelector.GetTemplatesToUpdate(index, IsFemale(), m_appearancePreviewTemplates, m_appearancePreviewItems, m_headPreviewName);
		forceUnloadAllExceptHair = m_sceneSelector.ShouldForceUnloadAllExceptHair(index, IsFemale());
		forceUnloadAll = m_sceneSelector.ShouldForceUnloadAll(index, IsFemale());
		NRD("OnDialogOptionSelected: index = " + index + ", dataIndex = " + m_sceneSelector.GetPreviewDataIndex() + ", forceUnloadAll = " + forceUnloadAll + ", forceUnloadAllExceptHair = " + forceUnloadAllExceptHair);
		// unload saved and load preview
		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			// NRD("OnDialogOptionSelected: slot = " + slot + ", preview = [" + m_appearancePreviewTemplates[slot] + "]");
			if (m_appearancePreviewTemplates[slot] != "" || forceUnloadAll || (forceUnloadAllExceptHair && slot != ENR_RSlotHair)) {
				// unload saved
				if (m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot]) {
					// unload saved
					ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
					m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = false;
					changes = true;
				}
				// load preview if any
				if (m_appearancePreviewTemplates[slot] != "") {
					NRD("OnDialogOptionSelected: load preview[" + slot + "] = " + m_appearancePreviewTemplates[slot]);
					IncludeAppearanceTemplate(m_appearancePreviewTemplates[slot]);
				}
			} else if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && !m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot]) {
				NRD("OnDialogOptionSelected: load saved[" + slot + "] = " + m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				changes = true;
				// load saved
				IncludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = true;
			}
			// else do nothing
		}

		// handle items
		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			if ((forceUnloadAll || forceUnloadAllExceptHair) && m_appearanceItemIsLoaded[GetCurrentPlayerType()][i]) {
				ExcludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
				m_appearanceItemIsLoaded[GetCurrentPlayerType()][i] = false;
			} else if (!forceUnloadAll && !forceUnloadAllExceptHair && !m_appearanceItemIsLoaded[GetCurrentPlayerType()][i]) {
				IncludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
				m_appearanceItemIsLoaded[GetCurrentPlayerType()][i] = true;
			}
		}

		// load preview items
		for (i = 0; i < m_appearancePreviewItems.Size(); i += 1) {
			changes = true;
			IncludeAppearanceTemplate(m_appearancePreviewItems[i]);
		}

		// load preview head
		if (IsNameValid(m_headPreviewName)) {
			NRD("OnDialogOptionSelected: load preview HEAD = " + NameToString(m_headPreviewName));
			changes = true;
			LoadHead(m_headPreviewName);
		// or load saved if no valid preview head and loaded != saved
		} else if (thePlayer.GetRememberedCustomHead() != m_headNames[GetCurrentPlayerType()]) {
			changes = true;
			LoadHead(m_headNames[GetCurrentPlayerType()]);
		}
		
		if (changes)
			UpdateAppearanceInfo();
	}
	// scene (preview) stuff functions //
	public function OnDialogOptionAccepted(index : int) {
		var slots : array<ENR_AppearanceSlots>;
		var paths : array<String>;
		var 	i : int;
		var	 forceUnloadAllExceptHair : bool = false;
		var   	   forceUnloadAll : bool = false;

		if (!IsReplacerActive())
			return;

		forceUnloadAllExceptHair = m_sceneSelector.ShouldForceUnloadAllExceptHair(index, IsFemale());
		forceUnloadAll = m_sceneSelector.ShouldForceUnloadAll(index, IsFemale());
		NRD("OnDialogOptionAccepted: " + index + ", forceUnloadAll = " + forceUnloadAll + ", forceUnloadAllExceptHair = " + forceUnloadAllExceptHair);
		if (m_sceneSelector.SaveOnAccept(index, IsFemale())) {
			NRD("Accept: save");
			// put preview to saved
			if (SaveAllAppearancePreviewTemplates(forceUnloadAllExceptHair, forceUnloadAll)) {
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
	public function GetPlayerDisplayNameLocStr() : String {
		return GetLocStringById( m_displayNameIDs[GetCurrentPlayerType()] );
	}
	
	// scene (preview) stuff functions //
	public function SetPlayerDisplayName(nameID : int) {
		var lucky 	: int;
		var witcher : NR_ReplacerWitcher = NR_GetWitcherReplacer();

		// RANDOM
		if (nameID == 1) {
			lucky = RandRange(m_stringsStorage.stringIds.Size());
			NRD("SetPlayerDisplayName: select random " + lucky + " of " + m_stringsStorage.stringIds.Size());
			nameID = m_stringsStorage.stringIds[lucky];
		}

		m_displayNameIDs[GetCurrentPlayerType()] = nameID;
		if (witcher && m_stringsStorage) {
			witcher.displayName = m_stringsStorage.GetLocalizedStringById(nameID);
		}
	}

	// scene (preview) stuff functions //
	public function ClearAppearanceSlot(slot : ENR_AppearanceSlots) {
		if (slot == ENR_GSlotHead) {
			if (IsFemale())
				UpdateHead('nr_h_01_wa__yennefer');	/* set default yennefer head */
			else
				UpdateHead('head_0');	/* set default geralt head */
			return;
		}
		if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "") {
			if (m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot]) {
				ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = false;
			}

			m_appearanceTemplates[GetCurrentPlayerType()][slot] = "";
		}
	}

	// scene (preview) stuff functions //
	public function SaveAppearanceSet() {
		var set : NR_AppearanceSet;

		set = new NR_AppearanceSet in this;
		set.appearanceTemplates = m_appearanceTemplates[GetCurrentPlayerType()];
		set.appearanceItems = m_appearanceItems[GetCurrentPlayerType()];
		set.headName = m_headNames[GetCurrentPlayerType()];

		m_appearanceSets[IsFemaleInt()].PushBack(set);
		m_appearanceInfoTextExtra = GetLocStringById(2115940097) + IntToString(m_appearanceSets[IsFemaleInt()].Size());

		if (IsFemaleInt())
			FactsSet("nr_appearance_sets_female", m_appearanceSets[1].Size());
		else
			FactsSet("nr_appearance_sets_male", m_appearanceSets[0].Size());
	}

	// scene (preview) stuff functions //
	public function LoadAppearanceSet(setIndex : int) {
		var 	i 		: int;
		var 	slot 	: int;

		if (setIndex < 0 || setIndex >= m_appearanceSets[IsFemaleInt()].Size())
			return;

		ResetAllAppearanceHeadHair();
		m_appearanceTemplates[GetCurrentPlayerType()] = m_appearanceSets[IsFemaleInt()][setIndex].appearanceTemplates;
		m_appearanceItems[GetCurrentPlayerType()] = m_appearanceSets[IsFemaleInt()][setIndex].appearanceItems;
		LoadAppearanceTemplates();
		UpdateHead(m_appearanceSets[IsFemaleInt()][setIndex].headName);
		m_appearanceInfoTextExtra = GetLocStringById(2115940585) + IntToString(setIndex);
	}

	// scene (preview) stuff functions //
	public function RemoveAppearanceSet(setIndex : int) {
		if (setIndex < 0 || setIndex >= m_appearanceSets[IsFemaleInt()].Size())
			return;

		m_appearanceSets[IsFemaleInt()].Erase(setIndex);
		m_appearanceInfoTextExtra = GetLocStringById(2115940586) + IntToString(setIndex);

		if (IsFemaleInt())
			FactsSet("nr_appearance_sets_female", m_appearanceSets[1].Size());
		else
			FactsSet("nr_appearance_sets_male", m_appearanceSets[0].Size());
	}

	// scene (preview) stuff functions //
	public function ClearItemSlot(item_index : int) {
		if (item_index == -1) {
			for (item_index = m_appearanceItems[GetCurrentPlayerType()].Size() - 1; item_index >= 0; item_index -= 1) {
				UpdateAppearanceItem("", item_index);
			}
		} else if (item_index > 0 && item_index <= m_appearanceItems[GetCurrentPlayerType()].Size()) {
			UpdateAppearanceItem("", item_index - 1);
		}
	}

	// scene (preview) stuff functions //
	public latent function ShowCustomDLCInfo() {
		var i : int;
		var popupData : W3TutorialPopupData;
		var info : String;
		if (!m_sceneSelector)
			return;

		info = "";
		for (i = 0; i < m_sceneSelector.m_customDLCInfo.Size(); i += 1) {
			// lazy modders..
			if ( NR_IsLocStrExists(m_sceneSelector.m_customDLCInfo[i].m_dlcNameKey) )
				info += "<font size=\"20\"><i>" + NR_StrLightBlue( NR_GetLocStringByKeyExt(m_sceneSelector.m_customDLCInfo[i].m_dlcNameKey) ) + "</i> ";
			else
				info += "<font size=\"20\"><i>" + NR_StrLightBlue( m_sceneSelector.m_customDLCInfo[i].m_dlcNameStr ) + "</i> ";
			// if ( !NR_IsLocStrExists(m_sceneSelector.m_customDLCInfo[i].m_dlcNameKey) ) {
			if ( !NR_IsDLCInstalled(m_sceneSelector.m_customDLCInfo[i].m_dlcID) ) {
				info += NR_StrRed(GetLocStringById(1223720)) + "<br>";
			} else {
				info += NR_StrGreen(GetLocStringById(1123265)) + "<br>";
			}
			
			info += "  " + NR_StrYellow("@" + m_sceneSelector.m_customDLCInfo[i].m_dlcAuthor) + ": " + m_sceneSelector.m_customDLCInfo[i].m_dlcLink + "<br></font>";
		}

		popupData = new W3TutorialPopupData in thePlayer;
		popupData.messageTitle = GetLocStringById(1089437);
		popupData.messageText = info;
		
		popupData.managerRef = theGame.GetTutorialSystem();
		popupData.enableGlossoryLink = false;
		popupData.autosize = true;
		popupData.blockInput = false;
		popupData.pauseGame = false;
		popupData.fullscreen = true;
		popupData.canBeShownInMenus = false;
		popupData.duration = -1;
		popupData.posX = 0;
		popupData.posY = 0;
		popupData.enableAcceptButton = true;

		SoundEventQuest("gui_character_synergy_effect", SESB_DontSave);
		theGame.GetTutorialSystem().ShowTutorialHint(popupData);
	}

	// scene (preview) stuff functions //
	public function GetTemplateFriendlyName(templateName : String) : String {
		if (templateName == "")
			return "<font color='#500000'>[" + GetLocStringById(1070947) + "]</font>";  // "<Empty slot>"
		else
			return StrBeforeLast( StrAfterLast(templateName, "/"), "." );
	}

	// stuff function
	public function GetSlotLocStr(slot : ENR_AppearanceSlots) : String {
		switch (slot) {
			case ENR_RSlotBody:
				return GetLocStringById(2115940106);
			case ENR_GSlotHead:
				return GetLocStringById(2115940107);
			case ENR_RSlotHair:
				return GetLocStringById(2115940108);
			case ENR_RSlotTorso:
				return GetLocStringById(2115940109);
			case ENR_RSlotArms:
				return GetLocStringById(2115940110);
			case ENR_RSlotGloves:
				return GetLocStringById(2115940111);
			case ENR_RSlotDress:
				return GetLocStringById(2115940112);
			case ENR_RSlotLegs:
				return GetLocStringById(2115940113);
			case ENR_RSlotShoes:
				return GetLocStringById(2115940114);
			case ENR_RSlotMisc:
				return GetLocStringById(2115940115);
		}
	}

	// scene (preview) stuff functions //
	public function SetCanShowAppearanceInfo(canShow : bool) {
		if (!canShow)
			HideAppearanceInfo();

		m_canShowAppearanceInfo = canShow;
	}

	// scene (preview) stuff functions //
	public function CanShowAppearanceInfo() : bool {
		return m_canShowAppearanceInfo;
	}

	// scene (preview) stuff functions //
	public function ShowAppearanceInfo() {
		UpdateAppearanceInfo();
	}

	// scene (preview) stuff functions //
	public function HideAppearanceInfo() {
		if (m_appearanceInfoText != "") {
			m_appearanceInfoText = "";
			theGame.GetGuiManager().ShowNotification("", 1.f);
		}
	}

	// scene (preview) stuff functions //
	public function UpdateAppearanceInfo() {
		var 	slot, i : int;
		var SLOT_STR, NBSP, BR : String;
		var 	text : String;
		var showPreview : bool;

		if (!CanShowAppearanceInfo()) {
			NRD("UpdateAppearanceInfo: can't show");
			return;
		}

		showPreview = FactsQuerySum("nr_scene_show_preview_names") > 0;

		// <img src='img://" + GetItemIconPathByName + "' height='" + GetNotificationFontSize() + "' width='" + GetNotificationFontSize() + "' vspace='-10' />&nbsp;
		BR = "<br>";
		NBSP = "&nbsp;";
		SLOT_STR = GetLocStringById(2115940105);

		text = GetLocStringById(2115940583) + BR;
		if (m_appearanceInfoTextExtra != "") {
			text += "  " + NR_StrBlue( m_appearanceInfoTextExtra, /*dark*/ true ) + BR;
			m_appearanceInfoTextExtra = "";
		}
		text += BR;
		text += "<font color=\"22\">" + GetLocStringById(2115940117) + ":" + NBSP + NR_StrBlue( GetCurrentPlayerTypeLocStr(), /*dark*/ true ) + BR;
		text += GetLocStringById(2115940558) + ":" + NBSP + NR_StrGreen( GetPlayerDisplayNameLocStr(), /*dark*/ true ) + BR;
		text += "<font color='#000080'>(" + GetSlotLocStr(ENR_RSlotBody) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[GetCurrentPlayerType()][ENR_RSlotBody]);
		if (showPreview && m_appearancePreviewTemplates[ENR_RSlotBody] != "") {
			text += NBSP + "<" + GetTemplateFriendlyName(m_appearancePreviewTemplates[ENR_RSlotBody]) + ">"; 
		}
		text += BR;
		text += "<font color='#000080'>(" + GetSlotLocStr(ENR_GSlotHead) + ")</font>" + NBSP + "=" + NBSP + NameToString(m_headNames[GetCurrentPlayerType()]); 
		if (showPreview && IsNameValid(m_headPreviewName)) {
			text += NBSP + "<" + NameToString(m_headPreviewName) + ">"; 
		}
		text += BR;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (slot == ENR_RSlotBody)
				continue;

			text += "<font color='#000080'>(" + GetSlotLocStr(slot) + ")</font>" + NBSP + "=" + NBSP + GetTemplateFriendlyName(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
			if (showPreview && m_appearancePreviewTemplates[slot] != "") {
				text += NBSP + "<" + GetTemplateFriendlyName(m_appearancePreviewTemplates[slot]) + ">"; 
			}
			text += BR;
		}

		text += "<font color='#003000'>(" + GetSlotLocStr(ENR_RSlotMisc) + ")</font>" + NBSP + "=" + NBSP + IntToString(m_appearanceItems[GetCurrentPlayerType()].Size()) + NBSP + GetLocStringById(1084753) + BR; 
		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			text += NBSP + NBSP + "<font color='#003000'>" + IntToString(i + 1) + ".</font>" + NBSP + GetTemplateFriendlyName(m_appearanceItems[GetCurrentPlayerType()][i]) + BR; 
		}
		text += "</font>";
		if (text != m_appearanceInfoText) {
			m_appearanceInfoText = text;
			NR_Notify(text, /* seconds */ 600.f);
		} else {
			NRD("UpdateAppearanceInfo: text has no changes");
		}
	}

	// fun function
	function ApplyRandomNPCSet() {
		var nodeIndexes : array<int>;
		var choiceIndexes : array<int>;
		var i, j, lucky : int;
		if (IsFemale()) {
			for (i = 0; i < m_sceneSelector.m_nodesFemale.Size(); i += 1) {
				for (j = 0; j < m_sceneSelector.m_nodesFemale[i].m_onPreviewChoice.Size(); j += 1) {
					if (m_sceneSelector.m_nodesFemale[i].m_onPreviewChoice[j].m_flags & ENR_SPNPCSet) {
						NRD("Add m_nodesFemale[" + i + "][" + j + "]");
						nodeIndexes.PushBack(i);
						choiceIndexes.PushBack(j);
					}
				}
			}
		} else {
			for (i = 0; i < m_sceneSelector.m_nodesMale.Size(); i += 1) {
				for (j = 0; j < m_sceneSelector.m_nodesMale[i].m_onPreviewChoice.Size(); j += 1) {
					if (m_sceneSelector.m_nodesMale[i].m_onPreviewChoice[j].m_flags & ENR_SPNPCSet) {
						NRD("Add m_nodesMale[" + i + "][" + j + "]");
						nodeIndexes.PushBack(i);
						choiceIndexes.PushBack(j);
					}
				}
			}
		}
		lucky = RandRange( nodeIndexes.Size() );
		NRD("ApplyRandomNPCSet: selected index = " + lucky + " of " + nodeIndexes.Size());
		m_sceneSelector.SetPreviewDataIndex(nodeIndexes[lucky], 0);
		OnDialogOptionSelected(choiceIndexes[lucky]);
		OnDialogOptionAccepted(choiceIndexes[lucky]);
		m_sceneSelector.SetPreviewDataIndex(-1, 0);
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
	function GetCurrentPlayerTypeLocStr() : String {
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

	// True if current player/replacer has female gender //
	public function IsFemaleInt() : int {
		return (int)IsFemale();
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
			m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][i] = false;
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
		
		FactsAdd("nr_player_type", (int)m_savedPlayerType);
		if (IsFemaleType(m_savedPlayerType)) {
			FactsAdd("nr_player_female", 1);
		}
		UpdateSpeechSwitchFacts();
	}

	function UpdateSpeechSwitchFacts() {
		var controlValue : int;
		FactsRemove("nr_speech_switch");
		controlValue = FactsQuerySum("nr_speech_manual_control");

		// controlValue: 0 - auto, 1 - always female, 2 - never female
		if (controlValue < 1) {
			FactsAdd("nr_speech_switch", (int)IsFemaleType(m_savedPlayerType));
		} else if (controlValue == 1) {
			FactsAdd("nr_speech_switch", 1);
		}
	}

	function SetInStoryScene(val : bool) {
		inStoryScene = val;
	}

	// quest API
	public function SetTypeChangeLocked(locked : bool, reason : String) {
		m_typeChangeLocked = locked;
		NRD("NR_PlayerManager.SetTypeLocked: " + locked + "(" + reason + ")");
		if (locked) {
			FactsSet("nr_player_type_change_locked", 1);
		} else {
			FactsSet("nr_player_type_change_locked", 0);
		}
	}

	// quest API
	public function IsTypeChangeLocked() : bool {
		return m_typeChangeLocked;
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
			if (m_appearanceTemplates[GetCurrentPlayerType()][i] == "")
				continue;
			
			templateResource = (CEntityTemplate)LoadResource( m_appearanceTemplates[GetCurrentPlayerType()][i], true );
			if (templateResource)
				extraTemplateResources.PushBack(templateResource);
		}

		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			if (m_appearanceItems[GetCurrentPlayerType()][i] == "")
				continue;
			
			templateResource = (CEntityTemplate)LoadResource( m_appearanceItems[GetCurrentPlayerType()][i], true );
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
		m_headNames[GetCurrentPlayerType()] = newHeadName;
		if (!IsReplacerActive())
			return;

		LoadHead(newHeadName);
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
	function IncludeAppearanceTemplate(templateName : String) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                   i : int;

		if (templateName == "")
			return;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			/* LOAD */
			template = (CEntityTemplate)LoadResource( templateName, true );
			if (template) {
				appearanceComponent.IncludeAppearanceTemplate(template);
				NRD("IncludeAppearanceTemplate: INCLUDE: template: " + templateName + " = " + template);
			} else {
				NRD("IncludeAppearanceTemplate: ERROR: can't load template: " + templateName);
			}
		} else {
			NRE("IncludeAppearanceTemplate: ERROR: AppearanceComponent not found!");
		}
	}

	// Unload template (if templateName != "") //
	function ExcludeAppearanceTemplate(templateName : String) {
		var appearanceComponent : CAppearanceComponent;
		var            template : CEntityTemplate;
		var                   i : int;

		if (templateName == "")
			return;

		appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
		if (appearanceComponent) {
			/* UNLOAD */
			template = (CEntityTemplate)LoadResource( templateName, true );
			if (template) {
				appearanceComponent.ExcludeAppearanceTemplate(template);
				NRD("ExcludeAppearanceTemplate: template: " + templateName + " = " + template);
			} else {
				NRD("ExcludeAppearanceTemplate: ERROR: can't load template: " + templateName);
			}
		} else {
			NRE("ExcludeAppearanceTemplate: ERROR: AppearanceComponent not found!");
		}
	}

	// All templates added to preview (and loaded) overwrite saved templates data //
	function SaveAllAppearancePreviewTemplates(forceUnloadAllExceptHair : bool, forceUnloadAll : bool) : bool {
		var 	i 		: int;
		var 	slot 	: int;
		var anyChanges	: bool;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearancePreviewTemplates[slot] == "") {
				if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && (forceUnloadAll || (forceUnloadAllExceptHair && slot != ENR_RSlotHair))) {
					m_appearanceTemplates[GetCurrentPlayerType()][slot] = "";
					m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = false;
					anyChanges = true;
				}
				continue;
			}
			
			anyChanges = true;
			m_appearanceTemplates[GetCurrentPlayerType()][slot] = m_appearancePreviewTemplates[slot];
			m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = true;

			m_appearancePreviewTemplates[slot] = "";
		}

		// remove all old items if needed
		if (forceUnloadAll || forceUnloadAllExceptHair) {
			for (i = m_appearanceItems[GetCurrentPlayerType()].Size() - 1; i >= 0; i -= 1) {
				UpdateAppearanceItem("", i);
			}
		}

		for (i = 0; i < m_appearancePreviewItems.Size(); i += 1) {
			anyChanges = true;
			ExcludeAppearanceTemplate(m_appearancePreviewItems[i]);  // avoid twice-loaded template
			UpdateAppearanceItem(m_appearancePreviewItems[i], -1);
		}
		m_appearancePreviewItems.Clear();

		if (IsNameValid(m_headPreviewName)) {
			anyChanges = true;
			m_headNames[GetCurrentPlayerType()] = m_headPreviewName;
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

			ExcludeAppearanceTemplate(m_appearancePreviewTemplates[slot]);
			m_appearancePreviewTemplates[slot] = "";
		}
		for (i = 0; i < m_appearancePreviewItems.Size(); i += 1) {
			ExcludeAppearanceTemplate(m_appearancePreviewItems[i]);
		}
		m_appearancePreviewItems.Clear();
		m_headPreviewName = '';
	}

	// Updates template in given slot: Exclude old + Include new (if new != "") //
	function UpdateAppearanceTemplate(templateName : String, slot : ENR_AppearanceSlots) {
		if (IsReplacerActive() && m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot]) {
			ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
			m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = false;
		}

		m_appearanceTemplates[GetCurrentPlayerType()][slot] = templateName;

		if (IsReplacerActive() && m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && !m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot]) {
			IncludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
			m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = true;
		}
	}

	// Updates template ITEM (slot == ENR_RSlotMisc) in given slot: Exclude old + Include new (if new != "") //
	// itemIndex: defines if given template should be appended (-1) or replace existing [0; itemCount - 1]
	function UpdateAppearanceItem(templateName : String, itemIndex : int) {
		if (itemIndex < 0 || itemIndex >= m_appearanceItems[GetCurrentPlayerType()].Size()) {
			// CREATE cell
			m_appearanceItems[GetCurrentPlayerType()].PushBack(templateName);
			m_appearanceItemIsLoaded[GetCurrentPlayerType()].PushBack(false);
			itemIndex = m_appearanceItems[GetCurrentPlayerType()].Size() - 1;
			FactsAdd("nr_appearance_item_" + IntToString(itemIndex + 1), 1);
		} else {
			// UNLOAD cell
			if (m_appearanceItems[GetCurrentPlayerType()][itemIndex] != "" && m_appearanceItemIsLoaded[GetCurrentPlayerType()][itemIndex]) {
				ExcludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][itemIndex]);
				m_appearanceItemIsLoaded[GetCurrentPlayerType()][itemIndex] = false;
			}
			m_appearanceItems[GetCurrentPlayerType()][itemIndex] = templateName;
		}

		if (m_appearanceItems[GetCurrentPlayerType()][itemIndex] == "") {
			// REMOVE cell //
			m_appearanceItems[GetCurrentPlayerType()].Erase(itemIndex);
			m_appearanceItemIsLoaded[GetCurrentPlayerType()].Erase(itemIndex);
			itemIndex = m_appearanceItems[GetCurrentPlayerType()].Size();
			if (FactsDoesExist("nr_appearance_item_" + IntToString(itemIndex + 1)))
				FactsRemove("nr_appearance_item_" + IntToString(itemIndex + 1));
		} else if (!m_appearanceItemIsLoaded[GetCurrentPlayerType()][itemIndex]) {
			// LOAD cell //
			IncludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][itemIndex]);
			m_appearanceItemIsLoaded[GetCurrentPlayerType()][itemIndex] = true;
		}
	}

	// Includes all saved appearance templates (on player reload) //
	function LoadAppearanceTemplates() {
		var slot : int;
		var i	 : int;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && !m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot]) {
				IncludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = true;
			}
		}
		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			IncludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
		}
	}

	// Excludes all saved appearance templates (on player reload) //
	function UnloadAppearanceTemplates() {
		var slot : int;
		var i	 : int;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "") {
				ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				m_appearanceTemplateIsLoaded[GetCurrentPlayerType()][slot] = false;
			}
		}
		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			ExcludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
		}
	}

	// Resets ALL saved templates + head + hair (used before applying new character set, manually from scene) //
	function ResetAllAppearanceHeadHair() {
		var slot, item_index : int;
		/* Set all slots to nothing, will unload if any template was loaded */
		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearanceTemplates[GetCurrentPlayerType()][slot] == "")
				continue;

			UpdateAppearanceTemplate("", slot);
		}
		
		NRD("ResetAllAppearanceHeadHair: m_appearanceItems size = " + m_appearanceItems[GetCurrentPlayerType()].Size());
		for (item_index = m_appearanceItems[GetCurrentPlayerType()].Size() - 1; item_index >= 0; item_index -= 1) {
			UpdateAppearanceItem("", item_index);
		}
		
		if (IsFemale())
			UpdateHead('nr_h_01_wa__yennefer');	/* set default yennefer head */
		else
			UpdateHead('head_0');	/* set default geralt head */
		RemoveHair();			/* set no hair item */
	}

	// Fixes replacer appearance (on loading, after type changing) //
	public function NR_FixReplacer() {
		var witcher : NR_ReplacerWitcher = NR_GetWitcherReplacer();

		if (witcher && m_stringsStorage) {
			witcher.displayName = m_stringsStorage.GetLocalizedStringById(m_displayNameIDs[GetCurrentPlayerType()]);
		} else {
			NRE("NR_FixReplacer: !m_stringsStorage");
		}

		NRD("NR_FixReplacer: Head = " + m_headNames[GetCurrentPlayerType()]);
		UnmountEquipment();
		RemoveHair();										/* saves and remove geralt hair */
		UpdateHead(m_headNames[GetCurrentPlayerType()]);	/* saves and replace geralt head */
		LoadAppearanceTemplates();  						/* load saved replacer templates */
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
		NRD("NR_PlayerManager::Idle: OnEnterState");
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_PlayerManager::Idle: OnLeaveState");
	}
}

state GameLaunched in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		NRD("NR_PlayerManager::GameLaunched: OnEnterState");
		GameLaunched();
	}

	entry function GameLaunched() {
		var startTime : float;

		startTime = theGame.GetEngineTimeAsSeconds();
		NRD("NR_PlayerManager::GameLaunched: GameLaunched");
		parent.OnStarted();
		while (thePlayer.GetComponentsCountByClassName( 'CAppearanceComponent' ) < 1) {
			Sleep(0.05f);
		}
		NRD("NR_PlayerManager::GameLaunched: Player's ready after: " + (theGame.GetEngineTimeAsSeconds() - startTime));
		parent.OnPlayerSpawned();
		NRD("NR_PlayerManager::GameLaunched: -> Idle");
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_PlayerManager::GameLaunched: OnLeaveState");
	}
}

state PlayerChange in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		NRD("NR_PlayerManager::PlayerChange: OnEnterState");
		PlayerChange();
	}

	entry function PlayerChange() {
		NRD("NR_PlayerManager::PlayerChange: PlayerChange");
		Sleep(0.25f);
		parent.OnPlayerSpawned();
		NRD("NR_PlayerManager::PlayerChange: -> Idle");
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_PlayerManager::PlayerChange: OnLeaveState");
	}
}

state FixReplacer in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		NRD("NR_PlayerManager::FixReplacer: OnEnterState");
		FixReplacer();
	}

	entry function FixReplacer() {
		NRD("NR_PlayerManager::FixReplacer: FixReplacer");
		Sleep(0.3f);
		parent.NR_FixReplacer();
		NRD("NR_PlayerManager::FixReplacer: -> Idle");
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_PlayerManager::FixReplacer: OnLeaveState");
	}
}

function NR_ChangePlayer(playerType : ENR_PlayerType) {
	var manager    : NR_PlayerManager;

	NRD("NR_ChangePlayer -> " + playerType);
	manager = NR_GetPlayerManager();
	manager.SetPlayerChangeRequested( true );

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
	manager.GotoState('PlayerChange');
}

function NR_GetPlayerManager() : NR_PlayerManager
{
	if ( !theGame.nr_playerManager || theGame.nr_playerManager.GetDataFormatVersion() < 1 ) {
		NR_CreatePlayerManager( theGame );
	}
	NRD("NR_GetPlayerManager: " + theGame.nr_playerManager);

	return theGame.nr_playerManager;
}

function NR_OnGameStarted(theGameObject : CR4Game) {
	if ( !theGameObject.nr_playerManager || theGameObject.nr_playerManager.GetDataFormatVersion() < 1 ) {
		NR_CreatePlayerManager( theGameObject );
	}
	NRD("theGame.OnGameStarted: PlayerManager -> GameLaunched.");
	theGameObject.nr_playerManager.GotoState('GameLaunched');
}

function NR_CreatePlayerManager(theGameObject : CR4Game) {
	if ( !theGameObject.nr_playerManager || theGameObject.nr_playerManager.GetDataFormatVersion() < 1 ) {
		theGameObject.nr_playerManager = new NR_PlayerManager in theGameObject;
		NRD("theGame.OnGameStarted: PlayerManager just created.");
		theGameObject.nr_playerManager.Init();
	}
}



exec function nrPlayer(playerType : int) {
	NR_ChangePlayer((int)playerType);
}

exec function nrLoad(templateName : String, slot : ENR_AppearanceSlots) {
	NR_GetPlayerManager().UpdateAppearanceTemplate(templateName, slot);
}
// nrLoad(dlc/ep1/data/items/bodyparts/geralt_items/trunk/common_light/armor_stand/t_02_mg__wedding_suit_armor_stand.w2ent, ENR_GSlotArmor, true)
// nrLoad(dlc/bob/data/items/bodyparts/geralt_items/trunk/armor_vampire/armor_stand/q704_t_01a_mg__vampire_armor_stand.w2ent, ENR_GSlotArmor, true)

exec function nrUnload(slot : ENR_AppearanceSlots) {
	NR_GetPlayerManager().UpdateAppearanceTemplate("", slot);
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
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent", /*slot*/ ENR_RSlotBody);
		NR_ChangePlayer(ENR_PlayerWitcher);
	}
}

exec function toEskel2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_eskel');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "dlc\dlcnewreplacers\data\entities\colorings\dlc_main\nr_l0s_02_ma__novigrad_citizen_coloring_8.w2ent", /*slot*/ ENR_RSlotBody);
		NR_ChangePlayer(ENR_PlayerWitcher);
	}
}

exec function toLambert() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_lambert');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/lambert/body_01_ma__lambert.w2ent", /*slot*/ ENR_RSlotBody);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

exec function toTrissDress(dressNum : int) {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	var dress : String;

	if (dressNum == 1)
		dress = "dlc\bob\data\characters\models\crowd_npc\bob_citizen_woman\torso\t2_07_wa__bob_woman_noble_p01.w2ent";
	else if (dressNum == 2)
		dress = "dlc\bob\data\characters\models\crowd_npc\bob_citizen_woman\torso\t2_07_wa__bob_woman_noble_p02.w2ent";
	else if (dressNum == 3)
		dress = "dlc\bob\data\characters\models\crowd_npc\bob_citizen_woman\torso\t2_07b_wa__bob_woman_noble_p02.w2ent";
	else if (dressNum == 4)
		dress = "dlc/bob/data/characters/models/main_npc/oriana/body_01_wa__oriana.w2ent";
	else if (dressNum == 5)
		dress = "dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_03_wa__bob_woman_noble.w2ent";
	else if (dressNum == 6)
		dress = "dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_06_wa__bob_woman_noble_px.w2ent";
	else if (dressNum == 7)
		dress = "dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_06_wa__bob_woman_noble_px_p02.w2ent";
	else if (dressNum == 8)
		dress = "dlc/bob/data/characters/models/crowd_npc/bob_citizen_woman/dress/d_06_wa__bob_woman_noble_px_p03.w2ent";
	else if (dressNum == 11)
		dress = "dlc/dlcnewreplacers/data/entities/colorings/dlc_main/nr_d_01_wa__bob_woman_noble_p01_coloring_1.w2ent";
	
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_wa__triss');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody);
		manager.UpdateAppearanceTemplate(/*path*/ dress, /*slot*/ ENR_RSlotDress);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/c_01_wa__triss.w2ent", /*slot*/ ENR_RSlotHair);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
	NR_Notify("Dress = " + dress);
}

exec function toTriss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_wa__triss');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/c_01_wa__triss.w2ent", /*slot*/ ENR_RSlotHair);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toYen() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		manager.RemoveHair();
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/pendant_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotMisc1);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toEmhyr() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_emhyr');
		manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/emhyr/body_01_ma__emhyr.w2ent", /*slot*/ ENR_RSlotBody);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/common/man_average/body/g_01_ma__body.w2ent", /*slot*/ ENR_RSlotGloves);
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
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/trunk/bare/t_01_mg__body_medalion.w2ent", /*slot*/ ENR_RSlotTorso);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/gloves/bare/g_01_mg__body.w2ent", /*slot*/ ENR_RSlotGloves);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/legs/casual_non_combat/l_02_mg__casual_skellige_pants.w2ent", /*slot*/ ENR_RSlotLegs);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/shoes/common_heavy/s_02_mg__common_heavy_lvl4.w2ent", /*slot*/ ENR_RSlotShoes);
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
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/trunk/bare/t_01_mg__body_medalion.w2ent", /*slot*/ ENR_RSlotTorso);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/gloves/bare/g_01_mg__body.w2ent", /*slot*/ ENR_RSlotGloves);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/legs/bare/l_01_mg__body_underwear.w2ent", /*slot*/ ENR_RSlotLegs);
		manager.UpdateAppearanceTemplate(/*path*/ "items/bodyparts/geralt_items/shoes/bare/s_01_mg__body.w2ent", /*slot*/ ENR_RSlotShoes);
		NR_ChangePlayer(ENR_PlayerWitcher); // change player type in the last queue
	}
}

exec function toTrissDLC() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss_dlc');
		//manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/b_01_wa__triss_dlc.w2ent", /*slot*/ ENR_RSlotBody);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/c_01_wa__triss_dlc.w2ent", /*slot*/ ENR_GSlotHair);
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
	}
}

exec function toYenn() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_yennefer');
		//manager.UpdateHair('NR Yennefer Hairstyle');
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/pendant_01_wa__yennefer.w2ent", /*slot*/ ENR_RSlotMisc1);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/b_03_wa_yennefer.w2ent", /*slot*/ ENR_RSlotBody);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/yennefer/l_02_wa__yennefer.w2ent", /*slot*/ ENR_RSlotLegs);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}

exec function toTrisss() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_wa__triss');
		//manager.UpdateHair('NR Triss Hairstyle DLC');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/b_01_wa__triss_dlc.w2ent", /*slot*/ ENR_RSlotBody);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlc6/data/characters/models/main_npc/triss/c_01_wa__triss_dlc.w2ent", /*slot*/ ENR_GSlotHair);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}
exec function toTrisss2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_triss');
		//manager.UpdateHair('NR Triss Hairstyle');
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody);
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
	}
}

exec function toRosa() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_rosa');
		//manager.RemoveHair(); -> not required!
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/h_00_mg__rosa.w2ent", /*slot*/ ENR_GSlotHead);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/bob/data/characters/models/main_npc/oriana/body_01_wa__oriana.w2ent", /*slot*/ ENR_RSlotDress);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/ep1/data/characters/models/secondary_npc/shani/c_01_wa__shani_hair.w2ent", /*slot*/ ENR_RSlotHair);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent", /*slot*/ ENR_RSlotGloves);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_GSlotArmor);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/nr_rosa_body_test.w2ent", /*slot*/ ENR_GSlotArmor);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc1);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc2);
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
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_03_wa__bob_woman_noble_px.w2ent", /*slot*/ ENR_RSlotDress);
	} else if (num == 2) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px.w2ent", /*slot*/ ENR_RSlotDress);
	} else if (num == 3) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p01.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p01.w2ent", /*slot*/ ENR_RSlotDress);
	} else if (num == 4) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p02.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p02.w2ent", /*slot*/ ENR_RSlotDress);
	} else if (num == 5) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p03.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/d_06_wa__bob_woman_noble_px_p03.w2ent", /*slot*/ ENR_RSlotDress);
	} else if (num == 6) {
		NR_Notify("dlc/dlcnewreplacers/data/entities/bob_dress/body_01_wa__oriana.w2ent");
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/bob_dress/body_01_wa__oriana.w2ent", /*slot*/ ENR_RSlotDress);
	}
}

exec function toRosa2() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_head_rosa');
		//manager.UpdateHair('');
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/ep1/data/characters/models/secondary_npc/shani/c_01_wa__shani.w2ent", /*slot*/ ENR_RSlotMisc3);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/bob/data/characters/models/main_npc/vivienne_de_tabris/vivienne_de_tabris.w2ent", /*slot*/ ENR_RSlotBody);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/rosa/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_GSlotArmor);
		//manager.UpdateAppearanceTemplate(/*path*/ "dlc/dlcnewreplacers/data/entities/nr_rosa_body_test.w2ent", /*slot*/ ENR_GSlotArmor);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_10_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc1);
		//manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/items/i_08_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotMisc2);
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
