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

latent storyscene function NR_ShowCustomDLCInfo_S(player: CStoryScenePlayer) {
	NR_GetPlayerManager().HideAppearanceInfo();
	NR_GetPlayerManager().ShowCustomDLCInfo();
}

storyscene function NR_SetPlayerDisplayName_S(player: CStoryScenePlayer, nameID : int) {
	NR_GetPlayerManager().SetPlayerDisplayName(nameID);
	NR_GetPlayerManager().ShowAppearanceInfo();
}

storyscene function NR_SwitchIncludeAsItem_S(player: CStoryScenePlayer, slot_index : int) {
	if (FactsQuerySum("nr_scene_stacking_as_items") < 1) {
		FactsSet("nr_scene_stacking_as_items", 1);
	} else {
		FactsSet("nr_scene_stacking_as_items", 0);
	}
}

storyscene function NR_SwitchPreviewNames_S(player: CStoryScenePlayer, slot_index : int) {
	if (FactsQuerySum("nr_scene_show_preview_names") < 1) {
		FactsSet("nr_scene_show_preview_names", 1);
	} else {
		FactsSet("nr_scene_show_preview_names", 0);
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
		thePlayer.AddAnimEventCallback('InitAction',		'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('Prepare',			'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('RotatePrePerformAction', 'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('PerformMagicAttack','OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('UnblockMiscActions','OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('PrepareTeleport',	'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('PerformTeleport',	'OnAnimEventMagic');
	} else {
		thePlayer.RemoveAnimEventCallback('InitAction');
		thePlayer.RemoveAnimEventCallback('Prepare');
		thePlayer.RemoveAnimEventCallback('RotatePrePerformAction');
		thePlayer.RemoveAnimEventCallback('PerformMagicAttack');
		thePlayer.RemoveAnimEventCallback('UnblockMiscActions');
		thePlayer.RemoveAnimEventCallback('PrepareTeleport');
		thePlayer.RemoveAnimEventCallback('PerformTeleport');
		magicManager.HideMagicInfo();
	}
}

// Magic stuff
storyscene function NR_ShowMagicInfo_S(player: CStoryScenePlayer, sectionName : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NR_Debug("NR_ShowMagicInfo_S: sectionName = " + sectionName);
	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.ShowMagicInfo(sectionName);
}

storyscene function NR_SetMagicSignName_S(player: CStoryScenePlayer, signName : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NR_Debug("NR_SetMagicSignName_S: signName = " + signName);
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

	NR_Debug("NR_SetMagicActionType_S: actionType = " + ENR_MAToName((ENR_MagicAction)actionType));
	if (!magicManager) {
		NR_Error("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetActionType((ENR_MagicAction)actionType);
}

storyscene function NR_SimulateLongMagicAction_S(player: CStoryScenePlayer, actionType : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NR_Debug("NR_SimulateLongMagicAction_S: actionType = " + ENR_MAToName((ENR_MagicAction)actionType));
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

	NR_Debug("NR_SetMagicLightRatio_S: slashNum = " + slashNum + ", throwNum = " + throwNum);
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

	NR_Debug("NR_SetMagicHeavyRatio_S: slashNum = " + rocksNum + ", bombNum = " + bombNum);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamInt('universal', "heavy_rocks_amount", rocksNum);
	magicManager.SetParamInt('universal', "heavy_bomb_amount", bombNum);
	magicManager.InitAspectsSelectors();
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamInt_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NR_Debug("NR_SetMagicParamInt_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamInt(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamFloat_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : float) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	
	NR_Debug("NR_SetMagicParamFloat_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingFloat_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamFloat(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamString_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : String) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NR_Debug("NR_SetMagicParamString_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingString_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamString(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamName_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	
	NR_Debug("NR_SetMagicParamName_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NR_Error("NR_SetMagicSettingName_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamName(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

latent storyscene function NR_CreatePortal_S(player: CStoryScenePlayer, waypointTag : name, worldName : String, optional activeTime : float) {
	NR_CreatePortal( waypointTag, worldName, activeTime );
}

latent storyscene function NR_ChooseMagicParamPercent_S(player: CStoryScenePlayer, signName : name, varName : String)
{
	var magicManager 	: NR_MagicManager = NR_GetMagicManager();
	var popupData 		: NR_MagicSliderData;
	var hud 			: CR4ScriptedHud;
	var dialogueModule 	: CR4HudModuleDialog;
	var value 			: int;

	hud = (CR4ScriptedHud)theGame.GetHud();
	if ( hud )
	{
		dialogueModule = (CR4HudModuleDialog)hud.GetHudModule("DialogModule");
		dialogueModule.OnDialogPreviousSentenceSet("");
		dialogueModule.OnDialogSentenceSet("");
		popupData = new NR_MagicSliderData in magicManager;
		
		popupData.ScreenPosX = 0.62;
		popupData.ScreenPosY = 0.65;
		popupData.SetMessageTitle( GetLocStringById(2115940587));
		// popupData.dialogueRef = dialogueModule;
		popupData.BlurBackground = false;  
		
		popupData.minValue = 0;
		popupData.maxValue = 100;
		popupData.currentValue = magicManager.GetParamInt(signName, varName);
		popupData.signName = signName;
		popupData.varName = varName;

		theGame.RequestMenu('PopupMenu', popupData);
		while ( !popupData.IsCompleted() ) {
			SleepOneFrame();
		}
		theGame.CloseMenu('PopupMenu');
	}

	NR_Debug("NR_ChooseMagicParamPercent_S: [" + signName + "] (" + varName + ")");
	magicManager.UpdateMagicInfo();
}

