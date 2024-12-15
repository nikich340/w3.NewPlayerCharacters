latent quest function NR_TrackPlayerProgress_Q() : bool {
    var playerManager : NR_PlayerManager;
    var magicManager : NR_MagicManager;
    var nextLevel, i : int;
    
    // in scene or not in game
    if ( !NR_IsPlayerFree() ) {
        return false;
    }

    playerManager = NR_GetPlayerManager();
    // is waiting to change type (should be in fade but anyway)
    if ( playerManager.IsPlayerChangeRequested() ) {
        // NR_Debug("NR_TrackPlayerProgress_Q: IsPlayerChangeRequested");
        return false;
    }
    if ( !playerManager.IsReady() ) {
        // NR_Debug("NR_TrackPlayerProgress_Q: !IsReady()");
        return false;
    }

    // First Time
    if ( FactsQuerySum("nr_quest_track_FirstTime") < 1 ) {
        // NR_Debug("NR_TrackPlayerProgress_Q: nr_quest_track_FirstTime < 1");
        NR_ShowTutorial( "FirstTime", /*fullscreen*/ true );
        // set fact to avoid showing changelog on fresh installation
        FactsAdd("nr_quest_track_Update_v1_2_2", 1);
        FactsAdd("nr_quest_track_Update_v2_0_2", 1);
        FactsAdd("nr_quest_track_Update_v2_3_1", 1);
        FactsAdd("nr_quest_track_Update_v3_0", 1);
        return true;
    }

    // HACK: if player has no Chameleon for some reason
    if ( !thePlayer.IsCiri() && !thePlayer.inv.HasItem('nr_chameleon_potion') ) {
        thePlayer.inv.AddAnItem('nr_chameleon_potion', 1);
        NR_Notify("Chameleon potion was added back to inventory. Don't lose it anymore :)");
        return true;
    }

    // script fixes - v1.2.2
    if ( FactsQuerySum("nr_quest_track_Update_v1_2_2") < 1 ) {
        if (FactsQuerySum("nr_master_apprentice") > 0)
            theGame.GetCommonMapManager().SetEntityMapPinDiscoveredScript(true, 'newreplacers_snow_arena_center_ft', true);
    }

    // script fixes - v2.0.2
    if ( FactsQuerySum("nr_quest_track_Update_v2_0_2") < 1 ) {
        NR_GetPlayerManager().SetPlayerScaleForType(ENR_PlayerWitcheress, 100);
        NR_GetPlayerManager().SetPlayerScaleForType(ENR_PlayerSorceress, 100);
        if ( NR_GetMagicManager() )
            NR_GetMagicManager().SetDefaults_DamageManual();
    }

    // changelog - v3.0
    if ( FactsQuerySum("nr_quest_track_Update_v3_0") < 1 ) {
		playerManager.InitSexSets();
        NR_ShowTutorial( "Update_v3_0", /*fullscreen*/ true );
        return true;
    }
	
	if ( FactsQuerySum("nr_quest_track_HotkeysHelp") < 1 ) {
		NR_ShowTutorial( "HotkeysHelp", /*fullscreen*/ true );
        return true;
	}
	
	if ( FactsQuerySum("nr_quest_track_SexSetHelp") < 1 ) {
		NR_ShowTutorial( "SexSetHelp", /*fullscreen*/ true );
        return true;
	}
    
    // check Female speech installation
    // check DhuCats installation
    // check JoWitcheress Models installation
    if ( !NR_IsIdStrExists(2115940999) || !theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') || !theGame.GetDLCManager().IsDLCAvailable('dlc_jowitcheress') ) {
        if (FactsQuerySum("nr_quest_track_MissedExtraContent") < 1) {
            NR_Info("NR_TrackPlayerProgress_Q: MissedExtraContent!");
            NR_ShowTutorial( "MissedExtraContent", /*fullscreen*/ true );
            return true;
        }
	}

    magicManager = NR_GetMagicManager();
    // check if currently sorceress
    if ( !magicManager ) {
        return false;
    }

    // not required: NR_GetPlayerManager().GetCurrentPlayerType() == ENR_PlayerSorceress
    if ( FactsQuerySum("nr_sorceress_quest_start") < 1 ) {
        NR_ShowTutorial( "SorceressLevel1", /*fullscreen*/ true );
        FactsAdd("nr_sorceress_quest_start", 1);
        return true;
    }

    // HACK: if player has no Chameleon for some reason

    // Sorceress Interaction Hints
    if ( FactsQuerySum("nr_quest_track_SorceressInteractionHints2") < 1 ) {
        NR_ShowTutorial( "SorceressInteractionHints2", /*fullscreen*/ true );
        return true;
    }

    // check if master was met
    if ( FactsQuerySum("nr_master_apprentice") < 1 ) {
        return false;
    }
	
	if ( FactsQuerySum("nr_reserved_update") < 1 ) {
		FactsAdd("nr_reserved_update", 1);
	}

    nextLevel = magicManager.GetSkillLevel() + 1;
    if ( magicManager.GetSkillLevel() < magicManager.GetPossibleSkillLevel() ) {
        magicManager.UpgradeSkillLevel();
        // show tutorial inside func ^
        return true;
    }
	
	if ( FactsQuerySum("nr_sorceress_training_completed") < 1 && magicManager.IsSorceressTrainingCompleted() ) {
		FactsAdd("nr_sorceress_training_completed", 1);
	}
	// nr_sorceress_training_completed + nr_golem_crafting_success -> quest completed

    return false;
}

