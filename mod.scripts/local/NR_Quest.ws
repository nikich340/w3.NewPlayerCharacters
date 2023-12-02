latent quest function NR_Wait_Q(sec : float) {
    Sleep(sec);
}

latent quest function NR_HideMaster_Q(phaseTag : name) {
    var masterNPC : CNewNPC;

    masterNPC = (CNewNPC)theGame.GetEntityByTag(phaseTag);
    if (masterNPC) {
        masterNPC.PlayEffect('teleport_out');
        Sleep(1.f);
        masterNPC.SetVisibility(false);
        // let effect finish
        Sleep(2.f);
    }
}

quest function NR_InitPlayerManager_Q() {
    NR_GetPlayerManager();
}

quest function NR_ChangePlayer_Q() {
    var newPlayerType   : ENR_PlayerType;
    var nr_manager      : NR_PlayerManager;

    nr_manager = NR_GetPlayerManager();
    if (!nr_manager)
        return;

    newPlayerType = (ENR_PlayerType)FactsQuerySum("nr_scene_player_change_type");
    NR_Debug("NR_ChangePlayer_Q: scene change to -> " + newPlayerType);
    NR_ChangePlayer(newPlayerType);
    FactsRemove("nr_scene_player_change_type"); 
}

quest function NR_IsPlayerFemale_Q() : bool {
    return NR_GetPlayerManager().IsFemale();
}

quest function NR_IsPlayerSorceress_Q() : bool {
    return (NR_GetPlayerManager().GetCurrentPlayerType() == ENR_PlayerSorceress);
}

quest function NR_FadeOutQuestBlack( fadeTime : float ) {
    FadeOutQuest(fadeTime, Color(0, 0, 0, 0));
}

quest function NR_AddContractToNoticeBoard( boardTag : CName, errandStringKey : string, newQuestFact : string, addedItemName : CName, optional forceActivate : bool ) {
  var newErrand : ErrandDetailsList;
  var newErrands : array<ErrandDetailsList>;
  
  newErrand.errandStringKey = errandStringKey;
  newErrand.newQuestFact = newQuestFact;
  newErrand.addedItemName = addedItemName;

  newErrands.PushBack(newErrand);
  AddErrandsToTheNoticeBoard( boardTag, newErrands, forceActivate );
}

quest function NR_CheckFactCond_Q(factName : string, factCond : string, factVal : int) : bool {
    var factValReal : int;
    var ret : bool;

    factValReal = FactsQuerySum(factName);
    
    switch(factCond) {
        case "==":
            ret = (factValReal == factVal);
            break;
        case "!=":
            ret = (factValReal != factVal);
            break;
        case ">=":
            ret = (factValReal >= factVal);
            break;
        case "<=":
            ret = (factValReal <= factVal);
            break;
        case ">":
            ret = (factValReal > factVal);
            break;
        case "<":
            ret = (factValReal < factVal);
            break;
    }
    return ret;
}

quest function NR_CheckRandomChance_Q( chance : int, maxChance : int ) : bool {
    return chance >= NR_GetRandomGenerator().nextRange(1, maxChance);
}

latent quest function NR_CheckEntitiesAlive_Q( tag : name, moreThan : int ) : bool {
    var entities : array<CEntity>;
    var actor : CActor;
    var i, alive : int;

    theGame.GetEntitiesByTag(tag, entities);
    for (i = 0; i < entities.Size(); i += 1) {
        actor = (CActor)entities[i];
        if (actor && actor.IsAlive()) {
            alive += 1;
        }
    }
    
    return alive > moreThan;
}

latent quest function NR_CreatePortal_Q( waypointTag : name, worldName : String, optional activeTime : float ) {
    NR_CreatePortal( waypointTag, worldName, activeTime );
}

