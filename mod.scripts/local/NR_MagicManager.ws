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
	ENR_LightAbstract,
	ENR_Slash,
	ENR_Lightning,
	ENR_Projectile,
	ENR_ProjectileWithPrepare,
		// heavy attack
	ENR_HeavyAbstract,
	ENR_Rock,	
	ENR_BombExplosion,
	ENR_RipApart,
	ENR_CounterPush,
		// special attack
	ENR_SpecialControl, // axii - временный контроль
	ENR_SpecialGolem,   // yrden - призыв случайного голема
	ENR_SpecialMeteor,   // igni - метеорит
	ENR_SpecialTornado, // aard - торнадо
	ENR_SpecialSphere, // quen - защитная сфера
		// special attack (alternative)
	ENR_SpecialTransform, 	// yrden long - котик
	ENR_SpecialMeteorFall, 	// igni long - дождь метеоров
	ENR_SpecialLightningFall, 	// aard long - дождь молний
	ENR_SpecialLumos, 	  	// quen long - свечка над головой + igni totus
	ENR_SpecialAxiiAlternate,  // axii long - ?

	ENR_Teleport   // teleport
}
function ENR_MagicActionToString(action : ENR_MagicAction) : String {
	switch (action) {
		case ENR_Slash:
			return "ENR_Slash";
		case ENR_Lightning:
			return "ENR_Lightning";
		case ENR_Projectile:
			return "ENR_Projectile";
		case ENR_ProjectileWithPrepare:
			return "ENR_ProjectileWithPrepare";
		case ENR_Rock:
			return "ENR_Rock";
		case ENR_BombExplosion:
			return "ENR_BombExplosion";
		case ENR_RipApart:
			return "ENR_RipApart";
		case ENR_CounterPush:
			return "ENR_CounterPush";
		case ENR_SpecialControl:
			return "ENR_SpecialControl";
		case ENR_SpecialGolem:
			return "ENR_SpecialGolem";
		case ENR_SpecialMeteor:
			return "ENR_SpecialMeteor";
		case ENR_SpecialTornado:
			return "ENR_SpecialTornado";
		case ENR_SpecialSphere:
			return "ENR_SpecialSphere";
		default:
			return "ENR_Unknown";
	}
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
	protected var aActionType 		: ENR_MagicAction;
	public var aEventsStack 	: array<SNR_MagicEvent>;
	public var aData 			: CPreAttackEventData;
	protected var cachedActions 	: array<NR_MagicAction>;
	protected var cursedActions 	: array<NR_MagicAction>;

	public var aIsAlternate 	: Bool;
	public var aTeleportPos		: Vector;
	public var aSelectorLight, aSelectorHeavy : NR_MagicAspectSelector;
	
	protected var aHandEffect 	: name;
	protected var i            	: int;
	protected var aName 			: String;

	default ST_Universal = 5; // EnumGetMax(ESignType); 
	default aHandEffect = '';
	default aName = "";
	
	public function InitDefaults() {
		sMap.Resize(6);
		for (i = 0; i <= ST_Universal; i += 1) {
			sMap[i] = new NR_Map in thePlayer;
		}
		aSelectorLight = new NR_MagicAspectSelector in this;
		aSelectorHeavy = new NR_MagicAspectSelector in this;
		SetStaminaCost();
		SetAspectsSelectionDef();
		SetSlashAttacksDef();
		SetThrowAttacksDef();
		SetRockAttacksDef();
		SetBombAttacksDef();
		SetSpecialAttacksDef();
		SetHandFXDef();
		SetTeleportFXDef();
		NRD("MagicManager: InitDefaults");
	}
	public function SetAspectsSelectionDef() {
		aSelectorLight.Reset();
		aSelectorLight.AddAttack('AttackLightSlash', 	2);
		aSelectorLight.AddAttack('AttackLightThrow', 	1);

		aSelectorHeavy.Reset();
		aSelectorHeavy.AddAttack('AttackHeavyRock', 	2);
		aSelectorHeavy.AddAttack('AttackHeavyThrow', 	1);
	}
	public function CorrectAspectName(aspectName : name) : name {
		switch (aspectName) {
			case 'AttackLight':
				return aSelectorLight.SelectAttack();
				break;
			case 'AttackHeavy':
				return aSelectorHeavy.SelectAttack();
				break;
			default:
				return aspectName;
				break;
		}
	}
	public function CorrectActionType(actionType : ENR_MagicAction, aspectName : name) : ENR_MagicAction {
		var sign : ESignType = GetWitcherPlayer().GetEquippedSign();

		if (actionType == ENR_LightAbstract) {
			if (aspectName == 'AttackLightSlash')
				actionType = ENR_Slash;
			else
				actionType = sMap[sign].getI("throw_attack_type", (int)ENR_Lightning);
		} else if (actionType == ENR_HeavyAbstract) {
			if (aspectName == 'AttackHeavyRock')
				actionType = ENR_Rock;
			else
				actionType = ENR_BombExplosion;
		}
		return actionType;
	}
	function SetStaminaCost() {
		// cost_<AttackType> in [0, 1] of total stamina
		// delay_<AttackType> in milliseconds
		sMap[ST_Universal].setF("cost_TeleportFar", 0.2f);
		sMap[ST_Universal].setF("delay_TeleportFar", 50.f);

		sMap[ST_Universal].setF("cost_TeleportClose", 0.1f);
		sMap[ST_Universal].setF("delay_TeleportClose", 0.5f);

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

		//sMap[ST_Aard].setN("meteor_entity", 'eredin_meteorite');
		//sMap[ST_Yrden].setN("meteor_entity", 'meteor_strong');
		sMap[ST_Igni].setN("meteor_entity", 'ciri_meteor');

		sMap[ST_Yrden].setN("golem_fx_entity", 'nr_fx_golem1');
		sMap[ST_Yrden].setN("golem_entity1", 'nr_golem3');
		sMap[ST_Yrden].setN("golem_entity2", 'nr_golem1');
		sMap[ST_Yrden].setN("golem_entity3", 'nr_golem2');
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
	public function SetActionType(type : ENR_MagicAction) {
		aActionType = type;
	}
	public function GetActionType() : ENR_MagicAction {
		return aActionType;
	}
	public function DEV_AddActionCustom( action : NR_MagicAction, optional isCursed : bool ) {
		if (!action) {
			return;
		}
		action.map 			= sMap;
		action.magicSkill 	= GetSkillLevel();
		if (isCursed) {
			cursedActions.PushBack(action);
		} else {
			cachedActions.PushBack(action);
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
		return 0.1f; // [0.0 - 1.0]
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

	event OnEnterState( prevStateName : name )
	{
		MainLoop();
	}
	event OnLeaveState( nextStateName : name )
	{
	}
	/* Creates instance of new magic action, when 'InitAction' event from anim received */
	latent function InitMagicAction(animName : String) {
		var type : ENR_MagicAction;
		var    i : int;

		mAction = NULL;
		parent.aName = animName;
		type = parent.GetActionType();
		NRD("InitMagicAction: type = " + type);
		switch(type) {
			case ENR_Slash:
				mAction = new NR_MagicSlash in this;
				break;
			case ENR_Lightning:
				mAction = new NR_MagicLightning in this;
				break;
			case ENR_Projectile:
			case ENR_ProjectileWithPrepare:
				mAction = new NR_MagicProjectileWithPrepare in this;
				break;
			case ENR_Rock:
				mAction = new NR_MagicRock in this;
				break;
			case ENR_BombExplosion:
				mAction = new NR_MagicBomb in this;
				break;
			case ENR_RipApart:
				mAction = new NR_MagicRipApart in this;
				break;
			case ENR_CounterPush:
				mAction = new NR_MagicCounterPush in this;
				break;
			case ENR_Teleport:
				mAction = new NR_MagicTeleport in this;
				break;
			case ENR_SpecialControl:
				mAction = new NR_MagicSpecialControl in this;
				break;
			case ENR_SpecialGolem:
				mAction = new NR_MagicSpecialGolem in this;
				break;
			case ENR_SpecialMeteor:
				mAction = new NR_MagicSpecialMeteor in this;
				break;
			case ENR_SpecialTornado:
				mAction = new NR_MagicSpecialTornado in this;
				break;
			case ENR_SpecialSphere:
				mAction = new NR_MagicSpecialSphere in this;
				break;
			case ENR_SpecialTransform:
				mAction = new NR_MagicSpecialTransform in this;
				break;
			case ENR_SpecialMeteorFall:
			case ENR_SpecialLightningFall:
			case ENR_SpecialLumos:
			case ENR_SpecialAxiiAlternate:
				NRE("Not implemented attack type: " + type);
				break;
			default:
				NRE("Unknown attack type: " + type);
				break;
		}

		if (!mAction) {
			NRE("No valid mAction created. animName = " + animName);
			return;
		}
		mAction.map 		= parent.sMap;
		mAction.magicSkill 	= parent.GetSkillLevel();
		mAction.OnInit();

		// protect new action from deleting by RAM cleaner
		parent.cachedActions.PushBack( mAction );
	}
	latent function PrepareMagicAction() {
		if (mAction) {
			NRD("PrepareMagicAction: type = " + mAction.actionType);
			if ( mAction.actionType == ENR_Slash ) {
				((NR_MagicSlash)mAction).SetSwingData(parent.aData.swingType, parent.aData.swingDir);
			} else if ( mAction.actionType == ENR_Teleport ) {
				((NR_MagicTeleport)mAction).SetTeleportPos(parent.aTeleportPos);
			}
			mAction.OnPrepare();
		} else {
			NRE("MM: PrepareMagicAction: NULL mAction!");
		}
	}
	latent function PerformMagicAction() {
		var sameActions 	: array<NR_MagicSpecialAction>;
		var maxActionCnt 	: int;
		var    i : int;

		if (mAction) {
			NRD("PerformMagicAction: type = " + mAction.actionType);
			mAction.OnPerform();
		} else {
			NRE("MM: PerformMagicAction: NULL mAction!");
		}

		NRD("check max count: " + "s_maxCount_" + mAction.actionType);

		// check if any of "cursed" finished
		for ( i = parent.cursedActions.Size() - 1; i >= 0; i -= 1 ) {
			if ( !parent.cursedActions[i].inPostState ) {
				parent.cursedActions.Erase( i );
			}
		}
		// check if any of "cached" stopped or finished
		for ( i = parent.cachedActions.Size() - 1; i >= 0; i -= 1 ) {
			if ( !parent.cachedActions[i].inPostState ) {
				parent.cachedActions.Erase( i );
			}
			else if ( parent.cachedActions[i].isCursed ) 
			{
				parent.cursedActions.PushBack( parent.cachedActions[i] );
				parent.cachedActions.Erase( i );
			}
			else if ( parent.cachedActions[i].actionType == mAction.actionType 
					&& ((NR_MagicSpecialAction)parent.cachedActions[i]) && parent.cachedActions[i] != mAction )
			{
				// adding special actions with the same type, excluding mAction
				sameActions.PushBack( (NR_MagicSpecialAction)parent.cachedActions[i] );
			}
		}

		// check if new action is special and stop old ones if limit is exceed
		maxActionCnt = parent.sMap[parent.ST_Universal].getI("s_" + mAction.actionType + "_maxCount", 1);
		while (sameActions.Size() + 1 > maxActionCnt) {
			NRD("Stopping special action: maxActionCnt = " + maxActionCnt + ", sameActions.Size() = " + sameActions.Size());
			// from front - older actions
			sameActions[0].StopAction();
			sameActions.Erase( 0 );
		}
	}
	latent function BreakMagicAction() {
		if (mAction) {
			mAction.BreakAction();
		} else {
			NRE("MM: BreakMagicAction: NULL mAction!");
		}
	}
	
	entry function MainLoop() {
		while(true) {
			SleepOneFrame();
			if (parent.aEventsStack.Size() > 0) {
				NRD("MAIN LOOP: anim = " + NameToString(parent.aEventsStack[0].animName) + ", event = " + parent.aEventsStack[0].eventName + ", time: " + EngineTimeToFloat(theGame.GetEngineTime()));
				switch (parent.aEventsStack[0].eventName) {
					case 'InitAction':
						InitMagicAction( NameToString(parent.aEventsStack[0].animName) );
						break;
					case 'Spawn':
					case 'Prepare':
					case 'PrepareTeleport':
						PrepareMagicAction();
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
		}
	}
}
// !! QuenImpulse()