exec function startNTR() {
	FactsAdd("ntr_quest_allowed", 2);
}

exec function NTR_lvl( tag : name, level : int ) {
	NTR_SetRelativeLevel(tag, level);
}

exec function encTest(enable: bool) {
	var encounter : CEncounter;
	encounter = (CEncounter)theGame.GetEntityByTag( 'shop_20_fishermans_hut_alchemist_enc' );
	if (encounter) {
		NTR_notify("OK!");
		encounter.EnableEncounter(enable);
		if (!enable) {
			encounter.ForceDespawnDetached();
			// or encounter.LeaveArea() ?
		} else {
			encounter.EnterArea();
		}
	}
}
exec function debugBaron(optional force : int) {
	var           npc : CNewNPC;


	npc = (CNewNPC)theGame.GetNPCByTag('ntr_baron_edward');

	NTR_notify("GetImmortalityMode = " + npc.GetImmortalityMode());
	npc.LogAllAbilities();
	if (force == 1)
		npc.ForceVulnerable();
	else if  (force == 2)
		npc.Kill('dieee', 1);
	else if (force == 3)
		npc.abilityManager.OnOwnerRevived();
}

exec function testHorse() {
	HorseWhistle();
}
//  ShowCredits(ntr_credits_1, 0)
exec function test_msg() {
	var showTime : float;
	var timeLapseMessageKey : string;
	var timeLapseAdditionalMessageKey : string;

	showTime = 7.0;
	timeLapseMessageKey = "ntr_test_msg";
	timeLapseAdditionalMessageKey = "ntr_test_msg_add";
	ShowTimeLapse(showTime, timeLapseMessageKey, timeLapseAdditionalMessageKey);
}

exec function credits(num : int) {
	var effectName : name;	
	var      template : CEntityTemplate;
	var           pos : Vector;
	var          logo : CEntity;
	var        result : Bool;
	
	if (num == 1) {
		effectName = 'ntr_credits_1';
	} else if (num == 2) {
		effectName = 'ntr_credits_2';
	} else if (num == 3) {
		effectName = 'ntr_credits_3';
	} else if (num == 4) {
		effectName = 'ntr_credits_4';
	} else if (num == 5) {
		effectName = 'ntr_credits_5';
	}
	logo = theGame.GetEntityByTag('ntr_logo_credits');
	/*if (destoy) {
		if (logo) {
			logo.Destroy();
		}
		return;
	}*/
	if (!logo) {
		template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/ntr_logo_entity.w2ent", true);
		pos = thePlayer.GetWorldPosition();
		pos.Z += 10.0;
		logo = (CEntity)theGame.CreateEntity(template, pos);
		logo.AddTag('ntr_logo_credits');
		//result = logo.CreateAttachment(thePlayer, 'r_weapon', Vector(0, 0, 0), EulerAngles(0, 0, 0));
	}

	logo.StopAllEffects();
	logo.PlayEffect(effectName);
}

// not work?
//NTR_MoveNPCsTo(oriana_test2, , 2.0)
exec function NTR_MoveNPCsTo(tag : name, target : name, optional speed : float) {
	var i               : int;
	var l_npcs 		    : array<CNewNPC>;
	var l_aiTree		: CAIMoveToAction;
	
	theGame.GetNPCsByTag(tag, l_npcs);
	
	l_aiTree = new CAIMoveToAction in theGame;
	l_aiTree.OnCreated();
	
	l_aiTree.params.targetTag = target;
	l_aiTree.params.moveSpeed = speed;
	l_aiTree.params.rotateAfterwards = false;
	
	if( speed > 1.0 )
	{
		l_aiTree.params.moveType = MT_Run;
	}
	
	for	( i = 0; i < l_npcs.Size(); i+= 1 )
	{
		if (l_npcs[i].IsAlive()) {
			l_npcs[i].ForceAIBehavior( l_aiTree, BTAP_Idle);
			NTR_notify("Force move " + l_npcs[i]);
		}
		/*
			BTAP_Unavailable,
            BTAP_Idle,
            BTAP_Emergency,
            BTAP_Combat,
            BTAP_FullCutscene,
            BTAP_BelowIdle,
            BTAP_AboveIdle,
            BTAP_AboveIdle2,
            BTAP_AboveEmergency,
            BTAP_AboveEmergency2,
            BTAP_AboveCombat,
            BTAP_AboveCombat2
        */
	}
}
/*function colorEntCommon(compN : int, h1 : Uint16, s1 : Int8, l1 : Int8, h2 : Uint16, s2 : Int8, l2 : Int8) {
	var template, temp : CEntityTemplate;
    //var colEntry : SEntityTemplateColoringEntry;
    var col1 : CColorShift;
    var col2 : CColorShift;
    var ent, npcEntity : CEntity;
    var pos : Vector;
    var rot : EulerAngles;
    var comp : CAppearanceComponent;    
    
    pos = thePlayer.GetWorldPosition() + VecConeRand(thePlayer.GetHeading(), 0, 2,2);
    rot = thePlayer.GetWorldRotation();
    rot.Yaw += 180;
    
        
    npcEntity = theGame.GetEntityByTag('colshifttestnpc');
    npcEntity.Destroy();
        
    //template = (CEntityTemplate)LoadResource( "characters\models\crowd_npc\nml_villager\torso\t1a_04_ma__nml_villager.w2ent", true);
    temp = (CEntityTemplate)LoadResource( "dlc/dlcntr/data/entities/baron_edward.w2ent", true);
       
    //colEntry.appearance = 'bob_knight_15';
    //colEntry.componentName = 'a_01_mb__bob_knights';

    col1.hue = h1;
    col1.saturation = s1;
    col1.luminance = l1;

    col2.hue = h2;
    col2.saturation = s2;
    col2.luminance = l2;

    //colEntry.colorShift1 = col1;
    //colEntry.colorShift2 = col2;
    
    if (temp.coloringEntries.Size() <= compN || compN < 0) {
        NTR_notify("Wrong! Max" + temp.coloringEntries.Size());
    } else {
        temp.coloringEntries[compN].colorShift1 = col1;
        temp.coloringEntries[compN].colorShift2 = col2;
        NTR_notify("Coloring comp [" + temp.coloringEntries[compN].componentName + "]");
    }

    npcEntity = theGame.CreateEntity( temp, pos, rot);
    npcEntity.ApplyAppearance('bob_knight_15');
    npcEntity.AddTag('colshifttestnpc');   
}

exec function colorEnt(compN : int, h1 : Uint16, s1 : Int8, l1 : Int8, h2 : Uint16, s2 : Int8, l2 : Int8)
{
    colorEntCommon(compN, h1, s1, l1, h2, s2, l2);
}

exec function clearColorEnt() {
	// for Baron
	
	colorEnt(0, -46, 36, -72, 50, -56, -23)
	colorEnt(1, 333, -100, 7, 315, -23, -56)
	colorEnt(2, 65, -41, -44, 333, -23, -56)
	colorEnt(3, 65, -41, -44, 333, -23, -56)

	
}*/