latent quest function NR_UseCrossStoneBossSpider_Q() {
    var teleportTemplate, crossTemplate, template : CEntityTemplate;
    var stoneEntity                     : CEntity;
    var teleportEntity                  : CEntity;
    var crossEntity                     : CEntity;
    var npc                             : CNewNPC;
    var pos                             : Vector;

    pos = Vector(-247.15420532219997, -304.2886657715, 41.4622840881);
    stoneEntity = theGame.GetEntityByTag('nr_interactive_ship_stone');
    stoneEntity.StopEffect('ready');
    stoneEntity.PlayEffect('use');
    Sleep(3.f);
    stoneEntity.PlayEffect('success');
    
    teleportTemplate = (CEntityTemplate)LoadResourceAsync("dlc/dlcnewreplacers/data/entities/magic/ft_teleport/nr_q109_keira_teleport_red.w2ent", true);
    crossTemplate = (CEntityTemplate)LoadResourceAsync("dlc/dlcnewreplacers/data/entities/nr_cross_effect.w2ent", true);
    PreloadEffectForEntityTemplate(teleportTemplate, 'teleport_activate');
    PreloadEffectForEntityTemplate(teleportTemplate, 'teleport_fx');
    PreloadEffectForEntityTemplate(crossTemplate, 'cross');

    NR_ShowLightningFx(stoneEntity.GetWorldPosition() + Vector(0,0,1.8f), pos + Vector(0,0,1.f), true, 'lightning_keira_red', 'hit_electric_red');

    crossEntity = (CEntity)theGame.CreateEntity(crossTemplate, pos + VecFromHeading(265 + 90.f) * 3.f + Vector(0,0,2.f), EulerAngles(0, 265 + 180.f, 0));
    crossEntity.StopAllEffectsAfter(3.f);
    crossEntity.DestroyAfter(10.f);

    crossEntity = (CEntity)theGame.CreateEntity(crossTemplate, pos + VecFromHeading(265 + 270.f) * 3.f + Vector(0,0,2.f), EulerAngles(0, 265 + 180.f, 0));
    crossEntity.StopAllEffectsAfter(3.f);
    crossEntity.DestroyAfter(10.f);

    teleportEntity = (CEntity)theGame.CreateEntity(teleportTemplate, pos, EulerAngles(0, 265 + 180.f, 0));
    teleportEntity.PlayEffect('teleport_activate');
    teleportEntity.PlayEffect('teleport_fx');
    teleportEntity.StopAllEffectsAfter(3.f);
    teleportEntity.DestroyAfter(10.f);
    Sleep(1.f);

    template = (CEntityTemplate)LoadResourceAsync("dlc/dlcnewreplacers/data/entities/nr_blood_spider_boss_big.w2ent", true);
    npc = (CNewNPC)theGame.CreateEntity(template, pos, EulerAngles(0, 265, 0));
    npc.AddTag('fairytale_witch');  // hack for CBehTreeTaskCSEffect.CanSwimOrFly to avoid killing
    npc.AddTag('nr_cross_stone_entity');
    npc.AddTag('nr_cross_stone_boss_spider');
    npc.SetLevel( Max(1, thePlayer.GetLevel() - 10) );
    npc.SetAnimationSpeedMultiplier( 1.1f );
    npc.SetImmortalityMode( AIM_Immortal, AIC_Combat );
    npc.SetImmortalityMode( AIM_Immortal, AIC_Default );
    npc.SetImmortalityMode( AIM_Immortal, AIC_Fistfight );
    npc.SetImmortalityMode( AIM_Immortal, AIC_IsAttackableByPlayer );
    NR_Debug("Check1 = " + theGame.GetActorByTag('nr_cross_stone_boss_spider'));
}

