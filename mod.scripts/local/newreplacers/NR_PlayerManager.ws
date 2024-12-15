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
	ENR_PlayerUnknown,		// 0
	ENR_PlayerGeralt, 		// 1
	ENR_PlayerCiri, 		// 2
	ENR_PlayerWitcher, 	// 3
	ENR_PlayerWitcheress,	// 4
	ENR_PlayerSorceress	// 5
}

class NR_AppearanceSet {
	public var headName : name;
	public var appearanceTemplates : array<String>;
	public var appearanceItems : array<String>;
}

// for quest function
struct SNR_ApperanceEntry {
	editable var templatePath : String;
	editable var slot : ENR_AppearanceSlots;
}

statemachine class NR_PlayerManager extends IScriptable {
	protected saved var m_savedPlayerType : ENR_PlayerType;
	default          	m_savedPlayerType = ENR_PlayerGeralt;

	protected saved var 				 m_headNames : array< name >;
	public saved var           m_appearanceTemplates : array< array<String> >;
	public 		 var    m_appearanceTemplateIsLoaded : array< bool >;
	public saved var           	   m_appearanceItems : array< array<String> >;
	public 		 var        m_appearanceItemIsLoaded : array< bool >;
	public saved var 				m_appearanceSets : array< array<NR_AppearanceSet> >;
	public saved var 			 m_appearanceSexSets : array< NR_AppearanceSet >;
	public saved var			m_appearanceSexSetInUse : bool;
	public saved var			m_appearanceNonSexSet : NR_AppearanceSet;
	public saved var 				m_displayNameIDs : array< int >;

	protected var  				 m_canShowAppearanceInfo : bool;
	protected var  			   m_appearanceInfoTextExtra : String;
	protected var  					m_appearanceInfoText : String;
	protected var  					   m_headPreviewName : name;
	protected var    		m_appearancePreviewTemplates : array<String>;
	protected var    			m_appearancePreviewItems : array<String>;
	protected var        m_appearanceTemplatesLoadFailed : NR_Map;

	protected saved	var m_magicDataMaps : array<NR_Map>;
	protected saved	var m_miscData : NR_Map;
	protected saved var m_dataFormatVersion : int;
	default 			m_dataFormatVersion = -1;
	const 			var ST_Universal	: int;
	default 			ST_Universal 	= 5;  // EnumGetMax(ESignType);

	protected saved var m_typeChangeLocks : array<String>;
	protected		var m_inventoryItemsToHide : array<SItemUniqueId>;
	protected		var m_inventoryItemsToShow : array<SItemUniqueId>;

	protected saved var m_geraltSavedItems  : array<name>;
	protected saved var m_geraltDataSaved : Bool;
	default             m_geraltDataSaved = false;

	protected var m_sceneSelector 	: NR_SceneSelector;
	protected var m_installedDLC 	: array<name>;
	protected var m_stringsStorage 	: NR_LocalizedStringStorage;
	protected var m_inStoryScene 		: Bool;
	default    	  m_inStoryScene 		= false;	

	protected var m_playerChangeRequested 	: Bool;
	default    		m_playerChangeRequested	= false;
	protected saved var m_replacerForQuestSaved : ENR_PlayerType;
	default    			m_replacerForQuestSaved = ENR_PlayerUnknown;

	protected saved var m_magicVersion : int;
	default 			m_magicVersion = -1; // unused
	public 		var m_worldPosition : Vector;
	public 		var m_worldRotation : EulerAngles;
	protected 	var m_modVersion : int;
	default  		m_modVersion = 302;  // v3.0.2

	// for testing
	public var m_debugObject : IScriptable;

	// called once: after entity created //
	public function Init() {
		var i, j, typesCount, slotsCount : int;

		m_dataFormatVersion = 2;
		NR_Info("NR_PlayerManager.Init");
		typesCount = EnumGetMax('ENR_PlayerType') + 1;
		slotsCount = EnumGetMax('ENR_AppearanceSlots') + 1;
		m_geraltSavedItems.Resize( slotsCount );
		
		m_appearanceSets.Resize( 2 );
		m_headNames.Resize( typesCount );
		m_appearanceItems.Resize( typesCount );
		m_appearanceTemplates.Resize( typesCount );

		for (i = 0; i < typesCount; i += 1) {
			m_appearanceTemplates[i].Resize( slotsCount );
			m_headNames[i] = 'head_0';
		}

		// Witcher - Eskel
		m_headNames[ENR_PlayerWitcher] = 'nr_h_01_ma__eskel';
		m_appearanceTemplates[ENR_PlayerWitcher][ENR_RSlotBody] = "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent";

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

		// Sorceress - Yennefer
		m_headNames[ENR_PlayerSorceress] = 'nr_h_01_wa__yennefer';
		m_appearanceTemplates[ENR_PlayerSorceress][ENR_RSlotBody] = "dlc/dlc4/data/characters/models/main_npc/yennefer/body_05__yennefer.w2ent";
		m_appearanceTemplates[ENR_PlayerSorceress][ENR_RSlotHair] = "characters/models/main_npc/yennefer/c_03_wa__yennefer.w2ent";
		m_appearanceTemplates[ENR_PlayerSorceress][ENR_RSlotShoes] = "dlc/dlcnewreplacers/data/entities/colorings/vanilla_main/nr_s_01_wa__novigrad_prostitute_coloring_10.w2ent";
		m_appearanceItems[ENR_PlayerSorceress].PushBack( "characters/models/main_npc/yennefer/pendant_01_wa__yennefer.w2ent" );
		
		m_displayNameIDs.Resize( typesCount );
		m_displayNameIDs[ENR_PlayerUnknown] = 318188;
		m_displayNameIDs[ENR_PlayerGeralt] = 318188;
		m_displayNameIDs[ENR_PlayerCiri] = 320820;
		m_displayNameIDs[ENR_PlayerWitcher] = 452675;
		m_displayNameIDs[ENR_PlayerWitcheress] = 2115940101;
		m_displayNameIDs[ENR_PlayerSorceress] = 358190;

		m_miscData = new NR_Map in this;
		InitSexSets();
	}

	// called once
	public function InitSexSets() {
		var i, j, typesCount, slotsCount : int;
		
		typesCount = EnumGetMax('ENR_PlayerType') + 1;
		slotsCount = EnumGetMax('ENR_AppearanceSlots') + 1;
		m_appearanceSexSets.Resize( typesCount );
		for (i = 0; i < typesCount; i += 1) {
			m_appearanceSexSets[i] = new NR_AppearanceSet in this;
			m_appearanceSexSets[i].appearanceTemplates.Resize( slotsCount );
		}
		m_appearanceNonSexSet = new NR_AppearanceSet in this;
		// enable by default
		FactsAdd("nr_use_sex_set_ENR_PlayerWitcher", 1);
		FactsAdd("nr_use_sex_set_ENR_PlayerWitcheress", 1);
		FactsAdd("nr_use_sex_set_ENR_PlayerSorceress", 1);
		
		// Witcher
		m_appearanceSexSets[ENR_PlayerWitcher].appearanceTemplates[ENR_RSlotTorso] = "items/bodyparts/geralt_items/trunk/bare/t_01_mg__body_medalion.w2ent";
		// naked fully: items/bodyparts/geralt_items/trunk/bare/t_01_mg__body.w2ent
		m_appearanceSexSets[ENR_PlayerWitcher].appearanceTemplates[ENR_RSlotGloves] = "items/bodyparts/geralt_items/gloves/bare/g_01_mg__body.w2ent";
		m_appearanceSexSets[ENR_PlayerWitcher].appearanceTemplates[ENR_RSlotLegs] = "items/bodyparts/geralt_items/legs/bare/l_01_mg__body_underwear.w2ent";
		// naked fully: items/bodyparts/geralt_items/legs/bare/l_01_mg__body.w2ent
		m_appearanceSexSets[ENR_PlayerWitcher].appearanceTemplates[ENR_RSlotShoes] = "items/bodyparts/geralt_items/shoes/bare/s_01_mg__body.w2ent";
		
		// Witcheress
		m_appearanceSexSets[ENR_PlayerWitcheress].appearanceTemplates[ENR_RSlotBody] = "characters/models/main_npc/triss/body_02_wa__triss.w2ent";
		// naked fully: characters/models/crowd_npc/naked_bodies/torso/twals_02_wa__body.w2ent
		
		// Sorceress
		m_appearanceSexSets[ENR_PlayerSorceress].appearanceTemplates[ENR_RSlotBody] = "characters/models/main_npc/yennefer/body_yennefer__lingerie.w2ent";
		m_appearanceSexSets[ENR_PlayerSorceress].appearanceTemplates[ENR_RSlotLegs] = "characters/models/crowd_npc/lingerie/legs/l_01a_wa__lingerie_slim.w2ent";
		m_appearanceSexSets[ENR_PlayerSorceress].appearanceItems.PushBack( "characters/models/main_npc/yennefer/pendant_03_wa__yennefer.w2ent" );
		// naked fully: characters/models/crowd_npc/naked_bodies/torso/twals_01_wa__body.w2ent
	}

	// run on every game load (load non-saved data) //
	public latent function OnStarted() {
		var template : CEntityTemplate;
		var 	   i, typesCount, slotsCount : int;

		NR_Info("NR_PlayerManager.OnStarted: m_dataFormatVersion = " + m_dataFormatVersion + ", m_magicVersion = " + m_magicVersion + ", m_modVersion = " + m_modVersion);
		// scene stuff //
		typesCount = EnumGetMax('ENR_PlayerType') + 1;
		slotsCount = EnumGetMax('ENR_AppearanceSlots') + 1;
		m_appearanceItemIsLoaded.Clear();
		m_appearanceTemplateIsLoaded.Clear();
		m_appearanceTemplateIsLoaded.Resize( slotsCount );

		m_appearancePreviewItems.Clear();
		m_appearancePreviewTemplates.Clear();
		m_appearancePreviewTemplates.Resize( slotsCount );
		m_appearanceTemplatesLoadFailed = new NR_Map in this;

		template = (CEntityTemplate)LoadResourceAsync("nr_scene_selector");
		if ( !template ) {
			NR_Error("NR_PlayerManager.OnStarted: !m_sceneSelector template");
		}
		// NR_Debug("NR_PlayerManager.OnStarted: template = " + template);
		m_sceneSelector = (NR_SceneSelector)theGame.CreateEntity(template, thePlayer.GetWorldPosition());
		if ( !m_sceneSelector ) {
			NR_Error("NR_PlayerManager.OnStarted: !m_sceneSelector");
		}
		// NR_Debug("NR_PlayerManager.OnStarted: m_sceneSelector = " + m_sceneSelector);
		m_installedDLC.Clear();
		for (i = 0; i < m_sceneSelector.m_customDLCInfo.Size(); i += 1) {
			// if dlc is installed and enabled - try fast way
			if (theGame.GetDLCManager().IsDLCAvailable(m_sceneSelector.m_customDLCInfo[i].m_dlcID)) {
				NR_Info("NR_PlayerManager.OnStarted: dlc installed (fast check): " + m_sceneSelector.m_customDLCInfo[i].m_dlcID);
				m_installedDLC.PushBack(m_sceneSelector.m_customDLCInfo[i].m_dlcID);
				continue;
			}

			// if dlc is installed but not enabled - try slow way
			template = (CEntityTemplate)LoadResourceAsync(m_sceneSelector.m_customDLCInfo[i].m_dlcCheckTemplatePath, /*depot*/ true);
			if (template) {
				NR_Info("NR_PlayerManager.OnStarted: dlc installed (slow check): " + m_sceneSelector.m_customDLCInfo[i].m_dlcID);
				m_installedDLC.PushBack(m_sceneSelector.m_customDLCInfo[i].m_dlcID);
			}
			NR_Info("NR_PlayerManager.OnStarted: dlc is not installed: " + m_sceneSelector.m_customDLCInfo[i].m_dlcID);
		}
		// NR_Debug("NR_PlayerManager.OnStarted: m_installedDLCs = " + m_installedDLC.Size());

		template = (CEntityTemplate)LoadResourceAsync("nr_localizedstrings_storage");
		if ( !template ) {
			NR_Error("NR_PlayerManager.OnStarted: !m_stringsStorage template");
		}
		m_stringsStorage = (NR_LocalizedStringStorage)theGame.CreateEntity(template, thePlayer.GetWorldPosition());
		// NR_Debug("OnSpawned: m_stringsStorage loaded.");
		if ( !m_stringsStorage ) {
			NR_Error("NR_PlayerManager.OnStarted: !m_stringsStorage");
		}
		RegisterListeners();
		NR_Info("NR_PlayerManager.OnStarted: Ready");
	}

	// this can be used to get mod version: static
	public function GetModVersion() : int {
		return m_modVersion;
	}

	// not work :(
	public function GetMagicVersion() : int {
		return m_magicVersion;
	}

	// not work :(
	public function SetMagicVersion(newVersion : int) {
		m_magicVersion = newVersion;
	}

	public function IsNeckTransitionVisible() : bool {
		return !FactsDoesExist("nr_neck_hidden_" + GetCurrentPlayerType());
	}

	public function SetNeckTransitionVisible(visible : bool) {
		if (!IsReplacerActive())
			return;

		if (!visible) {
			FactsAdd("nr_neck_hidden_" + GetCurrentPlayerType(), 1);
		} else {
			FactsRemove("nr_neck_hidden_" + GetCurrentPlayerType());
		}
		UpdateNeckTransitionVisibility();
	}

	public function IsSexSetEnabled() : bool {
		return FactsDoesExist("nr_use_sex_set_" + GetCurrentPlayerType());
	}
	
	public function SetIsSexSetEnabled(enabled : bool) {
		if (!IsReplacerActive())
			return;
			
		if (!enabled) {
			FactsRemove("nr_use_sex_set_" + GetCurrentPlayerType());
		} else {
			FactsAdd("nr_use_sex_set_" + GetCurrentPlayerType(), 1);
		}
	}
	
	public function DisableSexSetSync() {
		if (!IsReplacerActive())
			return;

		SetIsSexSetEnabled(false);
		if (m_appearanceSexSetInUse) {
			ResetAllAppearanceTemplates();
			// restore back
			m_appearanceTemplates[GetCurrentPlayerType()] = m_appearanceNonSexSet.appearanceTemplates;
			m_appearanceItems[GetCurrentPlayerType()] = m_appearanceNonSexSet.appearanceItems;
			LoadAppearanceTemplates();
			m_appearanceSexSetInUse = false;
		}
	}
	
	public function IsRealEquipmentModeEnabled() : bool {
		return (IsReplacerActive() && FactsQuerySum("nr_real_equipment_mode") > 0);
	}

	public function SetIsRealEquipmentModeEnabled(enabled : bool) {
		if (!IsReplacerActive())
			return;

		if (!enabled) {
			FactsRemove("nr_real_equipment_mode");
			LoadAppearanceTemplates();
			UnmountEquipment();
		} else {
			FactsAdd("nr_real_equipment_mode", 1);
			UnloadAppearanceTemplates(/*equipmentOnly*/ true);
			RestoreEquipment();
		}
		UpdateMagicJoItem();
	}

	public function UpdateMagicJoItem() {
		var ids : array<SItemUniqueId>;

		thePlayer.inv.RemoveItemByName('female_armors_jo', -1);
		if (IsRealEquipmentModeEnabled() && IsReplacerActive() && IsFemale()) {
			ids = thePlayer.inv.AddAnItem('female_armors_jo', 1);
    		thePlayer.inv.MountItem(ids[0], /*toHand*/ false, /*force*/ true);
		}
	}

	public function SetCurrentPlayerScale(newScale : int) {
		if ( !IsReplacerActive() )
			return;

		m_miscData.setI("nr_player_scale_" + GetCurrentPlayerType(), newScale);
		ApplyCurrentPlayerScale();
	}

	public function SetPlayerScaleForType(type : ENR_PlayerType, newScale : int) {
		m_miscData.setI("nr_player_scale_" + type, newScale);
		if (GetCurrentPlayerType() == type)
			ApplyCurrentPlayerScale();
	}

	public function ApplyCurrentPlayerScale() {
		var scale : float;
		if ( !IsReplacerActive() || GetCurrentPlayerScale() == 100 )
			return;

		scale = GetCurrentPlayerScale() * 0.01f;
		thePlayer.GetMovingAgentComponent().SetScale( Vector(scale, scale, scale) );
	}

	public function GetCurrentPlayerScale() : int {
		var defaultScale : int;

		if (IsFemale()) {
			defaultScale = 100;
		} else {
			defaultScale = 100;
		}

		return m_miscData.getI("nr_player_scale_" + GetCurrentPlayerType(), defaultScale);
	}

	// check if dlc installed - use pre-checked array
	// not API! only for appearance predefined dlcs!
	public function NR_IsDLCInstalled(dlcName : name) : bool {
		return m_installedDLC.Contains(dlcName);
	}

	// return map containing saved magic setups //
	public function GetMagicDataMaps(out map : array<NR_Map>, out wasLoaded : bool) {
		var 	   i : int;

		// NR_Debug("GetMagicDataMaps: " + m_magicDataMaps.Size());
		wasLoaded = true;
		if (m_magicDataMaps.Size() < 6) {
			// NR_Debug("Init m_magicDataMaps");
			// init maps //
			m_magicDataMaps.Resize(6);
			for (i = 0; i <= ST_Universal; i += 1) {
				m_magicDataMaps[i] = new NR_Map in this;
			}
			wasLoaded = false;
		}
		map = m_magicDataMaps;
	}

	// if any structs changed it will require recreating everything
	public function GetDataFormatVersion() : int {
		return m_dataFormatVersion;
	}

	// check if player change was initiated //
	public function IsPlayerChangeRequested() : bool {
		return m_playerChangeRequested;
	}

	// makes manager know that player change was initiated //
	public function SetPlayerChangeRequested(isRequested : bool) {
		m_playerChangeRequested = isRequested;
	}

	public function RegisterListeners() {
		// theInput.RegisterListener(this, 'OnInputUse', 'NRUse');
		theInput.RegisterListener(this, 'OnInputSelect1', 'NRSelect1');
		theInput.RegisterListener(this, 'OnInputSelect2', 'NRSelect2');
		theInput.RegisterListener(this, 'OnInputSelect3', 'NRSelect3');
		theInput.RegisterListener(this, 'OnInputSelect4', 'NRSelect4');
		theInput.RegisterListener(this, 'OnInputSelect5', 'NRSelect5');
		theInput.RegisterListener(this, 'OnInputSelect6', 'NRSelect6');
		theInput.RegisterListener(this, 'OnInputSelect7', 'NRSelect7');
		theInput.RegisterListener(this, 'OnInputSelect8', 'NRSelect8');
		theInput.RegisterListener(this, 'OnInputSelect9', 'NRSelect9');
		theInput.RegisterListener(this, 'OnInputSelect0', 'NRSelect0');
		theInput.RegisterListener(this, 'OnInputEquipmentSwitch', 'NREquipmentSwitch');
		theInput.RegisterListener(this, 'OnInputEnterScene', 'NREnterScene');
	}

	// unused
	public function UnregisterListeners() {
		// theInput.UnregisterListener(this, 'NRUse');
		theInput.UnregisterListener(this, 'NRSelect1');
		theInput.UnregisterListener(this, 'NRSelect2');
		theInput.UnregisterListener(this, 'NRSelect3');
		theInput.UnregisterListener(this, 'NRSelect4');
		theInput.UnregisterListener(this, 'NRSelect5');
		theInput.UnregisterListener(this, 'NRSelect6');
		theInput.UnregisterListener(this, 'NRSelect7');
		theInput.UnregisterListener(this, 'NRSelect8');
		theInput.UnregisterListener(this, 'NRSelect9');
		theInput.UnregisterListener(this, 'NRSelect0');
		theInput.UnregisterListener(this, 'NREquipmentSwitch');
		theInput.UnregisterListener(this, 'NREnterScene');
	}

	event OnInputSelect1(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(1 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect2(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(2 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect3(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(3 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect4(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(4 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect5(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(5 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect6(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(6 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect7(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(7 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect8(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(8 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect9(action : SInputAction) {
		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			NR_GetPlayerManager().LoadAppearanceSet(9 - 1, true);
			return true;
		}
		return false;
	}

	event OnInputSelect0(action : SInputAction) {
		var playerType : ENR_PlayerType;

		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			playerType = GetCurrentPlayerType();
			if (playerType >= EnumGetMax('ENR_PlayerType'))
				playerType = (ENR_PlayerType)1;
			else
				playerType = (ENR_PlayerType)((int)playerType  + 1);

			if ( IsPlayerTypeChangeLocked() )
				NR_Notify(GetPlayerTypeChangeLocksExplanation(), 3.f);
			else
				NR_ChangePlayer(playerType);
			return true;
		}
		return false;
	}

	event OnInputEquipmentSwitch(action : SInputAction) {
		var playerType : ENR_PlayerType;

		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			playerType = GetCurrentPlayerType();
			SetIsRealEquipmentModeEnabled( !IsRealEquipmentModeEnabled() );
			if ( IsRealEquipmentModeEnabled() )
				NR_Notify(NR_GetLocStringByIdExt(2115940529), 3.f);
			else
				NR_Notify(NR_GetLocStringByIdExt(2115940528), 3.f);
			return true;
		}
		return false;
	}

	event OnInputEnterScene(action : SInputAction) {
		var playerType : ENR_PlayerType;

		if ( IsPressed(action) && theInput.IsActionPressed('NRUse') ) {
			FactsAdd("item_use_nr_chameleon_potion", 1);
			return true;
		}
		return false;
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
		// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: index = " + index + ", dataIndex = " + m_sceneSelector.GetPreviewDataIndex() + ", forceUnloadAll = " + forceUnloadAll + ", forceUnloadAllExceptHair = " + forceUnloadAllExceptHair);
		
		// unload saved and load preview
		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearancePreviewTemplates[slot] != "" || forceUnloadAll || (forceUnloadAllExceptHair && slot != ENR_RSlotHair)) {
				// unload saved
				if (m_appearanceTemplateIsLoaded[slot]) {
					// unload saved
					ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
					m_appearanceTemplateIsLoaded[slot] = false;
					changes = true;
				}
				// load preview if any
				if ((!IsRealEquipmentModeEnabled() || slot == ENR_RSlotHair) && m_appearancePreviewTemplates[slot] != "") {
					// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: load preview[" + slot + "] = " + m_appearancePreviewTemplates[slot]);
					IncludeAppearanceTemplate(m_appearancePreviewTemplates[slot]);
				}
			} else if ((!IsRealEquipmentModeEnabled() || slot == ENR_RSlotHair) && m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && !m_appearanceTemplateIsLoaded[slot]) {
				// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: load saved[" + slot + "] = " + m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				changes = true;
				// load saved
				m_appearanceTemplateIsLoaded[slot] = true;
				IncludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
			}
			// else do nothing
		}

		// handle items
		// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: m_appearanceItemIsLoaded.size = " + m_appearanceItemIsLoaded.Size());
		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: m_appearanceItemIsLoaded[" + i + "] = " + m_appearanceItemIsLoaded[i]);
			if ((forceUnloadAll || forceUnloadAllExceptHair) && m_appearanceItemIsLoaded[i]) {
				// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: handle (unload) item[" + i + "] = ");
				m_appearanceItemIsLoaded[i] = false;
				ExcludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
			} else if (!forceUnloadAll && !forceUnloadAllExceptHair && !m_appearanceItemIsLoaded[i]) {
				// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: handle (load) item[" + i + "] = ");
				m_appearanceItemIsLoaded[i] = true;
				IncludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
			}
		}

		// load preview items
		for (i = 0; i < m_appearancePreviewItems.Size(); i += 1) {
			changes = true;
			// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: load preview ITEM = " + m_appearancePreviewItems[i]);
			IncludeAppearanceTemplate(m_appearancePreviewItems[i]);
		}

		// load preview head
		if (IsNameValid(m_headPreviewName)) {
			// NR_Debug("NR_PlayerManager.OnDialogOptionSelected: load preview HEAD = " + NameToString(m_headPreviewName));
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
		// NR_Debug("NR_PlayerManager.OnDialogOptionAccepted: " + index + ", forceUnloadAll = " + forceUnloadAll + ", forceUnloadAllExceptHair = " + forceUnloadAllExceptHair);
		if (m_sceneSelector.SaveOnAccept(index, IsFemale())) {
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
	/* API */ public function GetPlayerDisplayNameLocStr() : String {
		return GetLocStringById( m_displayNameIDs[GetCurrentPlayerType()] );
	}
	
	// scene (preview) stuff functions //
	/* API */ public function SetPlayerDisplayName(nameID : int) {
		var lucky 	: int;
		var witcher : NR_ReplacerWitcher = NR_GetWitcherReplacer();

		// RANDOM
		if (nameID == 1) {
			lucky = RandRange(m_stringsStorage.stringIds.Size());
			nameID = m_stringsStorage.stringIds[lucky];
		}

		m_displayNameIDs[GetCurrentPlayerType()] = nameID;
		if (witcher && m_stringsStorage) {
			witcher.displayName = m_stringsStorage.GetLocalizedStringById(nameID);
			NR_Info("NR_PlayerManager.SetPlayerDisplayName: set nameID = " + nameID);
		} else {
			NR_Error("NR_PlayerManager.SetPlayerDisplayName: can't set nameID = " + nameID);
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
		} else if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "") {
			if (m_appearanceTemplateIsLoaded[slot]) {
				ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				m_appearanceTemplateIsLoaded[slot] = false;
			}

			m_appearanceTemplates[GetCurrentPlayerType()][slot] = "";
		}
	}

	// scene (preview) stuff functions //
	public function SaveAppearanceSet() : int {
		var set : NR_AppearanceSet;

		NR_Info("NR_PlayerManager.SaveAppearanceSet: playerType = " + GetCurrentPlayerType());
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

		return m_appearanceSets[IsFemaleInt()].Size();
	}

	public function GetAppearanceSetCount() : int {
		return m_appearanceSets[IsFemaleInt()].Size();
	}

	// scene (preview) stuff functions //
	public function LoadAppearanceSet(setIndex : int, optional isUserInput : bool) {
		var 	i 		: int;
		var 	slot 	: int;

		if (setIndex < 0 || setIndex >= m_appearanceSets[IsFemaleInt()].Size()) {
			if (isUserInput)
				NR_Notify("Can't load set #" + (setIndex + 1) + ", index must be [1 - " + m_appearanceSets[IsFemaleInt()].Size() + "]");
			return;
		}

		NR_Info("NR_PlayerManager.LoadAppearanceSet: setIndex = " + setIndex + ", playerType = " + GetCurrentPlayerType());
		ResetAllAppearanceHeadHair();
		m_appearanceTemplates[GetCurrentPlayerType()] = m_appearanceSets[IsFemaleInt()][setIndex].appearanceTemplates;
		m_appearanceItems[GetCurrentPlayerType()] = m_appearanceSets[IsFemaleInt()][setIndex].appearanceItems;
		UpdateHead(m_appearanceSets[IsFemaleInt()][setIndex].headName);
		LoadAppearanceTemplates();
		m_appearanceInfoTextExtra = GetLocStringById(2115940585) + IntToString(setIndex);
	}

	// scene (preview) stuff functions //
	public function RemoveAppearanceSet(setIndex : int) {
		if (setIndex < 0 || setIndex >= m_appearanceSets[IsFemaleInt()].Size())
			return;

		NR_Info("NR_PlayerManager.RemoveAppearanceSet: setIndex = " + setIndex + ", playerType = " + GetCurrentPlayerType());
		m_appearanceSets[IsFemaleInt()].Erase(setIndex);
		m_appearanceInfoTextExtra = GetLocStringById(2115940586) + IntToString(setIndex);

		if (IsFemaleInt())
			FactsSet("nr_appearance_sets_female", m_appearanceSets[1].Size());
		else
			FactsSet("nr_appearance_sets_male", m_appearanceSets[0].Size());
	}

	// scene (preview) stuff functions //
	public function UpdateSexSet() {
		m_appearanceSexSets[GetCurrentPlayerType()].appearanceTemplates = m_appearanceTemplates[GetCurrentPlayerType()];
		m_appearanceSexSets[GetCurrentPlayerType()].appearanceItems = m_appearanceItems[GetCurrentPlayerType()];
	}
	
	// scene (preview) stuff functions //
	public function ClearItemSlot(item_index : int) {
		NR_Info("NR_PlayerManager.ClearItemSlot: item_index = " + item_index);
		if (item_index == -1) {
			for (item_index = m_appearanceItems[GetCurrentPlayerType()].Size() - 1; item_index >= 0; item_index -= 1) {
				UpdateAppearanceItem("", item_index);
			}
		} else if (item_index >= 0 && item_index < m_appearanceItems[GetCurrentPlayerType()].Size()) {
			UpdateAppearanceItem("", item_index);
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
			if ( NR_IsKeyStrExists(m_sceneSelector.m_customDLCInfo[i].m_dlcNameKey) )
				info += "<font size=\"18\"><i>" + NR_StrLightBlue( NR_GetLocStringByKeyExt(m_sceneSelector.m_customDLCInfo[i].m_dlcNameKey) ) + "</i> ";
			else
				info += "<font size=\"18\"><i>" + NR_StrLightBlue( m_sceneSelector.m_customDLCInfo[i].m_dlcNameStr ) + "</i> ";

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
		FactsAdd("nr_quest_track_CustomDLCInfo", 1);
	}

	// scene (preview) stuff functions //
	public function GetTemplateFriendlyName(templateName : String) : String {
		var shortName : String;

		if (templateName == "") {
			return NR_StrRGB("[" + GetLocStringById(1070947) + "]", 25,0,0);  // "<Empty slot>"
		} else {
			shortName = StrBeforeLast( StrAfterLast(templateName, "/"), "." );
			if ( m_appearanceTemplatesLoadFailed.hasKey(templateName) )
				return shortName + NR_StrRGB(" [" + GetLocStringById(1223359) + "]", 50,0,0);
			else 
				return shortName;
		}
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
			// NR_Debug("NR_PlayerManager.UpdateAppearanceInfo: can't show");
			return;
		}

		showPreview = FactsQuerySum("nr_scene_show_preview_names") > 0;

		BR = "<br>";
		NBSP = "&nbsp;";
		SLOT_STR = GetLocStringById(2115940105);

		text = GetLocStringById(2115940583) + BR;
		if (IsRealEquipmentModeEnabled())
			text += GetLocStringById(2115940527) + BR;

		if (m_appearanceInfoTextExtra != "") {
			text += "  " + NR_StrBlue( m_appearanceInfoTextExtra, /*dark*/ true ) + BR;
			m_appearanceInfoTextExtra = "";
		}

		text += BR;
		text += "<font size=\"22\">" + GetLocStringById(2115940117) + ":" + NBSP + NR_StrRGB( GetCurrentPlayerTypeLocStr(), 25, 0, 25 ) + BR;
		if (GetCurrentPlayerScale() != 100) {
			text +=  GetLocStringById(2115940523) + ":" + NBSP + GetCurrentPlayerScale() + "%" + BR;
		}
		text += GetLocStringById(2115940558) + ":" + NBSP + NR_StrRGB( GetPlayerDisplayNameLocStr(), 0, 25, 25 ) + BR;
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
		}
	}

	// fun scene stuff function //
	function ApplyRandomNPCSet() {
		var nodeIndexes : array<int>;
		var choiceIndexes : array<int>;
		var i, j, lucky : int;
		
		if (IsFemale()) {
			for (i = 0; i < m_sceneSelector.m_nodesFemale.Size(); i += 1) {
				for (j = 0; j < m_sceneSelector.m_nodesFemale[i].m_onPreviewChoice.Size(); j += 1) {
					if (m_sceneSelector.m_nodesFemale[i].m_onPreviewChoice[j].m_flags & ENR_SPNPCSet) {
						nodeIndexes.PushBack(i);
						choiceIndexes.PushBack(j);
					}
				}
			}
		} else {
			for (i = 0; i < m_sceneSelector.m_nodesMale.Size(); i += 1) {
				for (j = 0; j < m_sceneSelector.m_nodesMale[i].m_onPreviewChoice.Size(); j += 1) {
					if (m_sceneSelector.m_nodesMale[i].m_onPreviewChoice[j].m_flags & ENR_SPNPCSet) {
						nodeIndexes.PushBack(i);
						choiceIndexes.PushBack(j);
					}
				}
			}
		}
		lucky = RandRange( nodeIndexes.Size() );
		// NR_Debug("NR_PlayerManager.ApplyRandomNPCSet: selected index = " + lucky + " of " + nodeIndexes.Size());
		m_sceneSelector.SetPreviewDataIndex(nodeIndexes[lucky], 0);
		OnDialogOptionSelected(choiceIndexes[lucky]);
		OnDialogOptionAccepted(choiceIndexes[lucky]);
		m_sceneSelector.SetPreviewDataIndex(-1, 0);
	}

	// Helper function //
	/* API */ function GetCurrentPlayerType() : ENR_PlayerType {
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
	/* API */ function GetCurrentPlayerTypeLocStr() : String {
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
	/* API */ public function IsReplacerActive() : Bool {
		var playerType : ENR_PlayerType;

		playerType = GetCurrentPlayerType();
		return (playerType != ENR_PlayerGeralt && playerType != ENR_PlayerCiri);
	}

	// True if we saved replacer type previously for a quest change
	public function HasReplacerForQuestSaved() : Bool {
		return m_replacerForQuestSaved != ENR_PlayerUnknown;
	}

	// Must be called before changing player type in quest
	public function SaveReplacerForQuest() {
		m_replacerForQuestSaved = GetCurrentPlayerType();
	}

	// Returns saved for quest type
	public function GetReplacerForQuest() : ENR_PlayerType {
		return m_replacerForQuestSaved;
	}

	// Returns and erase saved for quest type
	public function PullReplacerForQuest() : ENR_PlayerType {
		var ret : ENR_PlayerType;

		ret = m_replacerForQuestSaved;
		m_replacerForQuestSaved = ENR_PlayerUnknown;
		return ret;
	}

	// True if current player/replacer has female gender //
	/* API */ public function IsFemale() : Bool {
		return IsFemaleType(GetCurrentPlayerType());
	}

	// True if current player/replacer has female gender //
	/* API */ public function IsFemaleInt() : int {
		return (int)IsFemale();
	}

	// Helper function //
	/* API */ public function IsFemaleType(playerType : ENR_PlayerType) : Bool {
		return playerType != ENR_PlayerGeralt && playerType != ENR_PlayerWitcher;
	}

	// Main postponed function to fix player appearance on spawning (in any case) //
	protected function OnPlayerSpawned() {
		var 				i : int;
		var currentPlayerType : ENR_PlayerType;

		m_inventoryItemsToHide.Clear();
		m_inventoryItemsToShow.Clear();
		currentPlayerType = GetCurrentPlayerType();
		// NR_Debug("NR_PlayerManager.OnPlayerSpawned: current player = " + currentPlayerType + ", saved player = " + m_savedPlayerType);

		for (i = ENR_RSlotHair; i < ENR_RSlotMisc; i += 1) {
			m_appearanceTemplateIsLoaded[i] = false;
		}

		if ( currentPlayerType != m_savedPlayerType ) {
			// FROM GERALT
			if ( m_savedPlayerType == ENR_PlayerGeralt ) {
				// TO CUSTOM PLAYER
				SavePlayerData();
			// FROM REPLACER
			} else {
				// TO GERALT & have saved items
				if ( currentPlayerType == ENR_PlayerGeralt && m_geraltDataSaved ) {
					// OK, we asked for it - restore mounted items
					if ( m_playerChangeRequested ) {
						NR_FixPlayer();
					// BAD, it was auto-reset to Geralt after World change(?)
					} else {
						// NR_Debug("NR_PlayerManager.OnPlayerSpawned: changed to Geralt without request.");
						NR_ChangePlayer( m_savedPlayerType );
						return;
					}
				}
			}
		}
		// WAS CUSTOM REPLACER - Reset appearance templates always
		if ( m_savedPlayerType != ENR_PlayerGeralt && m_savedPlayerType != ENR_PlayerCiri ) {
			UnloadAppearanceTemplates();
		}
		// CUSTOM REPLACER - APPLY FIX ALWAYS
		if ( IsReplacerActive() ) {
			NR_FixReplacer();
		}
		m_playerChangeRequested = false;
		m_savedPlayerType = currentPlayerType;

		// update facts
		FactsRemove("nr_player_female");
		FactsRemove("nr_player_type");
		
		FactsAdd("nr_player_type", (int)currentPlayerType);
		if ( IsFemale() ) {
			FactsAdd("nr_player_female", 1);
		}
		UpdateMagicJoItem();
		UpdateSpeechSwitchFacts();
	}

	// Scene helper function //
	function UpdateSpeechSwitchFacts() {
		var controlValue : int;
		FactsRemove("nr_speech_switch");
		controlValue = FactsQuerySum("nr_speech_manual_control");

		// controlValue: 0 - auto, 1 - always female, 2 - never female
		if (controlValue < 1) {
			FactsAdd("nr_speech_switch", (int)IsFemale());
		} else if (controlValue == 1) {
			FactsAdd("nr_speech_switch", 1);
		}
	}

	// helper function (do not forget to unlock later using the same reason) //
	/* API */ public function SetPlayerTypeChangeLocked(locked : bool, reason : String) {
		if ( locked && !m_typeChangeLocks.Contains(reason) )  {
			m_typeChangeLocks.PushBack(reason);
		} else if ( !locked && m_typeChangeLocks.Contains(reason) ) {
			m_typeChangeLocks.Remove(reason);
		}
		
		NR_Info("NR_PlayerManager.SetPlayerTypeChangeLocked: " + locked + " (" + reason + ")");
		FactsRemove("nr_player_type_change_locked");
		if ( IsPlayerTypeChangeLocked() ) {
			FactsAdd("nr_player_type_change_locked", 1);
		}
	}

	// helper function //
	/* API */ public function IsPlayerTypeChangeLocked() : bool {
		return m_typeChangeLocks.Size() > 0;
	}
	
	/* API */ public function GetPlayerTypeChangeLocksExplanation() : String {
		var str : String;
		var   i : int;
		
		if ( IsPlayerTypeChangeLocked() ) {
			str += NR_GetLocStringByIdExt(1066070);
			str += " [" + IntToString(m_typeChangeLocks.Size()) + "]: " + m_typeChangeLocks[0];
			for (i = 1; i < m_typeChangeLocks.Size(); i += 1) {
				str += ", " + m_typeChangeLocks[i];
			}
			return str;
		} else {
			return NR_GetLocStringByIdExt(1066069);
		}
	}

	// helper function //
	/* API */ public function IsReady() : bool {
		return GetCurrentStateName() == 'Idle';
	}

	// inventory helper function
	public function UpdateInventoryTemplateAppearance(template : CEntityTemplate) {
		var templateResource : CEntityTemplate;
		var extraTemplateResources : array<CEntityTemplate>;
		var       i, j : int;

		for (i = ENR_RSlotHair; i < ENR_RSlotMisc; i += 1) {
			if ((IsRealEquipmentModeEnabled() && i != ENR_RSlotHair) || m_appearanceTemplates[GetCurrentPlayerType()][i] == "")
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
	protected function SavePlayerData() {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		m_geraltSavedItems[ENR_GSlotHead] = headManager.GetCurHeadName();

		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'hair' );
		
		for ( i = 0; i < ids.Size(); i += 1 )
		{
			if (inv.IsItemMounted(ids[i])) {
				m_geraltSavedItems[ENR_GSlotHair] = inv.GetItemName(ids[i]);
				break;
			}
		}
	}

	// Load replacer head item //
	protected function LoadHead(newHeadName : name) {
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		thePlayer.RememberCustomHead( newHeadName );
		headManager.BlockGrowing( true );
		headManager.SetCustomHead( newHeadName );
	}

	// Get current head name from player //
	public function GetCurrentHeadName() : name {
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));
		return headManager.GetCurHeadName();
	}

	// Updates saved replacer head item and load it //
	/* API */ public function UpdateHead(newHeadName : name) {
		m_headNames[GetCurrentPlayerType()] = newHeadName;
		if (!IsReplacerActive())
			return;

		LoadHead(newHeadName);
	}

	// Removes geralt hair item (part of NR_FixPlayer) <- to use c_ app template for replacers //
	/* API */ public function RemoveHair() {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var ret : Bool;

		if (!IsReplacerActive())
			return;

		inv = thePlayer.GetInventory();
		if (!inv) {
			// NR_Debug("NR_PlayerManager.Restore head: !inv");
			return;
		}
		ids = inv.GetItemsByCategory( 'hair' );
		
		for ( i = 0; i < ids.Size(); i += 1 )
		{
			if ( inv.IsItemMounted(ids[i]) )
				inv.UnmountItem(ids[i]);
			inv.RemoveItem(ids[i], 1);
		}
	}

	// Mounts geralt saved head item (part of NR_FixPlayer) //
	protected function RestoreHead() {
		var headManager : CHeadManagerComponent;

		headManager = (CHeadManagerComponent)(thePlayer.GetComponentByClassName( 'CHeadManagerComponent' ));

		if (!headManager) {
			// NR_Debug("Restore head: NULL!");
			return;
		}

		thePlayer.ClearRememberedCustomHead();
		headManager.BlockGrowing( false );
		//headManager.RemoveCustomHead();
		headManager.SetCustomHead( m_geraltSavedItems[ENR_GSlotHead] );
		// NR_Debug("Restore head: " + m_geraltSavedItems[ENR_GSlotHead]);
	}

	// Mounts geralt saved hair item (part of NR_FixPlayer) //
	protected function RestoreHair() {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i : int;
		var ret : Bool;

		inv = thePlayer.GetInventory();
		ids = inv.GetItemsByCategory( 'hair' );
		
		for ( i = 0; i < ids.Size(); i += 1 )
		{
			inv.RemoveItem(ids[i], 1);
		}

		if ( !IsNameValid(m_geraltSavedItems[ENR_GSlotHair]) )
			m_geraltSavedItems[ENR_GSlotHair] = 'Long Loose Hairstyle';
		// NR_Debug("Restore hair: " + m_geraltSavedItems[ENR_GSlotHair]);
		ids = inv.AddAnItem( m_geraltSavedItems[ENR_GSlotHair] );
		ret = inv.MountItem(ids[0]);
		// NR_Debug("Hair RMount: " + ret + ", " + inv.IsIdValid(ids[0]) + ", "  + inv.GetItemName(ids[0]));
	}

	// Mounts all geralt saved equipment items (part of NR_FixPlayer) //
	public function RestoreEquipment() {
		var inv  : CInventoryComponent;
		var i : int;
		var id : SItemUniqueId;
		inv = thePlayer.GetInventory();

		m_inventoryItemsToHide.Clear();
		for ( i = ENR_GSlotArmor; i <= ENR_GSlotBoots; i += 1 ) {
			NR_Info("NR_PlayerManager.RestoreEquipment[" + (ENR_AppearanceSlots)i + "] = " + m_geraltSavedItems[i]);
			id = inv.GetItemId( m_geraltSavedItems[i] );
			if ( inv.IsIdValid( id ) ) {
				NR_Debug("NR_PlayerManager.RestoreEquipment: mount saved item");
				// unmount first to make mounting really work
				// inv.UnmountItem( id );
				inv.MountItem( id );
				m_inventoryItemsToShow.PushBack(id);
			} else {
				id = inv.GetItemId( GetDefaultItemByCategory(NR_CategoryByENRSlot((ENR_AppearanceSlots) i)) );
				NR_Debug("NR_PlayerManager.RestoreEquipment: mount default item");
				if ( inv.IsIdValid( id ) ) {
					// unmount first to make mounting really work
					// inv.UnmountItem( id );
					inv.MountItem( id );
					m_inventoryItemsToShow.PushBack(id);
				}
			}
		}
	}
	
	// removes armor items from updating inventory entity when replacer
	public function RemoveArmorItems(inventory : CInventoryComponent, out items : array<SItemUniqueId>, out enhancements : array<SGuiEnhancementInfo>) {
		var i : int;
		var category : name;
		if ( !IsReplacerActive() )
			return;

		for (i = items.Size() - 1; i >= 0; i -= 1) {
			category = inventory.GetItemCategory(items[i]);
			// NR_Debug("SetEntityItems: items[" + i + "] = " + NR_stringByItemUID(inventory, items[i]) + ", " + category);
			if (!IsRealEquipmentModeEnabled() && (category == 'armor' || category == 'gloves' || category == 'pants' || category == 'boots'))
				items.Erase(i);
		}
		//for (i = enhancements.Size() - 1; i >= 0; i -= 1) {
		//	NR_Debug("SetEntityItems: enhancements[" + i + "] = " + enhancements[i].enhancedItem + ", " + enhancements[i].enhancement);
		//}
	}

	// Returns default item names for geralt (part of RemoveSavedItem) //
	public function GetDefaultItemByCategory(category : name) : name {
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

	// inventory helper function: removes geralt saved equippment item (when replacer: to mount default item correctly later) //
	public function RemoveSavedItem(id : SItemUniqueId) {
		var inv  : CInventoryComponent;
		var category : name;
		inv = thePlayer.GetInventory();

		category = inv.GetItemCategory(id);
		if (!IsRealEquipmentModeEnabled() && m_inventoryItemsToHide.Contains(id))
			m_inventoryItemsToHide.Remove(id);
		// NR_Debug("NR_PlayerManager.RemoveSavedItem : " + category);
		m_geraltSavedItems[ NR_ENRSlotByCategory(category) ] = GetDefaultItemByCategory(category);
	}

	// inventory helper function: : updates geralt saved equippment item (when replacer: to mount it correctly later) //
	public function UpdateSavedItem(id : SItemUniqueId) {
		var inv  : CInventoryComponent;
		var itemName, category : name;
		
		inv = thePlayer.GetInventory();

		if (!inv.IsIdValid(id))
			return;

		category = inv.GetItemCategory(id);
		itemName = inv.GetItemName(id);
		NR_Info("NR_PlayerManager.UpdateSavedItem : " + itemName + " (" + category + "), mounted = " + inv.IsItemMounted(id) + ", inStoryScene = " + theGame.IsDialogOrCutscenePlaying());
		if ( !IsRealEquipmentModeEnabled() && inv.IsItemMounted(id) && (category == 'armor' || category == 'gloves' || category == 'pants' || category == 'boots') )
		{
			m_inventoryItemsToHide.PushBack(id);
		}

		m_geraltSavedItems[ NR_ENRSlotByCategory(category) ] = itemName;
	}

	// Saves and unmounts all geralt equipment items (part of NR_FixReplacer) //
	public function UnmountEquipment() {
		var inv  : CInventoryComponent;
		var ids  : array<SItemUniqueId>;
		var i    : int;
		var equippedOnSlot : EEquipmentSlots;
		var appearanceSlot : ENR_AppearanceSlots;
		
		// TEST
		if (IsRealEquipmentModeEnabled())
			return;

		m_inventoryItemsToShow.Clear();
		inv = thePlayer.GetInventory();
		inv.GetAllItems(ids);
		NR_Info("NR_PlayerManager.UnmountEquipment (Geralt items)");

		for (i = 0; i < ids.Size(); i += 1) {
			if ( !inv.IsItemMounted(ids[i]) )
				continue;

			equippedOnSlot = GetWitcherPlayer().GetItemSlot( ids[i] );
			
			if ( NR_GetWitcherReplacer().NR_IsSlotDenied(equippedOnSlot) ) {
				NR_GetWitcherReplacer().UnequipItemFromSlot( equippedOnSlot );
			}

			appearanceSlot = NR_EEquipmentSlotToENRSlot( equippedOnSlot );
			if ( appearanceSlot == ENR_GSlotArmor || appearanceSlot == ENR_GSlotGloves ||
				 appearanceSlot == ENR_GSlotBoots || appearanceSlot == ENR_GSlotPants ||
				(inv.ItemHasTag(ids[i], 'Body') && StrStartsWith(NR_stringByItemUID(inv, ids[i]), "Body")) )
			{
				UpdateSavedItem( ids[i] );
				// NR_Debug("NR_PlayerManager.UnmountEquipment: " + NR_stringByItemUID(inv, ids[i]) + ", name: " + inv.GetItemName(ids[i]) + " slot = " + equippedOnSlot);
			}
		}
	}

	// Load template (if templateName != "") //
	protected function IncludeAppearanceTemplate(templateName : String) {
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
				// NR_Debug("NR_PlayerManager.IncludeAppearanceTemplate: templateName = " + templateName);
			} else {
				if ( !m_appearanceTemplatesLoadFailed.hasKey(templateName) ) {
					m_appearanceTemplatesLoadFailed.setI(templateName, 1);
				}
				NR_Error("NR_PlayerManager.IncludeAppearanceTemplate: !template = " + templateName);
			}
		} else {
			NR_Error("NR_PlayerManager.IncludeAppearanceTemplate: !appearanceComponent");
		}
	}

	// Unload template (if templateName != "") //
	protected function ExcludeAppearanceTemplate(templateName : String) {
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
				// NR_Debug("NR_PlayerManager.ExcludeAppearanceTemplate: templateName = " + templateName);
			} else {
				NR_Error("NR_PlayerManager.ExcludeAppearanceTemplate: !template = " + templateName);
			}
		} else {
			NR_Error("NR_PlayerManager.ExcludeAppearanceTemplate: !appearanceComponent");
		}
	}

	// All templates added to preview (and loaded) overwrite saved templates data //
	protected function SaveAllAppearancePreviewTemplates(forceUnloadAllExceptHair : bool, forceUnloadAll : bool) : bool {
		var 	i 		: int;
		var 	slot 	: int;
		var anyChanges	: bool;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearancePreviewTemplates[slot] == "") {
				if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && (forceUnloadAll || (forceUnloadAllExceptHair && slot != ENR_RSlotHair))) {
					m_appearanceTemplates[GetCurrentPlayerType()][slot] = "";
					m_appearanceTemplateIsLoaded[slot] = false;
					anyChanges = true;
				}
				continue;
			}
			
			anyChanges = true;
			m_appearanceTemplates[GetCurrentPlayerType()][slot] = m_appearancePreviewTemplates[slot];
			m_appearanceTemplateIsLoaded[slot] = true;

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
	protected function ResetAllAppearancePreviewTemplates() {
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

	// Helper function: updates template in given slot: Exclude old + Include new (if new != "") //
	/* API */ public function UpdateAppearanceTemplate(templateName : String, slot : ENR_AppearanceSlots) {
		// NR_Debug("NR_PlayerManager.UpdateAppearanceTemplate: templateName = " + templateName + ", slot = " + slot);
		if (IsReplacerActive() && m_appearanceTemplateIsLoaded[slot]) {
			ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
			m_appearanceTemplateIsLoaded[slot] = false;
		}

		m_appearanceTemplates[GetCurrentPlayerType()][slot] = templateName;

		if ((!IsRealEquipmentModeEnabled() || slot == ENR_RSlotHair) && IsReplacerActive() && m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && !m_appearanceTemplateIsLoaded[slot]) {
			IncludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
			m_appearanceTemplateIsLoaded[slot] = true;
		}
	}

	// Helper function: updates template ITEM (slot == ENR_RSlotMisc) in given slot: Exclude old + Include new (if new != "") //
	// itemIndex: defines if given template should be appended (-1) or replace existing [0; itemCount - 1] //
	/* API */ public function UpdateAppearanceItem(templateName : String, itemIndex : int) {
		// NR_Debug("NR_PlayerManager.UpdateAppearanceItem: templateName = " + templateName + ", itemIndex = " + itemIndex);
		// NR_Debug("NR_PlayerManager.UpdateAppearanceItem: m_appearanceItems.size = " + m_appearanceItems[GetCurrentPlayerType()].Size() + ", m_appearanceItemIsLoaded.size = " + m_appearanceItemIsLoaded.Size());
		if (itemIndex < 0 || itemIndex >= m_appearanceItems[GetCurrentPlayerType()].Size()) {
			// CREATE cell
			m_appearanceItems[GetCurrentPlayerType()].PushBack(templateName);
			m_appearanceItemIsLoaded.PushBack(false);

			itemIndex = m_appearanceItems[GetCurrentPlayerType()].Size() - 1;
			FactsAdd("nr_appearance_item_" + IntToString(itemIndex), 1);
		} else {
			// UNLOAD cell
			if (m_appearanceItems[GetCurrentPlayerType()][itemIndex] != "" && m_appearanceItemIsLoaded[itemIndex]) {
				m_appearanceItemIsLoaded[itemIndex] = false;
				ExcludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][itemIndex]);
			}
			m_appearanceItems[GetCurrentPlayerType()][itemIndex] = templateName;
		}

		if (m_appearanceItems[GetCurrentPlayerType()][itemIndex] == "") {
			// REMOVE cell //
			m_appearanceItems[GetCurrentPlayerType()].Erase(itemIndex);
			m_appearanceItemIsLoaded.Erase(itemIndex);

			itemIndex = m_appearanceItems[GetCurrentPlayerType()].Size();
			FactsRemove("nr_appearance_item_" + IntToString(itemIndex));
		} else if (!m_appearanceItemIsLoaded[itemIndex]) {
			// LOAD cell //
			m_appearanceItemIsLoaded[itemIndex] = true;
			IncludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][itemIndex]);
		}
	}

	public function UpdateNeckTransitionVisibility() {
		var mesh : CMeshComponent;

		mesh = (CMeshComponent)thePlayer.GetComponent( "h_mg__neck_transition" );
		mesh.SetVisible( IsNeckTransitionVisible() );
	}

	// Includes all saved appearance templates (on player reload) //
	/* API */ public function LoadAppearanceTemplates() {
		var slot : int;
		var i	 : int;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if ((!IsRealEquipmentModeEnabled() || slot == ENR_RSlotHair) && m_appearanceTemplates[GetCurrentPlayerType()][slot] != "" && !m_appearanceTemplateIsLoaded[slot]) {
				// NR_Debug("LoadAppearanceTemplates: slot = " + slot + ", " + m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				IncludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				m_appearanceTemplateIsLoaded[slot] = true;
			}
		}

		m_appearanceItemIsLoaded.Clear();
		for (i = 0; i < 30; i += 1) {
			FactsRemove("nr_appearance_item_" + IntToString(i));
		}
		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			IncludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
			m_appearanceItemIsLoaded.PushBack(true);
			FactsAdd("nr_appearance_item_" + IntToString(i), 1);
		}
		UpdateNeckTransitionVisibility();
	}

	// Excludes all saved appearance templates (on player reload) //
	protected function UnloadAppearanceTemplates(optional equipmentOnly : bool) {
		var slot : int;
		var i	 : int;

		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (slot == ENR_RSlotHair && equipmentOnly)
				continue;

			if (m_appearanceTemplates[GetCurrentPlayerType()][slot] != "") {
				ExcludeAppearanceTemplate(m_appearanceTemplates[GetCurrentPlayerType()][slot]);
				m_appearanceTemplateIsLoaded[slot] = false;
			}
		}

		if (equipmentOnly)
			return;

		for (i = 0; i < m_appearanceItems[GetCurrentPlayerType()].Size(); i += 1) {
			ExcludeAppearanceTemplate(m_appearanceItems[GetCurrentPlayerType()][i]);
		}
	}

	// stuff functions - to reload slots and fix floating templates //
	public function ReloadAllAppearanceHeadHair() {
		var l_appearanceTemplates : array<String>;
		var l_appearanceItems : array<String>;
		var l_headName : name;
		var i : int;

		l_appearanceTemplates = m_appearanceTemplates[GetCurrentPlayerType()];
		l_appearanceItems = m_appearanceItems[GetCurrentPlayerType()];
		l_headName = m_headNames[GetCurrentPlayerType()];
		ResetAllAppearanceHeadHair();

		NR_Info("NR_PlayerManager.ReloadAllAppearanceHeadHair: playerType = " + GetCurrentPlayerType());
		NR_Info("NR_PlayerManager.ReloadAllAppearanceHeadHair: headName = " + l_headName);
		for (i = ENR_RSlotHair; i < ENR_RSlotMisc; i += 1) {
			if (l_appearanceTemplates[i] != "")
				NR_Info("NR_PlayerManager.ReloadAllAppearanceHeadHair: appearanceTemplates[" + (ENR_AppearanceSlots)i + "] = " + l_appearanceTemplates[i]);
		}
		for (i = 0; i < l_appearanceItems.Size(); i += 1) {
			NR_Info("NR_PlayerManager.ReloadAllAppearanceHeadHair: appearanceItems[" + i + "] = " + l_appearanceItems[i]);
		}

		UpdateHead(l_headName);
		m_appearanceTemplates[GetCurrentPlayerType()] = l_appearanceTemplates;
		m_appearanceItems[GetCurrentPlayerType()] = l_appearanceItems;
		LoadAppearanceTemplates();
	}
	
	// Resets ALL saved templates
	/* API */ public function ResetAllAppearanceTemplates() {
		var slot, item_index : int;
		
		/* Set all slots to nothing, will unload if any template was loaded */
		for (slot = ENR_RSlotHair; slot < ENR_RSlotMisc; slot += 1) {
			if (m_appearanceTemplates[GetCurrentPlayerType()][slot] == "")
				continue;

			UpdateAppearanceTemplate("", slot);
		}
		
		// NR_Debug("NR_PlayerManager.ResetAllAppearanceHeadHair: m_appearanceItems size = " + m_appearanceItems[GetCurrentPlayerType()].Size());
		for (item_index = m_appearanceItems[GetCurrentPlayerType()].Size() - 1; item_index >= 0; item_index -= 1) {
			UpdateAppearanceItem("", item_index);
		}
	}

	// Resets ALL saved templates + head + hair (used before applying new character set, manually from scene) //
	/* API */ public function ResetAllAppearanceHeadHair() {
		ResetAllAppearanceTemplates();
		
		if (IsFemale())
			UpdateHead('nr_h_01_wa__yennefer'); // set default yennefer head
		else
			UpdateHead('head_0');  // set default geralt head */
		RemoveHair();  // set no hair item
	}

	// Fixes replacer appearance (on loading, after type changing) //
	protected function NR_FixReplacer() {
		var witcher : NR_ReplacerWitcher = NR_GetWitcherReplacer();

		NR_Info("NR_PlayerManager.NR_FixReplacer");
		if ( IsRealEquipmentModeEnabled() ) {
			RestoreEquipment();
		} else {
			UnmountEquipment();
		}
		RemoveHair();  // saves and remove geralt hair
		UpdateHead(m_headNames[GetCurrentPlayerType()]);  // saves and replace geralt head
		LoadAppearanceTemplates();  // load saved replacer templates
		SetPlayerDisplayName( m_displayNameIDs[GetCurrentPlayerType()] );
		ApplyCurrentPlayerScale();
		m_geraltDataSaved = true;
	}

	// Fixes player appearance (after type chaning only) //
	protected function NR_FixPlayer() {
		NR_Info("NR_PlayerManager.NR_FixPlayer");
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
		NR_Info("NR_PlayerManager::Idle.OnEnterState");
		RunIdle();
	}
	
	function IsRealItemEquippedOnSlot( slot : ENR_AppearanceSlots ) : bool {
		var item : SItemUniqueId;
		var itemStr : String;
		
		// theGame.IsDialogOrCutscenePlaying()
		// GetWitcherPlayer().GetItemEquippedOnSlot( slot, item );
		itemStr = NameToString(parent.m_geraltSavedItems[slot]);
		if ( itemStr == "" || StrStartsWith(itemStr, "Body ") ) {
			return false;
		} else {
			return true;
		}
	}

	entry function RunIdle() {
		var entity : CEntity;
		var i : int;
		var item : SItemUniqueId;
		var armor, gloves, pants, boots : bool;
		var readyIdsHide, readyIdsShow : array<SItemUniqueId>;

		while (true) {
			SleepOneFrame();

			// CHECK HIDE
			for (i = parent.m_inventoryItemsToHide.Size() - 1; i >= 0; i -= 1) {
				if ( !thePlayer.inv.IsIdValid(parent.m_inventoryItemsToHide[i]) ) {
					NR_Debug("NR_PlayerManager.Idle: hide id[" + i + "] is invalid");
					parent.m_inventoryItemsToHide.Erase(i);
					continue;
				}

				entity = thePlayer.inv.GetItemEntityUnsafe( parent.m_inventoryItemsToHide[i] );
				if (entity) {
					NR_Debug("NR_PlayerManager.Idle: adding ready to hide entity: " + entity);
					readyIdsHide.PushBack(parent.m_inventoryItemsToHide[i]);
					parent.m_inventoryItemsToHide.Erase(i);
				}
			}

			// CHECK SHOW
			for (i = parent.m_inventoryItemsToShow.Size() - 1; i >= 0; i -= 1) {
				if ( !thePlayer.inv.IsIdValid(parent.m_inventoryItemsToShow[i]) ) {
					NR_Debug("NR_PlayerManager.Idle: show id[" + i + "] is invalid");
					parent.m_inventoryItemsToShow.Erase(i);
					continue;
				}

				entity = thePlayer.inv.GetItemEntityUnsafe( parent.m_inventoryItemsToShow[i] );
				if (entity) {
					NR_Debug("NR_PlayerManager.Idle: adding ready to show entity: " + entity);
					readyIdsShow.PushBack(parent.m_inventoryItemsToShow[i]);
					parent.m_inventoryItemsToShow.Erase(i);
				}
			}

			// let the entity and components to update
			Sleep(0.1f);
			for (i = 0; i < readyIdsHide.Size(); i += 1) {
				entity = thePlayer.inv.GetItemEntityUnsafe( readyIdsHide[i] );
				entity.SetHideInGame(true);
				NR_Debug("NR_PlayerManager.Idle: hide item[" + i + "] = " + thePlayer.inv.GetItemName(readyIdsHide[i]) + "(" + entity + ")");
			}
			readyIdsHide.Clear();

			for (i = 0; i < readyIdsShow.Size(); i += 1) {
				entity = thePlayer.inv.GetItemEntityUnsafe( readyIdsShow[i] );
				entity.SetHideInGame(false);
				NR_Debug("NR_PlayerManager.Idle: show item[" + i + "] = " + thePlayer.inv.GetItemName(readyIdsShow[i]) + "(" + entity + ")");
			}
			readyIdsShow.Clear();
			
			// use naked appearance set if it enabled and no equipment and not in setup scene
			// NR_Debug("m_appearanceSexSetInUse = " + parent.m_appearanceSexSetInUse + ", IsSexSetEnabled = " + parent.IsSexSetEnabled());
			armor = IsRealItemEquippedOnSlot( ENR_GSlotArmor );
			gloves = IsRealItemEquippedOnSlot( ENR_GSlotGloves );
			pants = IsRealItemEquippedOnSlot( ENR_GSlotPants );
			boots = IsRealItemEquippedOnSlot( ENR_GSlotBoots );
			if ( !parent.m_appearanceSexSetInUse && parent.IsSexSetEnabled() )
			{
				// check if we can ENABLE sex set
				if ( !armor && !gloves && !pants && !boots && !NR_IsSceneInPreviewState() )
				{
					// NR_Debug("any equipped item unloaded, load sex set");
					parent.m_appearanceNonSexSet.appearanceTemplates = parent.m_appearanceTemplates[parent.GetCurrentPlayerType()];
					parent.m_appearanceNonSexSet.appearanceItems = parent.m_appearanceItems[parent.GetCurrentPlayerType()];
					
					// copy hair template to sex set
					if ( parent.m_appearanceTemplates[parent.GetCurrentPlayerType()][ENR_RSlotHair] != "" )
						parent.m_appearanceSexSets[parent.GetCurrentPlayerType()].appearanceTemplates[ENR_RSlotHair] = parent.m_appearanceTemplates[parent.GetCurrentPlayerType()][ENR_RSlotHair];
					
					parent.ResetAllAppearanceTemplates();
					parent.m_appearanceTemplates[parent.GetCurrentPlayerType()] = parent.m_appearanceSexSets[parent.GetCurrentPlayerType()].appearanceTemplates;
					parent.m_appearanceItems[parent.GetCurrentPlayerType()] = parent.m_appearanceSexSets[parent.GetCurrentPlayerType()].appearanceItems;
					parent.LoadAppearanceTemplates();
					parent.m_appearanceSexSetInUse = true;
				}
			} else if ( parent.m_appearanceSexSetInUse ) {
				// check if we can DISABLE sex set
				if ( armor || gloves || pants || boots || NR_IsSceneInPreviewState() || !parent.IsSexSetEnabled() )
				{
					// NR_Debug("any equipped item loaded, unload sex set");
					parent.ResetAllAppearanceTemplates();
					// restore back
					parent.m_appearanceTemplates[parent.GetCurrentPlayerType()] = parent.m_appearanceNonSexSet.appearanceTemplates;
					parent.m_appearanceItems[parent.GetCurrentPlayerType()] = parent.m_appearanceNonSexSet.appearanceItems;
					parent.LoadAppearanceTemplates();
					parent.m_appearanceSexSetInUse = false;
				}
			}
		}
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Info("NR_PlayerManager::Idle.OnLeaveState");
	}
}

state GameLaunched in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		NR_Info("NR_PlayerManager::GameLaunched.OnEnterState");
		RunGameLaunched();
	}

	entry function RunGameLaunched() {
		var startTime : float;
		
		// NR_Debug("NR_PlayerManager::GameLaunched.RunGameLaunched");
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.OnStarted();
		thePlayer.SetVisibility(false);
		
		// wait until player appearance component is loaded
		while ( thePlayer.GetComponentsCountByClassName( 'CAppearanceComponent' ) < 1 ) {
			SleepOneFrame();
		}
		NR_Info("NR_PlayerManager::GameLaunched.RunGameLaunched: Player is ready after = " + (theGame.GetEngineTimeAsSeconds() - startTime));
		parent.OnPlayerSpawned();
		thePlayer.SetVisibility(true);
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Info("NR_PlayerManager::GameLaunched.OnLeaveState");
	}
}

