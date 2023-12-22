class NR_AssetCooker extends CEntity {
	editable var cookScenes : array<CStoryScene>;
	editable var cookMeshes : array<CMeshComponent>;
}

exec function sspawn(id : int, optional friendly : Bool, optional notAdjust : Bool, optional immortal : Bool) {
	var ent : CEntity;
	var pos : Vector;
	var template : CEntityTemplate;
	var npc : CNewNPC;

	if (id == 0) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_master_mage.w2ent", true);
	} else if (id == 1) {
		template = (CEntityTemplate)LoadResource("characters/npc_entities/main_npc/triss.w2ent", true);
	} else if (id == 2) {
		template = (CEntityTemplate)LoadResource("quests/main_npcs/yennefer.w2ent", true);
	} else if (id == 3) {
		template = (CEntityTemplate)LoadResource("quests/secondary_npcs/philippa_eilhart.w2ent", true);
	} else if (id == 4) {
		template = (CEntityTemplate)LoadResource("quests/secondary_npcs/keira_metz.w2ent", true);
	} else if (id == 5) {
		template = (CEntityTemplate)LoadResource("quests/part_1/quest_files/q104_mine/characters/q104_evil_keira.w2ent", true);
	} else if (id == 6) {
		template = (CEntityTemplate)LoadResource("quests/secondary_npcs/margarita.w2ent", true);
	} else if (id == 7) {
		template = (CEntityTemplate)LoadResource("quests/secondary_npcs/fringilla_vigo.w2ent", true);
	} else if (id == 8) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/mq7004_bleeding_tree/characters/mq7004_witch.w2ent", true);

	} else if (id == 11) {
		template = (CEntityTemplate)LoadResource("quests/main_npcs/avallach.w2ent", true);
	} else if (id == 12) {
		template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/q601_intro/characters/q601_ofir_mage.w2ent", true);
	} else if (id == 13) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_quests/quest_files/q701_wine_festival/characters/q701_00_nml_bandit_1h_sword_02_leader.w2ent", true);
	} else if (id == 14) {
		template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/main_npcs/olgierd.w2ent", true);
	} else if (id == 15) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/characters/npc_entities/secondary_npc/q703_mage.w2ent", true);
	
	} else if (id == 21) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/living_world/enemy_templates/water_hag_late.w2ent", true);
	}
	else if (id == 22) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/living_world/enemy_templates/wraith_late.w2ent", true);
	}
	else if (id == 23) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/living_world/enemy_templates/alghoul.w2ent", true);
	}
	else if (id == 24) {
		template = (CEntityTemplate)LoadResource("characters/npc_entities/monsters/wolf_lvl1.w2ent", true);
	}
	else if (id == 25) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/living_world/enemy_templates/wyvern.w2ent", true);
	}
	else if (id == 26) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_npcs/dettlaff_van_eretein_vampire.w2ent", true);
	}
	else if (id == 27) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/main_npcs/dettlaff_van_eretein_monster.w2ent", true);
	}
	else if (id == 28) {
		template = (CEntityTemplate)LoadResource("quests/part_3/quest_files/q210_precanaris/characters/q210_lab_golem.w2ent", true);
	}
	else if (id == 30) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_black_spider_34_boss_big.w2ent", true);
	}
	else if (id == 31) {
		template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/mq7023_mutations/characters/mq7023_gargoyle_1.w2ent", true);
	}
	else if (id == 32) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_q502_dao_fixed.w2ent", true);
	}
	else if (id == 33) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_elemental_dao_lvl3__ice_fixed.w2ent", true);
	}
	else if (id == 34) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_mq4006_ifryt_fixed.w2ent", true);
	}
	else if (id == 35) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_q210_lab_golem_fixed.w2ent", true);
	}
	else if (id == 36) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_th701_golem_fixed.w2ent", true);
	}
	else if (id == 37) {
		template = (CEntityTemplate)LoadResource("quests/secondary_npcs/djinn.w2ent", true);
	}
	else if (id == 38) {
		template = (CEntityTemplate)LoadResource("dlc/ep1/data/quests/quest_files/q604_mansion/characters/q604_caretaker.w2ent", true);
	}
	else if (id == 99) {
		template = (CEntityTemplate)LoadResource("quests/main_npcs/radovid.w2ent", true);
	}
	else if (id == 98) {
		template = (CEntityTemplate)LoadResource("quests/main_npcs/emhyr.w2ent", true);
	}
	else if (id == 101) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_replacer_sorceress_inv.w2ent", true);
	}
	else if (id == 102) {
		template = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_replacer_sorceress.w2ent", true);
	}
	if (!template) {
		NR_Notify("Invalid id! 1+ for women, 11+ for men, 21+ for monsters");
		return;
	}

	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = theGame.CreateEntity(template, pos );
	npc = (CNewNPC) ent;
	npc.AddTag('nr_test_entity');
	if (id == 0) {
		npc.ApplyAppearance('nr_master_mage_naked2');
	}

	if (immortal) {
		npc.SetImmortalityMode( AIM_Immortal, AIC_Combat );
		npc.SetImmortalityMode( AIM_Immortal, AIC_Default );
		npc.SetImmortalityMode( AIM_Immortal, AIC_Fistfight );
		npc.SetImmortalityMode( AIM_Immortal, AIC_IsAttackableByPlayer );
	} else {
		npc.SetImmortalityMode( AIM_None, AIC_Combat );
		npc.SetImmortalityMode( AIM_None, AIC_Default );
		npc.SetImmortalityMode( AIM_None, AIC_Fistfight );
		npc.SetImmortalityMode( AIM_None, AIC_IsAttackableByPlayer );
	}

	if (!friendly) {
		npc.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		npc.SetAttitude( thePlayer, AIA_Hostile );
		thePlayer.SetAttitude( npc, AIA_Hostile );
	} else {
		npc.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
		npc.SetAttitude( thePlayer, AIA_Friendly );
		thePlayer.SetAttitude( npc, AIA_Friendly );
	}
	if (!notAdjust) {
		npc.SetLevel( GetWitcherPlayer().GetLevel() );
	}
}

exec function dialog(tag : name) {
	var npc : CNewNPC;
	npc = (CNewNPC)theGame.GetEntityByTag(tag);
	if (!npc) {
		NR_Notify("NO NPC!");
	}
	NR_Notify("CanStartTalk = " + npc.CanStartTalk());
	npc.PlayDialog();
}

exec function nr_female(enable: bool) {
	if (enable) {
		NR_Notify("FEMALE ON");
		FactsAdd("nr_speech_switch", 1);
	} else {
		NR_Notify("FEMALE OFF");
		FactsRemove("nr_speech_switch");
	}
}

exec function nrCross() {
	var entityTemplate : CEntityTemplate;
	var entity : CEntity;
	entityTemplate = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\nr_cross_effect.w2ent", true);
	entity = theGame.CreateEntity(entityTemplate, thePlayer.GetWorldPosition() + Vector(0,0,1.5f), thePlayer.GetWorldRotation());
	NR_Debug("nrCross: entityTemplate = " + entityTemplate + ", enttiy = " + entity);
	if (entity) {
		NR_Debug("nrCross: PlayEffect = " + entity.PlayEffect('cross'));
	}
}

exec function nrfast() {
	FactsAdd("nr_dev_master0", 1);
	thePlayer.Teleport(Vector(-237.56506347649997, -304.7667541504, 40.3227920532));
}

exec function nr_master() {
	thePlayer.Teleport(Vector(-237.56506347649997, -304.7667541504, 40.3227920532));
}

