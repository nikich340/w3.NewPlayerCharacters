statemachine class NR_EffectsTester extends CObject {
	var map : NR_Map;
	var prefix_filter : String;

	public function Init() {
		prefix_filter = "";
		map = new NR_Map in this;
        map.setN("dlc/bob/data/characters/npc_entities/monsters/nightwraith_banshee_summon.w2ent", 'explode');
        map.setN("dlc/bob/data/characters/npc_entities/monsters/nightwraith_banshee_summon_skeleton.w2ent", 'explode');
        map.setN("dlc/bob/data/items/weapons/projectiles/q703_paint_bomb_blue.w2ent", 'explosion');
        map.setN("dlc/bob/data/items/weapons/projectiles/q703_paint_bomb_green.w2ent", 'explosion');
        map.setN("dlc/bob/data/items/weapons/projectiles/q703_paint_bomb_purple.w2ent", 'explosion');
        map.setN("dlc/bob/data/items/weapons/projectiles/q703_paint_bomb_red.w2ent", 'explosion');
        map.setN("dlc/bob/data/items/weapons/projectiles/q703_paint_bomb_yellow.w2ent", 'explosion');
        map.setN("dlc/bob/data/living_world/enemy_templates/nest/monster_nest_archespore.w2ent", 'explosion');
        map.setN("dlc/bob/data/living_world/enemy_templates/nest/monster_nest_endriaga.w2ent", 'explosion');
        map.setN("dlc/bob/data/living_world/enemy_templates/nest/monster_nest_kikimora.w2ent", 'explosion');
        map.setN("dlc/bob/data/living_world/enemy_templates/nest/monster_nest_scolopendromorph.w2ent", 'explosion');
        map.setN("dlc/bob/data/living_world/quests/barrens/poi_bar_a_13/poi_bar_a_13_mnest.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/main_quests/quest_files/q704_truth/entities/q704_explosion_entity.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_angry_dwarf_01.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_angry_dwarf_02.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_angry_dwarf_03.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_angry_dwarf_04.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_candidate.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_count_monnier.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_gwent_purists.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_herald.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_monnier_guards.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_novigradian_player.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_ofieri_player.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_skellige_player.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/cg700_card_game/characters/cg700_zerrikanian_player.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/mq7010_airborne_cattle/entities/mq7010_dracolizard_nest_draconide_destroyed.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/mq7010_airborne_cattle/entities/mq7010_dracolizard_nest_draconide_with_eggs.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/mq7010_airborne_cattle/entities/mq7010_dracolizard_nest_effects.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/minor_quests/quest_files/mq7018_last_one/characters/mq7018_guards.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/sidequests/quest_files/sq703_wine_wars/characters/sq703_guards.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/sidequests/quest_files/sq703_wine_wars/characters/sq703_investor.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/sidequests/quest_files/sq703_wine_wars/characters/sq703_servants.w2ent", 'explosion');
        map.setN("dlc/bob/data/quests/sidequests/quest_files/sq703_wine_wars/entities/sq703_bomb_target.w2ent", 'explosion');
        map.setN("dlc/ep1/data/fx/cutscenes/q604_10_study/q604_force_blast.w2ent", 'explosion');
        map.setN("dlc/ep1/data/fx/glyphword/glyphword_20/glyphword_20_explode.w2ent", 'explode');
        map.setN("dlc/ep1/data/fx/quest/q603/08_demo_dwarf/q603_08_fire_01.w2ent", 'explosion');
        map.setN("dlc/ep1/data/fx/quest/q603/08_demo_dwarf/q603_08_light_smoke.w2ent", 'explosion');
        map.setN("dlc/ep1/data/fx/quest/q603/08_demo_dwarf/q603_08_petard_dancing_star.w2ent", 'explosion');
        map.setN("dlc/ep1/data/fx/quest/q603/08_demo_dwarf/q603_08_smoke.w2ent", 'explosion');
        map.setN("dlc/ep1/data/fx/quest/q603/08_demo_dwarf/q603_08_sparks.w2ent", 'explosion');
        map.setN("dlc/ep1/data/fx/quest/q603/usm_demodwarf/q603_usm_explosion.w2ent", 'explosion');
        map.setN("dlc/ep1/data/living_world/enemy_templates/nests/monster_nest_spider.w2ent", 'explosion');
        map.setN("dlc/ep1/data/quests/quest_files/q603_bank/entities/q603_hut_explosive.w2ent", 'explosion');
        map.setN("fx/characters/filippa/attack_02/filippa_arcane_circle.w2ent", 'explosion');
        map.setN("fx/cutscenes/kaer_morhen/403_triss_spell/triss_explode_cutscene.w2ent", 'explode');
        map.setN("fx/quest/q205/sorceress_lightingball.w2ent", 'explosion');
        map.setN("fx/quest/q210/philippa_cast/philippa_cast_q210.w2ent", 'explode');
        map.setN("fx/quest/q310/q310_philippa_fireball.w2ent", 'explosion');
        map.setN("fx/quest/q403/meteorite/q403_meteorite.w2ent", 'explosion');
        map.setN("fx/quest/q403/meteorite/q403_meteorite_strong.w2ent", 'explosion');
        map.setN("gameplay/abilities/elemental/elemental_fireball_proj.w2ent", 'explosion');
        map.setN("gameplay/abilities/eredin/eredin_ice_spike.w2ent", 'explosion');
        map.setN("gameplay/abilities/eredin/eredin_meteorite.w2ent", 'explosion');
        map.setN("gameplay/abilities/fugas/fugas_stinkcloud_area.w2ent", 'explosion');
        map.setN("gameplay/abilities/sorceresses/soceress_arcane_missile.w2ent", 'explode');
        map.setN("gameplay/abilities/sorceresses/sorceress_fireball.w2ent", 'explosion');
        map.setN("gameplay/abilities/sorceresses/sorceress_fireball_fast.w2ent", 'explosion');
        map.setN("gameplay/abilities/wh_mage/wh_icespear.w2ent", 'explode');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_draconide.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_drowner.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_endriaga.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_ghoul.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_harpy.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_nekker.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_rotfiend.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/monster_nest/monster_nest_sirens.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/oil_barrel/oil_barrel.w2ent", 'explosion');
        map.setN("gameplay/interactive_objects/oil_barrel/oil_barrel_dwarfish.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_dancing_star.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_devils_puffball.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_dimeritium_bomb.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_dragons_dream.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_fungi_bomb.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_glue.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_grapeshot.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_salt_bomb.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_samum.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_shrapnel_bomb.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_silver_dust_bomb.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_snow_ball.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_virus_bomb.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/petards/petard_white_frost.w2ent", 'explosion');
        map.setN("items/weapons/projectiles/witcher_bolts/explosive_bolt.w2ent", 'explosion');
        map.setN("quests/epilogues/quest_files/q504_ciri_empress/entities/q504_przerebel.w2ent", 'explode');
        map.setN("quests/generic_quests/novigrad/quest_files/mh306_dao/entities/crystal/mh306_magic_crystal.w2ent", 'explode');
        map.setN("quests/minor_quests/no_mans_land/quest_files/mq1002_seller_of_bracelets/entities/mq1002_entry_teleport_v02.w2ent", 'explosion');
        map.setN("quests/minor_quests/no_mans_land/quest_files/mq1002_seller_of_bracelets/entities/mq1002_igni_power_crystal.w2ent", 'explode');
        map.setN("quests/part_1/quest_files/q104_mine/objects/q104_explosion_blizzard_door.w2ent", 'explosion');
        map.setN("quests/part_1/quest_files/q104_mine/objects/q104_petard_trap.w2ent", 'explosion');
        map.setN("quests/part_1/quest_files/q104_mine/objects/q104_rat_nest.w2ent", 'explosion');
        map.setN("quests/part_1/quest_files/q401_konsylium/entities/q401_megascope_explosion.w2ent", 'explosion');
        map.setN("quests/part_1/quest_files/q401_konsylium/entities/q401_megascope_rod.w2ent", 'explosion');
        map.setN("quests/part_2/quest_files/q403_battle/entities/main_gate_kaer_morhen.w2ent", 'explode');
        map.setN("quests/part_2/quest_files/q403_battle/entities/q403_crater.w2ent", 'explosion');
        map.setN("quests/part_2/quest_files/q403_battle/entities/q403_viper_trap_fire.w2ent", 'explosion');
        map.setN("quests/part_3/quest_files/q310_pregeels/entities/q310_simple_explosion.w2ent", 'explosion');
        map.setN("quests/part_3/quest_files/q311_geels/objects/q311_spiral_gate_effect.w2ent", 'explosion');
        map.setN("quests/part_3/quest_files/q311_geels/objects/q311_spiral_gate_for_novigrad.w2ent", 'explosion');
        map.setN("quests/part_3/quest_files/q501_eredin/entities/q501_battle_barrel.w2ent", 'explode');
        map.setN("quests/part_3/quest_files/q501_eredin/entities/q501_mortar_marker.w2ent", 'explode');
        map.setN("quests/part_3/quest_files/q502_avallach/entities/q502_crater.w2ent", 'explosion');
        map.setN("quests/part_3/quest_files/q502_avallach/entities/q502_crater_snow.w2ent", 'explosion');
        map.setN("quests/secondary_npcs/djinn_trapped.w2ent", 'explode');
        map.setN("quests/sidequests/no_mans_land/quest_files/sq102_letho/entities/sq102_shed_explosive.w2ent", 'explosion');
	}

	public function SetPrefixFilter(prefix : String) {
		prefix_filter = prefix;
	}
}

