// Appearance stuff
storyscene function NR_SetPreviewDataIndex_S(player: CStoryScenePlayer, data_index : int, choice_offset : int) {
	NR_GetPlayerManager().SetPreviewDataIndex(data_index, choice_offset);
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_ClearAppearanceSlot_S(player: CStoryScenePlayer, slot_index : int) {
	NR_GetPlayerManager().ClearAppearanceSlot((ENR_AppearanceSlots)slot_index);
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_ClearItemSlot_S(player: CStoryScenePlayer, item_index : int) {
	NR_GetPlayerManager().ClearItemSlot(item_index);
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_ClearAllSlotsItems_S(player: CStoryScenePlayer) {
	NR_GetPlayerManager().ResetAllAppearanceHeadHair();
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_ApplyRandomNPCSet_S(player: CStoryScenePlayer) {
	NR_GetPlayerManager().ApplyRandomNPCSet();
}

storyscene function NR_UserSetsSave_S(player: CStoryScenePlayer) {
	NR_GetPlayerManager().SaveAppearanceSet();
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_UserSetsLoad_S(player: CStoryScenePlayer, setIndex : int) {
	NR_GetPlayerManager().LoadAppearanceSet(setIndex);
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_UserSetsRemove_S(player: CStoryScenePlayer, setIndex : int) {
	NR_GetPlayerManager().RemoveAppearanceSet(setIndex);
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_ShowAppearanceInfo_S(player: CStoryScenePlayer) {
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_SetupMasterApprenticeQuestions_S(player: CStoryScenePlayer) {
	var generator : NR_RandomGenerator;

	// to make it more variative
    generator = NR_GetRandomGenerator();
    FactsSet("nr_master_apprentice_q1", generator.nextRange(1, 100));
    FactsSet("nr_master_apprentice_q2", generator.nextRange(1, 100));
    FactsSet("nr_master_apprentice_q3", generator.nextRange(1, 100));
}

latent storyscene function NR_ShowCustomDLCInfo_S(player: CStoryScenePlayer) {
	NR_GetPlayerManager().HideAppearanceInfo();
	NR_GetPlayerManager().ShowCustomDLCInfo();
}

storyscene function NR_SetPlayerDisplayName_S(player: CStoryScenePlayer, nameID : int) {
	NR_GetPlayerManager().SetPlayerDisplayName(nameID);
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_SwitchIncludeAsItem_S(player: CStoryScenePlayer) {
	if (FactsQuerySum("nr_scene_stacking_as_items") < 1) {
		FactsAdd("nr_scene_stacking_as_items", 1);
	} else {
		FactsRemove("nr_scene_stacking_as_items");
	}
}

storyscene function NR_SwitchAppearanceMode_S(player: CStoryScenePlayer) {
	if ( NR_GetPlayerManager().IsRealEquipmentModeEnabled() ) {
		NR_GetPlayerManager().SetIsRealEquipmentModeEnabled(false);
	} else {
		NR_GetPlayerManager().SetIsRealEquipmentModeEnabled(true);
	}
	NR_GetPlayerManager().ShowAppearanceInfo();
}

latent storyscene function NR_ChoosePlayerScale_S(player: CStoryScenePlayer) {
	var playerManager 	: NR_PlayerManager = NR_GetPlayerManager();
	var newValue : int;

	newValue = NR_SelectIntegerValue(/*title*/ 2115940524, /*min*/ 50, /*max*/ 200, /*current*/ playerManager.GetCurrentPlayerScale());
	playerManager.SetCurrentPlayerScale( newValue );
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_SwitchPreviewNames_S(player: CStoryScenePlayer) {
	if (FactsQuerySum("nr_scene_show_preview_names") < 1) {
		FactsAdd("nr_scene_show_preview_names", 1);
	} else {
		FactsRemove("nr_scene_show_preview_names");
	}
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_SwitchFemaleSpeech_S(player: CStoryScenePlayer) {
	var value : int;

	value = FactsQuerySum("nr_speech_manual_control");
	value = (value + 1) % 3;
	FactsSet("nr_speech_manual_control", value);
	NR_GetPlayerManager().UpdateSpeechSwitchFacts();
}

storyscene function NR_FactsSet_S(player: CStoryScenePlayer, factName : string, value : int) {
	FactsSet(factName, value);
}

// Magic stuff
storyscene function NR_SetMagicInSetupScene_S(player: CStoryScenePlayer, inSetupScene : bool) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetIsInSetupScene(inSetupScene);
	magicManager.HandFX(inSetupScene);

	if (inSetupScene) {
		NR_EnterScenePreviewState('NR_ScenePreviewSpells_DialogState');
	} else {
		NR_ExitScenePreviewState();
		magicManager.HideMagicInfo();
	}
}

// Magic stuff
storyscene function NR_ShowMagicInfo_S(player: CStoryScenePlayer, sectionName : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_ShowMagicInfo_S: sectionName = " + sectionName);
	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.ShowMagicInfo(sectionName);
}

storyscene function NR_SetMagicSignName_S(player: CStoryScenePlayer, signName : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_SetMagicSignName_S: signName = " + signName);
	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetSceneSign(SignNameToEnum(signName));
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicUpdateHandFx_S(player: CStoryScenePlayer) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.HandFX(true);
}

storyscene function NR_SetMagicActionType_S(player: CStoryScenePlayer, actionType : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_SetMagicActionType_S: actionType = " + ENR_MAToName((ENR_MagicAction)actionType));
	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetActionType((ENR_MagicAction)actionType);
}

storyscene function NR_SimulateLongMagicAction_S(player: CStoryScenePlayer, actionType : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_SimulateLongMagicAction_S: actionType = " + ENR_MAToName((ENR_MagicAction)actionType));
	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetActionType((ENR_MagicAction)actionType);
	magicManager.AddActionEvent( 'InitAction', 'SimulateLongMagicAction' );
	magicManager.AddActionEvent( 'Prepare', 'SimulateLongMagicAction' );
	magicManager.AddActionEvent( 'PerformMagicAttack', 'SimulateLongMagicAction' );
}

storyscene function NR_SetMagicLightRatio_S(player: CStoryScenePlayer, slashNum : int, throwNum : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_SetMagicLightRatio_S: slashNum = " + slashNum + ", throwNum = " + throwNum);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamInt('universal', "light_slash_amount", slashNum);
	magicManager.SetParamInt('universal', "light_throw_amount", throwNum);
	magicManager.InitAspectsSelectors();
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicHeavyRatio_S(player: CStoryScenePlayer, rocksNum : int, bombNum : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_SetMagicHeavyRatio_S: slashNum = " + rocksNum + ", bombNum = " + bombNum);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamInt('universal', "heavy_rocks_amount", rocksNum);
	magicManager.SetParamInt('universal', "heavy_bomb_amount", bombNum);
	magicManager.InitAspectsSelectors();
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetColorPerSignActions_S(player: CStoryScenePlayer, signName : name, colorValue : int, signStrId: int, colorStrId : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	var sign : ESignType = SignNameToEnum(signName);

	if (!magicManager) {
		NR_Error("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}

	magicManager.SetColorPerSignActions(sign, (ENR_MagicColor)colorValue);
	magicManager.HandFX(/*enable*/ false, /*onlyIfActive*/ true);
	magicManager.HandFX(/*enable*/ true);

	NR_Notify(GetLocStringById(signStrId) + " -> " + NR_ColorFormattedText(GetLocStringById(colorStrId), colorValue));
	// magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamInt_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_SetMagicParamInt_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamInt(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamFloat_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : float) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	
	// NR_Debug("NR_SetMagicParamFloat_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingFloat_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamFloat(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamString_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : String) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	// NR_Debug("NR_SetMagicParamString_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingString_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamString(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamName_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	
	// NR_Debug("NR_SetMagicParamName_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingName_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamName(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SwitchActionAbility_S(player: CStoryScenePlayer, type : name, abilityName : String) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	var oldValue : bool;
	var enumType : ENR_MagicAction;

	enumType = ENR_NameToMA(type);
	oldValue = magicManager.IsActionAbilityDisabledByUser(enumType, abilityName);
	// NR_Debug("NR_SwitchActionAbility_S: [" + type + "] (" + abilityName + ") = " + oldValue);
	magicManager.SetActionAbilityDisabledByUser(enumType, abilityName, !oldValue);
}

storyscene function NR_SwitchMagicControlHints_S(player: CStoryScenePlayer) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	
	if (FactsQuerySum("nr_magic_hide_control_hints") > 0) {
		FactsSet("nr_magic_hide_control_hints", 0);
		magicManager.ShowMagicControlHints(true);
	} else {
		FactsSet("nr_magic_hide_control_hints", 1);
		magicManager.ShowMagicControlHints(false);
	}
}

latent storyscene function NR_CHEAT_UnlockNextSkillLevel_S(player: CStoryScenePlayer) {
	NR_GetMagicManager().UpgradeSkillLevel();
}

storyscene function NR_CHEAT_SetMaxActionLevels_S(player: CStoryScenePlayer) {
	NR_GetMagicManager().SetActionSkillLevel(ENR_HandFx, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Teleport, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_CounterPush, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialLumos, 1);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialWeatherChange, 1);
	NR_GetMagicManager().SetActionSkillLevel(ENR_LightAbstract, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Slash, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_ThrowAbstract, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Lightning, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_ProjectileWithPrepare, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_BombExplosion, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Rock, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_RipApart, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_HeavyAbstract, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_FastTravelTeleport, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialShield, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialTornado, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialControl, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialMeteor, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialServant, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialLightningFall, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialField, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialMeteorFall, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialPolymorphism, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_WaterTrap, 10);
}

latent storyscene function NR_CreatePortal_S(player: CStoryScenePlayer, waypointTag : name, worldName : String, optional activeTime : float) {
	NR_CreatePortal( waypointTag, worldName, activeTime );
}

latent storyscene function NR_ReloadAllAppearanceHeadHair_S(player: CStoryScenePlayer) {
	NR_GetPlayerManager().ReloadAllAppearanceHeadHair();
}

latent storyscene function NR_ChooseMagicParamPercent_S(player: CStoryScenePlayer, signName : name, titleId : int, varName : String, minValue : int, maxValue : int)
{
	var magicManager 	: NR_MagicManager = NR_GetMagicManager();
	var newValue : int;

	newValue = NR_SelectIntegerValue(/*title*/ titleId, /*min*/ minValue, /*max*/ maxValue, /*current*/ magicManager.GetParamInt(signName, varName));
	magicManager.SetParamInt(signName, varName, newValue);
	// NR_Debug("NR_ChooseMagicParamPercent_S: [" + signName + "] (" + varName + ")");
	magicManager.UpdateMagicInfo();
}

storyscene function NR_EnterScenePreviewState_S(player: CStoryScenePlayer, stateName : name) {
	NR_EnterScenePreviewState(stateName);
    NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_ExitScenePreviewState_S(player: CStoryScenePlayer) {
	NR_ExitScenePreviewState();
    NR_GetPlayerManager().HideAppearanceInfo();
}
