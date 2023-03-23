exec function sspawn(id : int, optional friendly : Bool, optional notAdjust : Bool, optional immortal : Bool) {
	var ent : CEntity;
	var pos : Vector;
	var template : CEntityTemplate;
	var npc : CNewNPC;

	if (id == 1) {
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
	}
	if (!notAdjust) {
		npc.SetLevel( GetWitcherPlayer().GetLevel() );
	}
}

exec function nrtmp() {
	NR_GetMagicManager().SetDefaults_HeavyPush();
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

exec function nrUnlock() {
	var 	skillsList : array<String>;
	var  	i : int;
	skillsList = NR_GetMagicManager().GetMagicSkillsList();

	for (i = 0; i < skillsList.Size(); i += 1) {
		FactsAdd(skillsList[i], 1);
	}
}

exec function nrLock() {
	var 	skillsList : array<String>;
	var  	i : int;
	skillsList = NR_GetMagicManager().GetMagicSkillsList();

	for (i = 0; i < skillsList.Size(); i += 1) {
		FactsRemove(skillsList[i]);
	}
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
		NRD("Ability: " + abls[i]);
	}
	for (i = 0; i < attrs.Size(); i += 1) {
		if( theGame.params.IsForbiddenAttribute(attrs[i]) )
			continue;
		val = thePlayer.GetAttributeValue(attrs[i]);
		NRD("Attribute: " + attrs[i] + ", value: [base = " + val.valueBase + "], [mult = " + val.valueMultiplicative + "], [add = " + val.valueAdditive + "]");
	}
	NRD("Max ess: " + thePlayer.GetStatMax(BCS_Essence));
	NRD("Cur ess: " + thePlayer.GetStat(BCS_Essence));
	NRD("Max vit: " + thePlayer.GetStatMax(BCS_Vitality));
	NRD("Cur vit: " + thePlayer.GetStat(BCS_Vitality));
	NRD("Immortality: " + thePlayer.GetImmortalityMode());
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
		NRE("NULL scene!");

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene1f() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/01.player_change_female.w2scene", true);
	if (!scene)
		NRE("NULL scene!");

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
}

exec function scene1s() {
	var scene      : CStoryScene;
	scene = (CStoryScene)LoadResource("dlc/dlcnewreplacers/data/scenes/03.player_change_sorceress.w2scene", true);
	if (!scene)
		NRE("NULL scene!");

	theGame.GetStorySceneSystem().PlayScene(scene, "Input");
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

exec function pstate() {
	NR_Notify("Player state = " + thePlayer.GetCurrentStateName());
}

function PrintDamageAction( source: String, action : W3DamageAction )
{
		var i, size : int;
		var effectInfos : array< SEffectInfo >;
		var attackerPowerStatValue : SAbilityAttributeValue;
		
		size = action.GetEffects( effectInfos );
		attackerPowerStatValue = action.GetPowerStatValue();

		NRD("[" + source + "] PrintDamageAction");
		NRD("AddEffectsFromAction(): causer = " + action.causer);
		NRD("AddEffectsFromAction(): vitalityDamage = " + action.processedDmg.vitalityDamage);
		NRD("AddEffectsFromAction(): essenceDamage = " + action.processedDmg.essenceDamage);
		NRD("AddEffectsFromAction(): moraleDamage = " + action.processedDmg.moraleDamage);
		NRD("AddEffectsFromAction(): staminaDamage = " + action.processedDmg.staminaDamage);
		NRD("AddEffectsFromAction(): effSize = " + size);
		NRD("AddEffectsFromAction(): attacker = " + action.attacker);
		NRD("AddEffectsFromAction(): GetBuffSourceName = " + action.GetBuffSourceName());
		NRD("AddEffectsFromAction(): attackerPowerStatValue = " + CalculateAttributeValue(attackerPowerStatValue));
			
		for( i = 0; i < size; i += 1 )
		{	
			NRD("AddEffectsFromAction(): effectType[" + i + "] = " + effectInfos[i].effectType);
			NRD("AddEffectsFromAction(): effectDuration[" + i + "] = " + effectInfos[i].effectDuration);
			NRD("AddEffectsFromAction(): effectCustomValue[" + i + "] = " + CalculateAttributeValue(effectInfos[i].effectCustomValue));
			NRD("AddEffectsFromAction(): effectAbilityName[" + i + "] = " + effectInfos[i].effectAbilityName, );
			NRD("AddEffectsFromAction(): customFXName[" + i + "] = " + effectInfos[i].customFXName);
			NRD("AddEffectsFromAction(): effectCustomParam[" + i + "] = " + effectInfos[i].effectCustomParam);
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
	ids = inv.GetItemsIds('mh306_dao_trophy');	
	LogItems("DAO: " + ids.Size());
}
exec function dao2() {
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = thePlayer.inv;
	LogItems("DAO2: " + inv.GetItemQuantityByName('mh306_dao_trophy'));
}
exec function dao3() {
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
	LogItems("DAO3: " + inv.GetItemQuantityByName('mh306_dao_trophy'));
}

exec function dao4() {
	var inv : CInventoryComponent;
	var ids : array<SItemUniqueId>;
	var atts : array<name>;
	var i : int;

	inv = GetWitcherPlayer().GetAssociatedInventory();
	LogItems("DAO3: " + inv.GetItemQuantityByName('mh306_dao_trophy'));
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
			NRE("NULL scene!");
		play_index = inp;//RandRange(max_index + 1, min_index);
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
			NRE("NULL scene!");

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
exec function pspawn(path : string, optional app : string) {
	var template : CEntityTemplate;
	var entity : CEntity;
	var npc : CNewNPC;
	var pos : Vector;

	template = (CEntityTemplate)LoadResource(path, true);
	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	entity = theGame.CreateEntity(template, pos);
	entity.AddTag('NR_TEMP');
	if (app != "") {
		npc = (CNewNPC)entity;
		if (npc) {
			npc.ApplyAppearance(app);
		}
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
	entity = theGame.CreateEntity(template, thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f, thePlayer.GetWorldRotation());
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
				
		if(!inv.IsIdValid( headId ))
		{
			NR_Notify("W3Effect_Toxicity : Can't find head item");
			return;
		}
		
		head = inv.GetItemEntityUnsafe( headId );
		
		if( !head )
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