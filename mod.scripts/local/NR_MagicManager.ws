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
	ENR_SkillNovice, 		// 1
	ENR_SkillApprentice, 	// 2
	ENR_SkillExperienced,	// 3
	ENR_SkillMistress,		// 4
	ENR_SkillArchMistress	// 5
}
enum ENR_MagicElement {
	ENR_ElementUnknown, // 0
	ENR_ElementAir, 	// 1
	ENR_ElementWater, 	// 2
	ENR_ElementEarth,	// 3
	ENR_ElementFire,	// 4
	ENR_ElementMixed	// 5
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
	ENR_HandFx,   	// hand fx
	ENR_FastTravelTeleport
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
		case ENR_SpecialAbstractAlt:
			return 'ENR_SpecialAbstractAlt';
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
		case ENR_Teleport:
			return 'ENR_Teleport';
		case ENR_HandFx:
			return 'ENR_HandFx';
		case ENR_FastTravelTeleport:
			return 'ENR_FastTravelTeleport';
		default:
			NR_Notify("ENR_NameToMA: action = " + action);
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
		case 'ENR_SpecialAbstractAlt':
			return ENR_SpecialAbstractAlt;
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
		case 'ENR_Teleport':
			return ENR_Teleport;
		case 'ENR_HandFx':
			return ENR_HandFx;
		case 'ENR_FastTravelTeleport':
			return ENR_FastTravelTeleport;
		default:
			NR_Notify("ENR_NameToMA: name = " + actionName);
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
	protected var cachedActions : array<NR_MagicAction>;
	protected var cursedActions : array<NR_MagicAction>;
	protected var willeyVictim 	: CActor;
	protected var eqSign 		: ESignType;
	protected var m_entitiesRipCheck : array<CEntity>;

	public var aEventsStack 	: array<SNR_MagicEvent>;
	public var aData 			: CPreAttackEventData;
	public var aTargetPinTag 	: name;
	public var aTargetAreaId 	: EAreaName;
	public var aCurrentAreaId 	: EAreaName;
	public var aIsAlternate 	: Bool; // remove?
	public var aTeleportPos		: Vector;
	public var aSelectorLight, aSelectorHeavy : NR_MagicAspectSelector;
	
	protected var aHandEffect 	: name;
	protected var i            	: int;
	protected var aName 		: String;

	default ST_Universal 	= 5; // EnumGetMax(ESignType); 
	default aHandEffect 	= '';
	default aName 			= "";
	
