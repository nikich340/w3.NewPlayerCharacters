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
	ENR_LightAbstract,	// not a real type
	ENR_Slash,
	ENR_ThrowAbstract,	// not a real type
	ENR_Lightning,
	ENR_Projectile,
	ENR_ProjectileWithPrepare,
		// heavy attack
	ENR_HeavyAbstract,	// not a real type
	ENR_Rock,	
	ENR_BombExplosion,
		// heavy other attacks
	ENR_RipApart,
	ENR_CounterPush,
		// special attack
	ENR_SpecialAbstract,	// not a real type
	ENR_SpecialControl, 	// axii - временный контроль
	ENR_SpecialGolem,   	// yrden - призыв случайного голема
	ENR_SpecialMeteor,   	// igni - метеорит
	ENR_SpecialTornado, 	// aard - торнадо
	ENR_SpecialSphere, 		// quen - защитная сфера
		// special attack (alternative)
	ENR_SpecialAbstractAlt,		// not a real type
	ENR_SpecialTransform, 		// yrden long - котик
	ENR_SpecialMeteorFall, 		// igni long - дождь метеоров
	ENR_SpecialLightningFall, 	// aard long - дождь молний
	ENR_SpecialLumos, 	  		// quen long - свечка над головой + igni totus
	ENR_SpecialHeal,  			// axii long - heal?

	ENR_Teleport,   // teleport
	ENR_HandFx   	// hand fx
}
enum ENR_MagicColor {
	ENR_ColorBlack,		// 0
	ENR_ColorGrey,		// 1
	ENR_ColorWhite,		// 2
	ENR_ColorYellow,	// 3
	ENR_ColorOrange,	// 4
	ENR_ColorRed,		// 5
	ENR_ColorPink,		// 6
	ENR_ColorViolet,	// 7
	ENR_ColorBlue,		// 8
	ENR_ColorSeagreen,	// 9
	ENR_ColorGreen,		// 10
	    // reserved
	ENR_ColorSpecial1,	// 11
	ENR_ColorSpecial2,	// 12
	ENR_ColorSpecial3	// 13
}
/*
	ST_Aard, 	// 0
    ST_Yrden, 	// 1
    ST_Igni, 	// 2
    ST_Quen, 	// 3
    ST_Axii, 	// 4
    ST_None, 	// 5 == ST_Universal
*/
function ENR_MAToName(action : ENR_MagicAction) : name {
	switch (action) {
		case ENR_LightAbstract:
			return 'ENR_LightAbstract';
		case ENR_ThrowAbstract:
			return 'ENR_ThrowAbstract';
		case ENR_Slash:
			return 'ENR_Slash';
		case ENR_Lightning:
			return 'ENR_Lightning';
		case ENR_Projectile:
			return 'ENR_Projectile';
		case ENR_ProjectileWithPrepare:
			return 'ENR_ProjectileWithPrepare';
		case ENR_HeavyAbstract:
			return 'ENR_HeavyAbstract';
		case ENR_Rock:
			return 'ENR_Rock';
		case ENR_BombExplosion:
			return 'ENR_BombExplosion';
		case ENR_RipApart:
			return 'ENR_RipApart';
		case ENR_CounterPush:
			return 'ENR_CounterPush';
		case ENR_SpecialAbstract:
			return 'ENR_SpecialAbstract';
		case ENR_SpecialControl:
			return 'ENR_SpecialControl';
		case ENR_SpecialGolem:
			return 'ENR_SpecialGolem';
		case ENR_SpecialMeteor:
			return 'ENR_SpecialMeteor';
		case ENR_SpecialTornado:
			return 'ENR_SpecialTornado';
		case ENR_SpecialSphere:
			return 'ENR_SpecialSphere';
		default:
			return 'ENR_Unknown';
	}
}
function ENR_NameToMA(actionName : name) : ENR_MagicAction {
	switch (actionName) {
		case 'ENR_LightAbstract':
			return ENR_LightAbstract;
		case 'ENR_ThrowAbstract':
			return ENR_ThrowAbstract;
		case 'ENR_Slash':
			return ENR_Slash;
		case 'ENR_Lightning':
			return ENR_Lightning;
		case 'ENR_Projectile':
			return ENR_Projectile;
		case 'ENR_ProjectileWithPrepare':
			return ENR_ProjectileWithPrepare;
		case 'ENR_HeavyAbstract':
			return ENR_HeavyAbstract;
		case 'ENR_Rock':
			return ENR_Rock;
		case 'ENR_BombExplosion':
			return ENR_BombExplosion;
		case 'ENR_RipApart':
			return ENR_RipApart;
		case 'ENR_CounterPush':
			return ENR_CounterPush;
		case 'ENR_SpecialAbstract':
			return ENR_SpecialAbstract;
		case 'ENR_SpecialControl':
			return ENR_SpecialControl;
		case 'ENR_SpecialGolem':
			return ENR_SpecialGolem;
		case 'ENR_SpecialMeteor':
			return ENR_SpecialMeteor;
		case 'ENR_SpecialTornado':
			return ENR_SpecialTornado;
		case 'ENR_SpecialSphere':
			return ENR_SpecialSphere;
		default:
			return ENR_Unknown;
	}
}
function ENR_MCToName(color : ENR_MagicColor) : name {
	switch (color) {
		case ENR_ColorBlack:
			return 'ENR_ColorBlack';
		case ENR_ColorGrey:
			return 'ENR_ColorGrey';
		case ENR_ColorWhite:
			return 'ENR_ColorWhite';
		case ENR_ColorYellow:
			return 'ENR_ColorYellow';
		case ENR_ColorOrange:
			return 'ENR_ColorOrange';
		case ENR_ColorRed:
			return 'ENR_ColorRed';
		case ENR_ColorPink:
			return 'ENR_ColorPink';
		case ENR_ColorViolet:
			return 'ENR_ColorViolet';
		case ENR_ColorBlue:
			return 'ENR_ColorBlue';
		case ENR_ColorSeagreen:
			return 'ENR_ColorSeagreen';
		case ENR_ColorGreen:
			return 'ENR_ColorGreen';
		case ENR_ColorSpecial1:
			return 'ENR_ColorSpecial1';
		case ENR_ColorSpecial2:
			return 'ENR_ColorSpecial2';
		case ENR_ColorSpecial3:
			return 'ENR_ColorSpecial3';
		default:
			return 'ENR_ColorWhite';
	}
}
function ENR_NameToMC(colorName : name) : ENR_MagicColor {
	switch (colorName) {
		case 'ENR_ColorBlack':
			return ENR_ColorBlack;
		case 'ENR_ColorGrey':
			return ENR_ColorGrey;
		case 'ENR_ColorWhite':
			return ENR_ColorWhite;
		case 'ENR_ColorYellow':
			return ENR_ColorYellow;
		case 'ENR_ColorOrange':
			return ENR_ColorOrange;
		case 'ENR_ColorRed':
			return ENR_ColorRed;
		case 'ENR_ColorPink':
			return ENR_ColorPink;
		case 'ENR_ColorViolet':
			return ENR_ColorViolet;
		case 'ENR_ColorBlue':
			return ENR_ColorBlue;
		case 'ENR_ColorSeagreen':
			return ENR_ColorSeagreen;
		case 'ENR_ColorGreen':
			return ENR_ColorGreen;
		case 'ENR_ColorSpecial1':
			return ENR_ColorSpecial1;
		case 'ENR_ColorSpecial2':
			return ENR_ColorSpecial2;
		case 'ENR_ColorSpecial3':
			return ENR_ColorSpecial3;
		default:
			return ENR_ColorWhite;
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
	protected var mLumosAction 	: NR_MagicSpecialLumos;
	protected var aActionType 	: ENR_MagicAction;
	public var aEventsStack 	: array<SNR_MagicEvent>;
	public var aData 			: CPreAttackEventData;
	protected var cachedActions : array<NR_MagicAction>;
	protected var cursedActions : array<NR_MagicAction>;
	protected var willeyVictim 	: CActor;
	protected var eqSign 	: ESignType;

	public var aIsAlternate 	: Bool; // remove?
	public var aTeleportPos		: Vector;
	public var aSelectorLight, aSelectorHeavy : NR_MagicAspectSelector;
	
	protected var aHandEffect 	: name;
	protected var i            	: int;
	protected var aName 			: String;

	default ST_Universal 	= 5; // EnumGetMax(ESignType); 
	default aHandEffect 	= '';
	default aName 			= "";
	
	public function Init(optional forceReset : bool) {
		var wasLoaded : bool;

		NR_GetPlayerManager().GetMagicDataMaps(sMap, wasLoaded);
		if (!wasLoaded || forceReset) {
			SetDefaults_StaminaCost();

			SetDefaults_LightAbstract();
			SetDefaults_LightSlash();
			SetDefaults_LightThrow();

			SetDefaults_HeavyAbstract();
			SetDefaults_HeavyRock();
			SetDefaults_HeavyBomb();

			SetDefaults_Teleport();
			SetDefaults_HandFx();
			SetDefaults_Special();
			NRD("MagicManager: Init default spell params");
		} else {
			NRD("MagicManager: Load spell params");
		}

		aSelectorLight = new NR_MagicAspectSelector in this;
		aSelectorHeavy = new NR_MagicAspectSelector in this;
		InitAspectsSelectors();
	}

	public function SetDefaults_LightAbstract() {
		sMap[ST_Universal].setI("light_slash_amount", 2);
		sMap[ST_Universal].setI("light_throw_amount", 1);
	}

	public function SetDefaults_HeavyAbstract() {
		sMap[ST_Universal].setI("heavy_rock_amount", 2);
		sMap[ST_Universal].setI("heavy_bomb_amount", 1);
	}

	public function InitAspectsSelectors() {
		aSelectorLight.Reset();
		aSelectorLight.AddAttack('AttackLightSlash', 	sMap[ST_Universal].getI("light_slash_amount", 2));
		aSelectorLight.AddAttack('AttackLightThrow', 	sMap[ST_Universal].getI("light_throw_amount", 1));

		aSelectorHeavy.Reset();
		aSelectorHeavy.AddAttack('AttackHeavyRock', 	sMap[ST_Universal].getI("heavy_rock_amount", 2));
		aSelectorHeavy.AddAttack('AttackHeavyThrow', 	sMap[ST_Universal].getI("heavy_bomb_amount", 1));
	}

	public function CorrectAspectAction(out actionType : ENR_MagicAction, out aspectName : name) {
		UpdateEquippedSign();

		switch (aspectName) {
			case 'AttackLight':
				aspectName = aSelectorLight.SelectAttack();
				break;
			case 'AttackHeavy':
				aspectName = aSelectorHeavy.SelectAttack();
				break;
			default:
				break;
		}

		switch (actionType) {
			case ENR_LightAbstract:
				if (aspectName == 'AttackLightSlash')
					actionType = ENR_Slash;
				else
					actionType = (ENR_MagicAction)sMap[eqSign].getI("type_" + ENR_MAToName(ENR_ThrowAbstract));
				break;

			case ENR_HeavyAbstract:
				if (aspectName == 'AttackHeavyRock')
					actionType = ENR_Rock;
				else
					actionType = ENR_BombExplosion;
				break;
			case ENR_SpecialAbstract:
				actionType = (ENR_MagicAction)sMap[eqSign].getI("type_" + ENR_MAToName(ENR_SpecialAbstract));
				switch (actionType) {
					case ENR_SpecialTornado:
						aspectName = 'AttackHeavyRock';
						break;
					case ENR_SpecialHeal:
						aspectName = 'AttackSpecialHeal';
						break;
					case ENR_SpecialMeteor:
						aspectName = 'AttackSpecialFireball';
						break;
					// case ENR_SpecialSphere:
					// handled in Combat
					case ENR_SpecialGolem:
						aspectName = 'AttackHeavyRock';
						break;
				}
				break;
			case ENR_SpecialAbstractAlt:
				actionType = (ENR_MagicAction)sMap[eqSign].getI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt));
				switch (actionType) {
					case ENR_SpecialLightningFall:
						aspectName = 'AttackSpecialElectricity';
						break;
					case ENR_SpecialControl:
						aspectName = 'AttackSpecialFireball';
						break;
					case ENR_SpecialMeteorFall:
						aspectName = 'AttackSpecialFireball';
						break;
					case ENR_SpecialLumos:
						aspectName = 'AttackSpecialPray';
						break;
					case ENR_SpecialTransform:
						aspectName = 'AttackSpecialTransform';
						break;
				}
				break;
		}
	}

	public function UpdateEquippedSign() {
		if (!IsInSetupScene())
			eqSign = GetWitcherPlayer().GetEquippedSign();
	}

	/* Function for scene setup - should not be called during combat! */
	public function SetParamInt(signName : name, varName : String, varValue : int) {
		var signInt : int = (int)SignNameToEnum(signName);
		NRD("SetParamInt: varName = " + varName + ", signName = " + signName + ", signInt = " + signInt);
		sMap[signInt].setI(varName, varValue);
	}
	public function SetParamFloat(signName : name, varName : String, varValue : float) {
		var signInt : int = (int)SignNameToEnum(signName);
		sMap[signInt].setF(varName, varValue);
	}
	public function SetParamString(signName : name, varName : String, varValue : String) {
		var signInt : int = (int)SignNameToEnum(signName);
		sMap[signInt].setS(varName, varValue);
	}
	public function SetParamName(signName : name, varName : String, varValue : name) {
		var signInt : int = (int)SignNameToEnum(signName);
		sMap[signInt].setN(varName, varValue);
	}

	function SetDefaults_StaminaCost() {
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

	function SetDefaults_LightSlash() {
		sMap[ST_Aard].setN("entity_" + ENR_MAToName(ENR_Slash), 'magic_attack_lightning');
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorWhite);

		sMap[ST_Axii].setN("entity_" + ENR_MAToName(ENR_Slash), 'magic_attack_lightning');
		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorSeagreen);

		sMap[ST_Igni].setN("entity_" + ENR_MAToName(ENR_Slash), 'magic_attack_fire');
		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorOrange);

		sMap[ST_Quen].setN("entity_" + ENR_MAToName(ENR_Slash), 'ep2_magic_attack_lightning');
		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorYellow);

		sMap[ST_Yrden].setN("entity_" + ENR_MAToName(ENR_Slash), 'magic_attack_arcane');
		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorViolet);
	}

	function SetDefaults_LightThrow() {
		sMap[ST_Aard].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_Lightning);
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_Lightning), ENR_ColorWhite);
		sMap[ST_Aard].setN("fx_type_" + ENR_MAToName(ENR_Lightning), 'yennefer');
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_ProjectileWithPrepare), ENR_ColorWhite);
		sMap[ST_Aard].setN("entity_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'sorceress_fireball');

		sMap[ST_Axii].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ProjectileWithPrepare);
		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_Lightning), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("fx_type_" + ENR_MAToName(ENR_Lightning), 'yennefer');
		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_ProjectileWithPrepare), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("entity_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'ice_spear');

		sMap[ST_Igni].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ProjectileWithPrepare);
		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_Lightning), ENR_ColorOrange);
		sMap[ST_Igni].setN("fx_type_" + ENR_MAToName(ENR_Lightning), 'yennefer');
		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_ProjectileWithPrepare), ENR_ColorOrange);
		sMap[ST_Igni].setN("entity_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'sorceress_fireball');

		sMap[ST_Quen].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_Lightning);
		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_Lightning), ENR_ColorYellow);
		sMap[ST_Quen].setN("fx_type_" + ENR_MAToName(ENR_Lightning), 'lynx');
		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_ProjectileWithPrepare), ENR_ColorYellow);
		sMap[ST_Quen].setN("entity_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'arcane_projectile');

		sMap[ST_Yrden].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ProjectileWithPrepare);
		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_Lightning), ENR_ColorViolet);
		sMap[ST_Yrden].setN("fx_type_" + ENR_MAToName(ENR_Lightning), 'lynx');
		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_ProjectileWithPrepare), ENR_ColorViolet);
		sMap[ST_Yrden].setN("entity_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'arcane_projectile');
	}

	function SetDefaults_HeavyRock() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorWhite);
		sMap[ST_Aard].setN("entity_" + ENR_MAToName(ENR_Rock), 'sorceress_stone_proj');
		
		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("entity_" + ENR_MAToName(ENR_Rock), 'sorceress_wood_proj');

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorOrange);
		sMap[ST_Igni].setN("entity_" + ENR_MAToName(ENR_Rock), 'ep2_sorceress_stone_proj');

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorYellow);
		sMap[ST_Quen].setN("entity_" + ENR_MAToName(ENR_Rock), 'ep2_sorceress_stone_proj');

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorViolet);
		sMap[ST_Yrden].setN("entity_" + ENR_MAToName(ENR_Rock), 'sorceress_wood_proj');
	}

	function SetDefaults_HeavyBomb() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorWhite);

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorSeagreen);

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorOrange);

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorYellow);

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorViolet);
	}

	function SetDefaults_Special() {
		var i : int;
		
		sMap[ST_Aard].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialTornado);
		sMap[ST_Axii].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialHeal);
		sMap[ST_Igni].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialMeteor);
		sMap[ST_Quen].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialSphere);
		sMap[ST_Yrden].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialGolem);

		for (i = 0; i <= ST_Universal; i += 1) {
			// TORNADO
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialTornado), ENR_ColorGrey);
			// ? sMap[i].setN("entity_" + ENR_MAToName(ENR_SpecialTornado), 'nr_tornado');

			// HEAL - no visual customization

			// METEOR
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialMeteor), ENR_ColorOrange);
			sMap[i].setN("entity_" + ENR_MAToName(ENR_SpecialMeteor), 'ciri_meteor'); // eredin_meteorite

			// SPHERE
			// TODO!!!			

			// GOLEM
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialGolem), ENR_ColorViolet);
			sMap[i].setS("entity1_" + ENR_MAToName(ENR_SpecialGolem), "characters\npc_entities\monsters\golem_lvl3.w2ent");
			sMap[i].setS("entity2_" + ENR_MAToName(ENR_SpecialGolem), "characters\npc_entities\monsters\elemental_dao_lvl2.w2ent");
		}
	}

	function SetDefaults_SpecialAlt() {
		var i : int;

		sMap[ST_Aard].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialLightningFall);
		sMap[ST_Axii].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialControl);
		sMap[ST_Igni].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialMeteorFall);
		sMap[ST_Quen].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialLumos);
		sMap[ST_Yrden].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialTransform);

		for (i = 0; i <= ST_Universal; i += 1) {
			// LIGHTNING FALL
			// TODO!

			// CONTROL - no visual customization

			// METEOR FALL
			// TODO!

			// LUMOS
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialLumos), ENR_ColorWhite);

			// TRANSFORM
			// TODO!
		}
	}

	function SetDefaults_HandFx() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorWhite);
		sMap[ST_Aard].setN("fx_type_" + ENR_MAToName(ENR_HandFx), 'yennefer');

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("fx_type_" + ENR_MAToName(ENR_HandFx), 'keira');

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorOrange);
		sMap[ST_Igni].setN("fx_type_" + ENR_MAToName(ENR_HandFx), 'triss');

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorYellow);
		sMap[ST_Quen].setN("fx_type_" + ENR_MAToName(ENR_HandFx), 'lynx');

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorViolet);
		sMap[ST_Yrden].setN("fx_type_" + ENR_MAToName(ENR_HandFx), 'philippa');
	}

	function SetDefaults_Teleport() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorWhite);
		sMap[ST_Aard].setN("fx_type_" + ENR_MAToName(ENR_Teleport), 'yennefer');

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("fx_type_" + ENR_MAToName(ENR_Teleport), 'yennefer');

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorOrange);
		sMap[ST_Igni].setN("fx_type_" + ENR_MAToName(ENR_Teleport), 'triss');

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorYellow);
		sMap[ST_Quen].setN("fx_type_" + ENR_MAToName(ENR_Teleport), 'triss');

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorViolet);
		sMap[ST_Yrden].setN("fx_type_" + ENR_MAToName(ENR_Teleport), 'triss');
	}

	public function IsInSetupScene() : bool {
		return sMap[ST_Universal].getI("setup_scene_active", 0);
	}

	public function SetIsInSetupScene(value : bool) {
		if (value) {
			sMap[ST_Universal].setI("setup_scene_active", 1);
			FindWilleyInScene();
		}
		else {
			sMap[ST_Universal].setI("setup_scene_active", 0);
		}
	}

	protected function FindWilleyInScene() : bool {
		var 	entities : array<CGameplayEntity>;
		var  		actor : CActor;
		var  		i 	: int;

		FindGameplayEntitiesInRange(entities, thePlayer, 5.f, 500);
		for (i = 0; i < entities.Size(); i += 1) {
			actor = (CActor)entities[i];
			NRD("FindWilleyInScene: actor: " + entities[i].GetReadableName() + ", " + actor.IsInNonGameplayCutscene() + ", " + actor.GetVoicetag());
			if (actor && actor.IsAlive() && actor.IsInNonGameplayCutscene() && actor.GetVoicetag() == 'CYPRIAN WILLEY') {
				willeyVictim = actor;
				return true;
			}
		}
		NRE("FindWilleyInScene: Willey actor not found!");
		return false;
	}

	/* THE ONLY manual way to enable/disable/change color for lumos - don't manipulate effect outside! */
	public function LumosFX(enable : bool, optional reload : bool) {
		var      i : int;

		if (!enable || reload) {
			if (mLumosAction) {
				mLumosAction.BreakActionSync();
			}
		}

		if (enable) {
			if (!mLumosAction) {
				mLumosAction = new NR_MagicSpecialLumos in this;
			}
			mLumosAction.map 			= sMap;
			mLumosAction.magicSkill 	= GetSkillLevel();

			//mLumosAction.OnInit();
			mLumosAction.OnPerformSync();
		}
	}

	public function HandFX(enable: Bool, optional onlyIfActive: Bool) {
		var newHandEffect 	: name;

		UpdateEquippedSign();
		if (aHandEffect == '' && onlyIfActive) {
			return;
		}

		newHandEffect = HandFxName();

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
	// SetSceneSign first if needed
	public function SetActionType(type : ENR_MagicAction) {
		if (aActionType == ENR_ThrowAbstract) {
			aActionType = (ENR_MagicAction)sMap[eqSign].getI("throw_type", (int)ENR_Lightning);
		}
		// TODO: Heavy, Special
		aActionType = type;
	}
	// manually update eqSign without changing real equipped sign
	public function SetSceneSign(sign : ESignType) {
		eqSign = sign;
		HandFX(true, true);
	}
	public function GetEqSign() : ESignType {
		return eqSign;
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

	public function GetActionColor() : ENR_MagicColor {
		return sMap[eqSign].getI("color_" + ENR_MAToName(GetActionType()), ENR_ColorWhite);
	}

	public function GetHitFXName(color : ENR_MagicColor) : name {
		// ORANGE, RED -> 'fire_hit' (orange)
		// YELLOW -> 'hit_electric_quen' (yellow)
		// PINK, VIOLET -> 'yrden_shock' (violet)
		// OTHER -> 'hit_electric' (white-blue)
		switch (color) {
			case ENR_ColorYellow:
				return 'hit_electric_quen';
			case ENR_ColorOrange:
			case ENR_ColorRed:
				return 'fire_hit';
			case ENR_ColorPink:
			case ENR_ColorViolet:
				return 'yrden_shock';
			case ENR_ColorWhite:
			case ENR_ColorBlue:
			default:
				return 'hit_electric';
		}
	}

	function OnPreAttackEvent(animName : name, out data : CPreAttackEventData)
	{
		var hitFXName : name;

		NRD("MagicManager::OnPreAttackEvent -> anim = " + aName + ", swingType = " + data.swingType + ", swingDir = " + data.swingDir);
		UpdateEquippedSign();

		hitFXName = GetHitFXName( GetActionColor() );
		data.hitFX 				= hitFXName;
		data.hitParriedFX 		= hitFXName;
		data.hitBackFX 			= hitFXName;
		data.hitBackParriedFX 	= hitFXName;

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
	public function HasStaminaForAction(actionName : name, optional dontInformGUI : bool) : bool {
		var costPerc 			: float;
		var delay 				: float;
		var playerStaminaPerc 	: float = thePlayer.GetStaminaPercents(); // [0.0 - 1.0]

		GetStaminaValuesForAction(actionName, costPerc, delay);
		if (playerStaminaPerc < costPerc && !dontInformGUI) {
			thePlayer.SetShowToLowStaminaIndication( thePlayer.GetStatMax(BCS_Stamina) * costPerc );
		}
		return playerStaminaPerc >= costPerc;
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
		/*if (GetSkillLevel() >= ENR_SkillSuperior) {
			inv.AddItemCraftedAbility(id, theGame.params.GetRandomMasterworkWeaponAbility(), true);
		}*/
	}

	public function HandFxName() : name {
		var color 	: ENR_MagicColor = sMap[eqSign].getI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorWhite);
		var fx_type : name			 = sMap[eqSign].getN("fx_type_" + ENR_MAToName(ENR_HandFx), 'keira');

		switch (color) {
			//case ENR_ColorBlack:
			//case ENR_ColorGrey:
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_yellow';
					case 'triss':
						return 'hand_fx_triss_yellow';
					case 'lynx':
						return 'hand_fx_lynx_yellow';
					case 'philippa':
						return 'hand_fx_philippa_yellow';
					case 'keira':
					default:
						return 'hand_fx_keira_yellow';
				}
			case ENR_ColorOrange:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_orange';
					case 'triss':
						return 'hand_fx_triss_orange';
					case 'lynx':
						return 'hand_fx_lynx_orange';
					case 'philippa':
						return 'hand_fx_philippa_orange';
					case 'keira':
					default:
						return 'hand_fx_keira_orange';
				}
			case ENR_ColorRed:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_red';
					case 'triss':
						return 'hand_fx_triss_red';
					case 'lynx':
						return 'hand_fx_lynx_red';
					case 'philippa':
						return 'hand_fx_philippa_red';
					case 'keira':
					default:
						return 'hand_fx_keira_red';
				}
			case ENR_ColorPink:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_pink';
					case 'triss':
						return 'hand_fx_triss_pink';
					case 'lynx':
						return 'hand_fx_lynx_pink';
					case 'philippa':
						return 'hand_fx_philippa_pink';
					case 'keira':
					default:
						return 'hand_fx_keira_pink';
				}
			case ENR_ColorViolet:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_violet';
					case 'triss':
						return 'hand_fx_triss_violet';
					case 'lynx':
						return 'hand_fx_lynx_violet';
					case 'philippa':
						return 'hand_fx_philippa_violet';
					case 'keira':
					default:
						return 'hand_fx_keira_violet';
				}
			case ENR_ColorBlue:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_blue';
					case 'triss':
						return 'hand_fx_triss_blue';
					case 'lynx':
						return 'hand_fx_lynx_blue';
					case 'philippa':
						return 'hand_fx_philippa_blue';
					case 'keira':
					default:
						return 'hand_fx_keira_blue';
				}
			case ENR_ColorSeagreen:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_seagreen';
					case 'triss':
						return 'hand_fx_triss_seagreen';
					case 'lynx':
						return 'hand_fx_lynx_seagreen';
					case 'philippa':
						return 'hand_fx_philippa_seagreen';
					case 'keira':
					default:
						return 'hand_fx_keira_seagreen';
				}
			case ENR_ColorGreen:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_green';
					case 'triss':
						return 'hand_fx_triss_green';
					case 'lynx':
						return 'hand_fx_lynx_green';
					case 'philippa':
						return 'hand_fx_philippa_green';
					case 'keira':
					default:
						return 'hand_fx_keira_green';
				}
			// case ENR_ColorSpecial1:
			// case ENR_ColorSpecial2:
			// case ENR_ColorSpecial3:
			default:
			case ENR_ColorWhite:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_white';
					case 'triss':
						return 'hand_fx_triss_white';
					case 'lynx':
						return 'hand_fx_lynx_white';
					case 'philippa':
						return 'hand_fx_philippa_white';
					case 'keira':
					default:
						return 'hand_fx_keira_white';
				}
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
			case ENR_SpecialLumos:
				if (!parent.mLumosAction)
					parent.mLumosAction = new NR_MagicSpecialLumos in this;
				mAction = parent.mLumosAction;
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
			case ENR_SpecialHeal:
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
		if (parent.IsInSetupScene()) {
			mAction.target 	= parent.willeyVictim;
		}
		mAction.sign 		= parent.eqSign;
		mAction.map 		= parent.sMap;
		mAction.m_fxNameHit = parent.GetHitFXName( parent.GetActionColor() );;
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
			} else {
				if ( thePlayer.GetCurrentStateName() == 'Exploration' && theInput.IsActionJustPressed( 'SwordSheathe' ) ) {
					PerformExplorationTeleport();
				} else if ( thePlayer.GetCurrentStateName() == 'Swimming' && theInput.IsActionJustPressed( 'Ignite' ) ) {
					PerformDivingAttack();
				}
			}
		}
	}

	latent function PerformExplorationTeleport() {
		var startTime : float;

		startTime = theGame.GetEngineTimeAsSeconds();
		while (theGame.GetEngineTimeAsSeconds() - startTime < 0.2f) {
			SleepOneFrame();
			if ( !theInput.IsActionPressed( 'SwordSheathe' ) )
				break;
		}
		NRE("State = " + thePlayer.GetCurrentStateName());
		if ( theInput.GetLastActivationTime( 'SwordSheathe' ) < 0.2f ) {
			NRD("PerformExplorationTeleport: EBAT_Dodge");
			NR_GetReplacerSorceress().GotoCombatStateWithDodge( EBAT_Dodge );
		} else {
			NRD("PerformExplorationTeleport: EBAT_Roll");
			NR_GetReplacerSorceress().GotoCombatStateWithDodge( EBAT_Roll );
		}
	}

	latent function PerformDivingAttack() {
		NRE("PerformDivingAttack!");
	}
	// horse: thePlayer.GetUsedHorseComponent().GetUserCombatManager()
	//                   W3HorseComponent         
}
// !! QuenImpulse()