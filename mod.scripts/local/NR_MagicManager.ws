/* This class for Sorceress solves magic attack entities, effects, hit effects, fist weapon etc
	instead of NPC's w2behtree and its CBTTask classes */

	/*ice_spear - карантир
sorceress_lightingball - желтый компактный фаерболл
snowball - снежок
eredin_meteorite - ледяной метеорит*/

// БЛОК и ОТНЯТИЕ СИЛЫ (из actor -> abilityManager)
// DrainStamina(action, fixedCost, fixedDelay, abilityName, dt, costMult);
// DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, 
// optional abilityName : name, optional dt : float, optional costMult : float)

// DrainStamina(ESAT_FixedValue, costPerc * thePlayer.GetStatMax(BCS_Stamina), delay);
//action - stamina action type
//fixedValue - fixed value to drain, used only when ESAT_FixedValue is used
//abilityName - name of the ability to use when passing ESAT_Ability
//dt - if set then then stamina cost is treated as cost per second and thus multiplied by dt
//costMult - if set (other than 0 or 1) then the actual cost is multiplied by this value

// generic_spell_rh, keira.SetAutoEffect( 'magic_light' );, anims: woman_work_stand_praying_start + woman_work_stand_praying_stop

//Persistent 'breathing', ManageBuffImmunities (PLAYER, [EET_AirDrainDive, EET_AirDrain, EET_Drowning], false), 
//effect 'mind_control' -> q203_geralt_head (SpawnAndAttachEntity(quests\part_1\quest_files\q203_him\entities\q203_geralt_head_component.w2ent, PLAYER, head, PM_DontPersist, 0))
//? StaticShooter ability to Yen