latent quest function NR_UseCrossStone_Q() {
    var stoneEntity                     : CEntity;
    var templatesTier1, templatesTier2  : array<String>;
    var spawnPositions                  : array<Vector>;
    var spawnYaws                       : array<float>;
    var teleportTemplate, crossTemplate, template : CEntityTemplate;
    var teleportEntity                  : CEntity;
    var crossEntity                     : CEntity;
    var npc                             : CNewNPC;
    var pos_indexes                     : array<int>;
    var skillsLearned, entityLevel      : int;
    var triggerType                     : int;
    var i, idx, prev_idx, pidx, prev_pidx, numberToSpawn1, numberToSpawn2, levelReduct : int;
    
    stoneEntity = theGame.GetEntityByTag('nr_interactive_ship_stone');
    stoneEntity.StopEffect('ready');
    stoneEntity.PlayEffect('use');
    triggerType = FactsQuerySum("nr_magic_stone_activated");
    // 1 = player, 2 = auto, 3 = scene (longer activation)

    skillsLearned = FactsQuerySum("nr_magic_skill_learned");
    NR_Debug("NR_UseCrossStone_Q, skillsLearned = " + skillsLearned + " triggerType = " + triggerType);

    teleportTemplate = (CEntityTemplate)LoadResourceAsync("dlc/dlcnewreplacers/data/entities/magic/ft_teleport/nr_q109_keira_teleport_red.w2ent", true);
    crossTemplate = (CEntityTemplate)LoadResourceAsync("dlc/dlcnewreplacers/data/entities/nr_cross_effect.w2ent", true);
    PreloadEffectForEntityTemplate(teleportTemplate, 'teleport_activate');
    PreloadEffectForEntityTemplate(teleportTemplate, 'teleport_fx');
    PreloadEffectForEntityTemplate(crossTemplate, 'cross');
    // 11 variants
    templatesTier1.PushBack("quests/part_3/quest_files/q501_eredin/characters/q501_wild_hunt_tier_1.w2ent");
    templatesTier1.PushBack("dlc/bob/data/living_world/enemy_templates/barghest_late.w2ent");
    templatesTier1.PushBack("quests/part_1/quest_files/q103_daughter/characters/q103_endriaga.w2ent");
    templatesTier1.PushBack("dlc/bob/data/living_world/enemy_templates/endriaga_lvl2_mid.w2ent");
    templatesTier1.PushBack("dlc/bob/data/living_world/enemy_templates/spider_mid.w2ent");

    templatesTier2.PushBack("dlc/bob/data/quests/minor_quests/quest_files/mq7023_mutations/characters/mq7023_gargoyle_1.w2ent");
    templatesTier2.PushBack("quests/part_3/quest_files/q502_avallach/characters/q502_arachas.w2ent");
    templatesTier2.PushBack("dlc/dlcnewreplacers/data/entities/nr_q502_dao_fixed.w2ent");
    templatesTier2.PushBack("dlc/dlcnewreplacers/data/entities/nr_elemental_dao_lvl3__ice_fixed.w2ent");
    templatesTier2.PushBack("dlc/dlcnewreplacers/data/entities/nr_mq4006_ifryt_fixed.w2ent");
    templatesTier2.PushBack("dlc/dlcnewreplacers/data/entities/nr_q210_lab_golem_fixed.w2ent");
    // --- templatesTier2.PushBack("dlc/dlcnewreplacers/data/entities/nr_th701_golem_fixed.w2ent");

    spawnPositions.PushBack( Vector(-247.15420532219997, -304.2886657715, 41.4622840881) );
    spawnYaws.PushBack(265);
    spawnPositions.PushBack( Vector(-246.26473999009994, -298.8557128906, 41.3940124512) );
    spawnYaws.PushBack(233);
    spawnPositions.PushBack( Vector(-243.88269042959996, -296.0598449707, 41.3404922485) );
    spawnYaws.PushBack(220);
    spawnPositions.PushBack( Vector(-239.42431640619998, -294.1918640137, 41.289981842) );
    spawnYaws.PushBack(195);
    spawnPositions.PushBack( Vector(-234.83189392079996, -294.9366149902, 41.2076950073) );
    spawnYaws.PushBack(156);
    // 6 - near stone
    //spawnPositions.PushBack( Vector(-245.4210510254, -304.2425231934, 38.6909980774) );
    //spawnYaws.PushBack(123);
    spawnPositions.PushBack( Vector(-226.16511535639995, -306.4745788574, 41.7022399902) );
    spawnYaws.PushBack(87);
    spawnPositions.PushBack( Vector(-227.60054016099997, -312.5265808106, 41.8976325989) );
    spawnYaws.PushBack(63);
    spawnPositions.PushBack( Vector(-231.21844482409995, -316.3665466309, 41.7458457947) );
    spawnYaws.PushBack(28);
    spawnPositions.PushBack( Vector(-235.35278320299997, -316.4312744141, 41.4080238342) );
    spawnYaws.PushBack(-2);
    spawnPositions.PushBack( Vector(-240.48162841789997, -314.9214477539, 41.2192268372) );
    spawnYaws.PushBack(-28);
    spawnPositions.PushBack( Vector(-244.40750122059995, -310.2827453613, 41.268535614) );
    spawnYaws.PushBack(309);

    numberToSpawn1 = 1;
    numberToSpawn2 = 0;
    levelReduct = 10;
    if (skillsLearned > 5) {
        numberToSpawn1 += 1;
        levelReduct -= 1;
    }
    if (skillsLearned > 8) {
        numberToSpawn2 += 1;
        levelReduct -= 1;
    }
    if (skillsLearned > 10) {
        numberToSpawn1 += 1;
        levelReduct -= 1;
    }
    if (skillsLearned > 12) {
        numberToSpawn2 += 1;
        levelReduct -= 1;
    }
    if (skillsLearned > 14) {
        numberToSpawn1 += 1;
        levelReduct -= 1;
    }

    if (triggerType == 3) {
        // longer activation for scenes
        Sleep(3.f);
    }
    Sleep(3.f);
    stoneEntity.PlayEffect('success');

    // spawn teleports and fx
    prev_pidx = -1;
    for (i = 0; i < numberToSpawn1 + numberToSpawn2; i += 1) {
        pidx = RandDifferent(prev_pidx, spawnPositions.Size());
        pos_indexes.PushBack(pidx);
        NR_ShowLightningFx(stoneEntity.GetWorldPosition() + Vector(0,0,1.8f), spawnPositions[pidx] + Vector(0,0,1.f), true, 'lightning_lynx_red', 'hit_electric_red');

        crossEntity = (CEntity)theGame.CreateEntity(crossTemplate, spawnPositions[pidx] + Vector(0,0,4.f), EulerAngles(0, spawnYaws[pidx] + 180.f, 0));
        crossEntity.PlayEffect('cross');
        crossEntity.StopAllEffectsAfter(3.f);
        crossEntity.DestroyAfter(10.f);

        teleportEntity = (CEntity)theGame.CreateEntity(teleportTemplate, spawnPositions[pidx], EulerAngles(0, spawnYaws[pidx] + 180.f, 0));
        teleportEntity.PlayEffect('teleport_activate');
        teleportEntity.PlayEffect('teleport_fx');
        teleportEntity.StopAllEffectsAfter(3.f);
        teleportEntity.DestroyAfter(10.f);

        Sleep(0.1f);
    }

    Sleep(1.f);

    // spawn hostile entities: Tier1
    prev_idx = -1;
    for (i = 0; i < numberToSpawn1; i += 1) {
        idx = RandDifferent(prev_idx, templatesTier1.Size());
        pidx = pos_indexes[i];
        template = (CEntityTemplate)LoadResourceAsync(templatesTier1[idx], true);
        npc = (CNewNPC)theGame.CreateEntity(template, spawnPositions[pidx], EulerAngles(0, spawnYaws[pidx], 0));
        npc.AddTag('nr_cross_stone_entity');
        npc.AddTag('fairytale_witch');  // hack for CBehTreeTaskCSEffect.CanSwimOrFly to avoid killing
        entityLevel = Max(1, thePlayer.GetLevel() - levelReduct + NR_GetRandomGenerator().next(skillsLearned));
        npc.SetLevel(entityLevel);
        NR_Debug("NR_UseCrossStone_Q: Spawn npc tier1[" + i + "] = (" + idx + ")(" + pidx + ") = " + npc);
        Sleep(0.2f);
    }

    // spawn hostile entities: Tier2
    prev_idx = -1;
    for (i = 0; i < numberToSpawn2; i += 1) {
        idx = RandDifferent(prev_idx, templatesTier2.Size());
        pidx = pos_indexes[i];
        template = (CEntityTemplate)LoadResourceAsync(templatesTier2[idx], true);
        npc = (CNewNPC)theGame.CreateEntity(template, spawnPositions[pidx], EulerAngles(0, spawnYaws[pidx], 0));
        npc.AddTag('nr_cross_stone_entity');
        npc.AddTag('fairytale_witch');  // hack for CBehTreeTaskCSEffect.CanSwimOrFly to avoid killing
        entityLevel = Max(1, thePlayer.GetLevel() - levelReduct - 2 + NR_GetRandomGenerator().next(skillsLearned));
        npc.SetLevel(entityLevel);
        NR_Debug("NR_UseCrossStone_Q: Spawn npc tier2[" + i + "] = (" + idx + ")(" + pidx + ") = " + npc);
        Sleep(0.2f);
    }
}