latent quest function NR_ShowTutorial_Q(type : String, optional showInScenes : bool) {
    while ( !NR_IsPlayerFree() ) {
        Sleep(0.2f);
    }
    SoundEventQuest("gui_character_add_skill", SESB_DontSave);
    NR_ShowTutorial(type, /*fullscreen*/ true);
}

latent storyscene function NR_ShowTutorial_S(player: CStoryScenePlayer, type : String, optional reminder : bool) {
    if (NR_GetPlayerManager().CanShowAppearanceInfo()) {
        NR_GetPlayerManager().HideAppearanceInfo();
    }
    NR_ShowTutorial(type, /*fullscreen*/ true, reminder);
}

latent function NR_ShowTutorial(type : String, fullscreen : bool, optional reminder : bool) {
    var popupData : W3TutorialPopupData;
    var manager   : NR_MagicManager;

    NR_Info("NR_ShowTutorial: type = " + type + ", fullscreen = " + fullscreen + ", reminder = " + reminder);
    manager = NR_GetMagicManager();
    popupData = new W3TutorialPopupData in thePlayer;
    popupData.managerRef = theGame.GetTutorialSystem();
    popupData.enableGlossoryLink = false;
    popupData.autosize = true;
    popupData.blockInput = true;
    popupData.pauseGame = true;
    popupData.fullscreen = fullscreen;
    popupData.canBeShownInMenus = true;
    popupData.duration = -1;
    popupData.posX = 0;
    popupData.posY = 0;
    popupData.enableAcceptButton = true;

    if (type == "FirstTime") {
        theSound.SoundEvent("gui_enchanting_socket_add");
        popupData.messageTitle = GetLocStringById(2115940206);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940207) );
        // doesn't work popupData.imagePath = "img://icons/menubackground/panorama_novigrad.png";
    }
    else if (type == "MissedExtraContent" || type == "SceneMissedExtraContent") {
        popupData.messageTitle = GetLocStringById(1223359);
        if ( !NR_IsIdStrExists(2115940999) ) {
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940540) );
        }
        if ( !theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') ) {
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940539) );
        }
        if ( !theGame.GetDLCManager().IsDLCAvailable('dlc_jowitcheress') ) {
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940538) );
        }
        if ( StrLen(popupData.messageText) < 1 ) {
            return;
        }
        theSound.SoundEvent("gui_global_denied");
    } else if (StrStartsWith(type, "Update")) {
        theSound.SoundEvent("gui_enchanting_socket_add");
        popupData.messageTitle = GetLocStringById(1084047);
        if (type == "Update_v3_0") {
            popupData.messageText += "<font color=\"#ffff00\">v3.0 changes:</font><br>";
            popupData.messageText += "- fixed: correct weatness for all heads<br>";
            popupData.messageText += "- fixed: missed (T-pose) anims during \"In the Eternal Fire's Shadow\" quest<br>";
            popupData.messageText += "- improvement: better magic damage to ifryt enemies<br>";
            popupData.messageText += "- improvement: shorter notify if spell not learned<br>";
            popupData.messageText += "- improvement: switch player type with HOTKEY<br>";
            popupData.messageText += "- improvement: switch player equipment mode with HOTKEY<br>";
            popupData.messageText += "- improvement: switch player appearance with HOTKEYS<br>";
            popupData.messageText += "- improvement: perform exploration teleport with HOTKEY (no more Potion 4 slot locked)<br>";
            popupData.messageText += "- <font color=\"#00ff00\">new AI female voices</font> for Geralt (check nexusmods page)<br>";
            popupData.messageText += "- <font color=\"#00ff00\">big improvement</font>: \"Real equipment\" appearance mode for female types (requires Geralt\'s Armors for Female Character)<br>";
            popupData.messageText += "- <font color=\"#00ff00\">big improvement</font>: new \"naked set\" feature (only for Full custom mode)<br>";
            popupData.messageText += "- <font color=\"#FFAA00\">please MAKE SURE</font> you have added new lines to input.settings file, to let new hotkeys work (check update instructions on nexusmods)<br>";
        }
    }
    else if (type == "SorceressInteractionHints2") {
        popupData.messageTitle = GetLocStringById(2115940533);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940534) );
    }
    else if (type == "HotkeysHelp") {
        popupData.messageTitle = GetLocStringById(397231);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940323) );
    }
    else if (type == "SexSetHelp" || type == "SexSetHelp2") {
        popupData.messageTitle = GetLocStringById(397231);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940325) );
    }
    else if (type == "AppearanceHelp") {
        popupData.messageTitle = GetLocStringById(397231);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940557) );
    }
    else if (type == "SceneHelp") {
        popupData.messageTitle = GetLocStringById(397231);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940556) );
    }
    else if (type == "SceneHelp2") {
        popupData.messageTitle = GetLocStringById(397231);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940590) );
    }
    else if (type == "PolymorphismWarning") {
        popupData.messageTitle = GetLocStringById(1185194);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940548) );
    }
    else if (StrStartsWith(type, "SorceressLevel")) {
        //if (!reminder) {
        popupData.messageTitle = GetLocStringById(2115940208);
        popupData.messageText = GetLocStringById(2115940197) + "<b>" + manager.GetCurrentSkillLevelLocStr() + "</b><br>";
        theSound.SoundEvent("gui_ingame_level_up");
        //}
        //else {
        //  popupData.messageTitle = GetLocStringById(2115940195);
        //}
        if (type == "SorceressLevel1")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940209) );
        else if (type == "SorceressLevel2")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940210) );
        else if (type == "SorceressLevel3")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940213) );
        else if (type == "SorceressLevel4")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940217) );
        else if (type == "SorceressLevel5")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940222) );
    }
    else if (StrStartsWith(type, "SorceressSkill")) {
        if (!reminder) {
            popupData.messageTitle = GetLocStringById(2115940198);
            popupData.messageText = GetLocStringById(2115940196) + "<br>";
        }
        else {
            popupData.messageTitle = GetLocStringById(2115940195);
        }
        if (type == "SorceressSkillBasics")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940209) );
        if (type == "SorceressSkillHeavyAttacks")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940211) );
        else if (type == "SorceressSkillFastTravelTeleport")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940212) );
        else if (type == "SorceressSkillTornado") {
            FactsSet("nr_type_special_aard", (int)ENR_SpecialTornado);
            manager.SetParamInt('Aard', "type_" + ENR_MAToName(ENR_SpecialAbstract), (int)ENR_SpecialTornado);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940214) );
        }
        else if (type == "SorceressSkillControl") {
            FactsSet("nr_type_special_axii", (int)ENR_SpecialControl);
            manager.SetParamInt('Axii', "type_" + ENR_MAToName(ENR_SpecialAbstract), (int)ENR_SpecialControl);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940215) );
        }
        else if (type == "SorceressSkillShield") {
            FactsSet("nr_type_special_quen", (int)ENR_SpecialShield);
            manager.SetParamInt('Quen', "type_" + ENR_MAToName(ENR_SpecialAbstract), (int)ENR_SpecialShield);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940216) );
        }
        else if (type == "SorceressSkillWeatherChange") {
            FactsSet("nr_type_special_aard", (int)ENR_SpecialWeatherChange);
            manager.SetParamInt('Aard', "type_" + ENR_MAToName(ENR_SpecialAbstract), (int)ENR_SpecialWeatherChange);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940549) );
        }
        else if (type == "SorceressSkillMeteor") {
            FactsSet("nr_type_special_igni", (int)ENR_SpecialMeteor);
            manager.SetParamInt('Igni', "type_" + ENR_MAToName(ENR_SpecialAbstract), (int)ENR_SpecialMeteor);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940218) );
        }
        else if (type == "SorceressSkillServant") {
            FactsSet("nr_type_special_yrden", (int)ENR_SpecialServant);
            manager.SetParamInt('Yrden', "type_" + ENR_MAToName(ENR_SpecialAbstract), (int)ENR_SpecialServant);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940219) );
        }
        else if (type == "SorceressSkillLightningFall") {
            FactsSet("nr_type_special_alt_aard", (int)ENR_SpecialLightningFall);
            manager.SetParamInt('Aard', "type_" + ENR_MAToName(ENR_SpecialAbstractAlt), (int)ENR_SpecialLightningFall);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940220) );
        }
        else if (type == "SorceressSkillField") {
            FactsSet("nr_type_special_alt_axii", (int)ENR_SpecialField);
            manager.SetParamInt('Axii', "type_" + ENR_MAToName(ENR_SpecialAbstractAlt), (int)ENR_SpecialField);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940221) );
        }
        else if (type == "SorceressSkillMeteorFall") {
            FactsSet("nr_type_special_alt_igni", (int)ENR_SpecialMeteorFall);
            manager.SetParamInt('Igni', "type_" + ENR_MAToName(ENR_SpecialAbstractAlt), (int)ENR_SpecialMeteorFall);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940223) );
        }
        else if (type == "SorceressSkillPolymorphism") {
            FactsSet("nr_type_special_alt_yrden", (int)ENR_SpecialPolymorphism);
            manager.SetParamInt('Yrden', "type_" + ENR_MAToName(ENR_SpecialAbstractAlt), (int)ENR_SpecialPolymorphism);
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940224) );
        }
    }
    else {
        NR_Error("NR_ShowTutorial: Unknown tutorial type: " + type);
        return;
    }
    FactsAdd("nr_quest_track_" + type, 1);

    theGame.GetTutorialSystem().ShowTutorialHint(popupData);
}