exec function getPosRot(tag : name) {
	var ent : CEntity;
	var pos : Vector;
	var rot : EulerAngles;

	ent = theGame.GetEntityByTag(tag);
	pos = ent.GetWorldPosition();
	rot = ent.GetWorldRotation();
	NTR_notify("Entity <" + tag + "> pos: [" + pos.X + ", " + pos.Y + ", " + pos.Z + "], rot: [" + rot.Pitch + ", " + rot.Yaw + ", " + rot.Roll + "]");
}
exec function shiftPosRot(tag : name, x, y, z, pitch, yaw, roll : float) {
	var ent : CEntity;
	var pos : Vector;
	var rot : EulerAngles;

	ent = theGame.GetEntityByTag(tag);
	pos = ent.GetWorldPosition() + Vector(x, y, z);
	rot = ent.GetWorldRotation();
	rot.Pitch += pitch;
	rot.Yaw += yaw;
	rot.Roll += roll;
	ent.TeleportWithRotation(pos, rot);
}

exec function sc(num : int, optional input : String) {
    var scene : CStoryScene;
    var entity: CEntity;
    var path  : String;
	var sceneNames : array<String>;
	var null: String;
	
	sceneNames.PushBack("00.not_exist.w2scene");             // 0
	sceneNames.PushBack("01.intro_hag.w2scene");
	sceneNames.PushBack("02.intro_hag_runs.w2scene");
	sceneNames.PushBack("03.geralt_oneliners.w2scene");
	sceneNames.PushBack("04.triss_appear.w2scene");
	sceneNames.PushBack("05.triss_to_monster.w2scene");
	sceneNames.PushBack("06.triss_barghests.w2scene");
	sceneNames.PushBack("07.gameplay_triss_power.w2scene");
	sceneNames.PushBack("18_2.fisherman_oneliners.w2scene"); // 08
	sceneNames.PushBack("09.triss_final.w2scene");
	sceneNames.PushBack("10.regis_owl_arrive.w2scene");
	sceneNames.PushBack("11.orphanage.w2scene");
	sceneNames.PushBack("12.fistfight_loose.w2scene");
	sceneNames.PushBack("13.gameplay_orphanage.w2scene");
	sceneNames.PushBack("14.fistfight_win.w2scene");
	sceneNames.PushBack("15.fistfight_repeat.w2scene");
	sceneNames.PushBack("16.baron_meeting.w2scene");
	sceneNames.PushBack("17.baron_oneliners.w2scene");
	sceneNames.PushBack("18.fisherman.w2scene");
	sceneNames.PushBack("19.orianna_appear.w2scene");
	sceneNames.PushBack("20.orianna_main.w2scene");
	sceneNames.PushBack("21.orianna_to_bruxa.w2scene");
	sceneNames.PushBack("22.orianna_kills_geralt.w2scene");
	sceneNames.PushBack("23.orianna_bruxa_dies.w2scene");
	sceneNames.PushBack("24.baron_river_friendly.w2scene");
	sceneNames.PushBack("25.baron_dies_long.w2scene");
	sceneNames.PushBack("26.baron_river_aggressive.w2scene");
	sceneNames.PushBack("27.baron_dies_short.w2scene");
	sceneNames.PushBack("28.orianna_farewell.w2scene");
	sceneNames.PushBack("29.baron_leaving.w2scene");
	sceneNames.PushBack("30.children_corvo_byanko.w2scene");
	sceneNames.PushBack("31.ntr_completed.w2scene");
	sceneNames.PushBack("32.orianna_oneliners.w2scene");
	sceneNames.PushBack("33.orianna_diary.w2scene");
	sceneNames.PushBack("25b.baron_dies_long_with_ori.w2scene");
	
	if (input == null) {
		input = "Input";
	}
	//NTR_notify("input = " + input);
	path = "dlc/dlcntr/data/scenes/" + sceneNames[num];
	
    // -> SET SCENE PATH
    scene = (CStoryScene)LoadResource(path, true);
    theGame.GetStorySceneSystem().PlayScene(scene, input);
}

// cs704_diva_feeding
exec function orisc(optional input : String) {
	var scene : CStoryScene;
    var path  : String;
    var null: String;

	path = "dlc/bob/data/quests/main_quests/quest_files/q704_truth/scenes/q704_05_return_to_diva.w2scene";
    // -> SET SCENE PATH
    scene = (CStoryScene)LoadResource(path, true);
    theGame.GetStorySceneSystem().PlayScene(scene, input);
}
// q704_to_damien_with_regis
// FromBirds, FromRegis, Oneliner
exec function orisc2(optional input : String) {
	var scene : CStoryScene;
    var path  : String;
    var null: String;

	path = "dlc/bob/data/quests/main_quests/quest_files/q704_truth/scenes/q704_06_regis_info_inject.w2scene";
    // -> SET SCENE PATH
    scene = (CStoryScene)LoadResource(path, true);
    theGame.GetStorySceneSystem().PlayScene(scene, input);
}