state Idle in NR_EffectsTester {
}

state Work in NR_EffectsTester {
	event OnEnterState( prevStateName : name )
	{
		NRD("NR_EffectsTester::Work: OnEnterState");
		Work();
	}

	entry function Work() {
		var template 	: CEntityTemplate;
		var entity 		: CEntity;
		var actor 		: CActor;
		var effectName 	: CName;
		var      i 		: int;
		var     paths 	: array<String>;

		paths = parent.map.getKeys();
		for (i = 0; i < paths.Size(); i += 1) {
			NRD("NR_EffectsTester: " + i);
			effectName = parent.map.getN(paths[i]);
			if (StrLen(parent.prefix_filter) > 0 && !StrStartsWith(NameToString(effectName), parent.prefix_filter)) {
				NR_Notify("[" + i + "/" + paths.Size() + "] " + paths[i] + " -> " + NR_StrBlue("SKIP"));
				Sleep(1.f);
				continue;
			}

			template = (CEntityTemplate)LoadResourceAsync(paths[i], true);
			if (!template) {
				NR_Notify("[" + i + "/" + paths.Size() + "] " + paths[i] + " -> " + NR_StrRed("!template"));
				Sleep(1.f);
				continue;
			}
			entity = theGame.CreateEntity(template, thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.5f + Vector(0,0,1.5f));
			if (!entity) {
				NR_Notify("[" + i + "/" + paths.Size() + "] " + paths[i] + " -> " + NR_StrRed("!entity"));
				Sleep(1.f);
				continue;
			}
			actor = (CActor)entity;
			if (actor) {
				actor.SetTemporaryAttitudeGroup( 'friendly_to_player', AGP_Default );
			}
			Sleep(1.f);
			if (entity.PlayEffect(effectName)) {
				NR_Notify("[" + i + "/" + paths.Size() + "] " + paths[i] + " -> " + NR_StrGreen(NameToString(effectName), true));
				Sleep(5.f);
				entity.StopEffect(effectName);
				entity.Destroy();
			} else {
				NR_Notify("[" + i + "/" + paths.Size() + "] " + paths[i] + " -> " + NR_StrRed(NameToString(effectName), true));
				Sleep(1.f);
				entity.Destroy();
			}
			Sleep(0.5f);
		}
		NRD("NR_EffectsTester::Work: Finished");
		parent.GotoState('Idle');
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_EffectsTester::Work: OnLeaveState");
	}
}

