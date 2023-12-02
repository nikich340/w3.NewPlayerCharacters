latent quest function NR_TrackPlayerProgress_Q() : bool {
    var magicManager : NR_MagicManager;
    var nextLevel : int;
    var upgradeFactStr : String;
    var waitUpgrade : bool;
    
    // in scene or not in game
    if (!theGame.IsActive() || theGame.IsDialogOrCutscenePlaying() || thePlayer.IsInNonGameplayCutscene() || thePlayer.IsInGameplayScene() 
        || theGame.IsFading() || theGame.IsBlackscreen() || theGame.HasBlackscreenRequested() || thePlayer.IsInCombat()) {
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

latent quest function NR_ShowTutorial_Q(type : String, optional delay : float) {
    Sleep(delay);
    SoundEventQuest("gui_character_add_skill", SESB_DontSave);
    NR_ShowTutorial(type, /*fullscreen*/ true);
}

latent storyscene function NR_ShowTutorial_S(player: CStoryScenePlayer, type : String, optional reminder : bool) {
    if (NR_GetPlayerManager().CanShowAppearanceInfo()) {
        NR_GetPlayerManager().HideAppearanceInfo();
    }
    NR_ShowTutorial(type, /*fullscreen*/ true, reminder);
}

latent storyscene function NR_ShowMagicSkillStats_S(player: CStoryScenePlayer, fullscreen : bool) {
    NR_Debug("NR_ShowMagicSkillStats_S");
    NR_ShowMagicSkillStats(fullscreen);
}

latent function NR_ShowTutorial(type : String, fullscreen : bool, optional reminder : bool) {
    var popupData : W3TutorialPopupData;
    var manager   : NR_MagicManager;

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
        else if (type == "SorceressSkillTornado")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940214) );
        else if (type == "SorceressSkillControl")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940215) );
        else if (type == "SorceressSkillShield")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940216) );
        else if (type == "SorceressSkillMeteor")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940218) );
        else if (type == "SorceressSkillServant")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940219) );
        else if (type == "SorceressSkillLightningFall")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940220) );
        else if (type == "SorceressSkillTODO!!!")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940221) );
        else if (type == "SorceressSkillMeteorFall")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940223) );
        else if (type == "SorceressSkillPolymorphism")
            popupData.messageText += NR_FormatLocString( GetLocStringById(2115940224) );
    }
    else {
        NR_Error("NR_ShowTutorial: Unknown tutorial type: " + type);
        return;
    }
    FactsAdd("nr_quest_track_" + type, 1);

    theGame.GetTutorialSystem().ShowTutorialHint(popupData);
}

function NR_ShowMagicSkillStats(fullscreen : bool) {
    var manager   : NR_MagicManager;
    var popupData : W3TutorialPopupData;
    var         i : int;

    manager = NR_GetMagicManager();
    popupData = new W3TutorialPopupData in thePlayer;
    popupData.messageTitle = GetLocStringById(2115940194);
    // general 
    popupData.messageText = "<font size=\"16\">" + GetLocStringById(2115940243) + "<br><b>- " + GetLocStringById(1210143) + "</b>: " + NR_StrLightBlue(manager.GetCurrentSkillLevelLocStr() + "(" + (int)manager.GetSkillLevel() + "/5)") + "<br>";
    popupData.messageText += "  <i>" + GetLocStringById(1070900) + "</i>: " + NR_StrGreen("+" + IntToString(manager.GetGeneralDamageBonus()) + "%");
    popupData.messageText += ", <i>" + StrLower(GetLocStringById(174112)) + "</i>: " + NR_StrGreen("-" + IntToString(manager.GetGeneralStaminaBonus()) + "%");
    popupData.messageText += ", <i>" + StrLower(GetLocStringById(593508)) + "</i>: " + NR_StrGreen("+" + IntToString(manager.GetGeneralDurationBonus()) + "%<br>");
    
    // spells
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_Teleport);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_FastTravelTeleport);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_CounterPush);

    popupData.messageText += manager.GetSkillInfoLocStr(ENR_Slash);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_Lightning);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_ProjectileWithPrepare);
    
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_RipApart);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_BombExplosion);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_Rock);

    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialServant);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialMeteor);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialTornado);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialControl);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialShield);

    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialLightningFall);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialField);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialMeteorFall);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialLumos);
    popupData.messageText += manager.GetSkillInfoLocStr(ENR_SpecialPolymorphism);
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