latent quest function NR_SpawnMeteorsAtEntity_Q(entityTag : name, meteorsNum : int, intervalSec : float) {
    var entity : CEntity;
    var pos : Vector;
    var meteorTemplate : CEntityTemplate;
    var meteor : NR_MeteorProjectile;
    var i : int;

    entity = theGame.GetEntityByTag(entityTag);
    if (!entity) {
        NR_Error("NR_SpawnMeteorsAtEntity_Q: No entity!");
        return;
    }
    meteorTemplate = (CEntityTemplate)LoadResourceAsync("dlc/dlcnewreplacers/data/entities/magic/meteor/nr_eredin_meteor_blue.w2ent", true);
    
    for (i = 0; i < meteorsNum; i += 1) {
        pos = entity.GetWorldPosition();
        meteor = (NR_MeteorProjectile)theGame.CreateEntity(meteorTemplate, pos + Vector(0,0,30.f), entity.GetWorldRotation());
        meteor.m_shakeStrength = 0.3f;
        meteor.Init( thePlayer );
        meteor.ShootProjectileAtPosition( meteor.projAngle, meteor.projSpeed, pos, 500.f, NR_GetStandartCollisionNames() );
        meteor.DestroyAfter(10.f);
        NR_Debug("NR_SpawnMeteorsAtEntity_Q[" + i + "] = " + meteor);
        Sleep(intervalSec);
    }
}