exec function resetFact( factID : name ) {
	ResetFactQuest( factID );
}
exec function addFact( factID : name, val : int ) {
	FactsAdd( factID, val );
}

exec function ulock() {
	var actionLocks : array<array< SInputActionLock >>;
	var j,i : int;
	NTR_notify("TEST!");
	actionLocks = thePlayer.GetAllActionLocks();
	for (i = 0; i < actionLocks.Size(); i += 1) {
		for (j = 0; j < actionLocks[i].Size(); j += 1) {
			NTR_notify("lock[" + i + "][" + j + "] = " + actionLocks[i][j].sourceName);
		}
		
	}
	
}
//addAbl(ntr_triss_monster, ntr_mon_orianna_triss, 0)
exec function addAbl( tag : name, abl : name, optional remove : bool ) {
	var           npc : CNewNPC;
	npc = (CNewNPC)theGame.GetNPCByTag(tag);
	if ( npc.HasAbility(abl) )
		NTR_notify("Has ability: " + abl);
	if ( remove )
		npc.RemoveAbilityAll(abl);
	else
		npc.AddAbility(abl);
}
exec function getAttr( tag : name ) {
	var           npc : CNewNPC;
	var abls, attrs  : array<name>;
	var i : int;
	var val : SAbilityAttributeValue;
	
	npc = (CNewNPC)theGame.GetNPCByTag(tag);
	npc.GetCharacterStats().GetAbilities(abls);
	npc.GetCharacterStats().GetAllAttributesNames(attrs);
	if (npc.HasAbility('ntr_mon_orianna_bruxa') || npc.HasAbility('ntr_mon_triss'))
		NTR_notify("YEAH IT HAS IT!!!");
	for (i = 0; i < abls.Size(); i += 1) {
		NTR_notify("Ability: " + abls[i]);
	}
	for (i = 0; i < attrs.Size(); i += 1) {
		if( theGame.params.IsForbiddenAttribute(attrs[i]) )
			continue;
		val = npc.GetAttributeValue(attrs[i]);
		NTR_notify("Attribute: " + attrs[i] + ", value: [base = " + val.valueBase + "], [mult = " + val.valueMultiplicative + "], [add = " + val.valueAdditive + "]");
	}
	NTR_notify("Max ess: " + npc.GetStatMax(BCS_Essence));
	NTR_notify("Cur ess: " + npc.GetStat(BCS_Essence));
	NTR_notify("Max vit: " + npc.GetStatMax(BCS_Vitality));
	NTR_notify("Cur vit: " + npc.GetStat(BCS_Vitality));
	NTR_notify("Immortality: " + npc.GetImmortalityMode());
}
/* 30
[NTR_MOD] Max essence: 15357.599609
[NTR_MOD] Cur essence: 14860.817383

50
[NTR_MOD] Max essence: 25725.601563
[NTR_MOD] Cur essence: 22860.562500
*/
/*[Stats] -      [CALCULATED EXP]        -
[Stats] - base, without difficulty and -
[Stats] -   level difference bonuses   -
[Stats] --------------------------------
[Stats]  -> for entity : 
[Stats] --------------------------------
[Stats] * modDamage : 5380.500488
[Stats] * modArmor : 4000.000000
[Stats] * modVitality : 25722.601563
[Stats] + modOther : 11.000000
[Stats] --------------------------------
[Stats]  BASE EXPERIENCE POINTS = [ 40 ]
[Stats] --------------------------------*/

/*quest function oriDebug() {
	var           npc : CNewNPC;
	
	npc = (CNewNPC)theGame.GetNPCByTag('ntr_orianna_vampire');
	if (npc)
		NTR_notify("Appearance: <" + npc.GetAppearance() + ">");
	else
		NTR_notify("NOT FOUND!");
}*/
exec function soundState() {
	theSound.EnterGameState( ESGS_Default );
}
exec function soundState2() {
	theSound.LeaveGameState( ESGS_DialogNight );
}
exec function soundState4() {
	theSound.LeaveGameState( theSound.GetCurrentGameState() );
}
exec function soundState3() {
	NTR_notify( theSound.GetCurrentGameState() );
}
/*			case ESGS_Default:
				return "";
			case ESGS_Exploration:
				return "exploration";
			case ESGS_ExplorationNight:
				return "exploration_night";
			case ESGS_Focus:
				return "focus_exploration";
			case ESGS_FocusNight:
				return "focus_exploration_night";
			case ESGS_Combat:
				return "combat";
			case ESGS_CombatMonsterHunt:
				return "combat_monster_hunt";
			case ESGS_Dialog:
				return "dialog_scene";
			case ESGS_DialogNight:
				return "dialog_scene_night";
			case ESGS_Cutscene:
				return "cutscene";
			case ESGS_Minigame:
				return "minigames";
			case ESGS_Death:
				return "death";
			case ESGS_Movie:
				return "movie";
			case ESGS_Boat:
				return "boat";
			case ESGS_MusicOnly:
				return "music_only";
			case ESGS_Underwater:
				return "underwater";
			case ESGS_UnderwaterCombat:
				return "underwater_combat";
			case ESGS_FocusUnderwater:
				return "underwater_focus";
			case ESGS_FocusUnderwaterCombat:
				return "underwater_combat_focus";
			case ESGS_Paused:
				return "pause";
			case ESGS_Gwent:
				return "gwent";
			default:
				return "";*/