exec function nrMoveTo(pointNum : int) {
	var npc : CNewNPC;
	var points : array<Vector>;

	npc = (CNewNPC)theGame.GetEntityByTag('nr_test_entity');

	if (!npc) {
		NR_Notify("!npc");
		return;
	}
	points.PushBack(Vector(-278.8874206543, -313.2870178223, 40.0178413391));
	points.PushBack(Vector(-286.2327575684, -307.2341308594, 40.1103897095));
	NR_Debug("IsReadyForNewAction 1 = " + npc.IsReadyForNewAction());
	npc.ActionCancelAll();
	NR_Debug("IsReadyForNewAction 2 = " + npc.IsReadyForNewAction());
	NR_Notify("nrMoveTo1 = " + npc.ActionMoveToAsync(points[pointNum]));
}
exec function nrMoveTo2(pointNum : int) {
	var npc : CNewNPC;
	var points : array<Vector>;

	npc = (CNewNPC)theGame.GetEntityByTag('nr_test_entity');

	if (!npc) {
		NR_Notify("!npc");
		return;
	}
	points.PushBack(Vector(-278.8874206543, -313.2870178223, 40.0178413391));
	points.PushBack(Vector(-286.2327575684, -307.2341308594, 40.1103897095));
	NR_Debug("IsReadyForNewAction 1 = " + npc.IsReadyForNewAction());
	npc.ActionCancelAll();
	NR_Debug("IsReadyForNewAction 2 = " + npc.IsReadyForNewAction());
	NR_Notify("nrMoveTo2 = " + npc.ActionMoveOnCurveToAsync(points[pointNum], 10.f, true));
}
exec function nrMoveTo3(pointNum : int) {
	var npc : CNewNPC;
	var points : array<Vector>;
	var targeter : CMoveTRGFollowLocomotion;

	npc = (CNewNPC)theGame.GetEntityByTag('nr_test_entity');
	targeter = new CMoveTRGFollowLocomotion in npc;
	targeter.attractor = thePlayer;
	targeter.minimumDistance = 3.f;

	if (!npc) {
		NR_Notify("!npc");
		return;
	}
	npc.ActionCancelAll();
	NR_Debug("IsReadyForNewAction 2 = " + npc.IsReadyForNewAction());
	NR_Notify("nrMoveTo3 = " + npc.ActionMoveCustomAsync(targeter));
}

exec function nrBehRaise(eventName : name) {
	var npc : CNewNPC;
	npc = (CNewNPC)theGame.GetEntityByTag('nr_test_entity');
	if (!npc) {
		NR_Notify("No entity!");
		return;
	}
	NR_Notify("RaiseEvent [" + eventName + "] = " + npc.GetRootAnimatedComponent().RaiseBehaviorEvent(eventName));
}
exec function nrBehSet(varName : name, varValue : float) {
	var npc : CNewNPC;
	npc = (CNewNPC)theGame.GetEntityByTag('nr_test_entity');
	if (!npc) {
		NR_Notify("No entity!");
		return;
	}
	NR_Notify("SetBehaviorVariable [" + varName + ", " + varValue + "] = " + npc.SetBehaviorVariable(varName, varValue));
}

exec function nrTemp() {
	NR_GetMagicManager().SetDefaults_Special();
	NR_GetMagicManager().SetDefaults_SpecialAlt();
	NR_Notify("Temp script done");
}

exec function nrAllSkills() {
	FactsAdd("nr_magic_skill_ENR_HandFx", 1);
	FactsAdd("nr_magic_skill_ENR_Teleport", 1);
	FactsAdd("nr_magic_skill_ENR_CounterPush", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialLumos", 1);
	FactsAdd("nr_magic_skill_ENR_LightAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_Slash", 1);
	FactsAdd("nr_magic_skill_ENR_ThrowAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_Lightning", 1);
	FactsAdd("nr_magic_skill_ENR_ProjectileWithPrepare", 1);
	
	FactsAdd("nr_magic_skill_ENR_BombExplosion", 1);
	FactsAdd("nr_magic_skill_ENR_Rock", 1);
	FactsAdd("nr_magic_skill_ENR_RipApart", 1);
	FactsAdd("nr_magic_skill_ENR_HeavyAbstract", 1);
	FactsAdd("nr_magic_skill_ENR_FastTravelTeleport", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialShield", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialTornado", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialControl", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialMeteor", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialServant", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialLightningFall", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialField", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialMeteorFall", 1);
	FactsAdd("nr_magic_skill_ENR_SpecialPolymorphism", 1);
	FactsAdd("nr_magic_skill_ENR_WaterTrap", 1);

	// set max level
	NR_GetMagicManager().SetActionSkillLevel(ENR_HandFx, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_Teleport, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_CounterPush, 10);
	NR_GetMagicManager().SetActionSkillLevel(ENR_SpecialLumos, 10);
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

	// Pursuit
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialField, "Pursuit");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialField, "Pursuit");

	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "TwoServants");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Barghest");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Endriaga");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Arachnomorph");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Arachas");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Followers");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "Gargoyle");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "EarthElemental");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "IceElemental");
	NR_GetMagicManager().ActionAbilityUnlock(ENR_SpecialServant, "FireElemental");
}

exec function nrMasterBarrier(enable : bool) {
	var entity : CEntity;

	entity = theGame.GetEntityByTag('nr_master_arena_barrier');
	NR_Notify("entity = " + entity);
	if (enable)
		entity.PlayEffect('magic_obstacle');
	else
		entity.StopEffect('magic_obstacle');
}

exec function nrToArena() {
	thePlayer.Teleport(Vector(-248.0154418945, -321.4640502930, 38.7458457947));
}
exec function nrToPoint(num : int) {
	if (num == 0) {
		thePlayer.Teleport(Vector(4.2048754692, -14.9949951172, 1.3214421272));
	} else if (num == 1) {
		thePlayer.Teleport(Vector(-262.6635131836, -257.9526367188, 12.3288917542));
	} else if (num == 2) {
		thePlayer.Teleport(Vector(-248.0154418945, -321.4640502930, 38.7458457947));
	}
	
	
}

exec function nrLongAnim1() {
	var animName : name = 'AttackSpecialLongYenChanting';
	NR_GetMagicManager().SetParamName('universal', "anim_" + ENR_MAToName(ENR_SpecialMeteorFall), animName);
	NR_Notify("Set loop anim for meteor: " + animName);
}
exec function nrLongAnim2() {
	var animName : name = 'AttackSpecialLongCiriTargeting';
	NR_GetMagicManager().SetParamName('universal', "anim_" + ENR_MAToName(ENR_SpecialMeteorFall), animName);
	NR_Notify("Set loop anim for meteor: " + animName);
}
exec function nrLongAnim3() {
	var animName : name = 'AttackSpecialLongYenNaglfar';
	NR_GetMagicManager().SetParamName('universal', "anim_" + ENR_MAToName(ENR_SpecialMeteorFall), animName);
	NR_Notify("Set loop anim for meteor: " + animName);
}
exec function nrLongAnim4() {
	var animName : name = 'AttackSpecialLongMargeritaNaglfar';
	NR_GetMagicManager().SetParamName('universal', "anim_" + ENR_MAToName(ENR_SpecialMeteorFall), animName);
	NR_Notify("Set loop anim for meteor: " + animName);
}
exec function nrLongAnim5() {
	var animName : name = 'AttackSpecialLongSorceress';
	NR_GetMagicManager().SetParamName('universal', "anim_" + ENR_MAToName(ENR_SpecialMeteorFall), animName);
	NR_Notify("Set loop anim for meteor: " + animName);
}

exec function nrStamina() {
	NR_GetMagicManager().SetDefaults_StaminaCost();
}

exec function nrSkill(skillLevel : int) {
	if (skillLevel > EnumGetMax('ENR_MagicSkill') || skillLevel < 1) {
		NR_Notify("Invalid skill value, it must be [1; " + EnumGetMax('ENR_MagicSkill') + "]");
		return;
	}
	NR_Notify("Set skill value = [" + NR_GetMagicManager().GetSkillLevelLocStr(skillLevel) + "]");
	NR_GetMagicManager().SetParamInt('universal', "DEBUG_skillLevel", skillLevel);
}