quest function NR_AddChameleonPotion() {
    thePlayer.inv.AddAnItem('nr_chameleon_potion', 1);
}

quest function NR_UseChameleonPotion() {
    //var invMenu : CR4InventoryMenu;
    //var rootMenu : CR4Menu;
    var commonMenuRef : CR4CommonMenu;

    commonMenuRef = theGame.GetGuiManager().GetCommonMenu();

    if (commonMenuRef)
    {
          commonMenuRef.CloseMenu();
    }
    //invMenu = (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild();
    //if (invMenu)
    //  invMenu.OnCloseMenu();
    
    //NR_Notify("NR_UseChameleonPotion");
    /*theGame.Unpause("menus");
    rootMenu = theGame.GetGuiManager().GetRootMenu();
    if ( rootMenu )
    {
        rootMenu.CloseMenu();
    }*/

    theSound.SoundEvent("gui_character_synergy_effect");
    if ( !thePlayer.IsEffectActive( 'invisible' ) )
    {
        thePlayer.PlayEffect( 'use_potion' );
    }
}

latent quest function NR_SaveGameAndWait(type : string, slot : int, wait : float) {
    switch (type) {
        case "SGT_QuickSave":
            theGame.SaveGame(SGT_QuickSave, slot);
            break;
        case "SGT_Manual":
            theGame.SaveGame(SGT_Manual, slot);
            break;
        case "SGT_ForcedCheckPoint":
            theGame.SaveGame(SGT_ForcedCheckPoint, slot);
            break;
        case "SGT_AutoSave":
            theGame.SaveGame(SGT_AutoSave, slot);
            break;
    }
    Sleep(wait);
}

latent function NR_PlaySound( bankName : string, eventName : string, optional saveType : string ) {
    if ( !theSound.SoundIsBankLoaded(bankName) ) {
        theSound.SoundLoadBank(bankName, /*async*/ true);
        NR_Debug("NR_PlaySound: Loading bank [" + bankName + "]");
        while ( !theSound.SoundIsBankLoaded(bankName) ) {
            SleepOneFrame();
        }
        NR_Debug("NR_PlaySound: Loaded bank [" + bankName + "]");
    }
    NR_Debug("NR_PlaySound: bnk [" + bankName + "], event [" + eventName + "], saveType [" + saveType + "]");

    switch (saveType) {
        case "SESB_Save":
            SoundEventQuest(eventName, SESB_Save);
            break;
        case "SESB_ClearSaved":
            SoundEventQuest(eventName, SESB_ClearSaved);
            break;
        default:
            SoundEventQuest(eventName, SESB_DontSave);
            break;
    }
}

latent quest function NR_PlaySound_Q( bankName : string, eventName : string, optional saveType : string ) {
    NR_PlaySound( bankName, eventName, saveType );
}

/*
areaName = "novigrad", "skellige", "kaer_morhen", "prolog_village", 
    "wyzima_castle", "island_of_mist", "spiral", "no_mans_land", "toussaint" 
    (from which area you want to play music)
    NMLand == novigrad!!!
*/
quest function NR_PlayMusic( areaName : string, eventName : string, optional saveType : string ) {
    theSound.InitializeAreaMusic( AreaNameToType(areaName) );

    switch (saveType) {
        case "SESB_Save":
            SoundEventQuest(eventName, SESB_Save);
            break;
        case "SESB_ClearSaved":
            SoundEventQuest(eventName, SESB_ClearSaved);
            break;
        default:
            SoundEventQuest(eventName, SESB_DontSave);
            break;
    }
}

quest function NR_IsInCombatCond_Q( actorTag : name ) : bool {
    var actor : CActor;

    actor = (CActor)theGame.GetEntityByTag(actorTag);
    if (!actor) {
        NR_Error("NR_IsInCombat_Q: actor [" + actorTag + "] not found!");
        return false;
    }
    return actor.IsInCombat();
}

quest function NR_IsInSceneCond_Q(optional checkGameplayScene : bool) : bool {
    if ( theGame.IsDialogOrCutscenePlaying() )
        return true;

    if ( checkGameplayScene && thePlayer.IsInGameplayScene() ) {
        return true;
    }
    return false;
}