exec function execHide(range : float) {
    var acceptedTags : array<name>;
    var acceptedVoicetags : array<name>;
    var killIfHostile : bool;

    killIfHostile = true;
    acceptedTags.PushBack('PLAYER');
    //acceptedTags.PushBack('ntr_fisherman');
    acceptedVoicetags.PushBack('CELINA MONSTER');

    NTR_HideActorsInRange(range, acceptedTags, acceptedVoicetags, killIfHostile);
}

exec function execUnhide(range : float) {
    NTR_UnhideActorsInRange(range);
}

/*exec function getInRange(range : float, optional makeFriendly : int) {
    var entities: array<CGameplayEntity>;
    var actor : CActor;
    var i, t, maxEntities: int;
    var tags : array<name>;
    var pos : Vector;
        
    maxEntities = 1000;

    FindGameplayEntitiesInRange(entities, thePlayer, range, maxEntities);

    pos = thePlayer.GetWorldPosition();
    LogChannel('getInRange', "player pos: [" + pos.X + ", " + pos.Y + ", " + pos.Z + "]");
        
    for (i = 0; i < entities.Size(); i += 1) {
    	LogChannel('getInRange', "entity: " + entities[i]);
    	tags = entities[i].GetTags();

        for (t = 0; t < tags.Size(); t += 1) {
           LogChannel('getInRange', "   > tag " + tags[t]);
        }
        actor = (CActor)entities[i];
        if (actor) {
            if (!actor.IsAlive()) {
            	LogChannel('getInRange', "* actor dead");
            	continue;
            }
            if (actor.HasAttitudeTowards(thePlayer)) {
            	LogChannel('getInRange', "* GetAttitude to player: " + actor.GetAttitude(thePlayer));
            }
			LogChannel('getInRange', "* GetAttitudeGroup: " + actor.GetAttitudeGroup());
            

            LogChannel('getInRange', "* GetVoicetag: " + actor.GetVoicetag());
            LogChannel('getInRange', "* GetDisplayName: " + actor.GetDisplayName());
            if (makeFriendly == 1)
            	actor.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
            if (makeFriendly == 2  && ((actor.HasAttitudeTowards(thePlayer) && actor.GetAttitude(thePlayer) == AIA_Hostile) || actor.GetAttitudeGroup() == 'AG_nightwraith' || actor.GetAttitudeGroup() == 'hostile_to_player')) {
            	LogChannel('HideInRange', " x KILL");
            	actor.OnCutsceneDeath();
            }
            if (makeFriendly == 3)
            	actor.OnCutsceneDeath();            	
        }
    }
}*/

exec function scentGet() {
	var focusModeController : CFocusModeController;
	var i : int;

	focusModeController = theGame.GetFocusModeController();
	if ( focusModeController ) {
		for (i = 0; i < focusModeController.detectedCluesTags.Size(); i += 1) {
			NTR_notify("scent[" + i + " = " + focusModeController.detectedCluesTags[i]);
		}
	}
	NTR_notify("scentGet !");
}
exec function scentOn1() {
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent1', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent2', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent3', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent4', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent5', -1 );
	FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scents', -1 );
	NTR_notify("scentON1 !");
}
exec function scentOn11() {
	FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent1', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent2', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent3', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent4', -1 );
	//FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent5', -1 );
	NTR_notify("scentON1 !");
}
exec function scentOn2() {
	FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent1', -1 );
	FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent2', -1 );
	FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent3', -1 );
	FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent4', -1 );
	FocusEffect( FEAA_Enable, 'focus_smell', 'ntr_orianna_scent5', -1 );
	NTR_notify("scentON2 !");
}
/*exec function enableScent(enable : bool) {
	var scent : CCustomScent;
	var points : array<Vector>;

	scent = (CCustomScent) theGame.GetEntityByTag('ntr_orianna_scents');
	points.PushBack( Vector(-410.2420349121, -1439.0350341797, 87.9959182739) );
	points.PushBack( Vector(-407.3211975098, -1441.0976562500, 88.1598815918) );
	points.PushBack( Vector(-406.3743591309, -1443.0831298828, 88.1598815918) );
	scent.setScentPoints(points);
	scent.setScentEnabled(enable);
}
exec function scentDist(dist : float) {
	var scent : CCustomScent;

	scent = (CCustomScent) theGame.GetEntityByTag('ntr_orianna_scent_l');
	scent.setScentDistance(dist);
}*/

exec function GiveReward( rewardName : name ) : void
{
	theGame.GiveReward( rewardName, thePlayer );
}
function NTR_additem(itemName : name, optional count : int, optional equip : bool)
{
	var ids : array<SItemUniqueId>;
	var i : int;

	if(IsNameValid(itemName))
	{
		ids = thePlayer.inv.AddAnItem(itemName, count);
		if(thePlayer.inv.IsItemSingletonItem(ids[0]))
		{
			for(i=0; i<ids.Size(); i+=1)
				thePlayer.inv.SingletonItemSetAmmo(ids[i], thePlayer.inv.SingletonItemGetMaxAmmo(ids[i]));
		}
		
		if(ids.Size() == 0)
		{
			LogItems("exec function additem: failed to add item <<" + itemName + ">>, most likely wrong item name");
			return;
		}
		
		if(equip)
			thePlayer.EquipItem(ids[0]);
	}
	else
	{
		LogItems("exec function additem: Invalid item name <<"+itemName+">>, cannot add");
	}
}

