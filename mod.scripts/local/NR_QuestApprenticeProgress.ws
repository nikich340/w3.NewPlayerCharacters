latent quest function NR_TrackPlayerProgress_Q() : bool {
    var magicManager : NR_MagicManager;
    var nextLevel : int;
    var upgradeFactStr : String;
    var waitUpgrade : bool;
    
    // in scene or not in game
    if ( !NR_IsPlayerFree() ) {
        return false;
    }

    // is waiting to change type (should be in fade but anyway)
    if (FactsQuerySum("nr_scene_player_change_requested") > 0) {
        return false;
    }

    // First Time
    if ( !FactsQuerySum("nr_quest_track_FirstTime") ) {
        NR_ShowTutorial( "FirstTime", /*fullscreen*/ true );
        return true;
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

    // check if master was met
    if ( FactsQuerySum("nr_master_apprentice") < 1 ) {
        return false;
    }

    nextLevel = magicManager.GetSkillLevel() + 1;
    if ( magicManager.GetSkillLevel() < magicManager.GetPossibleSkillLevel() ) {
        magicManager.UpgradeSkillLevel();
        NR_ShowTutorial( "SorceressLevel" + IntToString(nextLevel), /*fullscreen*/ true );
        return true;
    }

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

    NR_Debug("NR_ShowTutorial: type = " + type + ", fullscreen = " + fullscreen + ", reminder = " + reminder);
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
        // SoundEventQuest("gui_enchanting_runeword_add", SESB_DontSave);
        SoundEventQuest("gui_enchanting_socket_add", SESB_DontSave);
        popupData.messageTitle = GetLocStringById(2115940206);
        popupData.messageText = NR_FormatLocString( GetLocStringById(2115940207) );
        // doesn't work popupData.imagePath = "img://icons/menubackground/panorama_novigrad.png";
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
        SoundEventQuest("gui_ingame_level_up", SESB_DontSave);
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
            manager.SetParamInt('Axii', "type_" + ENR_MAToName(ENR_SpecialAbstract), (int)ENR_SpecialField);
            popupData.messageText += NR_FormatLocString( GetLocStringById(ENR_SpecialAbstractAlt) );
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
    NR_Debug("NR_ShowMagicSkillStats_S");
    if (NR_GetMagicManager().IsInSetupScene()) {
        NR_GetMagicManager().HideMagicInfo();
    }
    NR_ShowMagicSkillStats(fullscreen, showNovice, showApprentice, showExperienced, showMistress, showArchMistress);
    /*
    Sleep(0.3f);
    while (theGame.GetGuiManager().IsModalPopupShown()) {
        SleepOneFrame();
    }
    */
    // NR_Debug("NR_ShowMagicSkillStats_S end");
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
    popupData.messageText = "<font size=\"21\">" + GetLocStringById(2115940243) + "<br><b>" + GetLocStringById(1210143) + "</b>: " + NR_StrLightBlue(manager.GetCurrentSkillLevelLocStr() + " (" + (int)manager.GetSkillLevel() + " / 5)") + "<br>";
    popupData.messageText += "  <i>" + GetLocStringById(1070900) + "</i>: " + NR_StrGreen("+" + IntToString(manager.GetGeneralDamageBonus()) + "%");
    popupData.messageText += ", <i>" + StrLower(GetLocStringById(174112)) + "</i>: " + NR_StrGreen("-" + IntToString(manager.GetGeneralStaminaBonus()) + "%");
    popupData.messageText += ", <i>" + StrLower(GetLocStringById(593508)) + "</i>: " + NR_StrGreen("+" + IntToString(manager.GetGeneralDurationBonus()) + "%<br><br>");
    
    // spells
    if (showNovice) {
        popupData.messageText += "[" + GetLocStringById(2115940253) + "]<br>";
        skills.PushBack(ENR_Teleport);
        skills.PushBack(ENR_CounterPush);

        skills.PushBack(ENR_Slash);
        skills.PushBack(ENR_Lightning);
        skills.PushBack(ENR_ProjectileWithPrepare);

        skills.PushBack(ENR_SpecialLumos);
    }

    if (showApprentice) {
        popupData.messageText += "[" + GetLocStringById(2115940254) + "]<br>";
        skills.PushBack(ENR_FastTravelTeleport);

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