exec function nrElement(element : int) {
	if (element > EnumGetMax('ENR_MagicElement') || element < 1) {
		NR_Notify("Invalid element value, it must be [1; " + EnumGetMax('ENR_MagicElement') + "]");
		return;
	}
	NR_Notify("Set element value = [" + NR_GetMagicManager().GetMagicElementLocStr(element) + "]");
	NR_GetMagicManager().SetParamInt('universal', "magic_skill_element", element);
}

exec function nrProjectile(damage : float) {
	if (damage < 0.f) {
		NR_Notify("Invalid damage value, it must be > 0");
		return;
	}
	NR_Notify("Set proj damage value = [" + damage + "]");
	NR_GetMagicManager().SetParamFloat('universal', "DEBUG_projectile_dmg", damage);
}

exec function playerAbl() {
	var abls, attrs  : array<name>;
	var i : int;
	var val : SAbilityAttributeValue;
	
	thePlayer.GetCharacterStats().GetAbilities(abls);
	thePlayer.GetCharacterStats().GetAllAttributesNames(attrs);

	for (i = 0; i < abls.Size(); i += 1) {
		NR_Debug("Ability: " + abls[i]);
	}
	for (i = 0; i < attrs.Size(); i += 1) {
		if ( theGame.params.IsForbiddenAttribute(attrs[i]) )
			continue;
		val = thePlayer.GetAttributeValue(attrs[i]);
		NR_Debug("Attribute: " + attrs[i] + ", value: [base = " + val.valueBase + "], [mult = " + val.valueMultiplicative + "], [add = " + val.valueAdditive + "]");
	}
	NR_Debug("Max ess: " + thePlayer.GetStatMax(BCS_Essence));
	NR_Debug("Cur ess: " + thePlayer.GetStat(BCS_Essence));
	NR_Debug("Max vit: " + thePlayer.GetStatMax(BCS_Vitality));
	NR_Debug("Cur vit: " + thePlayer.GetStat(BCS_Vitality));
	NR_Debug("Immortality: " + thePlayer.GetImmortalityMode());
}

exec function testl11() {
	thePlayer.PlayLine(158228, true);
}
exec function testl12() {
	thePlayer.PlayLine(1223911, true);
}
exec function testl21() {
	thePlayer.PlayLine(2115940050, true);
}
exec function testl22() {
	thePlayer.PlayLine(2115940058, true);
}
exec function testl23() {
	thePlayer.PlayLine(2115940052, true);
}
exec function testl24() {
	thePlayer.PlayLine(2115940057, true);
}
exec function testl25() {
	thePlayer.PlayLine(2115940054, true);
}
exec function testl26() {
	thePlayer.PlayLine(2115940055, true);
}
exec function testl27() {
	thePlayer.PlayLine(2115940059, true);
}
exec function testl3() {
	thePlayer.PlayLine(1000015, true);
}

exec function scene1m() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/01.player_change_male.w2scene", true);
	if (!scene)
		NR_Error("NULL scene!");

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene(path : string, optional input : String) {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource(path, true);
	if (StrLen(input) < 1) {
		input = "Input";
	}
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}
	NR_Notify("PLAY scene: " + input);

	theGame.GetStorySceneSystem().PlayScene(scene, input);
}