exec function getAcero() {
	NTR_additem('ntr_acero_sword_pc', 1, true);
}
exec function getItem(itemName : name) {
	NTR_additem(itemName, 1, true);
}
exec function getExoticSilver() {
        NTR_additem('stiletto_silver', 1, false);
        NTR_additem('hachyar', 1, false);
        NTR_additem('sickle_silver', 1, false);
        NTR_additem('machete_silver', 1, false);
        NTR_additem('silver', 1, false);
        NTR_additem('roh', 1, false);
        NTR_additem('talon', 1, false);
        NTR_additem('sabre', 1, false);
        NTR_additem('serrator', 1, false);
        NTR_additem('soul', 1, false);
        NTR_additem('kama_silver', 1, false);
        NTR_additem('naginata_silver', 1, false);
        NTR_additem('glaive_silver', 1, false);
        NTR_additem('crescent_silver', 1, false);
        NTR_additem('luani', 1, false);
        NTR_additem('rapier_silver', 1, false);
        NTR_additem('hjaven', 1, false);
        NTR_additem('maltonge', 1, false);
        NTR_additem('skinner', 1, false);
        NTR_additem('rachis', 1, false);
        NTR_additem('dagger1_silver', 1, false);
        NTR_additem('dagger2_silver', 1, false);
        NTR_additem('dagger3_silver', 1, false);
        NTR_additem('shortsword1_silver', 1, false);
        NTR_additem('shortsword2_silver', 1, false);
        NTR_additem('shortsword3_silver', 1, false);
        NTR_additem('greatsword1_silver', 1, false);
        NTR_additem('greatsword2_silver', 1, false);
        NTR_additem('greatsword3_silver', 1, false);
}
exec function getExoticSteel() {
        NTR_additem('stiletto', 1, false);
        NTR_additem('meat', 1, false);
        NTR_additem('cleaver', 1, false);
        NTR_additem('sickle', 1, false);
        NTR_additem('machete', 1, false);
        NTR_additem('bajinn', 1, false);
        NTR_additem('roh', 1, false);
        NTR_additem('claw', 1, false);
        NTR_additem('sabre', 1, false);
        NTR_additem('jaggat', 1, false);
        NTR_additem('spirit', 1, false);
        NTR_additem('kama', 1, false);
        NTR_additem('naginata', 1, false);
        NTR_additem('glaive', 1, false);
        NTR_additem('crescent', 1, false);
        NTR_additem('chakram', 1, false);
        NTR_additem('rapier', 1, false);
        NTR_additem('venasolak', 1, false);
        NTR_additem('orkur', 1, false);
        NTR_additem('wrisp', 1, false);
        NTR_additem('spinner', 1, false);
        NTR_additem('dagger1', 1, false);
        NTR_additem('dagger2', 1, false);
        NTR_additem('dagger3', 1, false);
        NTR_additem('shortsword1', 1, false);
        NTR_additem('shortsword2', 1, false);
        NTR_additem('shortsword3', 1, false);
        NTR_additem('greatsword1', 1, false);
        NTR_additem('greatsword2', 1, false);
        NTR_additem('greatsword3', 1, false);
}

exec function timeScale(timeScale : float) {
	SetTimeScaleQuest(timeScale);
}

exec function animScale(entityTag : name, timeScale : float) {
	var npc : CNewNPC;
	var slowdownCauserId : int;

	npc = (CNewNPC)theGame.GetNPCByTag(entityTag);
	if (timeScale != -1) {
		/*if (FactsQuerySum("ntr_animscale_id") != 0) {
			NTR_notify("ERROR! animScale already active!");
			return;
		}*/
		slowdownCauserId = npc.SetAnimationSpeedMultiplier( timeScale );
		FactsAdd("ntr_animscale_id", slowdownCauserId);
		NTR_notify("OK! slowdownCauserId = " + slowdownCauserId);
	} else {
		slowdownCauserId = FactsQuerySum("ntr_animscale_id");
		npc.ResetAnimationSpeedMultiplier(slowdownCauserId);
		NTR_notify("OK! Reset slowdownCauserId = " + slowdownCauserId);
		FactsSet("ntr_animscale_id", 0);
	}
}

exec function orianaDoor(newState : string, optional smoooth : bool, optional dontBlockInCombat : bool ) {
	NTR_DoorChangeState('q704_oriana_feeding_room', newState, , , smoooth, dontBlockInCombat);
}
exec function orianaDoor2(newState : string, optional smoooth : bool, optional dontBlockInCombat : bool ) {
	NTR_DoorChangeState('ntr_orianna_house_front_door', newState, , , smoooth, dontBlockInCombat);
}
exec function orianaDoor3(newState : string, optional smoooth : bool, optional dontBlockInCombat : bool ) {
	NTR_DoorChangeState('ntr_orianna_house_back_door', newState, , , smoooth, dontBlockInCombat);
}
exec function corvoDoor(newState : string, optional smoooth : bool, optional dontBlockInCombat : bool ) {
	NTR_DoorChangeState('mq7024_corvo_bianco_main_door', newState, , , smoooth, dontBlockInCombat);
}

exec function myspawn(path : string) {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource(path, true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	pos.Z += 1.0;
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_dress_test');
}

exec function morphOriana( morphRatio : float, blendTime : float ) {
	var           npc : CNewNPC;
	var manager : CMorphedMeshManagerComponent;
	
	npc = (CNewNPC)theGame.GetNPCByTag('oriana_test2');
	if (npc) {
		//manager = (CMorphedMeshManagerComponent)npc.GetComponentByClassName('CMorphedMeshManagerComponent');
		manager = (CMorphedMeshManagerComponent)npc.GetComponent('face_morph');
		if(manager) {
			manager.SetMorphBlend( morphRatio, blendTime );
		} else {
			theGame.GetGuiManager().ShowNotification("Morph component not found!");
		}
	} else {
		theGame.GetGuiManager().ShowNotification("Entity [OrianaTest] not found!");
	}
}

exec function triss1() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("characters/npc_entities/main_npc/triss.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	//ent.AddTag('oriana_test2');
	//ent.ApplyAppearance('orianna_vampire');
}
exec function triss2() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("quests/main_npcs/triss.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('vip');
	//ent.ApplyAppearance('orianna_vampire');
}
exec function triss3() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q705_epilog/characters/triss.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	//ent.AddTag('oriana_test2');
	//ent.ApplyAppearance('orianna_vampire');
}
exec function triss4() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/main_npc/triss.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	//ent.AddTag('oriana_test2');
	//ent.ApplyAppearance('orianna_vampire');
}