latent quest function NR_SwitchMusLocShip_Q() {
    var isOnMasterShip      : bool;
    var isCombatMusActive   : bool;

    isOnMasterShip = FactsQuerySum("nr_on_master_ship") > 0;
    // don't react when not on ship or in scene
    if (!isOnMasterShip || theGame.IsCurrentlyPlayingNonGameplayScene())
        return;

    isCombatMusActive = FactsQuerySum("nr_master_ship_combat_mus") > 0;
    if (thePlayer.IsInCombat()) {
        if (!isCombatMusActive) {
            SoundEventQuest("Stop_mus_loc_master_ship_background", SESB_ClearSaved);
            Sleep(0.5f);
            SoundEventQuest("Play_mus_loc_master_ship_combat", SESB_DontSave);
            FactsAdd("nr_master_ship_combat_mus", 1);
        }
    } else {
        if (isCombatMusActive) {
            SoundEventQuest("Stop_mus_loc_master_ship_combat", SESB_ClearSaved);
            Sleep(0.5f);
            SoundEventQuest("Play_mus_loc_master_ship_background", SESB_Save);
            FactsSet("nr_master_ship_combat_mus", 0);
        }
    }
}

quest function NR_PlayEffectWithTargetComp_Q( entityTag : name, effectName : name, activate : bool, targetTag : name, compName : name )
{
    var entities : array<CEntity>;
    var i      : int;
    var target : CEntity;
    var comp   : CComponent;
    var res    : bool;
    
    target = theGame.GetEntityByTag(targetTag);
    if (!target) {
        NR_Error("NR_PlayEffectWithTargetComp_Q: No target found with tag [" + targetTag + "]");
        return;
    }
    comp = target.GetComponent(compName);
    if (!comp) {
        NR_Error("NR_PlayEffectWithTargetComp_Q: No comp [" + compName + "] found in entity [" + targetTag + "]");
        return;
    }

    theGame.GetEntitiesByTag(entityTag, entities);
    for (i = 0; i < entities.Size(); i += 1 )
    {
        if (activate)
        {
            res = entities[i].PlayEffect(effectName, comp);
            NR_Debug("NR_PlayEffectWithTargetComp_Q: PlayEffect(" + effectName + ", " + comp + ") = " + res);
        }
        else
        {
            res = entities[i].StopEffect(effectName);
        }
    }
}

quest function NR_ToogleEffect_Q( entityTag : name, effectName : name ) {
    var entity : CEntity;

    entity = theGame.GetEntityByTag( entityTag );
    if ( !entity ) {
        NR_Error("NR_ToogleEffect_Q: no entity [" + entityTag + "] found!");
    }
    if ( entity.IsEffectActive(effectName) ) {
        entity.StopEffect(effectName);
    } else {
        entity.PlayEffect(effectName);
    }
}

quest function NR_IsNearTargetCond_Q( entityTag : name, targetTag : name, maxDistance : float ) : bool {
    var entity, target : CEntity;

    entity = theGame.GetEntityByTag( entityTag );
    if ( !entity ) {
        NR_Error("NR_IsNearTargetCond_Q: no entity [" + entityTag + "] found!");
        return false;
    }
    target = theGame.GetEntityByTag( targetTag );
    if ( !target ) {
        NR_Error("NR_IsNearTargetCond_Q: no target [" + targetTag + "] found!");
        return false;
    }
    return VecDistance(entity.GetWorldPosition(), target.GetWorldPosition()) <= maxDistance;
}

quest function NR_PlayHeadEffect_Q( tag : name, effect : name, optional stop : bool ) {
    NR_PlayHeadEffect( tag, effect, stop );
}

function NR_PlayHeadEffect( tag : name, effect : name, optional stop : bool )
{
    var inv     : CInventoryComponent;
    var headIds : array<SItemUniqueId>;
    var headId  : SItemUniqueId;
    var head    : CItemEntity;
    var i       : int;
    var target  : CActor;
    
    target = (CActor)theGame.GetEntityByTag(tag);
    if (!target) {
        NR_Error("NR_PlayHeadEffect: no actor with tag [" + tag + "]");
        return;
    }
    inv = target.GetInventory();
    headIds = inv.GetItemsByCategory('head');
    if (headIds.Size() == 0) {
        NR_Error("NR_PlayHeadEffect: no head category items in actor [" + tag + "]");
        return;
    }
    
    for ( i = 0; i < headIds.Size(); i+=1 )
    {
        if ( !inv.IsItemMounted( headIds[i] ) )
        {
            continue;
        }
        
        headId = headIds[i];
                
        if (!inv.IsIdValid( headId ))
        {
            NR_Debug("NR_PlayHeadEffect: invalid head item id [" + i + "]");
            continue;
        }
        
        head = inv.GetItemEntityUnsafe( headId );
        
        if ( !head )
        {
            NR_Debug("NR_PlayHeadEffect: null head entity [" + i + "]");
            continue;
        }

        if ( stop )
        {
            if ( head.IsEffectActive( effect ) ) {
                head.StopEffect( effect );
                NR_Debug("NR_PlayHeadEffect: stop head effect: " + effect + " [" + i + "]");
            }
        }
        else
        {
            if ( head.IsEffectActive( effect ) )    
                head.StopEffect( effect );          
            head.PlayEffect( effect );
            NR_Debug("NR_PlayHeadEffect: play head effect: " + effect + " [" + i + "]");
        }
    }
}