exec function scene1f() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/01.player_change_female.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene1s() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/03.player_change_sorceress.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene4() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/04.crystal_portal.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene9() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/09.hb.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene5() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/05.spider_boss_fight.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	NR_Notify("PLAY: Input");
	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene6() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/06.sorceress_treatment.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	NR_Notify("PLAY: Input");
	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene8(has_met : int, teaching : int) {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/08.sorceress_study.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	FactsSet("nr_master_met_before", has_met);
	FactsSet("nr_master_apprentice", teaching);
	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene10(optional input : String) {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/10.golem_crafting.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	if (StrLen(input) < 1) {
		input = "Input";
	}
	NR_Notify("PLAY: " + input);
	theGame.GetStorySceneSystem().PlayScene(scene, input);
}

exec function scene11(optional input : String) {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/11.golem_lines.w2scene", true);
	if (!scene) {
		NR_Notify("NULL scene!");
		return;
	}

	if (StrLen(input) < 1) {
		input = "Input";
	}
	NR_Notify("PLAY: " + input);
	theGame.GetStorySceneSystem().PlayScene(scene, input);
}

function NR_RoundTo(f : float, digits : int) : float {
	var divider : float;
	var i 		: int;

	divider = PowF(10, digits);
    i = RoundMath(f * divider);
    return i * 1.0f / divider;
}

exec function roundtest1(f : float, iters : int) {
	var x, f_i, startTime, endTime : float;
	var i : int;

	startTime = theGame.GetEngineTimeAsSeconds();

	for (i = 0; i < iters; i += 1) {
		f_i = f + i * Pi();
		x = RoundTo(f_i, 5);
		x = RoundTo(f_i, 4);
		x = RoundTo(f_i, 3);
		x = RoundTo(f_i, 2);
		x = RoundTo(f_i, 1);
		x = RoundTo(f_i, 0);
	}

	endTime = theGame.GetEngineTimeAsSeconds();
	NR_Notify("Elapsed (RoundTo) [" + iters + " iters]: " + (endTime - startTime));
}

exec function roundtest2(f : float, iters : int) {
	var x, f_i, startTime, endTime : float;
	var i : int;

	startTime = theGame.GetEngineTimeAsSeconds();

	for (i = 0; i < iters; i += 1) {
		f_i = f + i * Pi();
		x = NR_RoundTo(f_i, 5);
		x = NR_RoundTo(f_i, 4);
		x = NR_RoundTo(f_i, 3);
		x = NR_RoundTo(f_i, 2);
		x = NR_RoundTo(f_i, 1);
		x = NR_RoundTo(f_i, 0);
	}

	endTime = theGame.GetEngineTimeAsSeconds();
	NR_Notify("Elapsed (NR_RoundTo) [" + iters + " iters]: " + (endTime - startTime));
}

// PLAYER_SLOT
// MANUAL_DIALOG_SLOT
// EXP_SLOT
// GAMEPLAY_SLOT
// PLAYER_ACTION_SLOT
// VEHICLE_SLOT
exec function horse(animName : name) {
	thePlayer.ActionPlaySlotAnimationAsync( 'VEHICLE_SLOT', animName, 0.3, 0.5 );
}

exec function exploration(animName : name) {
	thePlayer.ActionPlaySlotAnimationAsync( 'PLAYER_SLOT', animName, 0.3, 0.5 );
}

exec function griffin() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("quests\prologue\quest_files\q001_beggining\scenes\q001_6_meet_griffin.w2scene", true);
	if (!scene)
		NR_Error("NULL scene!");

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function attach4(optional x, y, z, pitch, yaw, roll : float, optional breakE : Bool) {
	var template                 : CEntityTemplate;
	var entity, attachment       : CEntity;
	var entityTag, attachmentTag : name;
	var relativePosition         : Vector;
	var relativeRotation         : EulerAngles;
	var result                   : Bool;
	var ents : array<CEntity>;
	var i : int;
	var slotName : name;

	slotName = 'r_weapon';
	entityTag = 'PLAYER';
	attachmentTag = 'nr_crystal_test';

	if (breakE) {
		theGame.GetEntitiesByTag(attachmentTag, ents);
		for (i = 0; i < ents.Size(); i += 1) {
			ents[i].Destroy();
		}
	}

	template = (CEntityTemplate)LoadResource("dlc/bob/data/quests/minor_quests/quest_files/th701_archmastergear/th701_wolf/entities/th701_portal_crystal_glowing.w2ent", true);
	attachment = theGame.CreateEntity(template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
	attachment.AddTag(attachmentTag);

	relativePosition = Vector(x, y, z);
	relativeRotation = EulerAngles(pitch, yaw, roll);

	result = attachment.CreateAttachment(thePlayer, slotName, relativePosition, relativeRotation);
	NR_Notify("attach = " + result);
}

exec function anim1a(slotNum : int) {
	var slotName : name;
	var ret : bool;
	var mac : CMovingPhysicalAgentComponent;

	mac = (CMovingPhysicalAgentComponent) thePlayer.GetComponentByClassName( 'CMovingPhysicalAgentComponent' );
	if (!mac) {
		NR_Notify("!mac");
		return;
	}
	if (slotNum == 1)
		slotName = 'MIXER_SLOT';
	else if (slotNum == 2)
		slotName = 'PLAYER_SLOT';
	else if (slotNum == 3)
		slotName = 'GAMEPLAY_SLOT';
	else if (slotNum == 4)
		slotName = 'HIT';
	else if (slotNum == 5)
		slotName = 'TAKEDOWN';
	else if (slotNum == 6)
		slotName = 'EXP_SLOT';
	else if (slotNum == 7)
		slotName = 'PlayerActionSlot';
	else if (slotNum == 8)
		slotName = 'PLAYER_ACTION_SLOT';
	else if (slotNum == 9)
		slotName = 'UPPER_BODY_ANIM_SLOT';
	else if (slotNum == 10)
		slotName = 'FinisherSlot';
	else if (slotNum == 11)
		slotName = 'ComboSlot';
	else if (slotNum == 12)
		slotName = 'FinisherSlot';
	else if (slotNum == 13)
		slotName = 'FinisherSlot';

		
	ret = mac.PlaySlotAnimationAsync( 'woman_sorceress_attack_rock_bhand_rp', slotName );
	NR_Notify("A Slot: " + slotName + " = " + ret);
}

exec function anim1b() {
	var ret : bool;
		
	ret = (thePlayer.GetMovingAgentComponent()).PlaySkeletalAnimationAsync( 'woman_sorceress_attack_rock_bhand_rp', true );
	NR_Notify("B = " + ret);
}

exec function playerstate() {
	NR_Notify("Player state = " + thePlayer.GetCurrentStateName());
}

function PrintDamageAction( source: String, action : W3DamageAction )
{
		var i, size : int;
		var effectInfos : array< SEffectInfo >;
		var attackerPowerStatValue : SAbilityAttributeValue;
		
		size = action.GetEffects( effectInfos );
		attackerPowerStatValue = action.GetPowerStatValue();

		NR_Debug("[" + source + "] PrintDamageAction");
		NR_Debug("AddEffectsFromAction(): causer = " + action.causer);
		NR_Debug("AddEffectsFromAction(): vitalityDamage = " + action.processedDmg.vitalityDamage);
		NR_Debug("AddEffectsFromAction(): essenceDamage = " + action.processedDmg.essenceDamage);
		NR_Debug("AddEffectsFromAction(): moraleDamage = " + action.processedDmg.moraleDamage);
		NR_Debug("AddEffectsFromAction(): staminaDamage = " + action.processedDmg.staminaDamage);
		NR_Debug("AddEffectsFromAction(): effSize = " + size);
		NR_Debug("AddEffectsFromAction(): attacker = " + action.attacker);
		NR_Debug("AddEffectsFromAction(): GetBuffSourceName = " + action.GetBuffSourceName());
		NR_Debug("AddEffectsFromAction(): attackerPowerStatValue = " + CalculateAttributeValue(attackerPowerStatValue));
			
		for ( i = 0; i < size; i += 1 )
		{	
			NR_Debug("AddEffectsFromAction(): effectType[" + i + "] = " + effectInfos[i].effectType);
			NR_Debug("AddEffectsFromAction(): effectDuration[" + i + "] = " + effectInfos[i].effectDuration);
			NR_Debug("AddEffectsFromAction(): effectCustomValue[" + i + "] = " + CalculateAttributeValue(effectInfos[i].effectCustomValue));
			NR_Debug("AddEffectsFromAction(): effectAbilityName[" + i + "] = " + effectInfos[i].effectAbilityName, );
			NR_Debug("AddEffectsFromAction(): customFXName[" + i + "] = " + effectInfos[i].customFXName);
			NR_Debug("AddEffectsFromAction(): effectCustomParam[" + i + "] = " + effectInfos[i].effectCustomParam);
		}
}

exec function castquen() {
	NR_GetReplacerSorceress().CastQuen();
}

exec function handkeira(color : int) {
	NR_GetMagicManager().SetParamName('Aard', "fx_type_" + ENR_MAToName(ENR_HandFx), 'keira');
	NR_GetMagicManager().SetParamInt('Aard', "color_" + ENR_MAToName(ENR_HandFx), color);
	NR_GetMagicManager().HandFX(true);
	NR_Notify("Set [" + "color_" + ENR_MAToName(ENR_HandFx) + "] = " + ENR_MCToName(color));
}

exec function handkeira2() {
	NR_GetMagicManager().SetParamName('Aard', "fx_type_" + ENR_MAToName(ENR_HandFx), 'keira');
	NR_GetMagicManager().SetParamInt('Aard', "color_" + ENR_MAToName(ENR_HandFx), ENR_ColorYellow);
}

exec function dao() {
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = thePlayer.inv;
	ids = inv.GetItemsIds('mh106_gravehag_trophy');	
	NR_Notify("DAO: " + ids.Size());
}
exec function dao2() {
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = thePlayer.inv;
	NR_Notify("DAO2: (false) " + inv.GetItemQuantityByName('mh106_gravehag_trophy', false) + ", (true) " + inv.GetItemQuantityByName('mh106_gravehag_trophy', true));
}
exec function dao3() {
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
	NR_Notify("DAO3: " + inv.GetItemQuantityByName('mh106_gravehag_trophy'));
}

exec function dao4() {
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = GetWitcherPlayer().GetAssociatedInventory();
	NR_Notify("DAO4: " + inv.GetItemQuantityByName('mh106_gravehag_trophy'));
}

// S_Magic_s05
exec function signstat(signSkill : ESkill) {
	var att : SAbilityAttributeValue;
	att = thePlayer.GetTotalSignSpellPower(signSkill);
	NR_Notify("Sign stat = [" + att.valueBase + " * " + att.valueMultiplicative + "] + " + att.valueAdditive);
}

exec function spell_scene(inp : int) {
		var scene : CStoryScene;
		var path : String;
		var play_index : int;
		var min_index : int = 1;
		var max_index : int = 5;

		path = "dlc/dlcnewreplacers/data/scenes/02.magic_lines.w2scene";
		//path = "dlc/dlcntr/data/scenes/03.geralt_oneliners.w2scene";
		scene = (CStoryScene)LoadResource(path, true);
		if (!scene)
			NR_Error("NULL scene!");
		play_index = inp;
		NR_Notify("Play scene: [" + "spell_" + IntToString(play_index) + "]");

		theGame.GetStorySceneSystem().PlayScene(scene, "spell_" + IntToString(play_index));
		//theGame.GetStorySceneSystem().PlayScene(scene, "hag_wall");
}

exec function player_scene() {
		var scene : CStoryScene;
		var path : String;

		path = "dlc/dlcnewreplacers/data/scenes/01.player_change.w2scene";
		//path = "dlc/dlcntr/data/scenes/03.geralt_oneliners.w2scene";
		scene = (CStoryScene)LoadResource(path, true);
		if (!scene)
			NR_Error("NULL scene!");

		theGame.GetStorySceneSystem().PlayScene(scene, "Input");
	}
/*exec function checkSlot() {
	var template : CEntityTemplate;
	var slot : EntitySlot;
	var transform : EngineTransform;

	template = (CEntityTemplate)theGame.LoadResource("nr_replacer_witcher");
	slot = template.slots[29];
	NR_Notify("slot bone = " + slot.boneName);

	slot.transform.X = -0.5;
	slot.transform.Y = 0.1;
}*/
/*
	head:
        componentName: woman_base
        boneName: head
        transform:
          pos: [ -0.045, -0.035, 0 ]
          rot: [ 90.0, 0.0, 0.0 ]
          scale: [ 0.0, 0.0, 0.0 ]
*/

//characters/npc_entities/monsters/wolf_lvl1.w2ent
exec function pspawn(path : string, upscale : bool, optional app : string) {
	var template : CEntityTemplate;
	var entity : CEntity;
	var npc : CNewNPC;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource(path, true);
	if (!template) {
		NR_Notify("!template: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	entity = theGame.CreateEntity(template, pos);
	if (!entity) {
		NR_Notify("!entity: " + entity);
		return;
	}
	entity.AddTag('NR_TEMP');
	npc = (CNewNPC)entity;
	if (app != "" && npc) {
		npc.ApplyAppearance(app);
	}
	if (upscale && npc) {
		npc.SetLevel(thePlayer.GetLevel());
	}
	NR_Notify("Spawned = " + entity);
}

exec function papp(appName : String) {
	var appearanceComponent : CAppearanceComponent;
	var            template : CEntityTemplate;
	var                   i : int;

	appearanceComponent = (CAppearanceComponent)thePlayer.GetComponentByClassName( 'CAppearanceComponent' );
	if (appearanceComponent) {
		NR_Notify("APPLY APP = " + appName);
		appearanceComponent.ApplyAppearance(appName);
	} else {
		NR_Error("ERROR: AppearanceComponent not found!");
	}
}


class NR_TestManager {

}
state Latent in NR_TestManager {
	event OnEnterState( prevStateName : name )
	{
		Do();
	}
	entry function Do() {
		var ents : array<String>;
		var i:int;
		var templ: CEntityTemplate;
		var ent : CEntity;

			
			ents.PushBack("characters/npc_entities/main_npc/crach_an_craite.w2ent");
			ents.PushBack("characters/npc_entities/monsters/gryphon_lvl3__volcanic.w2ent");
			ents.PushBack("characters/npc_entities/monsters/gryphon_mh__volcanic.w2ent");
			ents.PushBack("characters/npc_entities/monsters/hag_grave_lvl1.w2ent");
			ents.PushBack("characters/npc_entities/monsters/hag_grave_lvl1__barons_wife.w2ent");
			ents.PushBack("characters/npc_entities/monsters/hag_grave__mh.w2ent");
			ents.PushBack("characters/npc_entities/monsters/hag_water_lvl1.w2ent");
			ents.PushBack("characters/npc_entities/monsters/hag_water_lvl2.w2ent");
			ents.PushBack("characters/npc_entities/monsters/hag_water_mh.w2ent");
		ents.PushBack("characters/npc_entities/monsters/fogling_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/fogling_lvl2.w2ent");
		ents.PushBack("characters/npc_entities/monsters/fogling_mh.w2ent");
		ents.PushBack("characters/npc_entities/monsters/cyclop_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/animals/horse/horse_background.w2ent");
		ents.PushBack("characters/npc_entities/animals/horse/horse_background_no_saddle.w2ent");
		ents.PushBack("characters/npc_entities/animals/horse/horse_racing_fast.w2ent");
		ents.PushBack("characters/npc_entities/animals/horse/horse_racing_slow.w2ent");
		ents.PushBack("characters/npc_entities/animals/horse/horse_vehicle.w2ent");
		ents.PushBack("characters/npc_entities/animals/horse/horse_wild_regular.w2ent");
		ents.PushBack("characters/npc_entities/monsters/fugas_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/fugas_lvl2.w2ent");
		ents.PushBack("characters/npc_entities/monsters/_quest__godling.w2ent");
		ents.PushBack("characters/npc_entities/crowd_npc/succubus/succubus.w2ent");
		ents.PushBack("characters/npc_entities/monsters/bear_berserker_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/bear_lvl1__black.w2ent");
		ents.PushBack("characters/npc_entities/monsters/bear_lvl2__grizzly.w2ent");
		ents.PushBack("characters/npc_entities/monsters/bear_lvl3__white.w2ent");
		ents.PushBack("characters/npc_entities/monsters/bies_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/bies_lvl2.w2ent");
		ents.PushBack("characters/npc_entities/monsters/bies_mh.w2ent");
		ents.PushBack("characters/npc_entities/monsters/czart_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/czart_mh.w2ent");
		ents.PushBack("characters/npc_entities/monsters/ice_giant.w2ent");
		ents.PushBack("characters/npc_entities/monsters/vampire_ekima_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/vampire_ekima_mh.w2ent");
		ents.PushBack("characters/npc_entities/monsters/vampire_katakan_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/vampire_katakan_mh.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wolf_lvl1.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wolf_lvl1__summon.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wolf_lvl1__summon_were.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wolf_lvl2__alpha.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wolf_white_lvl2.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wolf_white_lvl3__alpha.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wyvern_lvl2.w2ent");
		ents.PushBack("characters/npc_entities/monsters/wyvern_mh.w2ent");

		for (i = 6; i > 1; i -= 1) {
			theGame.GetGuiManager().ShowNotification(i, 1000);
			Sleep(1.f);
		}
		for (i = 0; i < ents.Size(); i += 1) {
			theGame.GetGuiManager().ShowNotification("[" + (i + 1) + "]" + ents[i], 3500);
			templ = (CEntityTemplate)LoadResourceAsync(ents[i], true);
			if (!templ){
				theGame.GetGuiManager().ShowNotification("[" + (i + 1) + "] NO TEMPLATE", 3500);
			}
			ent = theGame.CreateEntity(templ, thePlayer.GetWorldPosition() + Vector(0,0,1.0), thePlayer.GetWorldRotation());
			if (templ && !ent) {
				theGame.GetGuiManager().ShowNotification("[" + (i + 1) + "] NO ENTITY", 3500);
			}
			ent.DestroyAfter(3.5f);
			Sleep(4.f);
		}
	}
	event OnLeaveState( prevStateName : name )
	{
	}
}

exec function bye() {
	var ttask : CBTTaskAttack;
	ttask = new CBTTaskAttack in theGame;
	ttask.OnActivate();
}
exec function ndrain(st : EStaminaActionType, optional mult : float) {
	GetWitcherPlayer().DrainStamina(st,,,,,mult);
}

exec function eproj() {
	var entityTemplate : CEntityTemplate;
	var proj : W3AdvancedProjectile;
	var collisionGroups : array<name>;

	collisionGroups.PushBack('Ragdoll');
	collisionGroups.PushBack('Terrain');
	collisionGroups.PushBack('Static');
	collisionGroups.PushBack('Water');

	entityTemplate = (CEntityTemplate)LoadResource('eredin_frost_proj');
	proj = (W3AdvancedProjectile)theGame.CreateEntity(entityTemplate, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
	proj.Init(thePlayer);
	proj.ShootProjectileAtPosition(proj.projAngle, proj.projSpeed, thePlayer.GetWorldPosition() + theCamera.GetCameraDirection() * 10.f, 20.f, collisionGroups);
}

exec function managerreset() {
	NR_GetMagicManager().Init(true);
}

exec function head1() {
	var heading : float;
	var vecH, vecR : Vector;
	heading = thePlayer.GetHeading();
	vecH = thePlayer.GetHeadingVector();
	vecR = thePlayer.GetWorldRight();

	NR_Notify("PLAYER: heading = " + heading + ", vecH = " + VecToString(vecH) + ", vecR = " + VecToString(vecR));
}

exec function head2() {
	var heading : float;
	var vecH, vecR : Vector;
	heading = theCamera.GetCameraHeading();
	vecH = theCamera.GetCameraDirection();
	vecR = theCamera.GetCameraRight();

	NR_Notify("CAMERA: heading = " + heading + ", vecH = " + VecToString(vecH) + ", vecR = " + VecToString(vecR));
}

exec function tp1() {
	var pos : Vector;
	var rot : EulerAngles;
	pos = thePlayer.GetWorldPosition();
	rot = thePlayer.GetWorldRotation();
	pos.X += 1;
	thePlayer.TeleportWithRotation(pos, rot);
}

exec function nrEffect(eName : name, optional disable : bool) {
	if (disable) {
		thePlayer.StopEffect(eName);
	} else {
		thePlayer.PlayEffect(eName);
	}
}

exec function nrEntityEffect(templatePath : String, eName : name, optional disable : bool) {
	var template : CEntityTemplate;
	var entity : CEntity;

	template = (CEntityTemplate)LoadResource(templatePath, true);
	entity = theGame.CreateEntity(template, thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f + Vector(0,0,1.5f), thePlayer.GetWorldRotation());
	if (disable) {
		entity.StopEffect(eName);
	} else {
		entity.PlayEffect(eName);
	}
	entity.DestroyAfter(10.f);
}

function EulerToString(euler: EulerAngles) : String {
	return "[" + FloatToStringPrec(euler.Pitch,3) + ", " + FloatToStringPrec(euler.Yaw,3) + ", " + FloatToStringPrec(euler.Roll,3) + "]";
}
function PrintPosRot(nname:String, pos:Vector, rot:EulerAngles) {
	NR_Notify(nname + ": " + VecToString(pos) + "; " + EulerToString(rot));
}

exec function tcam3(optional test : int, optional fl1 : float, optional fl2 : float, optional fl3 : float) {
	var currRotation, currVelocity : EulerAngles;
	var topCamera : CCustomCamera;
	var preset : SCustomCameraPreset;
	var camera : CStaticCamera;
	var pos, pos2 : Vector;
	var rot : EulerAngles;

	PrintPosRot("thePlayer", thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
	NR_Notify("thePlayer: heading: " + VecToString(thePlayer.GetHeadingVector()));
	PrintPosRot("theCamera", theCamera.GetCameraPosition(), theCamera.GetCameraRotation());
	NR_Notify("theCamera: fov = "+theCamera.GetFov()+"heading = " + theCamera.GetCameraHeading() + ", headingVec: " + VecToString(theCamera.GetCameraDirection()));
	topCamera = (CCustomCamera) theCamera.GetTopmostCameraObject();
	preset = topCamera.GetActivePreset();
	PrintPosRot("TopmostCamera", topCamera.GetWorldPosition(), topCamera.GetWorldRotation());
	NR_Notify("TopmostCamera:Preset: [" + NameToString(preset.pressetName) + "] distance: " + preset.distance + ", offset: " + VecToString(preset.offset));
	NR_Notify("TopmostCamera:PivotPos: [" + topCamera.GetActivePivotPositionController().controllerName + "] offset = " + topCamera.GetActivePivotPositionController().offsetZ + ", PivotRot: [" + topCamera.GetActivePivotRotationController().controllerName + "] minPitch = " + topCamera.GetActivePivotRotationController().minPitch + ", maxPitch = " + topCamera.GetActivePivotRotationController().maxPitch);
	NR_Notify("TopmostCamera:PivotDist: [" + topCamera.GetActivePivotDistanceController().controllerName + "] minDist = " + topCamera.GetActivePivotDistanceController().minDist + ", maxDist = " + topCamera.GetActivePivotDistanceController().maxDist);

	pos = theCamera.GetCameraPosition() - thePlayer.GetWorldPosition();
	NR_Notify("raw DIFF: " + VecToString(pos) + ", VecDistance: " + VecDistance(theCamera.GetCameraPosition(), thePlayer.GetWorldPosition()));

	camera = NR_getStaticCamera();
	camera.activationDuration = 1.f;
	camera.deactivationDuration = 1.f;
	if (test == -3) {
		((CCustomCamera)theCamera.GetTopmostCameraObject()).GetActivePivotPositionController().SetDesiredPosition(Vector(fl1, fl2, fl3));
	} else if (test == -2) {
		((CCustomCamera)theCamera.GetTopmostCameraObject()).GetActivePivotDistanceController().SetDesiredDistance(fl1);
	} else if (test == -1) {
		camera.Stop();
	} else if (test == 1) {


		
		camera.TeleportWithRotation(theCamera.GetCameraPosition(), theCamera.GetCameraRotation());
		camera.Run();


	} else if (test == 2) {
		camera = NR_getStaticCamera();
		camera.TeleportWithRotation(topCamera.GetWorldPosition(), topCamera.GetWorldRotation());
		camera.Run();
	} else if (test == 3) {
		camera = NR_getStaticCamera();
		pos = theCamera.GetCameraPosition();
		rot = theCamera.GetCameraRotation();
		rot.Pitch = AngleNormalize(rot.Pitch - 180);
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 4) {
		camera = NR_getStaticCamera();
		pos = theCamera.GetCameraPosition();
		rot = theCamera.GetCameraRotation();
		rot.Yaw = AngleNormalize(rot.Yaw - 180);
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 5) {
		camera = NR_getStaticCamera();
		pos = theCamera.GetCameraPosition();
		rot = theCamera.GetCameraRotation();
		rot.Pitch = AngleNormalize(rot.Pitch - 180);
		rot.Yaw = AngleNormalize(rot.Yaw - 180);
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 6) {
		camera = NR_getStaticCamera();
		pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * fl1;
		pos.Z += fl2;

		rot = thePlayer.GetWorldRotation();
		rot.Pitch += fl3;
		rot.Yaw -= 180.0;
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 7) {
		camera = NR_getStaticCamera();
		pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * fl1;
		pos.Z += fl2;

		rot = thePlayer.GetWorldRotation();
		rot.Pitch += fl3;
		//rot.Yaw -= 180.0;
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 8) {
		camera = NR_getStaticCamera();
		pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * -2.11;
		pos.Z += 0.62;

		rot = thePlayer.GetWorldRotation();
		rot.Pitch += 9.5;
		rot.Yaw -= 180.0;
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	}
}

function NR_getStaticCamera(): CStaticCamera {
	var template: CEntityTemplate;
	var camera: CStaticCamera;

	camera = (CStaticCamera)theGame.GetEntityByTag('NR_CAMERA');
	if (!camera) {
		template = (CEntityTemplate)LoadResource("nr_static_camera");
		camera = (CStaticCamera)theGame.CreateEntity( template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
		camera.AddTag('NR_CAMERA');
		NR_Notify("Camera created!");
	}
	return camera;
}

exec function tcam2(cmd : String, optional val : float, optional val2 : float, optional val3 : float) {
	var camera : CStaticCamera;
	var comp   : CCameraComponent;
	var pos : Vector;
	var rot : EulerAngles;

	camera = NR_getStaticCamera();
	if (cmd == "toplayer") {
		camera.TeleportWithRotation( thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
	} else if (cmd == "posoff") {
		pos = camera.GetWorldPosition();
		if (val)
			pos.X += val;
		if (val2)
			pos.Y += val2;
		if (val3)
			pos.Z += val3;
		camera.TeleportWithRotation( pos, camera.GetWorldRotation() );
	} else if (cmd == "rotoff") {
		rot = camera.GetWorldRotation();
		if (val)
			rot.Pitch += val;
		if (val2)
			rot.Yaw += val2;
		if (val3)
			rot.Roll += val3;
		camera.TeleportWithRotation( camera.GetWorldPosition(), rot );
	} else if (cmd == "run") {
		camera.Run();
	} else if (cmd == "stop") {
		camera.Stop();
	} else if (cmd == "zoom" && val > 0.1) {
		camera.SetZoom(val);
	} else if (cmd == "fov" && val > 0.1) {
		camera.SetFov(val);
	} else if (cmd == "act" && val > 0.1) {
		camera.activationDuration = val;
	} else if (cmd == "deact" && val > 0.1) {
		camera.deactivationDuration = val;
	} else if (cmd == "timeout" && val > 0.1) {
		camera.timeout = val;
	} else if (cmd == "fadein" && val > 0.1) {
		camera.fadeStartDuration = val;
	} else if (cmd == "fadeout" && val > 0.1) {
		camera.fadeEndDuration = val;
	} else if (cmd == "reset") {
		camera.ResetRotation();
	} else if (cmd == "focus") {
		camera.FocusOn(thePlayer);
	} else if (cmd == "lookat") {
		camera.LookAt(thePlayer);
	} else if (cmd == "follow") {
		camera.CreateAttachment(thePlayer);
	} else if (cmd == "unfollow") {
		camera.BreakAttachment();
	} else {
		NR_Notify("Unknown command!");
	}
}

exec function ntrs(num : int, optional input : String) {
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

exec function getInRange(range : float, optional makeFriendly : bool) {
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
        LogChannel('getInRange', "   " + entities[i]);
        LogChannel('getInRange', "   - pos: " + VecToString(entities[i].GetWorldPosition()));
           LogChannel('getInRange', "   - rot: " + EulerToString(entities[i].GetWorldRotation()));
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
            if (makeFriendly)
                actor.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
        }
    }
}

exec function ep2logo( show : bool, fadeInterval : float, x : int, y : int )
{
	var overlayPopupRef : CR4OverlayPopup;
	
	overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
	if ( overlayPopupRef )
	{
		overlayPopupRef.ShowEP2Logo( show, fadeInterval, x, y );
	}
}

/*					case 0: PlayHeadEffect('toxic_000_025'); break;
					case 1: PlayHeadEffect('toxic_025_050'); break;
					case 2: HeadEffect(toxic_050_075); break;
					case 3: HeadEffect(toxic_075_100)  ; break;*/
exec function testh1() 
{
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
			manager.UpdateHead('nr_h_01_wa__syanna');
	}
}
exec function teste1(num : int, optional stop : bool) 
{
	if (num == 0) {
		PlayHeadEffect('toxic_000_025', stop); // black h_
	} else if (num == 1) {
		PlayHeadEffect('toxic_025_050', stop); // black h_ + he_
	} else if (num == 2) {
		PlayHeadEffect('toxic_050_075', stop); // nothing change (non existing)
	} else if (num == 3) {
		PlayHeadEffect('toxic_075_100', stop); // OK triss toxic
	} else if (num == 4) {
		PlayHeadEffect('toxic_100_075', stop); // OK triss toxic
	}
}
exec function testh2() 
{
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
			manager.UpdateHead('nr_h_02_wa__vivienne');
	}
}
exec function testh3() 
{
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
			manager.UpdateHead('nr_h_01_ma__udalryk');
	}
}
exec function testh4() 
{
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (manager) {
			manager.UpdateHead('nr_h_01_wa__ves');
	}
}

exec function HeadEffect( effect : name, optional stop : bool ) {
	PlayHeadEffect(effect, stop);
}
function PlayHeadEffect( effect : name, optional stop : bool )
{
	var inv : CInventoryComponent;
	var headIds : array<SItemUniqueId>;
	var headId : SItemUniqueId;
	var head : CItemEntity;
	var i : int;
	
	inv = thePlayer.GetInventory();
	headIds = inv.GetItemsByCategory('head');
	
	for ( i = 0; i < headIds.Size(); i+=1 )
	{
		if ( !inv.IsItemMounted( headIds[i] ) )
		{
			continue;
		}
		
		headId = headIds[i];
				
		if (!inv.IsIdValid( headId ))
		{
			NR_Notify("W3Effect_Toxicity : Can't find head item");
			return;
		}
		
		head = inv.GetItemEntityUnsafe( headId );
		
		if ( !head )
		{
			NR_Notify("W3Effect_Toxicity : head item is null");
			return;
		}

		if ( stop )
		{
			if (!head.HasEffect(effect))
				NR_Notify("W3Effect_Toxicity : head item has no effect: " + effect);
			head.StopEffect( effect );
		}
		else
		{
			if (!head.HasEffect(effect))
				NR_Notify("W3Effect_Toxicity : head item has no effect: " + effect);
			head.PlayEffectSingle( effect );
		}
	}
}

function NR_EulerToString(euler: EulerAngles) : String {
	return "[" + FloatToStringPrec(euler.Pitch,3) + ", " + FloatToStringPrec(euler.Yaw,3) + ", " + FloatToStringPrec(euler.Roll,3) + "]";
}

exec function NR_Range(range : float, optional makeFriendly : bool) {
		var entities: array<CGameplayEntity>;
    var actor : CActor;
    var i, t, maxEntities: int;
    var tags : array<name>;
    var pos : Vector;
        
    maxEntities = 1000;

    FindGameplayEntitiesInRange(entities, thePlayer, range, maxEntities);

    pos = thePlayer.GetWorldPosition();
    NR_Debug("player pos: [" + pos.X + ", " + pos.Y + ", " + pos.Z + "]");
    NR_Debug("player rot: " + NR_EulerToString(thePlayer.GetWorldRotation()));
		NR_Notify("nik_range: found entities: " + entities.Size());
    
		
    for (i = 0; i < entities.Size(); i += 1) {
        NR_Debug("entity: " + entities[i]);
        NR_Debug("   " + entities[i]);
        NR_Debug("   - pos: " + VecToString(entities[i].GetWorldPosition()));
           NR_Debug("   - rot: " + NR_EulerToString(entities[i].GetWorldRotation()));
        tags = entities[i].GetTags();

        for (t = 0; t < tags.Size(); t += 1) {
           NR_Debug("   > tag " + tags[t]);
        }
        actor = (CActor)entities[i];
        if (actor) {
            if (!actor.IsAlive()) {
                NR_Debug("* actor dead");
                continue;
            }
            if (actor.HasAttitudeTowards(thePlayer)) {
                NR_Debug("* GetAttitude to player: " + actor.GetAttitude(thePlayer));
            }
            NR_Debug("* GetAttitudeGroup: " + actor.GetAttitudeGroup());
            
            NR_Debug("* GetVoicetag: " + actor.GetVoicetag());
            NR_Debug("* GetDisplayName: " + actor.GetDisplayName());
            NR_Debug("* IsInNonGameplayCutscene: " + actor.IsInNonGameplayCutscene());
            NR_Debug("* IsInGameplayScene: " + actor.IsInGameplayScene());
            if (makeFriendly)
                actor.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
        }
    }
}


class NR_AssetCooked extends CEntity {
	var cookedTemplates : array<CEntityTemplate>;
	var cookedScenes : array<CStoryScene>;
	var cookedMeshes : array<CMeshComponent>;
}

exec function icespawn(optional app : bool) {
	var template : CEntityTemplate;
	var entity : CEntity;
	var npc : CNewNPC;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\quest\nr_golem_celestine.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	entity = theGame.CreateEntity(template, pos);
	entity.AddTag('nr_celestine');
	entity.AddTag('fairytale_witch');
	npc = (CNewNPC)entity;
	if (npc && !app) {
		// npc.ApplyAppearance("elemental_stone_morph");
		npc.ApplyAppearance("nr_celestine");
	} else {
		npc.ApplyAppearance("nr_celestine_stone_morph");
	}
	npc.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Default );
	npc.SetTemporaryAttitudeGroup('friendly_to_player', AGP_Default);
	npc.PlayLine(2115940953, true);
	NR_Notify("Spawned = " + npc);
}
exec function icespawn2(optional app : bool) {
	var template : CEntityTemplate;
	var entity : CEntity;
	var npc : CNewNPC;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("quests\sidequests\skellige\quest_files\sq210_impossible_tower\characters\sq210_golem_v2.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	entity = theGame.CreateEntity(template, pos);
	npc = (CNewNPC)entity;
	npc.SetTemporaryAttitudeGroup('friendly_to_player', AGP_Default);
	npc.PlayLine(2115940953, true);
	NR_Notify("Spawned = " + npc);
}
exec function icespawn3(optional app : bool) {
	var template : CEntityTemplate;
	var entity : CEntity;
	var npc : CNewNPC;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("quests\main_npcs\triss.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	entity = theGame.CreateEntity(template, pos);
	npc = (CNewNPC)entity;
	npc.SetTemporaryAttitudeGroup('friendly_to_player', AGP_Default);
	npc.PlayLine(2115940953, true);
	NR_Notify("Spawned = " + npc);
}

exec function iceapp( appName : String ) {
	var npc : CNewNPC;
	npc = theGame.GetNPCByTag('NR_ICE_DEBUG');
	if (npc) {
		NR_Notify("appearance = " + appName);
		npc.ApplyAppearance(appName);
	} else {
		NR_Notify("!NPC: " + npc);
	}
}

exec function icetest2() {
	var template : CEntityTemplate;
	var entity : CEntity;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\quest\nr_golem_ice_stone_morph.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f;
	entity = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation());
	entity.AddTag('NR_ICE_DEBUG');
	NR_Notify("Spawned = " + entity);
}

exec function icetest3() {
	var template : CEntityTemplate;
	var entity : CEntity;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\quest\nr_ground_golem_morph.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f;
	entity = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation());
	entity.AddTag('NR_ICE_DEBUG');
	NR_Notify("Spawned = " + entity);
}

exec function icetest4() {
	var template : CEntityTemplate;
	var entity : CEntity;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\quest\nr_fire_elemental_morph.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f;
	entity = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation());
	entity.AddTag('NR_ICE_DEBUG');
	NR_Notify("Spawned = " + entity);
}

exec function icetest5() {
	var template : CEntityTemplate;
	var entity : CEntity;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\quest\nr_stone_ice_tortilla_morph.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f;
	entity = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation());
	entity.AddTag('NR_ICE_DEBUG');
	NR_Notify("Spawned = " + entity);
}

exec function icetest6() {
	var template : CEntityTemplate;
	var entity : CEntity;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\quest\test_ice_wall.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f;
	entity = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation());
	entity.AddTag('NR_ICE_DEBUG');
	NR_Notify("Spawned = " + entity);
}