exec function oridet() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_vampire.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.AddTag('ntr_orianna_vampire');
	ent.AddTag('vip');
	ent.ApplyAppearance('orianna_human_morph');
}

exec function oridet2() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	var act : CActor;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_vampire.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	act = (CActor) ent;
	ent.AddTag('oriana_test2');
	ent.AddTag('ntr_orianna_vampire');
	ent.AddTag('vip');
	ent.ApplyAppearance('orianna_vampire');
	act.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
	act.SetAttitude( thePlayer, AIA_Hostile );
	thePlayer.SetAttitude( act, AIA_Hostile );
}

exec function orihum() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_human.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.AddTag('ntr_orianna_human');
	ent.AddTag('vip');
	ent.ApplyAppearance('orianna_human_morph');
}
exec function orihum2() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_human.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.AddTag('ntr_orianna_human');
	ent.AddTag('vip');
	ent.ApplyAppearance('orianna_vampire_bloody_morph');
}

exec function barolg() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	var act : CActor;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/baron_edward.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	act = (CActor) ent;
	act.AddTag('baron_test2');
	act.AddTag('ntr_baron_edward');
	act.AddTag('ntr_crossbow_bandit');
	act.AddTag('vip');
	act.ApplyAppearance('bob_knight_15');
	act.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
	act.SetAttitude( thePlayer, AIA_Hostile );
	thePlayer.SetAttitude( act, AIA_Hostile );
	//NTR_TuneNPC( 'baron_test2', GetWitcherPlayer().GetLevel(), "Hostile", "None", false, "ENGT_Quest", -1 );
}
exec function trissmonster() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	var act : CActor;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/triss_monster.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	act = (CActor) ent;
	act.AddTag('ntr_test');
	act.AddTag('vip');
	act.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
	act.SetAttitude( thePlayer, AIA_Hostile );
	thePlayer.SetAttitude( act, AIA_Hostile );
	//NTR_TuneNPC( 'baron_test2', GetWitcherPlayer().GetLevel(), "Hostile", "None", false, "ENGT_Quest", -1 );
}

exec function barolg2() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/baron_edward.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('baron_test2');
	ent.AddTag('ntr_baron_edward');
	ent.AddTag('vip');
	//ent.ApplyAppearance('bob_knight_15');
	NTR_TuneNPC( 'baron_test2', 50, "Hostile", "None", false, "ENGT_Quest", -1 );
}
exec function barolg3() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc\ep1\data\quests\main_npcs\olgierd.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('baron_test1');
	//ent.ApplyAppearance('bob_knight_15');
	NTR_TuneNPC( 'baron_test1', GetWitcherPlayer().GetLevel(), "Hostile", "None", false, "ENGT_Quest", -1 );
}

exec function barolg6() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc\bob\data\quests\secondary_npcs\damien.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('baron_test6');
	//ent.ApplyAppearance('bob_knight_15');
	NTR_TuneNPC( 'baron_test6', GetWitcherPlayer().GetLevel(), "Hostile", "None", false, "ENGT_Quest", -1 );
}

exec function createAtt(id : int) {
	NTR_CreateAttachment_Q( id );
}

exec function removeAtt(id : int) {
	NTR_RemoveAttachment_Q( id );
}

exec function oridress() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/oriana_dress/orianna_dress_lying.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	pos.Z += 1.0;
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_dress_test');
}
exec function testnpc() {
	var           npc : CNewNPC;
	
	npc = (CNewNPC)theGame.GetNPCByTag('oriana_test2');
	theGame.GetGuiManager().ShowNotification("appearance: " + npc.GetAppearance() + ", alive: " + npc.IsAlive());
}


exec function testLogo() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/ntr_logo_entity.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('ntr_logo_test');
}
exec function switchLogo(enable : bool) {
	var           ent : CEntity;

	ent = theGame.GetEntityByTag('ntr_logo_test');
	if (enable)
		ent.PlayEffect('ntr_logo_screen_en');
	else
		ent.StopEffect('ntr_logo_screen_en');
}
exec function switchLogo2(enable : bool) {
	var           ent : CEntity;

	ent = theGame.GetEntityByTag('ntr_logo_test');
	if (enable)
		ent.PlayEffect('ntr_logo_screen_en_baw');
	else
		ent.StopEffect('ntr_logo_screen_en_baw');
}

// playScene(dlc/bob/data/quests/main_quests/quest_files/q704_truth/scenes/q704_05_return_to_diva.w2scene)
exec function playScene(path : string, optional input : string) {
    var scene : CStoryScene;

    if (!input) {
    	input = "Input";
    }

    // -> SET SCENE PATH
    scene = (CStoryScene)LoadResource( path, true);
    theGame.GetStorySceneSystem().PlayScene(scene, input);
}

exec function oribru() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_bruxa.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.AddTag('ntr_orianna_bruxa');
	ent.ApplyAppearance('bruxa_monster_gameplay');
	NTR_TuneNPC( 'oriana_test2', GetWitcherPlayer().GetLevel(), "Neutral", "None", false, "ENGT_Quest", -1 );
}

