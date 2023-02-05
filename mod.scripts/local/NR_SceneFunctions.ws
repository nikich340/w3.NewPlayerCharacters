// Appearance stuff
storyscene function NR_SetPreviewDataIndex_S(player: CStoryScenePlayer, data_index : int, choice_offset : int) {
	NR_GetPlayerManager().SetPreviewDataIndex(data_index, choice_offset);
}

storyscene function NR_ClearAppearanceSlot_S(player: CStoryScenePlayer, slot_index : int) {
	NR_GetPlayerManager().ClearAppearanceSlot((ENR_AppearanceSlots)slot_index);
}

storyscene function NR_ClearItemSlot_S(player: CStoryScenePlayer, item_index : int) {
	NR_GetPlayerManager().ClearItemSlot(item_index);
}

storyscene function NR_ClearAllSlots_S(player: CStoryScenePlayer, item_index : int) {
	NR_GetPlayerManager().ResetAllAppearanceHeadHair();
}

storyscene function NR_SwitchIncludeAsItem_S(player: CStoryScenePlayer, slot_index : int) {
	if (FactsQuerySum("nr_scene_stacking_as_items") < 1) {
		FactsAdd("nr_scene_stacking_as_items", 1);
	} else {
		FactsSet("nr_scene_stacking_as_items", 0);
	}
}

// Magic stuff
storyscene function NR_SetMagicInSetupScene_S(player: CStoryScenePlayer, inSetupScene : bool) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	if (!magicManager) {
		NRE("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetIsInSetupScene(inSetupScene);
	magicManager.HandFX(inSetupScene);

	if (inSetupScene) {
		thePlayer.AddAnimEventCallback('InitAction',		'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('Prepare',			'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('Spawn',				'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('Shoot',				'OnAnimEventMagic');
		thePlayer.AddAnimEventCallback('PerformMagicAttack','OnAnimEventMagic');
	} else {
		thePlayer.RemoveAnimEventCallback('InitAction');
		thePlayer.RemoveAnimEventCallback('Prepare');
		thePlayer.RemoveAnimEventCallback('Spawn');
		thePlayer.RemoveAnimEventCallback('Shoot');
		thePlayer.RemoveAnimEventCallback('PerformMagicAttack');
		magicManager.HideMagicInfo();
	}
}

// Magic stuff
storyscene function NR_ShowMagicInfo_S(player: CStoryScenePlayer, sectionName : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	if (!magicManager) {
		NRE("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.ShowMagicInfo(sectionName);
}

storyscene function NR_SetMagicSignName_S(player: CStoryScenePlayer, signName : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NR_Notify("NR_SetMagicSignName_S: signName = " + signName);
	if (!magicManager) {
		NRE("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetSceneSign(SignNameToEnum(signName));
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicUpdateHandFx_S(player: CStoryScenePlayer) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	if (!magicManager) {
		NRE("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.HandFX(true);
}

storyscene function NR_SetMagicActionType_S(player: CStoryScenePlayer, actionType : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NRD("NR_SetMagicActionType_S: actionType = " + ENR_MAToName((ENR_MagicAction)actionType));
	if (!magicManager) {
		NRE("NR_SetMagicInSetupScene_S: NULL magicManager!");
		return;
	}
	magicManager.SetActionType((ENR_MagicAction)actionType);
}

storyscene function NR_SetMagicLightRatio_S(player: CStoryScenePlayer, slashNum : int, throwNum : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NRD("NR_SetMagicLightRatio_S: slashNum = " + slashNum + ", throwNum = " + throwNum);
	if (!magicManager) {
		NRE("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamInt('universal', "light_slash_amount", slashNum);
	magicManager.SetParamInt('universal', "light_throw_amount", throwNum);
	magicManager.InitAspectsSelectors();
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamInt_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : int) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NRD("NR_SetMagicParamInt_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NRE("NR_SetMagicSettingInt_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamInt(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamFloat_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : float) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	
	NRD("NR_SetMagicParamFloat_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NRE("NR_SetMagicSettingFloat_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamFloat(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamString_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : String) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();

	NRD("NR_SetMagicParamString_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NRE("NR_SetMagicSettingString_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamString(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}

storyscene function NR_SetMagicParamName_S(player: CStoryScenePlayer, signName : name, varName : String, varValue : name) {
	var magicManager : NR_MagicManager = NR_GetMagicManager();
	
	NRD("NR_SetMagicParamName_S: [" + signName + "] (" + varName + ") = " + varValue);
	if (!magicManager) {
		NRE("NR_SetMagicSettingName_S: NULL magicManager!");
		return;
	}
	magicManager.SetParamName(signName, varName, varValue);
	magicManager.UpdateMagicInfo();
}