exec function icetest7() {
	var template : CEntityTemplate;
	var entity : CEntity;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource("dlc\dlcnewreplacers\data\entities\quest\test_ice_wall.w2ent", true);
	if (!template) {
		NR_Notify("!TEMPLATE: " + template);
		return;
	}
	pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f;
	entity = theGame.CreateEntity(template, pos, thePlayer.GetWorldRotation());
	entity.AddTag('NR_ICE_DEBUG');
	NR_Notify("Spawned = " + entity);
}

exec function icedestroy() {
	var 	entities : array<CEntity>;
	var             i, j : int;

	theGame.GetEntitiesByTag('NR_ICE_DEBUG', entities);
	for (i = 0; i < entities.Size(); i += 1) {
		entities[i].Destroy();
	}
	NR_Notify("Destroyed = " + entities.Size());
}

exec function icemorph( ratio : float, blend : float ) {
	var 	entity : CEntity;
	var 	entities : array<CEntity>;
    var    components : array<CComponent>;
    var       manager : CMorphedMeshManagerComponent;
    var             i, j : int;

    theGame.GetEntitiesByTag('NR_ICE_DEBUG', entities);
    NR_Notify("!ENTITY: " + entities.Size());
    if (entities.Size() == 0) {
    	return;
    }
    NR_Debug("SOundbank loaded = " + theSound.SoundIsBankLoaded("monster_golem_ice.bnk"));
    if (!theSound.SoundIsBankLoaded("monster_golem_ice.bnk")) {
    	theSound.SoundLoadBank("monster_golem_ice.bnk", false);
    }
    for (i = 0; i < entities.Size(); i += 1) {
    	entity = entities[i];
    	entity.PlayEffect('glow');
    	entity.StopAllEffectsAfter(blend);
		entity.SoundEvent("monster_golem_ice_mv_recover");
		components = entity.GetComponentsByClassName('CMorphedMeshManagerComponent');
		if (components.Size() == 0) {
		    NR_Debug("NR_ICE_DEBUG: [ERROR] Not found morph managers for " + entity);
		}
		for (j = 0; j < components.Size(); j += 1) {
		    manager = (CMorphedMeshManagerComponent) components[j];
		    if (manager) {
		        NR_Debug("NR_ICE_DEBUG: [Info] Current morph ratio: " + manager.GetMorphBlend());
		        manager.SetMorphBlend( ratio, blend );
		        NR_Debug("NR_ICE_DEBUG: [OK] Morph component: " + manager + " to <" + ratio + "> in " + blend + " sec");
		    }
		}
	}
}