quest function NR_MagicActionAbilityUnlock_Q( type : name, abilityName : String ) {
    NR_GetMagicManager().ActionAbilityUnlock(ENR_NameToMA(type), abilityName);
}

// sceneBlockId = always NR-modded scene block
quest function NR_SetSceneBlockActive_Q( questPath : name, sceneBlockId : int, active : bool ) {
    var startTime : float = theGame.GetEngineTimeAsSeconds();

    NR_GetPlayerManager().SetSceneBlockActive(questPath, sceneBlockId, active);
    NR_Debug("NR_SetSceneBlockActive_Q: " + NameToString(questPath) + " #" + IntToString(sceneBlockId) + ", active = " + active + ", elapsed = " + FloatToString(theGame.GetEngineTimeAsSeconds() - startTime));
}

// sceneBlockId = always NR-modded scene block
quest function NR_IsSceneBlockActive_Q( questPath : name, sceneBlockId : int ) : bool {
    var active : bool;
    var startTime : float = theGame.GetEngineTimeAsSeconds();
    
    active = NR_GetPlayerManager().IsSceneBlockActive( questPath, sceneBlockId );
    NR_Debug("NR_IsSceneBlockActive_Q: " + NameToString(questPath) + " #" + IntToString(sceneBlockId) + ", active = " + active + ", elapsed = " + FloatToString(theGame.GetEngineTimeAsSeconds() - startTime));
    return active;
}

latent quest function NR_ProcessMasterThunder_Q() {
    var i, factVal, oldFactVal : int;
    var interval : float;
    var skyPos : Vector;
    var masterComp, golemComp : CComponent;
    var entity : CEntity;
    var lightningEntities : array<CEntity>;
    var golem, master : CActor;

    var height : float = 30.f;
    var radiusMax : float = 15.f;
    var started : bool = false;

    master = theGame.GetActorByTag('nr_master_mage');
    if ( !NR_FindActorInScene('NR_CELESTINE', golem) ) {
        return;
    }

    masterComp = master.GetComponent("l_hand_component");
    golemComp = golem.GetComponent("grassCollider");

    while (true) {
        SleepOneFrame();
        factVal = FactsQuerySum("nr_scene_crafting_thunder");
        if (!factVal)
            break;

        if (factVal == oldFactVal)
            continue;

        oldFactVal = factVal;
        skyPos = master.GetWorldPosition() + VecRingRand(1.f, radiusMax) + Vector(0,0,height);
        entity = NR_StartLightningToNode(skyPos, masterComp, 'lightning_loop_blue', 'hit_electric_blue');
        lightningEntities.PushBack( entity );
        Sleep(0.05f);
        master.SoundEvent("magic_sorceress_vfx_lightning_bolt");

        if (factVal == 7) {
            Sleep(0.1f);
            entity = NR_StartLightningToNode(golemComp.GetWorldPosition(), masterComp, 'lightning_loop_blue', 'hit_electric_blue');
            lightningEntities.PushBack( entity );
        }
    }

    for (i = 0; i < lightningEntities.Size(); i += 1) {
        NR_Debug("Stop effects: [" + i + "] " + lightningEntities[i]);
        lightningEntities[i].StopAllEffects();
        lightningEntities[i].DestroyAfter(5.f);
    }
}

quest function NR_ProcessSorceressFlowFx_Q() {
    var golem : CActor;
    var golemComp : CComponent;
    var factVal : int;

    if ( !NR_FindActorInScene('NR_CELESTINE', golem) ) {
        return;
    }
    golemComp = golem.GetComponent('grassCollider');  // grassCollider2 = l_toe
    factVal = FactsQuerySum("nr_scene_crafting_flow_fx");
    // R: water = 1, earth = 2, fire = 4, air = 8
    // L: water = 16, earth = 32, fire = 64, air = 128
    if (factVal & 1) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_water_r");
        thePlayer.PlayEffect('energy_flow_water_r', golemComp);
    } else if (factVal & 2) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_ground_r");
        thePlayer.PlayEffect('energy_flow_ground_r', golemComp);
    } else if (factVal & 4) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_fire_r");
        thePlayer.PlayEffect('energy_flow_fire_r', golemComp);
    } else if (factVal & 8) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_air_r");
        thePlayer.PlayEffect('energy_flow_air_r', golemComp);
    }

    if (factVal & 16) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_water_l");
        thePlayer.PlayEffect('energy_flow_water_l', golemComp);
    } else if (factVal & 32) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_ground_l");
        thePlayer.PlayEffect('energy_flow_ground_l', golemComp);
    } else if (factVal & 64) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_fire_l");
        thePlayer.PlayEffect('energy_flow_fire_l', golemComp);
    } else if (factVal & 128) {
        NR_Debug("NR_ProcessSorceressFlowFx_Q: energy_flow_air_l");
        thePlayer.PlayEffect('energy_flow_air_l', golemComp);
    }
}