exec function oribru2() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_bruxa.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.AddTag('ntr_orianna_bruxa');
	ent.ApplyAppearance('bruxa_monster_gameplay');
	NTR_TuneNPC( 'oriana_test2', GetWitcherPlayer().GetLevel(), "Hostile", "None", false, "ENGT_Quest", -1 );
}
exec function oribruh() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_bruxa.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.AddTag('ntr_orianna_bruxa');
	ent.ApplyAppearance('bruxa_monster_gameplay');
	NTR_TuneNPC( 'oriana_test2', GetWitcherPlayer().GetLevel(), "Hostile", "None", false, "ENGT_Quest", -1 );
}
/*
scream
fx - bruxa_base
dodge_smoke - bruxa_base(pelvis)
blood_point - bruxa_base(torso2)
blood_back_point - bruxa_base(torso)
ground
fx_cast_push
*/
// attle1(0, 0, 0,  0, 0, 0, true)
exec function attle1(optional x, y, z, pitch, yaw, roll : float, optional breakE : Bool) {
	var template                 : CEntityTemplate;
	var entity, attachment       : CEntity;
	var entityTag, attachmentTag : name;
	var relativePosition         : Vector;
	var relativeRotation         : EulerAngles;
	var result                   : Bool;
	var ents : array<CEntity>;
	var i : int;
	var slotName : name;

			entityTag = 'PLAYER';
			attachmentTag = 'ntr_geralt_letter_stamped';

	if (breakE) {
		theGame.GetEntitiesByTag(attachmentTag, ents);
		for (i = 0; i < ents.Size(); i += 1) {
			ents[i].Destroy();
		}
	}

			template = (CEntityTemplate)LoadResource("dlc\ep1\data\items\quest_items\q603\q603_item__glasses.w2ent", true);
			attachment = theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
			attachment.AddTag(attachmentTag);
			//entity = theGame.GetEntityByTag(entityTag);

			slotName = 'head';
			relativePosition = Vector(x, y, z);
			relativeRotation = EulerAngles(pitch, yaw, roll);

			result = attachment.CreateAttachment(thePlayer, slotName, relativePosition, relativeRotation);
			NTR_notify("attach = " + result);
}
exec function attle2(slotName : name, optional x, y, z, pitch, yaw, roll : float, optional breakE : Bool) {
	var template                 : CEntityTemplate;
	var entity, attachment       : CEntity;
	var entityTag, attachmentTag : name;
	var relativePosition         : Vector;
	var relativeRotation         : EulerAngles;
	var result                   : Bool;
	var ents : array<CEntity>;
	var i : int;

			entityTag = 'ntr_orianna_human';
			attachmentTag = 'ntr_orianna_letter_opened';

	if (breakE) {
		theGame.GetEntitiesByTag(attachmentTag, ents);
		for (i = 0; i < ents.Size(); i += 1) {
			ents[i].Destroy();
		}
	}

			template = (CEntityTemplate)LoadResource("dlc\bob\data\items\quest_items\q705\q705_item__comercial_poster_stamped.w2ent", true);
			attachment = theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
			attachment.AddTag(attachmentTag);
			entity = theGame.GetEntityByTag(entityTag);

			//slotName = 'r_weapon';
			relativePosition = Vector(x, y, z);
			relativeRotation = EulerAngles(pitch, yaw, roll);

			result = attachment.CreateAttachment(entity, slotName, relativePosition, relativeRotation);
			NTR_notify("attach = " + result);
}
exec function attbru(slotName : name, optional x, y, z, pitch, yaw, roll : float, optional breakE : Bool) {
	var template                 : CEntityTemplate;
	var entity, attachment       : CEntity;
	var entityTag, attachmentTag : name;
	var relativePosition         : Vector;
	var relativeRotation         : EulerAngles;
	var result                   : Bool;


			entityTag = 'ntr_orianna_bruxa';
			attachmentTag = 'ntr_bruxa_arrow2';

			template = (CEntityTemplate)LoadResource("items/weapons/projectiles/arrows/bolt_01.w2ent", true);
			attachment = theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
			attachment.AddTag(attachmentTag);
			entity = theGame.GetEntityByTag(entityTag);

			slotName = 'blood_point';
			relativePosition = Vector(x, y, z);
			relativeRotation = EulerAngles(pitch, yaw, roll);

			result = attachment.CreateAttachment(entity, slotName, relativePosition, relativeRotation);
			NTR_notify("attach = " + result);
}
exec function oricloak() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/dlcntr/data/entities/orianna_bruxa_cloak.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.ApplyAppearance('orianna_bruxa');
}
exec function detl() {
	var      template : CEntityTemplate;
	var           pos : Vector;
	var           ent : CEntity;
	
	template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q704_truth/characters/q704_dettlaff_vampire.w2ent", true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = (CEntity)theGame.CreateEntity(template, pos);
	ent.AddTag('oriana_test2');
	ent.ApplyAppearance('dettlaff_vampire');
}
exec function applyAp( ap : name ) {
	var           npc : CNewNPC;
	
	npc = (CNewNPC)theGame.GetNPCByTag('oriana_test2');
	npc.ApplyAppearance(ap);
}
exec function playEff( effect : name ) {
	var           npc : CNewNPC;
	
	npc = (CNewNPC)theGame.GetNPCByTag('oriana_test2');
	npc.PlayEffect(effect);
}
exec function playEffGeralt( effect : name, optional stop : bool ) {
	if (stop) {
		theGame.GetGuiManager().ShowNotification("Stop: " + effect);
		thePlayer.StopEffect(effect);
	} else {
		theGame.GetGuiManager().ShowNotification("Play: " + effect);
		thePlayer.PlayEffect(effect);
	}
}
/*quest function <modid>_setFactOnIgnite (tag : name, factName : name) {
	var gameLightComp : CGameplayLightComponent;        
	var           ent : CEntity;
        
	ent = (CEntity)theGame.GetEntityByTag(tag);
	gameLightComp = (CGameplayLightComponent)ent.GetComponentByClassName('CGameplayLightComponent');
	if (gameLightComp) {
		gameLightComp.factOnIgnite = factName;  
	} else {
		theGame.GetGuiManager().ShowNotification("CGameplayLightComponent not found in [" + tag + "]");
	}
}*/