latent storyscene function NR_ShowMagicSkillStats_S(player: CStoryScenePlayer, fullscreen : bool, showNovice : bool, showApprentice : bool, showExperienced : bool, showMistress : bool, showArchMistress : bool) {
    // NR_Debug("NR_ShowMagicSkillStats_S");
    if (NR_GetMagicManager().IsInSetupScene()) {
        NR_GetMagicManager().HideMagicInfo();
    }
    NR_ShowMagicSkillStats(fullscreen, showNovice, showApprentice, showExperienced, showMistress, showArchMistress);
}

latent function NR_ShowMagicSkillStats(fullscreen : bool, showNovice : bool, showApprentice : bool, showExperienced : bool, showMistress : bool, showArchMistress : bool) {
    var manager   : NR_MagicManager;
    var popupData : W3TutorialPopupData;
    var         i : int;
    var    skills : array<ENR_MagicAction>;

    manager = NR_GetMagicManager();
    SoundEventQuest("gui_enchanting_socket_add", SESB_DontSave);
    popupData = new W3TutorialPopupData in thePlayer;
    popupData.messageTitle = GetLocStringById(2115940194);
    // general 
    popupData.messageText = "<font size=\"23\">" + GetLocStringById(2115940243) + "<br><b>" + GetLocStringById(1070944) + "</b>: " + NR_StrLightBlue(manager.GetCurrentSkillLevelLocStr() + " (" + (int)manager.GetSkillLevel() + " / 5)") + "<br>";
    popupData.messageText += "  <i>" + GetLocStringById(1070900) + "</i>: " + NR_StrGreen("+" + IntToString(manager.GetGeneralDamageBonus()) + "%");
    popupData.messageText += ", <i>" + StrLower(GetLocStringById(174112)) + "</i>: " + NR_StrGreen("-" + IntToString(manager.GetGeneralStaminaBonus()) + "%");
    popupData.messageText += ", <i>" + StrLower(GetLocStringById(593508)) + "</i>: " + NR_StrGreen("+" + IntToString(manager.GetGeneralDurationBonus()) + "%<br><br>");
    
    // spells
    if (showNovice) {
        popupData.messageText += "[" + GetLocStringById(2115940253) + "]<br>";
        skills.PushBack(ENR_Teleport);
        skills.PushBack(ENR_FastTravelTeleport); // should be learned - locked by default
        skills.PushBack(ENR_CounterPush);

        skills.PushBack(ENR_Slash);
        skills.PushBack(ENR_Lightning);
        skills.PushBack(ENR_ProjectileWithPrepare);

        skills.PushBack(ENR_SpecialLumos);
    }

    if (showApprentice) {
        popupData.messageText += "[" + GetLocStringById(2115940254) + "]<br>";
        skills.PushBack(ENR_RipApart);
        skills.PushBack(ENR_BombExplosion);
        skills.PushBack(ENR_Rock);

        skills.PushBack(ENR_SpecialShield);
        skills.PushBack(ENR_SpecialWeatherChange);
    }

    if (showExperienced) {
        popupData.messageText += "[" + GetLocStringById(2115940255) + "]<br>";
        skills.PushBack(ENR_SpecialTornado);
        skills.PushBack(ENR_SpecialControl);

        skills.PushBack(ENR_SpecialField);
    }

    if (showMistress) {
        popupData.messageText += "[" + GetLocStringById(2115940256) + "]<br>";
        skills.PushBack(ENR_SpecialServant);
        skills.PushBack(ENR_SpecialMeteor);

        skills.PushBack(ENR_SpecialLightningFall);
    }
    
    if (showArchMistress) {
        popupData.messageText += "[" + GetLocStringById(2115940257) + "]<br>";
        
        skills.PushBack(ENR_SpecialMeteorFall);
        skills.PushBack(ENR_SpecialPolymorphism);
    }
    // first learned
    for (i = 0; i < skills.Size(); i += 1) {
        if ( manager.IsActionLearned(skills[i]) )
            popupData.messageText += manager.GetSkillInfoLocStr(skills[i]);
    }
    // second locked
    for (i = 0; i < skills.Size(); i += 1) {
        if ( !manager.IsActionLearned(skills[i]) )
            popupData.messageText += manager.GetSkillInfoLocStr(skills[i]);
    }

    popupData.messageText += "</font>";

    popupData.managerRef = theGame.GetTutorialSystem();
    popupData.enableGlossoryLink = false;
    popupData.autosize = true;
    popupData.blockInput = true;
    popupData.pauseGame = true;
    popupData.fullscreen = fullscreen;
    popupData.canBeShownInMenus = true;
    popupData.duration = -1;
    popupData.posX = 0;
    popupData.posY = 0;
    popupData.enableAcceptButton = true;

    theGame.GetTutorialSystem().ShowTutorialHint(popupData);
}

exec function NR_ExecFloatingShipIcon() {
    theGame.GetCommonMapManager().SetEntityMapPinDiscoveredScript(true, 'newreplacers_snow_arena_center_ft', true);
}

exec function NR_ExecCheatSpiderBoss() {
    var spider : CNewNPC;

    spider = theGame.GetNPCByTag('nr_cross_stone_boss_spider');
    spider.SetHealthPerc(30.f);
}

exec function NR_ExecReleaseShipSavelock() {
    theGame.ReleaseNoSaveLockByName("NR_CrossStoneQuest");
}