quest function NR_ProcessGolemMorph_Q() {
    var     golem : CActor;
    var    components : array<CComponent>;
    var       manager : CMorphedMeshManagerComponent;
    var             i, j : int;
    var ratio       : float = 1.f;
    var blendTime   : float = 2.f;

    if ( !NR_FindActorInScene('NR_CELESTINE', golem) ) {
        return;
    }
    components = golem.GetComponentsByClassName('CMorphedMeshManagerComponent');
    NR_Debug("NR_ProcessGolemMorph_Q: Celestine app = " + golem.GetAppearance());
    if (components.Size() == 0) {
        NR_Debug("NR_ProcessGolemMorph_Q: [ERROR] Not found morph managers for " + golem);
    }
    for (j = 0; j < components.Size(); j += 1) {
        manager = (CMorphedMeshManagerComponent) components[j];
        if (manager) {
            NR_Debug("NR_ProcessGolemMorph_Q: [Info] Current morph ratio: " + manager.GetMorphBlend());
            manager.SetMorphBlend( ratio, blendTime );
            NR_Debug("NR_ProcessGolemMorph_Q: [OK] Morph component: " + manager + " to <" + ratio + "> in " + blendTime + " sec");
        }
    }
}

latent quest function NR_SpawnHostileEntity_Q(path : String, relativeLevel : int, x : float, y : float, z : float, yaw : float) {
    var template : CEntityTemplate;
    var npc     : CNewNPC;

    template = (CEntityTemplate)LoadResourceAsync(path, true);
    if (!template) {
        NR_Debug("NR_SpawnHostileEntity_Q: !template: " + path);
        return;
    }
    npc = (CNewNPC)theGame.CreateEntity(template, Vector(x,y,z), EulerAngles(0.f, yaw, 0.f));
    npc.SetLevel(Max(1, thePlayer.GetLevel() + relativeLevel));
    npc.AddTag('NR_SpawnHostileEntity_Q');
    npc.AddTag('fairytale_witch');
}

// Change from replacer - save type, change to geralt - restore replacer if saved
latent function NR_ChangePlayerQuestWrapper( designatedTemplate: EQuestReplacerEntities )
{
    var manager : NR_PlayerManager = NR_GetPlayerManager();

    switch (designatedTemplate) {
        case EQRE_Geralt:
            if ( manager.HasReplacerForQuestSaved() ) {
                NR_ChangePlayerLatent( manager.PullReplacerForQuest() );
            } else {
                if ( manager.IsReplacerActive() )
                    manager.SaveReplacerForQuest();
                NR_ChangePlayerLatent( ENR_PlayerGeralt );
            }
            break;
        case EQRE_Ciri:
            if ( manager.IsReplacerActive() )
                manager.SaveReplacerForQuest();
            NR_ChangePlayerLatent( ENR_PlayerCiri );
            thePlayer.ApplyAppearance("ciri_player");
            break;
        case EQRE_CiriNaked:
            if ( manager.IsReplacerActive() )
                manager.SaveReplacerForQuest();
            NR_ChangePlayerLatent( ENR_PlayerCiri, /*nakedCiriTemplate*/ true );
            break;
        case EQRE_CiriWounded:
            if ( manager.IsReplacerActive() )
                manager.SaveReplacerForQuest();
            NR_ChangePlayerLatent( ENR_PlayerCiri );
            thePlayer.ApplyAppearance("ciri_wounded");
            break;
        case EQRE_CiriWounded:
            if ( manager.IsReplacerActive() )
                manager.SaveReplacerForQuest();
            NR_ChangePlayerLatent( ENR_PlayerCiri );
            thePlayer.ApplyAppearance("ciri_winter");
            break;
        default:
            NR_Error("NR_ChangePlayerQuest: Unkown designatedTemplate = " + designatedTemplate);
            break;
    }

    thePlayer.abilityManager.RestoreStat(BCS_Vitality);
}