exec function hostileOrianna() {
	NTR_TuneNPC( 'oriana_test2', 40, "Hostile", "None", false, "ENGT_Enemy", -1 );
}
exec function hostileOrianna2() {
	NTR_TuneNPC2( 'oriana_test2', 40, "Hostile", "None", false, "ENGT_Enemy", -1 );
}
exec function hostileOrianna3() {
	NTR_TuneNPC2( 'oriana_test2', 40, "Friendly", "None", false, "ENGT_Friendly", -1 );
}
exec function addAbil(abil : name, add : bool) {
	var           npc : CNewNPC;
	
	npc = (CNewNPC)theGame.GetNPCByTag('oriana_test2');
	if (npc) {
		NTR_notify("OK");
		if (add) {
			npc.AddAbility(abil);
		} else {
			npc.RemoveAbilityAll(abil);
		}
	}
}
quest function NTR_TuneNPC2( tag : name, level : int, optional attitude : string, optional mortality : string, optional finishers : bool, optional npcGroupType : string, optional scale : float ) {
	var NPCs   : array <CNewNPC>;
	var i      : int;
	var meshh : CMovingPhysicalAgentComponent;
	var meshhs : array<CComponent>;
	var j : int;
	
	theGame.GetNPCsByTag(tag, NPCs);
	//LogQuest( "<<Tune NPC>>> tag: " + tag + " found npcs: " + NPCs.Size());	//- uncomment it to check if NPCs are found
	//theGame.GetGuiManager().ShowNotification("Found npcs: " + NPCs.Size() + " nodes: " + nodes.Size());
	if (NPCs.Size() < 1) {
		theGame.GetGuiManager().ShowNotification("[ERROR] No NPCs found with tag <" + tag + ">");
		LogChannel('NTR_TuneNPC', "[ERROR] No NPCs found with tag <" + tag + ">");
		return;
	}
	theGame.GetGuiManager().ShowNotification("[OK] Tune npc with tag <" + tag + ">");
	if (level > 500) {
		// 1005 = playerLvl + 5;
		// 995 = playerLvl - 5
		level = GetWitcherPlayer().GetLevel() + (level - 1000);
		if (level < 1)
			level = 1;
	}
	
	for (i = 0; i < NPCs.Size(); i += 1 )
	{	
		/* SET LEVEL */
		if (level > 0)
			NPCs[i].SetLevel(level);
		//NPCs[i].RemoveAbilityAll('IgnoreLevelDiffForParryTest');
		//NPCs[i].RemoveAbilityAll('mon_EP2_q704detlaf');
		//NPCs[i].RemoveAbilityAll('NPCDoNotGainBoost');
		//NPCs[i].RemoveAbilityAll('NPCLevelBonusDeadly');
		//NPCs[i].RemoveAbilityAll('VesemirDamage');
		//NPCs[i].RemoveAbilityAll('BurnIgnore');
		//NPCs[i].RemoveAbilityAll('_q403Follower');
		NPCs[i].AddAbility('dettlaff_hardcore');
		if (finishers)
			NPCs[i].RemoveAbilityAll('DisableFinishers');
		else
			NPCs[i].AddAbility( 'DisableFinishers', false );
		
		/* SET ATTITUDE TO PLAYER */
		switch (attitude) {
			case "Friendly":
				NPCs[i].SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
				NPCs[i].SetAttitude( thePlayer, AIA_Friendly );
				thePlayer.SetAttitude( NPCs[i], AIA_Friendly );
				break;
			case "Hostile":
				NPCs[i].SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
				NPCs[i].SetAttitude( thePlayer, AIA_Hostile );
				thePlayer.SetAttitude( NPCs[i], AIA_Hostile );
				break;
			case "Neutral":
				NPCs[i].SetTemporaryAttitudeGroup( 'neutral_to_player', AGP_Default );
				NPCs[i].SetAttitude( thePlayer, AIA_Neutral );
				thePlayer.SetAttitude( NPCs[i], AIA_Neutral );
				break;
		}
		
		/* SET MORTALITY */
		switch (mortality) {
			case "None":
				NPCs[i].SetImmortalityMode( AIM_None, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_None, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_None, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_None, AIC_IsAttackableByPlayer );
				break;
			case "Unconscious":
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_Unconscious, AIC_IsAttackableByPlayer );
				break;
			case "Invulnerable":
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_Invulnerable, AIC_IsAttackableByPlayer );
				break;
			case "Immortal":
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_Combat );
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_Default );
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_Fistfight );
				NPCs[i].SetImmortalityMode( AIM_Immortal, AIC_IsAttackableByPlayer );
				break;
		}
		
		/* SET NPC TYPE GROUP */
		switch(npcGroupType) {
			case "ENGT_Commoner":
				NPCs[i].SetNPCType(ENGT_Commoner);
				break;
			case "ENGT_Guard":
				NPCs[i].SetNPCType(ENGT_Guard);
				break;
			case "ENGT_Quest":
				NPCs[i].SetNPCType(ENGT_Quest);
				break;
			case "ENGT_Enemy":
				NPCs[i].SetNPCType(ENGT_Enemy);
				break;
			
		}
		
		/* SET SCALE (DANGER BUT FUNNY) */
		if (scale > 0) {
			meshhs = NPCs[i].GetComponentsByClassName('CMovingPhysicalAgentComponent');

			for (j = 0; j < meshhs.Size(); j += 1) {
				meshh = (CMovingPhysicalAgentComponent)meshhs[j];
				if (meshh) {
					meshh.SetScale(Vector(scale, scale, scale));
				}
			}
		}
	}
}