state PlayerChange in NR_PlayerManager {
	event OnEnterState( prevStateName : name )
	{
		NR_Info("NR_PlayerManager::PlayerChange.OnEnterState");
		RunPlayerChange();
	}

	entry function RunPlayerChange() {
		var startTime : float;
		
		// NR_Debug("NR_PlayerManager::PlayerChange.RunPlayerChange");
		thePlayer.SetVisibility(false);
		// wait player entity to change
		Sleep(0.25f);
		startTime = theGame.GetEngineTimeAsSeconds();
		// wait until player appearance component is loaded
		while ( thePlayer.GetComponentsCountByClassName( 'CAppearanceComponent' ) < 1 ) {
			SleepOneFrame();
		}
		NR_Info("NR_PlayerManager::PlayerChange.RunPlayerChange: Player is ready after = " + (theGame.GetEngineTimeAsSeconds() - startTime));
		parent.OnPlayerSpawned();
		// FactsAdd("nr_player_change_done", 1);
		thePlayer.SetVisibility(true);
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
		NR_Info("NR_PlayerManager::PlayerChange.OnLeaveState");
	}
}

// async version: returns control as fast as possible (thePlayer may be not ready!)
function NR_ChangePlayer(newPlayerType : ENR_PlayerType, optional nakedCiriTemplate : bool) {
	var manager    : NR_PlayerManager;
	var wasSexSetEnabled : bool;

	NR_Info("NR_ChangePlayer: newPlayerType = " + newPlayerType);
	manager = NR_GetPlayerManager();
	
	if (manager.GetCurrentPlayerType() == newPlayerType)
		return;

	if ( NR_GetReplacerSorceress() ) {
		NR_GetReplacerSorceress().OnDestroying();
	}

	manager.SetPlayerChangeRequested( true );
	wasSexSetEnabled = manager.IsSexSetEnabled();
	manager.DisableSexSetSync();
	switch (newPlayerType) {
		case ENR_PlayerGeralt:
			theGame.ChangePlayer( "Geralt" );
			break;
		case ENR_PlayerCiri:
			if (nakedCiriTemplate)
				theGame.ChangePlayer( "Ciri_naked" );
			else
				theGame.ChangePlayer( "Ciri" );
			break;
		case ENR_PlayerWitcher:
			theGame.ChangePlayer( "nr_replacer_witcher" );
			break;
		case ENR_PlayerWitcheress:
			theGame.ChangePlayer( "nr_replacer_witcheress" );
			break;
		case ENR_PlayerSorceress:
			theGame.ChangePlayer( "nr_replacer_sorceress" );
			break;
		default:
			NR_Error("NR_ChangePlayer: unknown player type = " + newPlayerType);
			break;
	}

	thePlayer.Debug_ReleaseCriticalStateSaveLocks();
	if ( wasSexSetEnabled ) {
		manager.SetIsSexSetEnabled( true );
	}
	manager.GotoState('PlayerChange');
}