exec function locstr(key: string) {
	NR_Notify("STR = [" + GetLocStringByKeyExt(key) + "]");
}

exec function coloring(h1 : Uint16, l1 : Int8, s1 : Int8, h2 : Uint16, l2 : Int8, s2 : Int8)
{
    var template, temp : CEntityTemplate;
    var colEntry : SEntityTemplateColoringEntry;
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
        
    temp = (CEntityTemplate)LoadResource( "dlc\dlccyberpunkprototypeattire\data\items\cyberpunk_armor\s_01a_cyberpunk_01.w2ent", true);
    template = (CEntityTemplate)LoadResource( "characters\models\crowd_npc\nml_villager\torso\t1a_04_ma__nml_villager.w2ent", true);
        
    colEntry.appearance = 'test';
    colEntry.componentName = 't1a_04_ma__nml_villager';


    col1.hue = h1;
    col1.saturation = s1;
    col1.luminance = l1;

    col2.hue = h2;
    col2.saturation = s2;
    col2.luminance = l2;

    colEntry.colorShift1 = col1;
    colEntry.colorShift2 = col2;
    
    if (temp.coloringEntries.Size() > 0)
        temp.coloringEntries[0] = colEntry;
    else
        temp.coloringEntries.PushBack(colEntry);

    npcEntity = theGame.CreateEntity( temp, pos, rot);
    npcEntity.ApplyAppearance(colEntry.appearance);
    npcEntity.AddTag('colshifttestnpc');
    
    
    comp = (CAppearanceComponent)npcEntity.GetComponentByClassName('CAppearanceComponent');
    comp.IncludeAppearanceTemplate(template);
    
    theGame.GetGuiManager().ShowNotification(" "+Int8ToInt(s1)+" "+Int8ToInt(l1)+" "+" "+Int8ToInt(s2)+" "+Int8ToInt(l2));
}


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