exec function test_effects(optional prefix : String) {
	var tester : NR_EffectsTester;
	var manager : NR_PlayerManager = NR_GetPlayerManager();

	tester = new NR_EffectsTester in manager;
	tester.Init();
	if (StrLen(prefix) > 0)
		tester.SetPrefixFilter(prefix);
	tester.GotoState('Work');
	manager.m_debugLatentObject = tester;
}


statemachine class NR_FuncSpeedTester extends CObject {
    var f : float;
    var iters : int;

    public function Init() {}
}

state Idle in NR_FuncSpeedTester {
}

state Work1 in NR_FuncSpeedTester {
    event OnEnterState( prevStateName : name )
    {
        NRD("NR_FuncSpeedTester::Work: OnEnterState");
        Work1();
    }

    entry function Work1() {
        var x, f_i, startTime, endTime : float;
        var i : int;

        startTime = theGame.GetEngineTimeAsSeconds();

        for (i = 0; i < parent.iters; i += 1) {
            f_i = parent.f + i * Pi();
            x = RoundTo(f_i, 5);
            x = RoundTo(f_i, 4);
            x = RoundTo(f_i, 3);
            x = RoundTo(f_i, 2);
            x = RoundTo(f_i, 1);
            x = RoundTo(f_i, 0);
            SleepOneFrame();
        }
        
        endTime = theGame.GetEngineTimeAsSeconds();
        NR_Notify("Elapsed (RoundTo) [" + parent.iters + " iters]: " + (endTime - startTime));
        parent.GotoState('Idle');
    }

    event OnLeaveState( nextStateName : name )
    {
        NRD("NR_FuncSpeedTester::Work: OnLeaveState");
    }
}