// latent version: returns control only when new thePlayer is loaded and ready
/* API */ latent function NR_ChangePlayerLatent(newPlayerType : ENR_PlayerType, optional nakedCiriTemplate : bool) {
	var manager    : NR_PlayerManager;

	NR_Info("NR_ChangePlayerLatent: newPlayerType = " + newPlayerType);
	manager = NR_GetPlayerManager();
	
	NR_ChangePlayer( newPlayerType, nakedCiriTemplate );
	while (manager.GetCurrentPlayerType() != newPlayerType || !manager.IsReady()) {
		SleepOneFrame();
	}
	NR_Info("NR_ChangePlayerLatent: READY");
}

/* API */ function NR_GetPlayerManager() : NR_PlayerManager
{
	if ( !theGame.nr_playerManager || theGame.nr_playerManager.GetDataFormatVersion() < 2 ) {
		NR_CreatePlayerManager( theGame );
	}

	return theGame.nr_playerManager;
}

function NR_OnGameStarted() {
	NR_Info("NR_OnGameStarted");
	NR_GetPlayerManager().GotoState('GameLaunched');
}

function NR_CreatePlayerManager(theGameObject : CR4Game) {
	if ( !theGameObject.nr_playerManager || theGameObject.nr_playerManager.GetDataFormatVersion() < 2 ) {
		theGameObject.nr_playerManager = new NR_PlayerManager in theGameObject;
		theGameObject.nr_playerManager.Init();
		NR_Info("NR_CreatePlayerManager: PlayerManager has been just created");
	}
}