enum ENR_MagicSkill {
	ENR_SkillUnknown, 		// 0
	ENR_SkillBasic, 		// 1
	ENR_SkillEnhanced, 		// 2
	ENR_SkillSuperior,		// 3
	ENR_SkillMistress,		// 4
	ENR_SkillArchMistress	// 5
}
enum ENR_MagicAction {
		// unknown
	ENR_Unknown,
		// light attack
	ENR_Slash,
		// light "throw" attack
	ENR_Lightning,
	ENR_Projectile,
	ENR_ProjectileWithPrepare,
		// heavy attack
	ENR_Rock,	
	ENR_BombExplosion,
	ENR_RipApart,
	ENR_CounterPush,
		// special attack
	ENR_SpecialControl, // axii - временный контроль, помеченный соперник(и) восстают после смерти за тебя? Zombie
	ENR_SpecialGolem,   // yrden - призыв случайного голема
	ENR_SpecialMeteor,   // igni - метеорит
	ENR_SpecialTornado, // aard - торнадо?
	ENR_SpecialSphere, // quen - защитная сфера
			// teleport
	ENR_Teleport
}
struct SNR_MagicEvent {
	var eventName 		: name;
	var animName 		: name;
	var animTime 		: float;
}
statemachine class NR_MagicManager {
	// set on Init
	protected var sMap		: array<NR_Map>;
	const var ST_Universal	: int;

	// shared stuff
	public var aEventsStack 	: array<SNR_MagicEvent>;
	public var aData 			: CPreAttackEventData;
	public var aIsAlternate 	: Bool;
	public var aTeleportPos		: Vector;
	
	protected var aHandEffect 	: name;
	protected var i            	: int;
	protected var aName 			: String;

	default ST_Universal = 5; // EnumGetMax(ESignType); 
	default aHandEffect = '';
	default aName = "";
	
	function InitDefaults() {
		sMap.Resize(6);
		for (i = 0; i <= ST_Universal; i += 1) {
			sMap[i] = new NR_Map in thePlayer;
		}
		SetStaminaCost();
		SetSlashAttacksDef();
		SetThrowAttacksDef();
		SetRockAttacksDef();
		SetBombAttacksDef();
		SetSpecialAttacksDef();
		SetHandFXDef();
		SetTeleportFXDef();
	}
	function SetStaminaCost() {
		// cost_<AttackType> in % of total stamina
		// delay_<AttackType> in milliseconds
		sMap[ST_Universal].setF("cost_AttackNoStamina", 0.0f);
		sMap[ST_Universal].setF("delay_AttackNoStamina", 0.0f);

		sMap[ST_Universal].setF("cost_AttackLight", 0.1f);
		sMap[ST_Universal].setF("delay_AttackLight", 0.0f);

		sMap[ST_Universal].setF("cost_AttackHeavy", 0.2f);
		sMap[ST_Universal].setF("delay_AttackHeavy", 0.25f);

		sMap[ST_Universal].setF("cost_AttackFinisher", 0.25f);
		sMap[ST_Universal].setF("delay_AttackFinisher", 0.5f);

		sMap[ST_Universal].setF("cost_AttackPush", 0.25f);
		sMap[ST_Universal].setF("delay_AttackPush", 1.0f);	

		sMap[ST_Universal].setF("cost_AttackSpecialAard", 0.5f);
		sMap[ST_Universal].setF("delay_AttackSpecialAard", 1.5f);	

		sMap[ST_Universal].setF("cost_AttackSpecialYrden", 0.5f);
		sMap[ST_Universal].setF("delay_AttackSpecialYrden", 1.5f);

		sMap[ST_Universal].setF("cost_AttackSpecialAxii", 0.5f);
		sMap[ST_Universal].setF("delay_AttackSpecialAxii", 1.5f);

		sMap[ST_Universal].setF("cost_AttackSpecialQuen", 0.5f);
		sMap[ST_Universal].setF("delay_AttackSpecialQuen", 1.5f);

		sMap[ST_Universal].setF("cost_AttackSpecialIgni", 0.5f);
		sMap[ST_Universal].setF("delay_AttackSpecialIgni", 1.5f);
	}
	function SetThrowAttacksDef() {
		sMap[ST_Aard].setI("throw_attack_type", ENR_Lightning);
		sMap[ST_Aard].setN("lightning_fx", 'lightning_yennefer');
		sMap[ST_Aard].setN("throw_dummy_fx", 'hit_electric');

		sMap[ST_Yrden].setI("throw_attack_type", ENR_ProjectileWithPrepare);
		sMap[ST_Yrden].setN("throw_entity", 'arcane_projectile');
		
		sMap[ST_Igni].setI("throw_attack_type", ENR_ProjectileWithPrepare);
		sMap[ST_Igni].setN("throw_entity", 'sorceress_fireball');

		sMap[ST_Quen].setI("throw_attack_type", ENR_Lightning);
		sMap[ST_Quen].setN("lightning_fx", 'lightning_lynx');
		sMap[ST_Quen].setN("throw_dummy_fx", 'hit_electric');

		sMap[ST_Axii].setI("throw_attack_type", ENR_ProjectileWithPrepare);
		sMap[ST_Axii].setN("throw_entity", 'ice_spear');
	}
	function SetRockAttacksDef() {
		sMap[ST_Aard].setN("rock_proj", 'sorceress_stone_proj');
		sMap[ST_Aard].setN("rock_push_entity", 'keira_metz_cast');
				
		sMap[ST_Yrden].setN("rock_proj", 'sorceress_stone_proj');
		sMap[ST_Yrden].setN("rock_push_entity", 'keira_metz_cast');

		sMap[ST_Igni].setN("rock_proj", 'ep2_sorceress_stone_proj');
		sMap[ST_Igni].setN("rock_push_entity", 'lynx_cast');

		sMap[ST_Quen].setN("rock_proj", 'ep2_sorceress_stone_proj');
		sMap[ST_Quen].setN("rock_push_entity", 'lynx_cast');

		sMap[ST_Axii].setN("rock_proj", 'sorceress_wood_proj');
		sMap[ST_Axii].setN("rock_push_entity", 'keira_metz_cast');
	}
	function SetSlashAttacksDef() {
		sMap[ST_Aard].setN("slash_entity", 'magic_attack_lightning');
		sMap[ST_Yrden].setN("slash_entity", 'magic_attack_arcane');
		sMap[ST_Igni].setN("slash_entity", 'magic_attack_fire');
		sMap[ST_Quen].setN("slash_entity", 'ep2_magic_attack_lightning');
		sMap[ST_Axii].setN("slash_entity", 'magic_attack_lightning');
	}
	function SetBombAttacksDef() {
		sMap[ST_Aard].setN("bomb_entity", 'arcaneExplosion');
		sMap[ST_Yrden].setN("bomb_entity", 'arcaneExplosion');
		sMap[ST_Igni].setN("bomb_entity", 'arcaneExplosion');
		sMap[ST_Quen].setN("bomb_entity", 'arcaneExplosion');
		sMap[ST_Axii].setN("bomb_entity", 'arcaneExplosion');
	}
	function SetSpecialAttacksDef() {
		sMap[ST_Aard].setN("tornado_entity", 'nr_tornado');

		sMap[ST_Aard].setN("meteor_entity", 'eredin_meteorite');
		sMap[ST_Yrden].setN("meteor_entity", 'meteor_strong');
		sMap[ST_Igni].setN("meteor_entity", 'ciri_meteor');

		sMap[ST_Yrden].setN("golem_fx_entity", 'nr_fx_golem1');
		sMap[ST_Yrden].setN("golem_entity1", 'nr_golem1');
		sMap[ST_Yrden].setN("golem_entity2", 'nr_golem2');
		sMap[ST_Yrden].setN("golem_entity3", 'nr_golem3');
	}
	function SetHandFXDef() {
		sMap[ST_Aard].setN("hand_fx", 'hand_fx_yennefer');
		sMap[ST_Yrden].setN("hand_fx", 'hand_fx_philippa');
		sMap[ST_Igni].setN("hand_fx", 'hand_fx_triss');
		sMap[ST_Quen].setN("hand_fx", 'hand_fx_lynx');
		sMap[ST_Axii].setN("hand_fx", 'hand_fx_keira');
	}
	function SetTeleportFXDef() {
		sMap[ST_Aard].setN("teleport_in_fx", 'teleport_in_yennefer');
		sMap[ST_Aard].setN("teleport_out_fx", 'teleport_out_yennefer');

		sMap[ST_Yrden].setN("teleport_in_fx", 'teleport_out_keira');
		sMap[ST_Yrden].setN("teleport_out_fx", 'teleport_out_keira');

		sMap[ST_Igni].setN("teleport_in_fx", 'teleport_in_triss');
		sMap[ST_Igni].setN("teleport_out_fx", 'teleport_out_triss');

		sMap[ST_Quen].setN("teleport_in_fx", 'teleport_in_triss');
		sMap[ST_Quen].setN("teleport_out_fx", 'teleport_out_triss');

		sMap[ST_Axii].setN("teleport_in_fx", 'teleport_out_keira');
		sMap[ST_Axii].setN("teleport_out_fx", 'teleport_out_keira');
	}

	function HandFX(enable: Bool, optional onlyIfActive: Bool) {
		var newHandEffect 	: name;
		var sign 			: ESignType;

		// update sign
		sign = GetWitcherPlayer().GetEquippedSign();

		if (aHandEffect == '' && onlyIfActive) {
			return;
		}

		newHandEffect = sMap[sign].getN("hand_fx");

		if (!enable && aHandEffect != '') {
			thePlayer.StopEffect(aHandEffect);
			aHandEffect = '';
		} else if (enable && aHandEffect != newHandEffect) {
			if (aHandEffect != '') {
				thePlayer.StopEffect(aHandEffect);
			}
			
			thePlayer.PlayEffect(newHandEffect);
			aHandEffect = newHandEffect;
		}
	}
	function GetActionType() : ENR_MagicAction {
		var sign : ESignType = GetWitcherPlayer().GetEquippedSign();

		if (StrStartsWith(aName, "woman_sorceress_attack_slash")) {
			return ENR_Slash;
		} else if (StrStartsWith(aName, "woman_sorceress_attack_rock")) {
			return ENR_Rock;
		} else if (StrStartsWith(aName, "woman_sorceress_attack_push")) {
			return ENR_CounterPush;
		} else if (StrStartsWith(aName, "woman_sorceress_rip_apart")) {
			return ENR_RipApart;
		} else if (StrStartsWith(aName, "woman_sorceress_teleport")) {
			return ENR_Teleport;
		} else if (StrStartsWith(aName, "woman_sorceress_attack_throw")) {
			// THROW - depends on selected sign
			return sMap[sign].getI("throw_attack_type", (int)ENR_Lightning);
		} else if (StrStartsWith(aName, "woman_sorceress_attack_arcane")) {
			return ENR_BombExplosion;
		} else if (StrStartsWith(aName, "woman_sorceress_special_attack_fireball")) {
			return ENR_SpecialMeteor;
		} else if (StrStartsWith(aName, "woman_sorceress_special_quen")) {
			return ENR_SpecialSphere;
		} else if (StrStartsWith(aName, "woman_sorceress_special_attack_tornado")) {
			return ENR_SpecialTornado;
		} else if (StrStartsWith(aName, "woman_sorceress_special_attack_control")) {
			return ENR_SpecialControl;
		} else if (StrStartsWith(aName, "woman_sorceress_special_attack_golem")) {
			return ENR_SpecialGolem;
		} else {
			NRD("Unknown attack: aName = " + aName);
			return ENR_Unknown;
		}
	}
	function OnPreAttackEvent(animName : name, out data : CPreAttackEventData)
	{
		var sign : ESignType;

		sign = GetWitcherPlayer().GetEquippedSign();
		if (sign == ST_Igni) {
			data.hitFX 				= 'fire_hit';
			data.hitParriedFX 		= 'fire_hit';
			data.hitBackFX 			= 'fire_hit';
			data.hitBackParriedFX 	= 'fire_hit';
		} else if (sign == ST_Quen) {
			data.hitFX 				= 'hit_electric_quen';
			data.hitParriedFX 		= 'hit_electric_quen';
			data.hitBackFX 			= 'hit_electric_quen';
			data.hitBackParriedFX 	= 'hit_electric_quen';
		} else if (sign == ST_Yrden) {
			data.hitFX 				= 'yrden_shock';
			data.hitParriedFX 		= 'yrden_shock';
			data.hitBackFX 			= 'yrden_shock';
			data.hitBackParriedFX 	= 'yrden_shock';
		} else {
			data.hitFX 				= 'hit_electric';
			data.hitParriedFX 		= 'hit_electric';
			data.hitBackFX 			= 'hit_electric';
			data.hitBackParriedFX 	= 'hit_electric';
		}
		aData = data;
	}

	/* STAMINA */
	private function GetStaminaValuesForAction(actionName : name, out costPerc : float, out delay : float) {
		var skillLevel : int = GetSkillLevel();
		var reduceBySkill : float = 1.f + ((float)skillLevel - 1.f) / 2.f; // [1.0 - 3.0]
		var actionString : String = NameToString(actionName);

		// basic values
		costPerc = sMap[ST_Universal].getF("cost_" + actionString, 0.1f);
		delay = sMap[ST_Universal].getF("delay_" + actionString, 0.0f);

		// magic skill bonus
		costPerc = costPerc / reduceBySkill;
		delay = delay / reduceBySkill;

		// TODO: Fact-based extra skills to reduce stamina
	}
	public function HasStaminaForAction(actionName : name) : bool {
		var costPerc 		: float;
		var delay 			: float;
		var playerStamina 	: float = thePlayer.GetStaminaPercents(); // [0.0 - 1.0]

		GetStaminaValuesForAction(actionName, costPerc, delay);
		return playerStamina >= costPerc;
	}
	public function DrainStaminaForAction(actionName : name) {
		var costPerc 		: float;
		var delay 			: float;

		GetStaminaValuesForAction(actionName, costPerc, delay);
		thePlayer.DrainStamina(ESAT_FixedValue, costPerc * thePlayer.GetStatMax(BCS_Stamina), delay);
	}

	/* DAMAGE & SKILLS */
	public function GetSkillLevel() : ENR_MagicSkill
	{
		var playerLevel : int;
		var playerMax	: int;
		playerLevel = GetWitcherPlayer().GetLevel();
		playerMax = GetWitcherPlayer().GetMaxLevel();
		if ( FactsQuerySum("NewGamePlus") <= 0 ) {
			playerMax = playerMax / 2;
			// ? theGame.params.NEW_GAME_PLUS_MIN_LEVEL;
		}

		if (playerLevel >= FloorF(playerMax * 80 / 100)) {
			return ENR_SkillArchMistress;
		} else if (playerLevel >= FloorF(playerMax * 60 / 100)) {
			return ENR_SkillMistress;
		} else if (playerLevel >= FloorF(playerMax * 40 / 100)) {
			return ENR_SkillSuperior;
		} else if (playerLevel >= FloorF(playerMax * 20 / 100)) {
			return ENR_SkillEnhanced;
		} else {
			return ENR_SkillBasic;
		}
	}
	public function GetMaxHealthPercForFinisher() : float {
		// TODO!
		return 0.1f;
	}
	// [0 .. chance] -> finisher available
	public function GetChancePercForFinisher() : float {
		// TODO?
		var chance : float = theGame.params.FINISHER_ON_DEATH_CHANCE;

		return chance;
	}
	public function UpdateFistsLevel(id: SItemUniqueId) {
		var playerLevel, levelDiff : int;
		var inv : CInventoryComponent;
		var i : int;

		NR_Notify("GetSkillLevel = " + GetSkillLevel());
		playerLevel = GetWitcherPlayer().GetLevel();
		inv = thePlayer.GetInventory();
		// vanilla logic from 'GenerateItemLevel'
		//AddItemCraftedAbility(id, 'autogen_steel_base' );
		//AddItemCraftedAbility(id, 'autogen_silver_base' ); 
		//AddItemCraftedAbility(id, 'nr_autogen_elemental_base' ); 
		// ^ NR magic fists _Stats

		// STEEL & SILVER & ELEMENTAL
		for( i = 0; i < playerLevel; i += 1 ) 
		{
			if ( FactsQuerySum("NewGamePlus") > 0 || FactsQuerySum("StandAloneEP1") > 0) {
				inv.AddItemCraftedAbility(id, 'autogen_fixed_steel_dmg', true );
				inv.AddItemCraftedAbility(id, 'autogen_fixed_silver_dmg', true );
				inv.AddItemCraftedAbility(id, 'nr_autogen_fixed_elemental_dmg', true );
			}
			else {
				//inv.AddItemCraftedAbility(id, 'autogen_steel_dmg', true ); 
				inv.AddItemCraftedAbility(id, 'autogen_silver_dmg', true );
				//inv.AddItemCraftedAbility(id, 'nr_autogen_fixed_elemental_dmg', true );
			}
		}

		// NGP
		if (FactsQuerySum("NewGamePlus") > 0)
		{
			levelDiff = theGame.params.NewGamePlusLevelDifference();
			for( i = 0; i < levelDiff; i += 1 ) 
			{
				inv.AddItemCraftedAbility(id, 'nr_autogen_fixed_elemental_dmg', true );
				inv.AddItemCraftedAbility(id, 'autogen_fixed_steel_dmg', true );
				inv.AddItemCraftedAbility(id, 'autogen_fixed_silver_dmg', true ); 
			}
			inv.SetItemModifierInt(id, 'NGPItemAdjusted', 1);
		}

		// BONUS GIFT
		if (GetSkillLevel() >= ENR_SkillSuperior) {
			inv.AddItemCraftedAbility(id, theGame.params.GetRandomMasterworkWeaponAbility(), true);
		}
	}
}
state MagicLoop in NR_MagicManager {
	var mAction 		: NR_MagicAction;
	var cachedActions 	: array<NR_MagicAction>;

	event OnEnterState( prevStateName : name )
	{
		MainLoop();
	}
	event OnLeaveState( nextStateName : name )
	{
	}
	latent function PerformMagicAction() {
		if (mAction) {
			mAction.onPerform();
		}
	}
	latent function BreakMagicAction() {
		if (mAction) {
			mAction.BreakAction();
		}
	}
	latent function PrepareMagicAction(animName : String) {
		var type : ENR_MagicAction;

		cachedActions.PushBack(mAction);
		mAction = NULL;

		parent.aName = animName;
		type = parent.GetActionType();
		switch(type) {
			case ENR_Slash:
				mAction = new NR_MagicSlash in thePlayer;
				((NR_MagicSlash)mAction).SetSwingData(parent.aData.swingType, parent.aData.swingDir);
				break;
			case ENR_Lightning:
				mAction = new NR_MagicLightning in thePlayer;
				break;
			case ENR_Projectile:
			case ENR_ProjectileWithPrepare:
				mAction = new NR_MagicProjectileWithPrepare in thePlayer;
				break;
			case ENR_Rock:
				mAction = new NR_MagicRock in thePlayer;
				break;
			case ENR_BombExplosion:
				mAction = new NR_MagicBomb in thePlayer;
				break;
			case ENR_RipApart:
				mAction = new NR_MagicRipApart in thePlayer;
				break;
			case ENR_CounterPush:
				mAction = new NR_MagicCounterPush in thePlayer;
				break;
			case ENR_Teleport:
				mAction = new NR_MagicTeleport in thePlayer;
				((NR_MagicTeleport)mAction).SetTeleportPos(parent.aTeleportPos);
				break;
			case ENR_SpecialControl:
				//mAction = new NR_MagicSpecialMeteor in thePlayer;
				break;
			case ENR_SpecialGolem:
				mAction = new NR_MagicSpecialGolem in thePlayer;
				break;
			case ENR_SpecialMeteor:
				mAction = new NR_MagicSpecialMeteor in thePlayer;
				break;
			case ENR_SpecialTornado:
				mAction = new NR_MagicSpecialTornado in thePlayer;
				break;
			case ENR_SpecialSphere:
				mAction = new NR_MagicSpecialSphere in thePlayer;
				break;
			default:
				NRE("Unknown attack type: " + type);
				break;
		}

		if (!mAction) {
			NRE("No valid mAction created.");
			return;
		}
		mAction.map = parent.sMap;
		mAction.onPrepare();
	}
	entry function MainLoop() {
		while(true) {
			while (parent.aEventsStack.Size() > 0) {
				NRD("MAIN LOOP: anim = " + NameToString(parent.aEventsStack[0].animName) + ", event = " + parent.aEventsStack[0].eventName + ", time: " + EngineTimeToFloat(theGame.GetEngineTime()));
				switch (parent.aEventsStack[0].eventName) {
					case 'Spawn':
					case 'Prepare':
					case 'PrepareTeleport':
						PrepareMagicAction( NameToString(parent.aEventsStack[0].animName) );
						break;
					case 'Shoot':
					case 'PerformMagicAttack':
					case 'PerformTeleport':
						PerformMagicAction();
						break;
					case 'BreakMagicAttack':
						BreakMagicAction();
						break;
					default:
						NR_Notify("Unknown magic event! event = " + parent.aEventsStack[0].eventName + ", anim = " + parent.aEventsStack[0].animName);
						break;
				}
				// pop front - processed
				parent.aEventsStack.Erase(0);
			}
			SleepOneFrame();
		}
	}
}
// !! QuenImpulse()