state Work2 in NR_FuncSpeedTester {
    event OnEnterState( prevStateName : name )
    {
        NRD("NR_FuncSpeedTester::Work: OnEnterState");
        Work2();
    }

    entry function Work2() {
        var x, f_i, startTime, endTime : float;
        var i : int;

        startTime = theGame.GetEngineTimeAsSeconds();

        for (i = 0; i < parent.iters; i += 1) {
            f_i = parent.f + i * Pi();
            x = NR_RoundTo(f_i, 5);
            x = NR_RoundTo(f_i, 4);
            x = NR_RoundTo(f_i, 3);
            x = NR_RoundTo(f_i, 2);
            x = NR_RoundTo(f_i, 1);
            x = NR_RoundTo(f_i, 0);
            SleepOneFrame();
        }

        endTime = theGame.GetEngineTimeAsSeconds();
        NR_Notify("Elapsed (NR_RoundTo) [" + parent.iters + " iters]: " + (endTime - startTime));
        parent.GotoState('Idle');
    }

    event OnLeaveState( nextStateName : name )
    {
        NRD("NR_FuncSpeedTester::Work: OnLeaveState");
    }
}

exec function test_func1(f : float, iters : int) {
    var tester : NR_FuncSpeedTester;
    var manager : NR_PlayerManager = NR_GetPlayerManager();

    tester = new NR_FuncSpeedTester in manager;
    tester.Init();
    tester.f = f;
    tester.iters = iters;
    manager.m_debugLatentObject = tester;
    tester.GotoState('Work1');
}

exec function test_func2(f : float, iters : int) {
    var tester : NR_FuncSpeedTester;
    var manager : NR_PlayerManager = NR_GetPlayerManager();

    tester = new NR_FuncSpeedTester in manager;
    tester.Init();
    tester.f = f;
    tester.iters = iters;
    manager.m_debugLatentObject = tester;
    tester.GotoState('Work2');
}