function NR_ErasePlayerManager(theGameObject : CR4Game, reason : String) {
	NR_Info("NR_ErasePlayerManager: reason = " + reason);
	if (theGameObject.nr_playerManager) {
		delete theGameObject.nr_playerManager;
		theGameObject.nr_playerManager = NULL;
	}
}


// example console functions
exec function NRToGeralt() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	if (manager) {
		NR_ChangePlayer(ENR_PlayerGeralt);
	}
}

exec function NRToCiri() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	if (manager) {
		NR_ChangePlayer(ENR_PlayerCiri);
	}
}

exec function NRToWitcher() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	if (manager) {
		NR_ChangePlayer(ENR_PlayerWitcher);
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_ma__eskel');
		// manager.RemoveHair();
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/secondary_npc/eskel/body_01_ma__eskel.w2ent", /*slot*/ ENR_RSlotBody);
	}
}

exec function NRToWitcheress() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	if (manager) {
		NR_ChangePlayer(ENR_PlayerWitcheress); // change player type in the last queue
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_wa__edna');
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/bob/data/characters/models/main_npc/oriana/body_01_wa__oriana.w2ent", /*slot*/ ENR_RSlotDress);
		manager.UpdateAppearanceTemplate(/*path*/ "dlc/ep1/data/characters/models/secondary_npc/shani/c_01_wa__shani_hair.w2ent", /*slot*/ ENR_RSlotHair);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/common/woman_average/body/a2g_02_wa__body.w2ent", /*slot*/ ENR_RSlotGloves);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/torso/t3d_02_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotTorso);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/skellige_warrior_woman/arms/a_01_wa__skellige_warrior_woman.w2ent", /*slot*/ ENR_RSlotArms);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/legs/l2_06_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotLegs);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/crowd_npc/novigrad_citizen_woman/shoes/s_05_wa__novigrad_citizen.w2ent", /*slot*/ ENR_RSlotShoes);
	}
}

exec function NRToSorceress() {
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	if (manager) {
		NR_ChangePlayer(ENR_PlayerSorceress); // change player type in the last queue
		manager.ResetAllAppearanceHeadHair();
		manager.UpdateHead('nr_h_01_wa__triss');
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/body_01_wa__triss.w2ent", /*slot*/ ENR_RSlotBody);
		manager.UpdateAppearanceTemplate(/*path*/ "characters/models/main_npc/triss/c_01_wa__triss.w2ent", /*slot*/ ENR_RSlotHair);
	}
}

exec function NRSaveMyAppearance() {
	NR_Notify("Saved as set #" + NR_GetPlayerManager().SaveAppearanceSet());
}

exec function NRLoadMyAppearance(index : int) {
	NR_GetPlayerManager().LoadAppearanceSet(index - 1, true);
}

exec function NRRemoveMyAppearance(index : int) {
	if (index < 1 || index > NR_GetPlayerManager().GetAppearanceSetCount()) {
		NR_Notify("Can't remove set #" + index + ", index must be [1 - " + NR_GetPlayerManager().GetAppearanceSetCount());
		return;
	}
	NR_GetPlayerManager().RemoveAppearanceSet(index - 1);
	NR_Notify("Removed set #" + index);
}