exec function toDress(num : int) {
	var manager : NR_PlayerManager = NR_GetPlayerManager();
	if (!manager) {
		NR_Error("No manager!");
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

exec function toScene0() {
	NR_PlaySceneF("quests/prologue/quest_files/q001_beggining/scenes/q001_5_wake_up.w2scene");
}

exec function toScene1() {
	NR_PlaySceneF("quests/sidequests/skellige/quest_files/sq204_forest_spirit/scenes/sq204_03b_cs_leshy_appear.w2scene");
}

exec function yensc(optional input : String) {
	NR_PlaySceneF("dlc/bob/data/quests/main_quests/quest_files/q705_epilog/scenes/q705_20a_yen_visit_vineyard.w2scene");
}

exec function tosc(path : String, optional input : String) {
	NR_PlaySceneF(path, input);
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

exec function testgate(optional enable: bool) {
	var swit : W3InteractionSwitch;

	swit = (W3InteractionSwitch)theGame.GetEntityByTag('q403_main_gate');
	if (!swit) {
		NR_Debug("!switch");
	}
	NR_Debug("switch = " + swit + ", IsLocked = " + swit.IsLocked() + ", focusModeHighlight = " + swit.focusModeHighlight + ", interactionActiveInState = " + swit.interactionActiveInState);
	if (enable) {
		// swit.Enable(true);
		swit.Lock(false);
	}
}

exec function nrresetsaved() {
	NR_GetPlayerManager().PullReplacerForQuest();	
}

exec function getdebug() {
	NR_Notify("Lines = " + NR_GetPlayerManager().GetDebugLineCount());
}

exec function printdebug() {
	NR_GetPlayerManager().PrintDebugLines();
}