	public function Init(optional forceReset : bool) {
		var wasLoaded : bool;

		NR_GetPlayerManager().GetMagicDataMaps(sMap, wasLoaded);

		SetDefaults_StaminaCost(); // TOREMOVE!
		if (!wasLoaded || forceReset) {
			SetDefaults_StaminaCost();

			SetDefaults_LightAbstract();
			SetDefaults_LightSlash();
			SetDefaults_LightThrow();

			SetDefaults_HeavyAbstract();
			SetDefaults_HeavyRock();
			SetDefaults_HeavyBomb();
			SetDefaults_HeavyPush();

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
		aSelectorHeavy.AddAttack('AttackHeavyRock', 	sMap[ST_Universal].getI("heavy_rocks_amount", 2));
		aSelectorHeavy.AddAttack('AttackHeavyThrow', 	sMap[ST_Universal].getI("heavy_bomb_amount",  1));
	}

	public function CorrectAspectAction(out actionType : ENR_MagicAction, out aspectName : name) {
		UpdateEquippedSign();
		NRD("CorrectAspectAction: (before) actionType = " + ENR_MAToName(actionType) + ", aspectName = " + aspectName);

		// select aspect name for light/heavy
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

		// select action type based on aspect (light/heavy) and selected action type (heavy throw/special attacks)
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
				break;
			case ENR_SpecialAbstractAlt:
				actionType = (ENR_MagicAction)sMap[eqSign].getI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt));
				break;
		}

		// select aspect name based on final type (special attacks)
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
		NRD("CorrectAspectAction: (after) actionType = " + ENR_MAToName(actionType) + ", aspectName = " + aspectName);
	}

	public function UpdateEquippedSign() {
		if (!IsInSetupScene())
			eqSign = GetWitcherPlayer().GetEquippedSign();
	}

	/* Function for scene setup - should not be called during combat! */
	public function GetParamInt(signName : name, varName : String) : int {
		var signInt : int = (int)SignNameToEnum(signName);
		return sMap[signInt].getI(varName);
	}
	public function SetParamInt(signName : name, varName : String, varValue : int) {
		var signInt : int = (int)SignNameToEnum(signName);
		sMap[signInt].setI(varName, varValue);
	}
	public function GetParamFloat(signName : name, varName : String) : float {
		var signInt : int = (int)SignNameToEnum(signName);
		return sMap[signInt].getF(varName);
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

	public function HideMagicInfo() {
		theGame.GetGuiManager().ShowNotification("", 1.f);
	}
	public function SignLocId(sign : ESignType) : int {
		switch (sign) {
			case ST_Aard:
				return 1061945;
			case ST_Axii:
				return 1066290;
			case ST_Igni:
				return 1066291;
			case ST_Quen:
				return 1066292;
			case ST_Yrden:
				return 1066293;
			default:
				return 147158; // Error
		}
	}
	public function ColorLocId(color : ENR_MagicColor) : int {
		switch (color) {
			case ENR_ColorBlack:
				return 2115940124;
			case ENR_ColorGrey:
				return 2115940125;
			case ENR_ColorYellow:
				return 2115940127;
			case ENR_ColorOrange:
				return 2115940128;
			case ENR_ColorRed:
				return 2115940129;
			case ENR_ColorPink:
				return 2115940130;
			case ENR_ColorViolet:
				return 2115940131;
			case ENR_ColorBlue:
				return 2115940132;
			case ENR_ColorSeagreen:
				return 2115940133;
			case ENR_ColorGreen:
				return 2115940134;
			case ENR_ColorSpecial1:
				return 2115940135;
			case ENR_ColorSpecial2:
				return 2115940136;
			case ENR_ColorSpecial3:
				return 2115940137;
			case ENR_ColorWhite:
			default:
				return 2115940126;
		}
	}
	public function ColorHexStr(color : ENR_MagicColor) : String {
		switch (color) {
			case ENR_ColorBlack:
				return "#000000";
			case ENR_ColorGrey:
				return "#666666";
			case ENR_ColorYellow:
				return "#AAAA00";
			case ENR_ColorOrange:
				return "#CC5500";
			case ENR_ColorRed:
				return "#CC0000";
			case ENR_ColorPink:
				return "#CC0088";
			case ENR_ColorViolet:
				return "#8800CC";
			case ENR_ColorBlue:
				return "#0000CC";
			case ENR_ColorSeagreen:
				return "#00AF92";
			case ENR_ColorGreen:
				return "#00AD00";
			case ENR_ColorSpecial1:
				return "#440000";
			case ENR_ColorSpecial2:
				return "#004400";
			case ENR_ColorSpecial3:
				return "#000044";
			case ENR_ColorWhite:
			default:
				return "#FFFFFF";
		}
	}
	protected function ColorFormattedText(text : String, color : ENR_MagicColor) : String {
		return "<font color = '" + ColorHexStr(color) + "'>" + text + "</font>";
	}
	protected function ColorFormattedValue(valueId : int, color : ENR_MagicColor) : String {
		return ColorFormattedText( GetLocStringById(valueId), color );
	}
	public function MageLocId(characterName : name) : int {
		switch (characterName) {
			case 'yennefer':
				return 162823;
			case 'keira':
				return 334714;
			case 'triss':
				return 162822;
			case 'lynx':
				return 1157557;
			case 'philippa':
				return 300169;
			case 'caranthir':
				return 335803;
			case 'eredin':
				return 335796;
			case 'djinn':
				return 583032;
			case 'ofieri':
				return 1105972;
			case 'hermit':
				return 1119070;
			default:
				return 147158; // Error
		}
	}

	public function GetMagicSkillsList() : array<String> {
		var list : array<String>;
		list.PushBack("nr_magic_RespectCaster");
		list.PushBack("nr_magic_DoubleSlash");
		list.PushBack("nr_magic_ProjectileAim");
		list.PushBack("nr_magic_LightningRebound");
		list.PushBack("nr_magic_DoubleRocks");
		list.PushBack("nr_magic_RocksAim");
		list.PushBack("nr_magic_BombAim");
		list.PushBack("nr_magic_PushSlowdown");
		list.PushBack("nr_magic_PushFreeze");
		list.PushBack("nr_magic_PushBurn");
		list.PushBack("nr_magic_PushFullBlast");
		list.PushBack("nr_magic_RipChance");
		list.PushBack("nr_magic_TeleportAutoPush");
		return list;
	}

	public function ShowMagicInfo(sectionName : name) {
		var 		s, i, j : int;
		var 	skillsList : array<String>;
		var 	NBSP, BR : String;
		var 	text : String;
		var styleName : name;
		var typeId, styleId, color, color2 : int;

		sMap[ST_Universal].setN("setup_scene_section", sectionName);
		// <img src='img://" + GetItemIconPathByName + "' height='" + GetNotificationFontSize() + "' width='" + GetNotificationFontSize() + "' vspace='-10' />&nbsp;
		BR = "<br>";
		NBSP = "&nbsp;";
		text = "";

		if (sectionName == 'main') {
			// light attacks
			text += "<font color='#000145'>[{358190}]</font>{ }{539939}:{ }" + GetSkillLevelLocStr(GetSkillLevel()) + "{ } (" + IntToString(GetSkillLevel()) + ")" + BR;
			text += "<font color='#145000'>[{2115940164}]</font>:{ }" + BR;
			j = 0;
			skillsList = GetMagicSkillsList();
			for (i = 0; i < skillsList.Size(); i += 1) {
				if (FactsQuerySum(skillsList[i]) > 0) {
					j += 1;
					// TODO: skillsList[i] to nice description
					text += "{ }{ }{ }" + IntToString(j) + ".{ }" + skillsList[i] + BR;
				}
			}
			
		} else if (sectionName == 'hand') {
			// light attacks
			text += "<font color='#3a0045'>[{2115940144}]</font><br>";
			text += "{2115940119}{ }={ }" + sMap[ST_Universal].getI("light_slash_amount", 2) + ":" + sMap[ST_Universal].getI("light_throw_amount", 1) + BR;
			for (s = ST_Aard; s < ST_Universal; s += 1) {
				if (eqSign == s) {
					text += "> ";
				}
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName(ENR_HandFx), 'keira') );
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorWhite);
				text += "({" + SignLocId(s) + "}){ }" + ColorFormattedValue(styleId, color);
				text += BR;
				// else {
				//	text += ",{ }{147158}/{147158}";
				//}
			}
		} else if (sectionName == 'teleport') {
			// light attacks
			text += "<font color='#3a0045'>[{2115940161}]</font><br>";
			for (s = ST_Aard; s < ST_Universal; s += 1) {
				if (eqSign == s) {
					text += "> ";
				}
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName(ENR_Teleport), 'yennefer') );
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorWhite);
				text += "({" + SignLocId(s) + "}){ }" + ColorFormattedValue(styleId, color);
				text += BR;
			}
		} else if (sectionName == 'light') {
			// light attacks
			text += "<font color='#004e01'>[{2115940118}]</font><br>";
			text += "{2115940119}{ }={ }" + sMap[ST_Universal].getI("light_slash_amount", 2) + ":" + sMap[ST_Universal].getI("light_throw_amount", 1) + BR;
			for (s = ST_Aard; s < ST_Universal; s += 1) {
				if (eqSign == s) {
					text += "> ";
				}
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName(ENR_Slash), 'yennefer') );
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorWhite);
				text += "({" + SignLocId(s) + "}){ }{2115940123}:{ }" + ColorFormattedValue(styleId, color) + ";{ }";
				
				typeId = sMap[s].getI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_Lightning);
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorWhite);
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName((ENR_MagicAction)typeId), 'yennefer') );
				if (typeId == ENR_Lightning) {
					text += "{2115940140}:{ }" + ColorFormattedValue(styleId, color) + "";
				} else if (typeId == ENR_ProjectileWithPrepare) {
					text += "{2115940141}:{ }" + ColorFormattedValue(styleId, color) + "";
				}
				text += BR;
			}
		} else if (sectionName == 'heavy') {
			// light attacks
			text += "<font color='#004e01'>[{2115940152}]</font><br>";
			text += "{2115940153}{ }={ }" + sMap[ST_Universal].getI("heavy_rock_amount", 2) + ":" + sMap[ST_Universal].getI("heavy_bomb_amount", 1) + BR;
			for (s = ST_Aard; s < ST_Universal; s += 1) {
				if (eqSign == s) {
					text += "> ";
				}
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName(ENR_Rock), 'keira') );
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorWhite);
				color2 = sMap[s].getI("color_cone_" + ENR_MAToName(ENR_Rock), ENR_ColorWhite);
				text += "({" + SignLocId(s) + "}){ }{2115940154}:{ }" + ColorFormattedValue(styleId, color) + "/" + ColorFormattedText("*", color2) + ";{ }";
				
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorWhite);
				//styleId = MageLocId( sMap[s].getN("color_" + ENR_MAToName(ENR_BombExplosion), 'philippa') );
				text += "{2115940157}:{ }" + ColorFormattedValue(ColorLocId(color), color) + "";
				text += BR;
			}
		}

		text = NR_FormatLocString(text);
		theGame.GetGuiManager().ShowNotification(text, 600 * 1000.f, false);
	}

	public function UpdateMagicInfo() {
		if (IsInSetupScene()) {
			ShowMagicInfo(sMap[ST_Universal].getN("setup_scene_section", 'main'));
		}
	}

	public function GetStaminaRegenPoints(regenPoints : float, dt : float) : float {
		var regenPerSec : float = 150.f; // 100 => 60 sec
		var skillLevel : int = GetSkillLevel();
		var skillReductionBonus : float = 0.05f * ((float)skillLevel - 1.f); // [0.0 - 0.28]
		//NRD("GetRegenPoints: regenPoints = " + regenPoints + " (" + dt + " s, time " + theGame.GetEngineTimeAsSeconds() + ")");

		return regenPerSec * (1.f - skillReductionBonus) * dt;
	}

	function SetDefaults_StaminaCost() {
		// cost_<AttackType> in [0, 100]% of max stamina
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_FastTravelTeleport), 20.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Teleport), 5.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_CounterPush), 10.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Slash), 10.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Lightning), 15.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_ProjectileWithPrepare), 20.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_RipApart), 20.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Rock), 30.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_BombExplosion), 30.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialGolem), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialMeteor), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialTornado), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialHeal), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialSphere), 50.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialLightningFall), 75.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialControl), 75.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialMeteorFall), 75.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialLumos), 75.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialTransform), 75.f);
	}

	function SetDefaults_LightSlash() {
		sMap[ST_Aard].setN("style_" + ENR_MAToName(ENR_Slash), 'yennefer');
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorWhite);

		sMap[ST_Axii].setN("style_" + ENR_MAToName(ENR_Slash), 'yennefer');
		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorSeagreen);

		sMap[ST_Igni].setN("style_" + ENR_MAToName(ENR_Slash), 'triss');
		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorOrange);

		sMap[ST_Quen].setN("style_" + ENR_MAToName(ENR_Slash), 'lynx');
		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorYellow);

		sMap[ST_Yrden].setN("style_" + ENR_MAToName(ENR_Slash), 'philippa');
		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_Slash), ENR_ColorViolet);
	}

	function SetDefaults_LightThrow() {
		sMap[ST_Aard].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_Lightning);
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorWhite);
		sMap[ST_Aard].setN("style_" + ENR_MAToName(ENR_Lightning), 'keira');
		sMap[ST_Aard].setN("style_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'triss');

		sMap[ST_Axii].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ProjectileWithPrepare);
		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("style_" + ENR_MAToName(ENR_Lightning), 'keira');
		sMap[ST_Axii].setN("style_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'caranthir');

		sMap[ST_Igni].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ProjectileWithPrepare);
		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorOrange);
		sMap[ST_Igni].setN("style_" + ENR_MAToName(ENR_Lightning), 'keira');
		sMap[ST_Igni].setN("style_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'triss');

		sMap[ST_Quen].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_Lightning);
		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorYellow);
		sMap[ST_Quen].setN("style_" + ENR_MAToName(ENR_Lightning), 'lynx');
		sMap[ST_Quen].setN("style_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'philippa');

		sMap[ST_Yrden].setI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ProjectileWithPrepare);
		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorViolet);
		sMap[ST_Yrden].setN("style_" + ENR_MAToName(ENR_Lightning), 'lynx');
		sMap[ST_Yrden].setN("style_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'philippa');
	}

	function SetDefaults_HeavyRock() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorWhite);
		sMap[ST_Aard].setI("color_cone_" + ENR_MAToName(ENR_Rock), ENR_ColorWhite);
		sMap[ST_Aard].setN("style_" + ENR_MAToName(ENR_Rock), 'keira');
		
		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorSeagreen);
		sMap[ST_Axii].setI("color_cone_" + ENR_MAToName(ENR_Rock), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("style_" + ENR_MAToName(ENR_Rock), 'djinn');

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorOrange);
		sMap[ST_Igni].setI("color_cone_" + ENR_MAToName(ENR_Rock), ENR_ColorOrange);
		sMap[ST_Igni].setN("style_" + ENR_MAToName(ENR_Rock), 'keira');

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorYellow);
		sMap[ST_Quen].setI("color_cone_" + ENR_MAToName(ENR_Rock), ENR_ColorYellow);
		sMap[ST_Quen].setN("style_" + ENR_MAToName(ENR_Rock), 'keira');

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorViolet);
		sMap[ST_Yrden].setI("color_cone_" + ENR_MAToName(ENR_Rock), ENR_ColorViolet);
		sMap[ST_Yrden].setN("style_" + ENR_MAToName(ENR_Rock), 'djinn');
	}

	function SetDefaults_HeavyBomb() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorWhite);

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorSeagreen);

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorOrange);

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorYellow);

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorViolet);
	}

	function SetDefaults_HeavyPush() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorWhite);

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorSeagreen);

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorOrange);

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorYellow);

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorViolet);
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
		sMap[ST_Aard].setN("style_" + ENR_MAToName(ENR_HandFx), 'yennefer');

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("style_" + ENR_MAToName(ENR_HandFx), 'keira');

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorOrange);
		sMap[ST_Igni].setN("style_" + ENR_MAToName(ENR_HandFx), 'triss');

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorYellow);
		sMap[ST_Quen].setN("style_" + ENR_MAToName(ENR_HandFx), 'keira');

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorViolet);
		sMap[ST_Yrden].setN("style_" + ENR_MAToName(ENR_HandFx), 'philippa');
	}

	function SetDefaults_Teleport() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorWhite);
		sMap[ST_Aard].setN("style_" + ENR_MAToName(ENR_Teleport), 'ofieri');

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("style_" + ENR_MAToName(ENR_Teleport), 'yennefer');

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorOrange);
		sMap[ST_Igni].setN("style_" + ENR_MAToName(ENR_Teleport), 'triss');

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorYellow);
		sMap[ST_Quen].setN("style_" + ENR_MAToName(ENR_Teleport), 'hermit');

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorViolet);
		sMap[ST_Yrden].setN("style_" + ENR_MAToName(ENR_Teleport), 'triss');
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
		NRD("HandFX (enable = " + enable + "), fx = " + newHandEffect);

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
		// break old action for a case
		aEventsStack.PushBack(SNR_MagicEvent('BreakMagicAttack', 'dummy_anim', 0.f));

		switch (type) {
			case ENR_ThrowAbstract:
				aActionType = (ENR_MagicAction)sMap[eqSign].getI("type_" + ENR_MAToName(ENR_ThrowAbstract), (int)ENR_Lightning);
				break;
			case ENR_SpecialAbstract:
				aActionType = (ENR_MagicAction)sMap[eqSign].getI("type_" + ENR_MAToName(ENR_SpecialAbstract));
				break;
			case ENR_SpecialAbstractAlt:
				aActionType = (ENR_MagicAction)sMap[eqSign].getI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt));
				break;
			default:
				aActionType = type;
				break; 
		}
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

	public function AddActionManual( action : NR_MagicAction, optional isCursed : bool ) {
		if (!action) {
			return;
		}
		action.sign 		= eqSign;
		action.map 			= sMap;
		action.m_fxNameHit 	= GetHitFXName( GetActionColor() );
		action.magicSkill 	= GetSkillLevel();
		if (isCursed) {
			cursedActions.PushBack(action);
		} else {
			cachedActions.PushBack(action);
		}
	}

	public function CreateFastTravelTeleport(pinTag : name, areaId : EAreaName, currentAreaId : EAreaName) : bool
	{
		if (areaId == -1)
			areaId = currentAreaId;

		if (!HasStaminaForAction(ENR_FastTravelTeleport)) {
			return false;
		}

		aTargetPinTag = pinTag;
		aTargetAreaId = areaId;
		aCurrentAreaId = currentAreaId;
		NR_GetReplacerSorceress().GotoCombatStateWithAttack( 'attack_magic_ftteleport' );
		return true;
	}

	public function GetTeleportDistance(farTeleport : bool) : float {
		if (farTeleport)
			return sMap[eqSign].getI("distance_" + ENR_MAToName(ENR_Teleport), 16) * 1.f;
		else
			return sMap[eqSign].getI("distance_far_" + ENR_MAToName(ENR_Teleport), 8) * 1.f;
	}

	public function GetActionColor() : ENR_MagicColor {
		var actionType : ENR_MagicAction = GetActionType();

		switch (actionType) {
			case ENR_Lightning:
			case ENR_ProjectileWithPrepare:
				actionType = ENR_ThrowAbstract;
				break;
			case ENR_SpecialTornado:
			case ENR_SpecialControl:
			case ENR_SpecialMeteor:
			case ENR_SpecialSphere:
			case ENR_SpecialGolem:
				actionType = ENR_SpecialAbstract;
				break;
			case ENR_SpecialLightningFall:
			case ENR_SpecialHeal:
			case ENR_SpecialMeteorFall:
			case ENR_SpecialLumos:
			case ENR_SpecialTransform:
				actionType = ENR_SpecialAbstractAlt;
				break;
		}
		return sMap[eqSign].getI("color_" + ENR_MAToName(actionType), ENR_ColorWhite);
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
	// returns final cost with bonuses applied in range [0 - 100]% of max stamina
	protected function GetStaminaCostForAction(actionType : ENR_MagicAction) : float {
		var costPerc : float;
		var skillLevel : int = GetSkillLevel();
		var skillReductionBonus : float = 0.1f * ((float)skillLevel - 1.f); // [0.0 - 0.4]
		var skillElement : int = 0;

		// basic value
		costPerc = sMap[ST_Universal].getF("cost_" + ENR_MAToName(actionType), 1.0f);

		// magic skill bonus
		NRD("skillReductionBonus = " + skillReductionBonus);
		costPerc = costPerc * (1.f - skillReductionBonus);

		return costPerc;
	}

	public function HasStaminaForAction(actionType : ENR_MagicAction, optional dontInformGUI : bool) : bool {
		var costPerc 			: float;
		var playerStaminaPerc 	: float = thePlayer.GetStaminaPercents() * 100.f; // [0.0 - 100.0]%

		costPerc = GetStaminaCostForAction(actionType);
		if (playerStaminaPerc < costPerc && !dontInformGUI) {
			thePlayer.SetShowToLowStaminaIndication( thePlayer.GetStatMax(BCS_Stamina) * costPerc / 100.f );
			thePlayer.SoundEvent("gui_no_stamina");
			theGame.VibrateControllerVeryLight();
		}
		return playerStaminaPerc >= costPerc;
	}

	public function DrainStaminaForAction(actionType : ENR_MagicAction) {
		var costPerc 		: float;
		var delay 			: float;

		costPerc = GetStaminaCostForAction(actionType);
		thePlayer.DrainStamina(ESAT_FixedValue, thePlayer.GetStatMax(BCS_Stamina) * costPerc / 100.f, /*delay*/ 1.f);
	}

	/* DAMAGE & SKILLS */
	public function GetSkillLevel() : ENR_MagicSkill
	{
		var playerLevel : int;
		var playerMax	: int;

		if (sMap[ST_Universal].getI("DEBUG_skillLevel", 0) > 0) {
			return sMap[ST_Universal].getI("DEBUG_skillLevel", 0);
		}

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
			return ENR_SkillExperienced;
		} else if (playerLevel >= FloorF(playerMax * 20 / 100)) {
			return ENR_SkillApprentice;
		} else {
			return ENR_SkillNovice;
		}
	}

	public function GetSkillLevelLocStr(skillLevel : ENR_MagicSkill) : String
	{
		//var skillLevel : ENR_MagicSkill = GetSkillLevel();
		switch (skillLevel) {
			case ENR_SkillNovice:
				return GetLocStringById(2115940147);
			case ENR_SkillApprentice:
				return GetLocStringById(2115940148);
			case ENR_SkillExperienced:
				return GetLocStringById(2115940149);
			case ENR_SkillMistress:
				return GetLocStringById(2115940150);
			case ENR_SkillArchMistress:
				return GetLocStringById(2115940151);
		}
	}

	public function GetMagicElementLocStr(element : ENR_MagicElement) : String
	{
		//var skillLevel : ENR_MagicSkill = GetSkillLevel();
		switch (element) {
			case ENR_ElementAir:
				return "Air";
			case ENR_ElementWater:
				return "Water";
			case ENR_ElementEarth:
				return "Earth";
			case ENR_ElementFire:
				return "Fire";
			case ENR_ElementMixed:
				return "Mixed";
		}
	}

	public function GetMaxHealthPercForFinisher() : float {
		var perc : float = 0.15f;
		if (FactsQuerySum("nr_magic_RipChance") > 0)
			perc = 0.25f;

		return perc; // [0.0 - 1.0]
	}

	// [0 .. chance] -> finisher available
	public function GetChancePercForFinisher(entity : CEntity) : int {
		var chance : int = 10;
		if (FactsQuerySum("nr_magic_RipChance") > 0)
			chance += 10;

		if (entity) {
			// checked before - no chance
			if (m_entitiesRipCheck.Contains(entity)) {
				chance = -1;
			} else {
				m_entitiesRipCheck.PushBack(entity);
			}
		}
		return chance;
	}



	public function UpdateFistsLevel(id: SItemUniqueId) {
		var playerLevel, levelDiff : int;
		var inv : CInventoryComponent;
		var i : int;
		var abilities, attributes : array<name>;
		var att : SAbilityAttributeValue;

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
			//inv.AddItemCraftedAbility(id, 'nr_autogen_magic_fists_dmg', true );
		}

		// NGP
		/*if (FactsQuerySum("NewGamePlus") > 0)
		{
			levelDiff = theGame.params.NewGamePlusLevelDifference();
			for( i = 0; i < levelDiff; i += 1 ) 
			{
				inv.AddItemCraftedAbility(id, 'nr_autogen_magic_fists_dmg', true );
			}
			inv.SetItemModifierInt(id, 'NGPItemAdjusted', 1);
		}*/

		NRD("--- NR FISTS STATS ---");
		NRD("Level: " + inv.GetItemLevel(id));
		inv.GetItemAbilities(id, abilities);
		for( i = 0; i < abilities.Size(); i += 1 ) 
		{
			NRD("Abilitiy[" + i + "] = " + abilities[i]);
		}
		inv.GetItemBaseAttributes(id, attributes);
		for( i = 0; i < attributes.Size(); i += 1 ) 
		{
			att = inv.GetItemAttributeValue(id, attributes[i]);
			NRD("Base attribute[" + i + "] = " + attributes[i] + " (" + att.valueBase + " * (1 + " + att.valueMultiplicative + ") + " + att.valueAdditive + ")");
		}
		inv.GetItemAttributes(id, attributes);
		for( i = 0; i < attributes.Size(); i += 1 ) 
		{
			att = inv.GetItemAttributeValue(id, attributes[i]);
			NRD("Attribute[" + i + "] = " + attributes[i] + " (" + att.valueBase + " * (1 + " + att.valueMultiplicative + ") + " + att.valueAdditive + ")");
		}

		// BONUS GIFT
		/*if (GetSkillLevel() >= ENR_SkillExperienced) {
			inv.AddItemCraftedAbility(id, theGame.params.GetRandomMasterworkWeaponAbility(), true);
		}*/
	}

	public function HandFxName() : name {
		var color 	: ENR_MagicColor = sMap[eqSign].getI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorWhite);
		var fx_type : name			 = sMap[eqSign].getN("style_" + ENR_MAToName(ENR_HandFx), 'keira');

		switch (color) {
			//case ENR_ColorBlack:
			case ENR_ColorGrey:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_grey';
					case 'triss':
						return 'hand_fx_triss_grey';
					case 'philippa':
						return 'hand_fx_philippa_grey';
					case 'keira':
					default:
						return 'hand_fx_keira_grey';
				}
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'yennefer':
						return 'hand_fx_yennefer_yellow';
					case 'triss':
						return 'hand_fx_triss_yellow';
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
					case 'philippa':
						return 'hand_fx_philippa_white';
					case 'keira':
					default:
						return 'hand_fx_keira_white';
				}
		}
	}

	public function SphereFxName() : name {
		var color 	: ENR_MagicColor = sMap[eqSign].getI("color_" + ENR_MAToName(ENR_SpecialSphere), ENR_ColorYellow);

		switch (color) {
			//case ENR_ColorBlack:
			//case ENR_ColorGrey:
			case ENR_ColorWhite:
				return 'shield_white';
			case ENR_ColorOrange:
				return 'shield_orange';
			case ENR_ColorRed:
				return 'shield_red';
			case ENR_ColorPink:
				return 'shield_pink';
			case ENR_ColorViolet:
				return 'shield_violet';
			case ENR_ColorBlue:
				return 'shield_blue';
			case ENR_ColorSeagreen:
				return 'shield_seagreen';
			case ENR_ColorGreen:
				return 'shield_white';
			// case ENR_ColorSpecial1:
			// case ENR_ColorSpecial2:
			// case ENR_ColorSpecial3:
			case ENR_ColorYellow:
			default:
				return 'shield_yellow';
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
			case ENR_FastTravelTeleport:
				mAction = new NR_MagicFastTravelTeleport in this;
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
		mAction.m_fxNameHit = parent.GetHitFXName( parent.GetActionColor() );
		mAction.magicSkill 	= parent.GetSkillLevel();
		mAction.OnInit();

		// protect new action from deleting by RAM cleaner
		parent.cachedActions.PushBack( mAction );
	}

	latent function PrepareMagicAction() {
		if (mAction) {
			NRD("PrepareMagicAction: type = " + mAction.actionType);
			if (mAction.isBroken)
				return;
			if ( mAction.actionType == ENR_Slash ) {
				((NR_MagicSlash)mAction).SetSwingData(parent.aData.swingType, parent.aData.swingDir);
			} else if ( mAction.actionType == ENR_Teleport ) {
				((NR_MagicTeleport)mAction).SetTeleportPos(parent.aTeleportPos);
			} else if ( mAction.actionType == ENR_FastTravelTeleport ) {
				((NR_MagicFastTravelTeleport)mAction).SetTravelData(parent.aTargetPinTag, parent.aTargetAreaId, parent.aCurrentAreaId);
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
			if (mAction.isBroken)
				return;
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
		if (mAction && !mAction.isPerformed) {
			mAction.BreakAction();
		} else {
			NRD("MM: BreakMagicAction: NULL mAction!");
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

// dt - time passed, targetPos - position is where entity is going to currently, reachPos is where entity should go ideally
latent function NR_SmoothMoveToTarget(dt : float, metersPerSec : float, out currentPos : Vector, out targetPos : Vector, reachPos : Vector) {
	var resultPos : Vector;
	var moveDir : Vector;
	var moveDirLen, maxMoveLen, Z : float;

	targetPos = VecInterpolate( targetPos, reachPos, 0.7f ); // for smooth direction change
	moveDir = targetPos - currentPos;
	moveDirLen = VecDistance(currentPos, targetPos);
	maxMoveLen = dt * metersPerSec;

	currentPos = VecInterpolate( currentPos, targetPos, MinF(0.8f, maxMoveLen / moveDirLen) );
	if ( theGame.GetWorld().PhysicsCorrectZ(currentPos + Vector(0,0,1.f), Z) ) {
		currentPos.Z = Z;
	}
}