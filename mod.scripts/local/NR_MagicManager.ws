/* This class for Sorceress solves magic attack entities, effects, hit effects, fist weapon etc
	instead of NPC's w2behtree and its CBTTask classes */

enum ENR_MagicSkill {
	ENR_SkillUnknown, 		// 0
	ENR_SkillNovice, 		// 1
	ENR_SkillApprentice, 	// 2
	ENR_SkillExperienced,	// 3
	ENR_SkillMistress,		// 4
	ENR_SkillArchMistress	// 5
}

enum ENR_MagicElement {
	ENR_ElementUnknown, 	// 0
	ENR_ElementAir, 		// 1
	ENR_ElementWater, 		// 2
	ENR_ElementEarth,		// 3
	ENR_ElementFire,		// 4
	ENR_ElementMixed		// 5
}
enum ENR_MagicAction {
		// unknown
	ENR_Unknown,
		// light attacks
	ENR_LightAbstract,			// not a real type
	ENR_Slash,
	ENR_ThrowAbstract,			// not a real type
	ENR_Lightning,
	ENR_Projectile,
	ENR_ProjectileWithPrepare,
		// heavy attacks
	ENR_HeavyAbstract,			// not a real type
	ENR_Rock,	
	ENR_BombExplosion,
		// heavy other attacks
	ENR_RipApart,
	ENR_CounterPush,
		// special attacks
	ENR_SpecialAbstract,		// not a real type
	ENR_SpecialControl,
	ENR_SpecialServant,
	ENR_SpecialMeteor,
	ENR_SpecialTornado,
	ENR_SpecialShield,
		// special attack (alternative)
	ENR_SpecialAbstractAlt,	// not a real type
	ENR_SpecialPolymorphism,
	ENR_SpecialMeteorFall,
	ENR_SpecialLightningFall,
	ENR_SpecialLumos,
	ENR_SpecialField,
		// misc
	ENR_Teleport,
	ENR_HandFx,
	ENR_FastTravelTeleport,
	ENR_WaterTrap,
	ENR_UnderwaterBreathing
}
enum ENR_MagicColor {
	ENR_ColorBlack,	// 0
	ENR_ColorGrey,		// 1
	ENR_ColorWhite,	// 2
	ENR_ColorYellow,	// 3
	ENR_ColorOrange,	// 4
	ENR_ColorRed,		// 5
	ENR_ColorPink,		// 6
	ENR_ColorViolet,	// 7
	ENR_ColorBlue,		// 8
	ENR_ColorSeagreen,	// 9
	ENR_ColorGreen,	// 10
	    // special
	ENR_ColorSpecial1,	// 11
	ENR_ColorSpecial2,	// 12
	ENR_ColorSpecial3,	// 13
	ENR_ColorRandom	// 14 -> White..Green [2 - 10]
}

/*
enum ESignType
{
	ST_Aard, 	// 0
    ST_Yrden, 	// 1
    ST_Igni, 	// 2
    ST_Quen, 	// 3
    ST_Axii, 	// 4
    ST_None, 	// 5 == ST_Universal
}
*/

struct SNR_MagicEvent {
	var eventName 		: name;
	var animName 		: name;
	//var animTime 		: float;
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
	protected var aEventsStack 	: array<SNR_MagicEvent>;
	protected var mAction 		: NR_MagicAction;
	protected var mMiscActionsBlocked : bool;

	public var aData 			: CPreAttackEventData;
	public var aTargetPinTag 	: name;
	public var aTargetAreaId 	: EAreaName;
	public var aCurrentAreaId 	: EAreaName;
	public var aIsAlternate 	: Bool; // remove?
	public var aTeleportPos		: Vector;
	public var aSelectorLight, aSelectorHorse, aSelectorHeavy : NR_MagicAspectSelector;
	
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
			// basic spells are learned by default
			FactsAdd("nr_magic_skill_level", 1);
			FactsAdd("nr_magic_skill_learned", 5); // hand-fx, counter-push, teleport, light attacks, lumos
			FactsAdd("nr_magic_skill_points", 1); // ftt

			FactsAdd("nr_magic_skill_ENR_HandFx", 1);
			FactsAdd("nr_magic_skill_ENR_Teleport", 1);
			FactsAdd("nr_magic_skill_ENR_CounterPush", 1);
			FactsAdd("nr_magic_skill_ENR_SpecialLumos", 1);
			FactsAdd("nr_magic_skill_ENR_LightAbstract", 1);
			FactsAdd("nr_magic_skill_ENR_Slash", 1);
			FactsAdd("nr_magic_skill_ENR_ThrowAbstract", 1);
			FactsAdd("nr_magic_skill_ENR_Lightning", 1);
			FactsAdd("nr_magic_skill_ENR_ProjectileWithPrepare", 1);
			FactsAdd("nr_magic_skill_ENR_WaterTrap", 1);
			
			SetDefaults_StaminaCost();
			SetDefaults_CurseChance();
			SetDefaults_Duration();

			SetDefaults_CounterPush();
			SetDefaults_LightAbstract();
			SetDefaults_LightSlash();
			SetDefaults_LightThrow();

			SetDefaults_HeavyAbstract();
			SetDefaults_HeavyRock();
			SetDefaults_HeavyBomb();

			SetDefaults_Teleport();
			SetDefaults_FastTravelTeleport();
			SetDefaults_HandFx();
			SetDefaults_Special();
			SetDefaults_SpecialAlt();
			SetDefaults_VoicelineChances();
			NR_Debug("MagicManager: Init default spell params");
		} else {
			NR_Debug("MagicManager: Load spell params");
		}

		aSelectorLight = new NR_MagicAspectSelector in this;
		aSelectorHorse = new NR_MagicAspectSelector in this;
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

		aSelectorHorse.Reset();
		aSelectorHorse.AddAttack('AttackHorseLightning', 	sMap[ST_Universal].getI("horse_lightning_amount", 1));
		aSelectorHorse.AddAttack('AttackHorseProjectile', 	sMap[ST_Universal].getI("horse_projectile_amount", 1));

		aSelectorHeavy.Reset();
		aSelectorHeavy.AddAttack('AttackHeavyRock', 	sMap[ST_Universal].getI("heavy_rocks_amount", 2));
		aSelectorHeavy.AddAttack('AttackHeavyThrow', 	sMap[ST_Universal].getI("heavy_bomb_amount",  1));
	}

	public function CorrectAspectAction(out actionType : ENR_MagicAction, out aspectName : name) {
		UpdateEquippedSign();
		NR_Debug("CorrectAspectAction: (before) actionType = " + ENR_MAToName(actionType) + ", aspectName = " + aspectName);

		// select aspect name for light/heavy
		switch (aspectName) {
			case 'AttackLight':
				aspectName = aSelectorLight.SelectAttack();
				break;
			case 'AttackHorse':
				aspectName = aSelectorHorse.SelectAttack();
				if (aspectName == 'AttackHorseLightning')
					actionType = ENR_Lightning;
				else
					actionType = ENR_ProjectileWithPrepare;
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
			default:
				break;
		}

		// select aspect name based on final type (special attacks)
		switch (actionType) {
			case ENR_SpecialTornado:
				aspectName = 'AttackHeavyRock';
				break;
			case ENR_SpecialField:
				aspectName = 'AttackSpecialElectricity';
				break;
			case ENR_SpecialMeteor:
				aspectName = 'AttackSpecialFireball';
				break;
			case ENR_SpecialShield:
				aspectName = 'AttackSpecialShield';
				break;
			case ENR_SpecialServant:
				aspectName = 'AttackHeavyRock';
				break;
			case ENR_SpecialLightningFall:
				aspectName = 'AttackSpecialLongCiriTargeting';
				break;
			case ENR_SpecialControl:
				aspectName = 'AttackSpecialFireball';
				break;
			case ENR_SpecialMeteorFall:
				aspectName = 'AttackSpecialLongYenChanting';
				break;
			case ENR_SpecialLumos:
				aspectName = 'AttackSpecialPray';
				break;
			case ENR_SpecialPolymorphism:
				aspectName = 'AttackSpecialTransform';
				break;
			default:
				break;
		}
		NR_Debug("CorrectAspectAction: (after) actionType = " + ENR_MAToName(actionType) + ", aspectName = " + aspectName);
	}

	public function CanContinueMagicAction() : bool {
		return (mAction && mAction.isPerformed && !mAction.isBroken);
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
			case ENR_ColorRandom:
				return 2115940138;
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
			case ENR_ColorRandom:
				return "#440044";
			case ENR_ColorWhite:
			default:
				return "#FFFFFF";
		}
	}
	protected function ColorFormattedText(text : String, color : ENR_MagicColor) : String {
		var ii, i, j, k, len : int;
		var result : String;
		if (color == ENR_ColorRandom) {
			text = NR_FormatLocString(text);
			len = StrLen(text);
			k = Max(1, len / 7);

			i = 0;
			result = "";
			for (ii = 0; ii < 7; ii += 1) {
				j = Min(k, len - i);
				result += ColorFormattedText(StrMid(text, i, j), (int)ENR_ColorOrange + ii);
				i += k;
				if (i >= len)
					break;
			}
			return result;
		}

		return "<font color = '" + ColorHexStr(color) + "'>" + text + "</font>";
	}
	protected function ColorFormattedValue(valueId : int, color : ENR_MagicColor) : String {
		return ColorFormattedText( GetLocStringById(valueId), color );
	}
	public function MageLocId(characterName : name) : int {
		switch (characterName) {
			// characters
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
			case 'default':
				return 1224932;
			case 'wild_hunt':
				return 535322;
			// animals
			case 'cat':
				return 1085583;
			// minions
			case 'wild_hunt_hound':
				return 1050491;
			case 'barghest':
				return 1174826;
			case 'endriaga':
				return 447384;
			case 'arachnomorph':
				return 1130394;
			case 'arachas':
				return 466798;
			case 'gargoyle':
				return 1080238;
			case 'earth_elemental':
				return 572370;
			case 'ice_elemental':
				return 1084776;
			case 'fire_elemental':
				return 1084974;
			default:
				NR_Error("MageLocId: unknown characterName = " + characterName);
				return 147158; // Error
		}
	}

	public function SelfColoredPerc(perc : int) : String {
		return "<font color=\"#" + NR_PercToHex(perc) + "00" + NR_PercToHex(perc) + "\">" + IntToString(perc) + "%</font>";
	}

	public function ShowMagicInfo(sectionName : name) {
		var 		s, i, j : int;
		var 	NBSP, BR : String;
		var 	text : String;
		var 	actionTypes : array<ENR_MagicAction>;
		var styleName, appName, entityName : name;
		var typeId, styleId, color, color2 : int;

		sMap[ST_Universal].setN("setup_scene_section", sectionName);
		// <img src='img://" + GetItemIconPathByName + "' height='" + GetNotificationFontSize() + "' width='" + GetNotificationFontSize() + "' vspace='-10' />&nbsp;
		BR = "<br>";
		NBSP = "&nbsp;";
		text = GetLocStringById(2115940583) + BR + BR;

		if (sectionName == 'main') {
			// sorceress
			text += NR_StrRGB("[{358190}]", 40,25,0) + BR;
			// level
			s = GetSkillLevel();
			text += "{ }" + NR_StrRGB("{539939}", 0,15,15) + ":{ }" + GetSkillLevelLocStr(s) + BR;
			// next level
			text += "{ }" + NR_StrRGB("{1073627}", 0,15,15) + ":{ }";
			if (s < ENR_SkillArchMistress)
				text += GetSkillLevelLocStr(s+1) + "{ } ({1087828}: " + GetPlayerLevelForSkillLevel(s+1) + ")" + BR;
			else
				text += "-" + BR;
		} else if (sectionName == 'hand') {
			// hand
			text += "<font color='#3a0045'>[{2115940143}]</font><br>";
			text += "{2115940119}{ }={ }" + sMap[ST_Universal].getI("light_slash_amount", 2) + ":" + sMap[ST_Universal].getI("light_throw_amount", 1) + BR;
			for (s = ST_Aard; s < ST_Universal; s += 1) {
				if (eqSign == s) {
					text += "> ";
				}
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName(ENR_HandFx), 'keira') );
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorWhite);
				text += NR_GetSignIconFormattedByType(s) + "{ }" + ColorFormattedValue(styleId, color);
				text += BR;
			}
		} else if (sectionName == 'teleport') {
			// teleport
			text += "<font color='#3a0045'>[{2115940589}]</font><br>";
			for (s = ST_Aard; s < ST_Universal; s += 1) {
				if (eqSign == s) {
					text += "> ";
				}
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName(ENR_Teleport), 'yennefer') );
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_Teleport), ENR_ColorWhite);
				text += NR_GetSignIconFormattedByType(s) + "{ }" + ColorFormattedValue(styleId, color);
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
				text += NR_GetSignIconFormattedByType(s) + "{ }" + "{2115940122}:{ }" + ColorFormattedValue(styleId, color) + ";{ }";
				
				typeId = sMap[s].getI("type_" + ENR_MAToName(ENR_ThrowAbstract), ENR_Lightning);
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorWhite);
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName((ENR_MagicAction)typeId), 'yennefer') );
				if (typeId == ENR_Lightning) {
					text += "{2115940141}:{ }" + ColorFormattedValue(styleId, color) + ";{ }";
				} else if (typeId == ENR_ProjectileWithPrepare) {
					text += "{2115940142}:{ }" + ColorFormattedValue(styleId, color) + ";{ }";
				}

				color = sMap[s].getI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorWhite);
				color2 = sMap[s].getI("buff_" + ENR_MAToName(ENR_CounterPush), 0);
				styleId = 1117589;  // Standart
				if (IsActionAbilityUnlocked(ENR_CounterPush, "Burning") && color2 == 1)
					styleId = 1083738;
				else if (IsActionAbilityUnlocked(ENR_CounterPush, "Freezing") && color2 == 0)
					styleId = 1081836;
				text += "{2115940151}:{ }" + ColorFormattedValue(styleId, color);

				text += BR;
			}
		} else if (sectionName == 'heavy') {
			// heavy attacks
			text += "<font color='#004e01'>[{2115940146}]</font><br>";
			text += "{2115940147}{ }={ }" + sMap[ST_Universal].getI("heavy_rock_amount", 2) + ":" + sMap[ST_Universal].getI("heavy_bomb_amount", 1) + BR;
			for (s = ST_Aard; s < ST_Universal; s += 1) {
				if (eqSign == s) {
					text += "> ";
				}
				styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName(ENR_Rock), 'keira') );
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_Rock), ENR_ColorWhite);
				color2 = sMap[s].getI("color_cone_" + ENR_MAToName(ENR_Rock), ENR_ColorWhite);
				text += NR_GetSignIconFormattedByType(s) + "{ }" + "{2115940148}:{ }" + ColorFormattedValue(styleId, color) + "/" + ColorFormattedText("*", color2) + ";{ }";
				
				color = sMap[s].getI("color_" + ENR_MAToName(ENR_BombExplosion), ENR_ColorWhite);
				//styleId = MageLocId( sMap[s].getN("color_" + ENR_MAToName(ENR_BombExplosion), 'philippa') );
				text += "{2115940149}:{ }" + ColorFormattedValue(ColorLocId(color), color) + "";
				text += BR;
			}
		} else if (sectionName == 'special') {
			text += "<font color='#004e01'>[{2115940152}]</font><br>";
            for (s = ST_Aard; s < ST_Universal; s += 1) {
                if (eqSign == s) {
                    text += "=> ";
                }
                text += NR_GetSignIconFormattedByType(s) + "{ }";
                
                typeId = sMap[s].getI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialMeteor);
                color = sMap[s].getI("color_" + ENR_MAToName((ENR_MagicAction)typeId), ENR_ColorWhite);
                styleId = MageLocId( sMap[s].getN("style_" + ENR_MAToName((ENR_MagicAction)typeId), 'yennefer') );
                if (typeId == ENR_SpecialControl) {
                    text += "{2115940154}";
                } else if (typeId == ENR_SpecialTornado) {
                    text += "{2115940153}:{ }" + ColorFormattedValue(styleId, ENR_ColorBlack);
                } else if (typeId == ENR_SpecialMeteor) {
                    text += "{2115940155}:{ }" + ColorFormattedValue(styleId, color);
                } else if (typeId == ENR_SpecialShield) {
                    text += "{2115940156}:{ }" + ColorFormattedValue(ColorLocId(color), color);
                } else if (typeId == ENR_SpecialServant) {
                    text += "{2115940157}:{ }";
                    entityName = sMap[s].getN("entity_0_" + ENR_MAToName(ENR_SpecialServant), 'wild_hunt_hound');
                    text += ColorFormattedValue( MageLocId(entityName), color );
                    if (IsActionAbilityUnlocked(ENR_SpecialServant, "TwoServants")) {
                    	entityName = sMap[s].getN("entity_1_" + ENR_MAToName(ENR_SpecialServant), 'wild_hunt_hound');
                    	text += "{ }/{ }" + ColorFormattedValue( MageLocId(entityName), color );
                    }
                }
                text += BR;
            }
		} else if (sectionName == 'special_alt') {
			text += "<font color='#004e01'>[{2115940158}]</font><br>";
            for (s = ST_Aard; s < ST_Universal; s += 1) {
                if (eqSign == s) {
                    text += "=> ";
                }
                text += NR_GetSignIconFormattedByType(s) + "{ }";
                
                typeId = sMap[s].getI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialLightningFall);
                color = sMap[s].getI("color_" + ENR_MAToName((ENR_MagicAction)typeId), ENR_ColorWhite);
                styleName = sMap[s].getN("style_" + ENR_MAToName((ENR_MagicAction)typeId), 'yennefer');
                styleId = MageLocId( styleName );
                if (typeId == ENR_SpecialLightningFall) {
                    text += "{2115940162}:{ }" + ColorFormattedValue(styleId, color);
                } else if (typeId == ENR_SpecialField) {
                    text += "{2115940163}:{ }" + ColorFormattedValue(ColorLocId(color), color);
                } else if (typeId == ENR_SpecialMeteorFall) {
                    text += "{2115940164}:{ }" + ColorFormattedValue(styleId, color);
                } else if (typeId == ENR_SpecialLumos) {
                    text += "{2115940165}:{ }" + ColorFormattedValue(ColorLocId(color), color);
                } else if (typeId == ENR_SpecialPolymorphism) {
                	text += "{2115940166}:{ }";
                	appName = sMap[s].getN("cat_app_" + ENR_MAToName((ENR_MagicAction)typeId), 'cat_vanilla_01');
                	if (styleName == 'cat') {
                		if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') ) {
							appName = sMap[s].getN("cat_app_" + ENR_MAToName((ENR_MagicAction)typeId), 'cat_20');
							text += ColorFormattedText(appName, color);
                		} else {
							appName = sMap[s].getN("cat_app_" + ENR_MAToName((ENR_MagicAction)typeId), 'cat_vanilla_01');
							text += ColorFormattedText(appName, color);
							text += BR + NR_StrRed("   {1223720}: ", true) + NR_StrGreen("Immersive Wildlife Project (Dhu Cats)", true) + BR + "nexusmods.com/witcher3/mods/3527";
						}
                	} else {
                		text += "??? " + styleName;
                	}
                }
                text += BR;
            }
		} else if (sectionName == 'spell_voicelines') {
			text += "<font color='#004e01'>[{2115940588}]</font><br>";
			text += "{2115940145}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_FastTravelTeleport)) ) + BR;
			text += "{2115940151}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_CounterPush)) ) + BR;
			text += "{2115940122}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_Slash)) ) + BR;
			text += "{2115940141}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_Lightning)) ) + BR;
			text += "{2115940142}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_ProjectileWithPrepare)) ) + BR;
			text += "{2115940148}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_Rock)) ) + BR;
			text += "{2115940149}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_BombExplosion)) ) + BR;
			text += "{2115940160}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_RipApart)) ) + BR;
			text += "{2115940153}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialTornado)) ) + BR;
			text += "{2115940154}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialControl)) ) + BR;
			text += "{2115940155}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialMeteor)) ) + BR;
			text += "{2115940156}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialShield)) ) + BR;
			text += "{2115940157}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialServant)) ) + BR;
			text += "{2115940162}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialLightningFall)) ) + BR;
			text += "{2115940163}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialField)) ) + BR;
			text += "{2115940164}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialMeteorFall)) ) + BR;
			text += "{2115940165}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialLumos)) ) + BR;
			text += "{2115940166}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_SpecialPolymorphism)) ) + BR;
			text += "{2115940168}: " + SelfColoredPerc( sMap[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(ENR_WaterTrap)) ) + BR;
		} else {
			text += "<font color='#004e01'>Unknown type: " + sectionName + "</font><br>";
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
		var regenPerSec : float = 200.f; // 100 => 60 sec
		var skillLevel : int = GetSkillLevel();
		var skillReductionBonus : float = 0.05f * ((float)skillLevel - 1.f); // [0.0 - 0.2]
		//NR_Debug("GetRegenPoints: regenPoints = " + regenPoints + " (" + dt + " s, time " + theGame.GetEngineTimeAsSeconds() + ")");

		return regenPerSec * (1.f - skillReductionBonus) * dt;
	}

	function SetDefaults_StaminaCost() {
		// cost_<AttackType> in [0, 100]% of max stamina
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_FastTravelTeleport), 20.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Teleport), 3.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_CounterPush), 3.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Slash), 5.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Lightning), 8.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_ProjectileWithPrepare), 8.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_RipApart), 10.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_Rock), 15.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_BombExplosion), 15.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialServant), 40.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialMeteor), 60.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialTornado), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialControl), 40.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialShield), 40.f);

		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialLightningFall), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialField), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialMeteorFall), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialLumos), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_SpecialPolymorphism), 50.f);
		sMap[ST_Universal].setF("cost_" + ENR_MAToName(ENR_WaterTrap), 40.f);
	}

	function SetDefaults_CurseChance() {
		// curse_chance_<AttackType> in [0, 100]%
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialServant), 15);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialMeteor), 20);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialTornado), 15);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialControl), 15);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialShield), 0);

		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialLightningFall), 25);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialField), 25);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialMeteorFall), 25);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialLumos), 0);
		sMap[ST_Universal].setI("curse_chance_" + ENR_MAToName(ENR_SpecialPolymorphism), 0);
	}

	function SetDefaults_Duration() {
		// duration_<AttackType> in sec
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialServant), 40.f);
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialTornado), 15.f);
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialControl), 40.f);
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialShield), 100.f);
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialPolymorphism), 40.f);

		// duration_<AttackType> in sec (interval between creating meteors/lightnings)
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialLumos), 999999.f);
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialField), 40.f);
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialMeteorFall), 0.8f);
		sMap[ST_Universal].setF("duration_" + ENR_MAToName(ENR_SpecialLightningFall), 0.5f);
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

		// horse attacks
		sMap[ST_Axii].setI("color_horse_" + ENR_MAToName(ENR_ThrowAbstract), ENR_ColorRandom);
		sMap[ST_Axii].setN("style_horse_" + ENR_MAToName(ENR_Lightning), 'keira');
		sMap[ST_Axii].setN("style_horse_" + ENR_MAToName(ENR_ProjectileWithPrepare), 'philippa');
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

	function SetDefaults_CounterPush() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorWhite);

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorSeagreen);

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorOrange);

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorYellow);

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_CounterPush), ENR_ColorViolet);
	}

	function SetDefaults_Special() {
		var i : int;
		
		sMap[ST_Aard].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialTornado);
		sMap[ST_Axii].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialControl);
		sMap[ST_Igni].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialMeteor);
		sMap[ST_Quen].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialShield);
		sMap[ST_Yrden].setI("type_" + ENR_MAToName(ENR_SpecialAbstract), ENR_SpecialServant);

		FactsSet("nr_type_special_aard", (int)ENR_SpecialTornado);
		FactsSet("nr_type_special_axii", (int)ENR_SpecialControl);
		FactsSet("nr_type_special_igni", (int)ENR_SpecialMeteor);
		FactsSet("nr_type_special_quen", (int)ENR_SpecialShield);
		FactsSet("nr_type_special_yrden", (int)ENR_SpecialServant);

		// use ST_Universal as default value?
		for (i = 0; i < ST_Universal; i += 1) {
			// TORNADO
			sMap[i].setN("style_" + ENR_MAToName(ENR_SpecialTornado), 'ofieri');

			// CONTROL - no visual customization

			// METEOR
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialMeteor), ENR_ColorOrange);
			sMap[i].setN("style_" + ENR_MAToName(ENR_SpecialMeteor), 'triss');

			// SPHERE
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialShield), ENR_ColorRed);

			// GOLEM
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialServant), ENR_ColorViolet);
			sMap[i].setN("entity_0_" + ENR_MAToName(ENR_SpecialServant), 'wild_hunt_hound');
			sMap[i].setN("entity_1_" + ENR_MAToName(ENR_SpecialServant), 'wild_hunt_hound');
		}
	}

	function SetDefaults_SpecialAlt() {
		var i : int;

		sMap[ST_Aard].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialLightningFall);
		sMap[ST_Axii].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialField);
		sMap[ST_Igni].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialMeteorFall);
		sMap[ST_Quen].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialLumos);
		sMap[ST_Yrden].setI("type_" + ENR_MAToName(ENR_SpecialAbstractAlt), ENR_SpecialPolymorphism);

		FactsSet("nr_type_special_alt_aard", (int)ENR_SpecialLightningFall);
		FactsSet("nr_type_special_alt_axii", (int)ENR_SpecialField);
		FactsSet("nr_type_special_alt_igni", (int)ENR_SpecialMeteorFall);
		FactsSet("nr_type_special_alt_quen", (int)ENR_SpecialLumos);
		FactsSet("nr_type_special_alt_yrden", (int)ENR_SpecialPolymorphism);

		for (i = 0; i <= ST_Universal; i += 1) {
			// LIGHTNING FALL
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialLightningFall), ENR_ColorBlue);
			sMap[i].setN("style_" + ENR_MAToName(ENR_SpecialLightningFall), 'lynx');

			// FIELD
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialField), ENR_ColorSeagreen);

			// METEOR FALL
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialMeteorFall), ENR_ColorOrange);
			sMap[i].setN("style_" + ENR_MAToName(ENR_SpecialMeteorFall), 'triss');

			// LUMOS
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialLumos), ENR_ColorWhite);

			// TRANSFORM
			sMap[i].setI("color_" + ENR_MAToName(ENR_SpecialPolymorphism), ENR_ColorViolet);
			sMap[i].setN("style_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat');
			if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') )
				sMap[i].setN("cat_app_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat_20');
			else
				sMap[i].setN("cat_app_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat_vanilla_01');
		}
	}

	function SetDefaults_VoicelineChances() {
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_FastTravelTeleport), 5);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_CounterPush), 0);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_Slash), 5);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_Lightning), 10);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_ProjectileWithPrepare), 15);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_Rock), 20);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_BombExplosion), 20);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_RipApart), 25);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialTornado), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialControl), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialMeteor), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialShield), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialServant), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialLightningFall), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialField), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialMeteorFall), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialLumos), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_SpecialPolymorphism), 30);
		sMap[ST_Universal].setI("voiceline_chance_" + ENR_MAToName(ENR_WaterTrap), 30);
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

	function SetDefaults_FastTravelTeleport() {
		sMap[ST_Aard].setI("color_" + ENR_MAToName(ENR_FastTravelTeleport), ENR_ColorWhite);
		sMap[ST_Aard].setN("style_" + ENR_MAToName(ENR_FastTravelTeleport), 'default');

		sMap[ST_Axii].setI("color_" + ENR_MAToName(ENR_FastTravelTeleport), ENR_ColorSeagreen);
		sMap[ST_Axii].setN("style_" + ENR_MAToName(ENR_FastTravelTeleport), 'keira');

		sMap[ST_Igni].setI("color_" + ENR_MAToName(ENR_FastTravelTeleport), ENR_ColorOrange);
		sMap[ST_Igni].setN("style_" + ENR_MAToName(ENR_FastTravelTeleport), 'default');

		sMap[ST_Quen].setI("color_" + ENR_MAToName(ENR_FastTravelTeleport), ENR_ColorYellow);
		sMap[ST_Quen].setN("style_" + ENR_MAToName(ENR_FastTravelTeleport), 'keira');

		sMap[ST_Yrden].setI("color_" + ENR_MAToName(ENR_FastTravelTeleport), ENR_ColorViolet);
		sMap[ST_Yrden].setN("style_" + ENR_MAToName(ENR_FastTravelTeleport), 'wild_hunt');
	}

	public function IsInSetupScene() : bool {
		return sMap[ST_Universal].getI("setup_scene_active", 0);
	}

	public function SetIsInSetupScene(value : bool) {
		if (value) {
			sMap[ST_Universal].setI("setup_scene_active", 1);
			NR_FindActorInScene('CYPRIAN WILLEY', willeyVictim);
		}
		else {
			sMap[ST_Universal].setI("setup_scene_active", 0);
		}
	}
	
	/* THE ONLY manual way to enable/disable/change color for lumos - don't manipulate effect outside! */
	public function LumosFX(enable : bool, fxName : name) {
		var      i : int;

		if (!mLumosAction) {
			mLumosAction = new NR_MagicSpecialLumos in this;
			mLumosAction.map 			= sMap;
			mLumosAction.magicSkill 	= GetSkillLevel();
		}

		NR_Debug("MagicManager.LumosFX: enable = " + enable);
		mLumosAction.OnSwitchSync(enable, fxName);
	}

	public function HandFX(enable: Bool, optional onlyIfActive: Bool) {
		var newHandEffect 	: name;

		UpdateEquippedSign();
		if (aHandEffect == '' && onlyIfActive) {
			return;
		}

		newHandEffect = HandFxName();
		NR_Debug("HandFX (enable = " + enable + "), fx = " + newHandEffect);

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
	// add event from animation for current action
	public function AddActionEvent(eventName : name, animName : name) {
		aEventsStack.PushBack( SNR_MagicEvent(eventName, animName) );
	}
	// SetSceneSign first if needed
	public function SetActionType(type : ENR_MagicAction) {
		// TOREMOVE: break old action for a case
		// aEventsStack.PushBack(SNR_MagicEvent('BreakMagicAttack', 'dummy_anim', 0.f));

		NR_Debug("SetActionType = " + type);
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

	public function AddActionScripted( action : NR_MagicAction, optional isCursed : bool ) {
		if (!action) {
			return;
		}
		action.sign 		= eqSign;
		action.map 			= sMap;
		action.m_fxNameHit 	= GetHitFXName( GetActionColor() );
		action.magicSkill 	= GetSkillLevel();
		action.SetScripted(true);
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
			return sMap[ST_Universal].getI("distance_" + ENR_MAToName(ENR_Teleport), 20) * 1.f;
		else
			return sMap[ST_Universal].getI("distance_far_" + ENR_MAToName(ENR_Teleport), 10) * 1.f;
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
			case ENR_SpecialShield:
			case ENR_SpecialServant:
				actionType = ENR_SpecialAbstract;
				break;
			case ENR_SpecialLightningFall:
			case ENR_SpecialField:
			case ENR_SpecialMeteorFall:
			case ENR_SpecialLumos:
			case ENR_SpecialPolymorphism:
				actionType = ENR_SpecialAbstractAlt;
				break;
		}
		return NR_FinalizeColor( sMap[eqSign].getI("color_" + ENR_MAToName(actionType), ENR_ColorWhite) );
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

		NR_Debug("MagicManager::OnPreAttackEvent -> anim = " + aName + ", swingType = " + data.swingType + ", swingDir = " + data.swingDir);
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
		var basicCost, bonus : float;

		// basic value
		basicCost = sMap[ST_Universal].getF("cost_" + ENR_MAToName(actionType), 1.0f);

		// bonuses
		bonus = GetGeneralStaminaBonus() + GetActionStaminaBonus(actionType);

		return basicCost * (100.f - bonus) / 100.f;
	}

	/* true for actions which you hold to resume cast */
	public function IsLongMagicAction(actionType : ENR_MagicAction) : bool {
		return (actionType == ENR_SpecialLightningFall || actionType == ENR_SpecialMeteorFall);
	}

	public function HasStaminaForAction(actionType : ENR_MagicAction, optional dontInformGUI : bool) : bool {
		var costPerc 			: float;
		var playerStaminaPerc 	: float = thePlayer.GetStaminaPercents() * 100.f; // [0.0 - 100.0]%

		costPerc = GetStaminaCostForAction(actionType);
		if (playerStaminaPerc < costPerc && !dontInformGUI) {
			thePlayer.SetShowToLowStaminaIndication( thePlayer.GetStatMax(BCS_Stamina) * costPerc / 100.f );
			theSound.SoundEvent("gui_no_stamina");
			theGame.VibrateControllerVeryLight();
		}
		return playerStaminaPerc >= costPerc;
	}
	
	public function GetStaminaCostForActionTick(actionType : ENR_MagicAction, deltaTime : float) : float {
		return GetStaminaCostForAction(actionType) * 0.1f * deltaTime;
	}

	public function HasStaminaForActionTick(actionType : ENR_MagicAction, deltaTime : float) : bool {
		var costPerc 			: float;
		var playerStaminaPerc 	: float = thePlayer.GetStaminaPercents() * 100.f; // [0.0 - 100.0]%

		costPerc = GetStaminaCostForActionTick(actionType, deltaTime);

		if (playerStaminaPerc < costPerc) {
			thePlayer.SetShowToLowStaminaIndication( thePlayer.GetStatMax(BCS_Stamina) * costPerc / 100.f );
			thePlayer.SoundEvent("gui_no_stamina");
			theGame.VibrateControllerVeryLight();
		}
		return playerStaminaPerc >= costPerc;
	}

	public function DrainStaminaForActionTick(actionType : ENR_MagicAction, deltaTime : float) {
		var costPerc 		: float;
		var delay 			: float;

		costPerc = GetStaminaCostForActionTick(actionType, deltaTime);
		thePlayer.DrainStamina(ESAT_FixedValue, thePlayer.GetStatMax(BCS_Stamina) * costPerc / 100.f, /*delay*/ 0.1f);
	}

	public function DrainStaminaForAction(actionType : ENR_MagicAction, optional specialMultiplier : float) {
		var costPerc 		: float;
		var delay 			: float;

		costPerc = GetStaminaCostForAction(actionType);
		if (specialMultiplier > 0.f)
			costPerc = costPerc * specialMultiplier;
		NR_Debug("DrainStaminaForAction: " + actionType + " = " + costPerc);
		thePlayer.DrainStamina(ESAT_FixedValue, thePlayer.GetStatMax(BCS_Stamina) * costPerc / 100.f, /*delay*/ 0.5f);
	}

	/* DAMAGE & SKILLS */
	public function GetSkillLevel() : ENR_MagicSkill
	{
		return (ENR_MagicSkill)FactsQuerySum("nr_magic_skill_level");
	}

	public function UpgradeSkillLevel()
	{
		var nextLevel : int;

		nextLevel = GetSkillLevel() + 1;
		if (nextLevel > GetPossibleSkillLevel()) {
			NR_Error("UpgradeSkillLevel: Can't upgrade to level: " + nextLevel);
			return;
		}
		FactsAdd("nr_magic_skill_level", 1);

		// points = how many new spells can you learn, used for scene
		if (nextLevel == 2) {
			// Heavy Attacks, Shield
			FactsAdd("nr_magic_skill_points", 2);
		} else if (nextLevel == 3) {
			// Tornado, Control
			FactsAdd("nr_magic_skill_points", 2);
		} else if (nextLevel == 4) {
			// Meteor, Servant, Alzur's Thunder, Gravitational Field
			FactsAdd("nr_magic_skill_points", 4);
		} else if (nextLevel == 5) {
			// Melgar's fire, Polymorphism
			FactsAdd("nr_magic_skill_points", 2);
		}
	}

	public function GetPossibleSkillLevel() : ENR_MagicSkill
	{
		var playerLevel : int;
		var playerMax	: int;
		var skillLevel	: int;

		playerLevel = GetWitcherPlayer().GetLevel();
		playerMax = GetWitcherPlayer().GetMaxLevel();
		if ( FactsQuerySum("NewGamePlus") < 1 ) {
			playerMax = playerMax / 2;
			// ? theGame.params.NEW_GAME_PLUS_MIN_LEVEL;
		}
		//NR_Debug("GetPossibleSkillLevel: playerMax = " + playerMax);

		for ( skillLevel = ENR_SkillArchMistress; skillLevel >= ENR_SkillNovice; skillLevel -= 1 ) {
			if ( playerLevel >= GetPlayerLevelForSkillLevel((ENR_MagicSkill)skillLevel) ) {
				return (ENR_MagicSkill)skillLevel;
			}
		}
		return ENR_SkillNovice;
	}

	public function GetPlayerLevelForSkillLevel(skillLevel : ENR_MagicSkill) : int {
		var playerMax	: int;

		playerMax = GetWitcherPlayer().GetMaxLevel();
		if ( FactsQuerySum("NewGamePlus") < 1 ) {
			playerMax = playerMax / 2;
		}

		switch (skillLevel) {
			case ENR_SkillNovice:
				return 0;
			case ENR_SkillApprentice:
				return FloorF(playerMax * 10 / 100);
			case ENR_SkillExperienced:
				return FloorF(playerMax * 25 / 100);
			case ENR_SkillMistress:
				return FloorF(playerMax * 45 / 100);
			case ENR_SkillArchMistress:
				return FloorF(playerMax * 70 / 100);
			default:
				return -1;
		}
	}

	public function GetSkillLevelLocStr(skillLevel : ENR_MagicSkill) : String
	{
		//var skillLevel : ENR_MagicSkill = GetSkillLevel();
		switch (skillLevel) {
			case ENR_SkillApprentice:
				return GetLocStringById(2115940201);
			case ENR_SkillExperienced:
				return GetLocStringById(2115940202);
			case ENR_SkillMistress:
				return GetLocStringById(2115940203);
			case ENR_SkillArchMistress:
				return GetLocStringById(2115940204);
			case ENR_SkillNovice:
			default:
				return GetLocStringById(2115940200);
		}
	}

	public function GetCurrentSkillLevelLocStr() : String
	{
		//var skillLevel : ENR_MagicSkill = GetSkillLevel();
		return GetSkillLevelLocStr( GetSkillLevel() );
	}

	public function GetActionPerformedCount( type : ENR_MagicAction ) : int {
		return FactsQuerySum("nr_magic_performed_" + ENR_MAToName(type));
	}

	public function SetActionSkillLevel( type : ENR_MagicAction, newLevel : int ) {
		FactsSet("nr_magic_skill_" + ENR_MAToName(type), newLevel + 1);
	}

	public function GetActionSkillLevel( type : ENR_MagicAction ) : int {
		// return sMap[ST_Universal].getI("level_" + ENR_MAToName(type), 0);
		// do -1,+1 because skill = 1 means learned but level 0
		return FactsQuerySum("nr_magic_skill_" + ENR_MAToName(type)) - 1;
	}

	public function GetGeneralDamageBonus() : int {
		return GetSkillLevel() * 3;
	}

	public function GetGeneralDurationBonus() : int {
		return GetSkillLevel() * 3;
	}

	public function GetGeneralStaminaBonus() : int {
		return GetSkillLevel() * 3;
	}

	public function GetActionDamageBonus( type : ENR_MagicAction ) : int {
		return GetActionSkillLevel(type) * 2;
	}

	public function GetActionDurationBonus( type : ENR_MagicAction ) : int {
		return GetActionSkillLevel(type) * 2;
	}

	public function GetActionStaminaBonus( type : ENR_MagicAction ) : int {
		return GetActionSkillLevel(type) * 2;
	}

	public function GetShieldDamageAbsorption() : int {
		return (int)(100 * (3.f + GetActionSkillLevel(ENR_SpecialShield) / 2.f));
	}

	public function GetActionMaxApplies( type : ENR_MagicAction ) : int {
		switch (type) {
			case ENR_SpecialServant:
				return 1 + GetActionSkillLevel(type) / 10;
			case ENR_SpecialControl:
			case ENR_SpecialTornado:
			case ENR_SpecialMeteor:
				return 1 + GetActionSkillLevel(type) / 5;
			case ENR_SpecialLightningFall:
				return 4 + GetActionSkillLevel(type) / 2;
			case ENR_SpecialMeteorFall:
				return 2 + GetActionSkillLevel(type) / 5;
			default:
				return 1;
		}
	}

	public function IsActionLearned( type : ENR_MagicAction ) : bool {
		return FactsQuerySum("nr_magic_skill_" + ENR_MAToName(type)) >= 1;
	}

	public function IsActionCustomizationUnlocked( type : ENR_MagicAction ) : bool {
		//return FactsQuerySum("nr_skill_customization_" + ENR_MAToName(type)) >= 1;
		return IsActionLearned(type) && GetActionSkillLevel(type) >= 1;
	}

	public function ActionAbilityUnlock( type : ENR_MagicAction, abilityName : String ) {
		FactsAdd("nr_magic_" + ENR_MAToName(type) + "_" + abilityName, 1);
	}

	public function IsActionAbilityUnlocked( type : ENR_MagicAction, abilityName : String ) : bool {
		return FactsQuerySum("nr_magic_" + ENR_MAToName(type) + "_" + abilityName) >= 1;
	}

	public function GetSkillInfoLocStr( type : ENR_MagicAction, optional detailed : bool ) : String {
		var info, locked, unlocked, tmp, l_tmp, r_tmp : String;
		var specialAbilities : array<String>;
		var specialAbilityIds : array<int>;
		var i : int;

		unlocked = StrLower(GetLocStringById(1066069));
		locked = StrLower(GetLocStringById(1066070));

		if (!IsActionLearned(type)) {
			return "<b>- " + ENR_MAToLocString(type) + "</b>: " + NR_StrRed(locked) + "<br>";
		}
		// name, level
		info = "<b>- " + ENR_MAToLocString(type) + "</b>: <i>" + StrLower(GetLocStringById(539939)) + "</i>: " + IntToString(GetActionSkillLevel(type)) + " / 10<br>";
		// performs
		info += "  <i>" + GetLocStringById(2115940225) + "</i>: " + IntToString(GetActionPerformedCount(type));
		//damage
		if (type != ENR_SpecialShield && type != ENR_SpecialLumos && type != ENR_CounterPush && type != ENR_RipApart
		 	&& type != ENR_Teleport && type != ENR_FastTravelTeleport && type != ENR_SpecialPolymorphism) {
			info += ". <i>" + GetLocStringById(1070900) + "</i>: " + NR_StrGreen("(+" + IntToString(GetActionDamageBonus(type)) + "%)");
		}
		// duration
		if (type == ENR_SpecialControl || type == ENR_SpecialServant || type == ENR_SpecialShield  || type == ENR_SpecialTornado) {
			info += ". <i>" + GetLocStringById(593508) + "</i>: " + FloatToString(sMap[ST_Universal].getF("duration_" + ENR_MAToName(type))) + " " + GetLocStringById(1086450); 
			info += NR_StrGreen(" (+" + IntToString(GetActionDurationBonus(type)) + "%)");
		}
		// stamina cost
		info += ". <i>" + GetLocStringById(174112) + "</i>: " + FloatToString(sMap[ST_Universal].getF("cost_" + ENR_MAToName(type))) + "%";
		info += NR_StrGreen(" (-" + IntToString(GetActionStaminaBonus(type)) + "%)");
		// customization
		if (type != ENR_SpecialControl && type != ENR_RipApart && type != ENR_SpecialPolymorphism) {
			tmp = GetLocStringById(2115940226);
			if (!detailed) {
				StrSplitFirst( tmp, " [", tmp, r_tmp );
			}
			if ( IsActionCustomizationUnlocked(type) )
				info += ". <i>" + NR_StrGreen(tmp) + "</i>";
			else
				info += ". <i>" + NR_StrRed(tmp) + "</i>";			
		}
		info += "<br>";

		// special info
		if (type == ENR_Teleport) {
			specialAbilities.PushBack("AutoCounterPush"); specialAbilityIds.PushBack(2115940232);
		} else if (type == ENR_Slash) {
			specialAbilities.PushBack("DoubleSlash"); specialAbilityIds.PushBack(2115940228);
		} else if (type == ENR_Lightning) {
			specialAbilities.PushBack("Rebound"); specialAbilityIds.PushBack(2115940230);
		} else if (type == ENR_ProjectileWithPrepare) {
			specialAbilities.PushBack("AutoAim"); specialAbilityIds.PushBack(2115940229);
		} else if (type == ENR_CounterPush) {
			specialAbilities.PushBack("FullBlast"); specialAbilityIds.PushBack(2115940231);
			specialAbilities.PushBack("Freezing"); specialAbilityIds.PushBack(2115940246);
			specialAbilities.PushBack("Burning"); specialAbilityIds.PushBack(2115940245);
		} else if (type == ENR_Rock) {
			specialAbilities.PushBack("AutoAim"); specialAbilityIds.PushBack(2115940229);
		} else if (type == ENR_BombExplosion) {
			specialAbilities.PushBack("Pursuit"); specialAbilityIds.PushBack(2115940239);
			specialAbilities.PushBack("DamageControl"); specialAbilityIds.PushBack(2115940244);
		} else if (type == ENR_RipApart) {
			//GetMaxHealthPercForFinisher()
			//GetChancePercForFinisher(NULL)
		//} else if (type == ENR_FastTravelTeleport) {
		} else if (type == ENR_SpecialTornado) {
			specialAbilities.PushBack("Pursuit"); specialAbilityIds.PushBack(2115940239);
			specialAbilities.PushBack("Freezing"); specialAbilityIds.PushBack(1081836);
			specialAbilities.PushBack("DamageControl"); specialAbilityIds.PushBack(2115940244);
			info += "  <i>" + GetLocStringById(2115940236) + "</i>: " + GetActionMaxApplies(type) + "<br>";
		} else if (type == ENR_SpecialControl) {
			specialAbilities.PushBack("Upscaling"); specialAbilityIds.PushBack(2115940233);
			info += "  <i>" + GetLocStringById(2115940234) + "</i>: " + GetActionMaxApplies(type) + "<br>";
		} else if (type == ENR_SpecialServant) {
			specialAbilities.PushBack("Followers"); specialAbilityIds.PushBack(2115940237);
			specialAbilities.PushBack("TwoServants"); specialAbilityIds.PushBack(2115940249);
			specialAbilities.PushBack("WildHuntHound"); specialAbilityIds.PushBack(1050491);
			specialAbilities.PushBack("Barghest"); specialAbilityIds.PushBack(1174826);
			specialAbilities.PushBack("Endrega"); specialAbilityIds.PushBack(447384);
			specialAbilities.PushBack("Arachnomorph"); specialAbilityIds.PushBack(1130243);
			specialAbilities.PushBack("Arachas"); specialAbilityIds.PushBack(452894);
			specialAbilities.PushBack("Gargoyle"); specialAbilityIds.PushBack(1080238);
			specialAbilities.PushBack("EarthElemental"); specialAbilityIds.PushBack(572370);
			specialAbilities.PushBack("IceElemental"); specialAbilityIds.PushBack(1084776);
			specialAbilities.PushBack("FireElemental"); specialAbilityIds.PushBack(1065074);
			info += "  <i>" + GetLocStringById(2115940235) + "</i>: " + GetActionMaxApplies(type) + "<br>";
		} else if (type == ENR_SpecialMeteor) {
			specialAbilities.PushBack("DamageControl"); specialAbilityIds.PushBack(2115940244);
			info += "  <i>" + GetLocStringById(2115940240) + "</i>: " + GetActionMaxApplies(type) + "<br>";
		} else if (type == ENR_SpecialShield) {
			specialAbilities.PushBack("AutoLightning"); specialAbilityIds.PushBack(2115940230);
			info += "  <i>" + GetLocStringById(2115940241) + "</i>: " + GetShieldDamageAbsorption() + "%<br>";
		} else if (type == ENR_SpecialPolymorphism) {
			
		} else if (type == ENR_SpecialMeteorFall || type == ENR_SpecialLightningFall) {
			specialAbilities.PushBack("DamageControl"); specialAbilityIds.PushBack(2115940244);
			// num
			info += "  <i>" + GetLocStringById(2115940247) + "</i>: " + GetActionMaxApplies(type) + "<br>";
			// interval
			info += ". <i>" + GetLocStringById(2115940248) + "</i>: " + FloatToString(sMap[ST_Universal].getF("duration_" + ENR_MAToName(type))) + " " + GetLocStringById(1086450); 
			info += NR_StrGreen(" (-" + IntToString(GetActionDurationBonus(type)) + "%)");
		} else if (type == ENR_SpecialLumos) {
			// nothing
		} else if (type == ENR_SpecialField) {
			specialAbilities.PushBack("Pursuit"); specialAbilityIds.PushBack(2115940237);
		}

		// print special abilities
		if (specialAbilities.Size() > 0) {
			tmp = GetLocStringById(2115940227);
			if (!detailed) {
				StrSplitFirst( tmp, " [", tmp, r_tmp );
				info += "  <i>" + tmp + "</i>: ";
			} else {
				info += "  <i>" + tmp + "</i>:<br>";
			}
			

			for (i = 0; i < specialAbilities.Size(); i += 1) {
				if (i > 0) {
					if (!detailed) {
						info += ", ";
					} else {
						info += "<br>  * ";
					}
				}
				tmp = GetLocStringById(specialAbilityIds[i]);
				if (!detailed) {
					StrSplitFirst( tmp, " [", tmp, r_tmp );
				}
				if (IsActionAbilityUnlocked(type, specialAbilities[i]))
					info += NR_StrGreen( tmp );
				else
					info += NR_StrRed( tmp );
			}
			
			info += "<br>";
		}

		return info;
	}

	public function ShowSkillLevelup( type : ENR_MagicAction ) {
		// this is basic logic, override it in children classes
		var popupData : W3TutorialPopupData;

		popupData = new W3TutorialPopupData in thePlayer;
		popupData.messageTitle = GetLocStringById(2115940193);
		popupData.messageText = GetLocStringById(2115940243) + "<br>" + GetSkillInfoLocStr( type, /*detailed*/ true );
		
		popupData.managerRef = theGame.GetTutorialSystem();
		popupData.enableGlossoryLink = false;
		popupData.autosize = true;
		popupData.blockInput = true;
		popupData.pauseGame = false;
		popupData.fullscreen = true;
		popupData.canBeShownInMenus = false;
		popupData.duration = -1;
		popupData.posX = 0;
		popupData.posY = 0;
		popupData.enableAcceptButton = true;

		SoundEventQuest("gui_character_synergy_effect", SESB_DontSave);
		theGame.GetTutorialSystem().ShowTutorialHint(popupData);
	}

	public function IsMiscStateActionsBlocked() : bool {
		return mMiscActionsBlocked;
	}

	public function SetMiscStateActionsBlocked(blocked : bool) {
		mMiscActionsBlocked = blocked;
		if (blocked) {
			thePlayer.BlockAction( EIAB_DismountVehicle, 'MagicManager' );
		} else {
			thePlayer.UnblockAction( EIAB_DismountVehicle, 'MagicManager' );
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
		return 0.15f + GetActionSkillLevel(ENR_RipApart) * 0.01f; // [0.0 - 1.0]
	}

	// [0 .. chance] -> finisher available
	public function GetChancePercForFinisher(entity : CEntity) : int {
		var chance : int;
		
		chance = 15 + GetActionSkillLevel(ENR_RipApart);

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

		//NR_Debug("UpdateFistsLevel: GetSkillLevel = " + GetSkillLevel());
		playerLevel = GetWitcherPlayer().GetLevel();
		inv = thePlayer.GetInventory();
		// vanilla logic from 'GenerateItemLevel'
		//AddItemCraftedAbility(id, 'autogen_steel_base' );
		//AddItemCraftedAbility(id, 'autogen_silver_base' ); 
		//AddItemCraftedAbility(id, 'nr_autogen_elemental_base' ); 
		// ^ NR magic fists _Stats

		// STEEL & SILVER & ELEMENTAL
		//for ( i = 0; i < playerLevel; i += 1 ) 
		//{
		//	inv.AddItemCraftedAbility(id, 'nr_autogen_magic_fists_dmg', true );
		//}

		// NGP
		/*if (FactsQuerySum("NewGamePlus") > 0)
		{
			levelDiff = theGame.params.NewGamePlusLevelDifference();
			for ( i = 0; i < levelDiff; i += 1 ) 
			{
				inv.AddItemCraftedAbility(id, 'nr_autogen_magic_fists_dmg', true );
			}
			inv.SetItemModifierInt(id, 'NGPItemAdjusted', 1);
		}*/

		NR_Debug("--- NR FISTS STATS ---");
		NR_Debug("Level: " + inv.GetItemLevel(id));
		inv.GetItemAbilities(id, abilities);
		for ( i = 0; i < abilities.Size(); i += 1 ) 
		{
			NR_Debug("Abilitiy[" + i + "] = " + abilities[i]);
		}
		inv.GetItemBaseAttributes(id, attributes);
		for ( i = 0; i < attributes.Size(); i += 1 ) 
		{
			att = inv.GetItemAttributeValue(id, attributes[i]);
			NR_Debug("Base attribute[" + i + "] = " + attributes[i] + " (" + att.valueBase + " * (1 + " + att.valueMultiplicative + ") + " + att.valueAdditive + ")");
		}
		inv.GetItemAttributes(id, attributes);
		for ( i = 0; i < attributes.Size(); i += 1 ) 
		{
			att = inv.GetItemAttributeValue(id, attributes[i]);
			NR_Debug("Attribute[" + i + "] = " + attributes[i] + " (" + att.valueBase + " * (1 + " + att.valueMultiplicative + ") + " + att.valueAdditive + ")");
		}

		// BONUS GIFT
		/*if (GetSkillLevel() >= ENR_SkillExperienced) {
			inv.AddItemCraftedAbility(id, theGame.params.GetRandomMasterworkWeaponAbility(), true);
		}*/
	}

	public function HandFxName() : name {
		var color 	: ENR_MagicColor = NR_FinalizeColor( sMap[eqSign].getI("color_" + ENR_MAToName(ENR_HandFx), ENR_ColorWhite) );
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
		var color 	: ENR_MagicColor = NR_FinalizeColor( sMap[eqSign].getI("color_" + ENR_MAToName(ENR_SpecialShield), ENR_ColorRed) );

		switch (color) {
			//case ENR_ColorBlack:
			//case ENR_ColorGrey:
			case ENR_ColorWhite:
				return 'philippa_shield_white';
			case ENR_ColorYellow:
				return 'philippa_shield_yellow';
			case ENR_ColorOrange:
				return 'philippa_shield_orange';
			case ENR_ColorPink:
				return 'philippa_shield_pink';
			case ENR_ColorViolet:
				return 'philippa_shield_violet';
			case ENR_ColorBlue:
				return 'philippa_shield_blue';
			case ENR_ColorSeagreen:
				return 'philippa_shield_seagreen';
			case ENR_ColorGreen:
				return 'philippa_shield_green';
			// case ENR_ColorSpecial1:
			// case ENR_ColorSpecial2:
			// case ENR_ColorSpecial3:
			case ENR_ColorRed:
			default:
				return 'philippa_shield_red';
		}
	}

	public function SphereHitFxName() : name {
		var color 	: ENR_MagicColor = NR_FinalizeColor( sMap[eqSign].getI("color_" + ENR_MAToName(ENR_SpecialShield), ENR_ColorRed) );

		switch (color) {
			//case ENR_ColorBlack:
			//case ENR_ColorGrey:
			case ENR_ColorWhite:
				return 'philippa_shield_hit_white';
			case ENR_ColorYellow:
				return 'philippa_shield_hit_yellow';
			case ENR_ColorOrange:
				return 'philippa_shield_hit_orange';
			case ENR_ColorPink:
				return 'philippa_shield_hit_pink';
			case ENR_ColorViolet:
				return 'philippa_shield_hit_violet';
			case ENR_ColorBlue:
				return 'philippa_shield_hit_blue';
			case ENR_ColorSeagreen:
				return 'philippa_shield_hit_seagreen';
			case ENR_ColorGreen:
				return 'philippa_shield_hit_green';
			// case ENR_ColorSpecial1:
			// case ENR_ColorSpecial2:
			// case ENR_ColorSpecial3:
			case ENR_ColorRed:
			default:
				return 'philippa_shield_hit_red';
		}
	}
}

state MagicLoop in NR_MagicManager {
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

		parent.mAction = NULL;
		parent.aName = animName;
		type = parent.GetActionType();
		NR_Debug("InitMagicAction: type = " + type);
		switch(type) {
			case ENR_Slash:
				parent.mAction = new NR_MagicSlash in this;
				break;
			case ENR_Lightning:
				parent.mAction = new NR_MagicLightning in this;
				break;
			case ENR_Projectile:
			case ENR_ProjectileWithPrepare:
				parent.mAction = new NR_MagicProjectileWithPrepare in this;
				break;
			case ENR_Rock:
				parent.mAction = new NR_MagicRock in this;
				break;
			case ENR_BombExplosion:
				parent.mAction = new NR_MagicBomb in this;
				break;
			case ENR_RipApart:
				parent.mAction = new NR_MagicRipApart in this;
				break;
			case ENR_CounterPush:
				parent.mAction = new NR_MagicCounterPush in this;
				break;
			case ENR_Teleport:
				parent.mAction = new NR_MagicTeleport in this;
				break;
			case ENR_FastTravelTeleport:
				parent.mAction = new NR_MagicFastTravelTeleport in this;
				break;
			case ENR_SpecialLumos:
				if (!parent.mLumosAction)
					parent.mLumosAction = new NR_MagicSpecialLumos in this;
				parent.mAction = parent.mLumosAction;
				break;
			case ENR_SpecialControl:
				parent.mAction = new NR_MagicSpecialControl in this;
				break;
			case ENR_SpecialServant:
				parent.mAction = new NR_MagicSpecialServant in this;
				break;
			case ENR_SpecialMeteor:
				parent.mAction = new NR_MagicSpecialMeteor in this;
				break;
			case ENR_SpecialTornado:
				parent.mAction = new NR_MagicSpecialTornado in this;
				break;
			case ENR_SpecialShield:
				parent.mAction = new NR_MagicSpecialShield in this;
				break;
			case ENR_SpecialPolymorphism:
				parent.mAction = new NR_MagicSpecialPolymorphism in this;
				break;
			case ENR_SpecialMeteorFall:
				parent.mAction = new NR_MagicSpecialMeteorFall in this;
				break;
			case ENR_SpecialLightningFall:
				parent.mAction = new NR_MagicSpecialLightningFall in this;
				break;
			case ENR_SpecialField:
				parent.mAction = new NR_MagicSpecialField in this;
				break;
			case ENR_WaterTrap:
				parent.mAction = new NR_MagicWaterTrap in this;
				break;
			default:
				NR_Error("Unknown attack type: " + type);
				break;
		}

		if (!parent.mAction) {
			NR_Error("No valid parent.mAction created. animName = " + animName);
			return;
		}
		if (parent.IsInSetupScene()) {
			parent.mAction.target 	= parent.willeyVictim;
		}
		parent.mAction.sign 		= parent.eqSign;
		parent.mAction.map 			= parent.sMap;
		parent.mAction.m_fxNameHit 	= parent.GetHitFXName( parent.GetActionColor() );
		parent.mAction.magicSkill 	= parent.GetSkillLevel();
		parent.mAction.OnInit();

		// protect new action from deleting by RAM cleaner
		parent.cachedActions.PushBack( parent.mAction );
	}

	latent function PrepareMagicAction() {
		if (parent.mAction) {
			NR_Debug("PrepareMagicAction: type = " + parent.mAction.actionType);
			if (parent.mAction.isBroken)
				return;
			if ( parent.mAction.actionType == ENR_Slash ) {
				((NR_MagicSlash)parent.mAction).SetSwingData(parent.aData.swingType, parent.aData.swingDir);
			} else if ( parent.mAction.actionType == ENR_Teleport ) {
				((NR_MagicTeleport)parent.mAction).SetTeleportPos(parent.aTeleportPos);
			} else if ( parent.mAction.actionType == ENR_FastTravelTeleport ) {
				((NR_MagicFastTravelTeleport)parent.mAction).SetTravelData(parent.aTargetPinTag, parent.aTargetAreaId, parent.aCurrentAreaId);
			}
			parent.mAction.OnPrepare();
		} else {
			NR_Error("MM: PrepareMagicAction: NULL parent.mAction!");
		}
	}

	latent function RotatePrePerformMagicAction() {
		if (parent.mAction) {
			NR_Debug("RotatePrePerformMagicAction: type = " + parent.mAction.actionType);
			if (parent.mAction.isBroken)
				return;

			parent.mAction.OnRotatePrePerform();
		} else {
			NR_Error("MM: RotatePrePerformMagicAction: NULL parent.mAction!");
		}
	}

	latent function PerformMagicAction() {
		var sameActions 	: array<NR_MagicSpecialAction>;
		var maxActionCnt 	: int;
		var    i : int;

		if (parent.mAction) {
			NR_Debug("PerformMagicAction: type = " + parent.mAction.actionType);
			if (parent.mAction.isBroken)
				return;
			parent.mAction.OnPerform();
		} else {
			NR_Error("MM: PerformMagicAction: NULL parent.mAction!");
		}

		NR_Debug("check max count: " + "s_maxCount_" + parent.mAction.actionType);

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
			else if ( parent.cachedActions[i].actionType == parent.mAction.actionType 
					&& ((NR_MagicSpecialAction)parent.cachedActions[i]) && parent.cachedActions[i] != parent.mAction )
			{
				// adding special actions with the same type, excluding parent.mAction
				sameActions.PushBack( (NR_MagicSpecialAction)parent.cachedActions[i] );
			}
		}

		// check if new action is special and stop old ones if limit is exceed
		maxActionCnt = parent.GetActionMaxApplies(parent.mAction.actionType);
		while (sameActions.Size() + 1 > maxActionCnt) {
			NR_Debug("PerformMagicAction: Stopping special duplicate action: maxActionCnt = " + maxActionCnt + ", sameActions.Size() = " + sameActions.Size());
			// from front - older actions
			sameActions[0].StopAction();
			sameActions.Erase( 0 );
		}
	}
	
	public function ContinueMagicAction(animName : name) {
		if (parent.mAction && parent.mAction.isPerformed) {
			parent.mAction.ContinueAction();
			NR_Debug("MM: ContinueMagicAction: " + parent.mAction);
		} else {
			NR_Error("MM: ContinueMagicAction: NULL or !performed.");
		}
	}

	latent function BreakMagicAction() {
		if (parent.mAction) {
			parent.mAction.BreakAction();
			NR_Debug("MM: BreakMagicAction: " + parent.mAction);
		} else {
			NR_Error("MM: BreakMagicAction: NULL parent.mAction.");
		}
	}
	
	entry function MainLoop() {
		while (true) {
			SleepOneFrame();
			if (parent.aEventsStack.Size() > 0) {
				NR_Debug("MAIN LOOP: anim = " + NameToString(parent.aEventsStack[0].animName) + ", event = " + parent.aEventsStack[0].eventName + ", time: " + EngineTimeToFloat(theGame.GetEngineTime()));
				switch (parent.aEventsStack[0].eventName) {
					case 'InitAction':
						InitMagicAction( NameToString(parent.aEventsStack[0].animName) );
						break;
					case 'Prepare':
					case 'PrepareTeleport':
						PrepareMagicAction();
						break;
					case 'RotatePrePerformAction':
						RotatePrePerformMagicAction();
						break;
					case 'PerformMagicAttack':
					case 'PerformTeleport':
						PerformMagicAction();
						break;
					case 'ContinueAction':
						ContinueMagicAction(parent.aEventsStack[0].animName);
						break;
					case 'BreakMagicAttack':
						BreakMagicAction();
						break;
					case 'UnblockMiscActions':
						parent.SetMiscStateActionsBlocked(false);
						break;
					default:
						NR_Notify("Unknown magic event! event = " + parent.aEventsStack[0].eventName + ", anim = " + parent.aEventsStack[0].animName);
						break;
				}
				// pop front - processed
				parent.aEventsStack.Erase(0);
			} else {
				ProcessMiscStateActions();
			}
		}
	}



	latent function ProcessMiscStateActions() {
		var stateName : name;

		if (parent.IsMiscStateActionsBlocked()) {
			return;
		}

		stateName = thePlayer.GetCurrentStateName();
		switch (stateName) {
			case 'Exploration':
				if ( theInput.IsActionJustPressed( 'DrinkPotion4' ) )
					PerformExplorationTeleport();
				break;
			case 'Swimming':
				if ( theInput.IsActionJustPressed( 'Finish' ) )
					PerformSwimmingAction();
				break;
			case 'HorseRiding':
				if ( theInput.IsActionJustPressed( 'VehicleAttack' ) )
					PerformHorseRidingAction();
				break;
			case 'Sailing':
			case 'SailingPassive':
				// PerformSailingAction();
				break;
			default:
				// NR_Debug("PerformMiscStateAction in unwrapped state: " + stateName);
				break;
		}
	}

	latent function CheckIsActionHeld(actionName : name) : bool {
		var startTime : float;

		startTime = theGame.GetEngineTimeAsSeconds();
		while (theGame.GetEngineTimeAsSeconds() - startTime < 0.2f) {
			SleepOneFrame();
			if ( !theInput.IsActionPressed( actionName ) ) {
				return false;
			}
		}
		return true;
	}

	latent function PerformExplorationTeleport() {
		//var hold : bool;

		//hold = CheckIsActionHeld('DrinkPotion4');
		//if ( hold ) {
		//	NR_Debug("PerformExplorationTeleport: EBAT_Roll");
		NR_GetReplacerSorceress().GotoCombatStateWithDodge( EBAT_Roll );
		//} else {
		//	NR_Debug("PerformExplorationTeleport: EBAT_Dodge");
		//	NR_GetReplacerSorceress().GotoCombatStateWithDodge( EBAT_Dodge );
		//}
	}

	latent function PerformSwimmingAction() {
		var target : CActor;
		target = thePlayer.GetTarget();
		NR_Debug("PerformSwimmingAction, target swimming = " + target.IsSwimming());
		if (!target || !target.IsSwimming())
			return;

		parent.SetActionType(ENR_WaterTrap);
		parent.SetMiscStateActionsBlocked(true);
		thePlayer.PlayEffect('q104_spell');  // q104_spell
		InitMagicAction("PerformSwimmingAction");
		Sleep(0.2f);
		PrepareMagicAction();
		RotatePrePerformMagicAction();
		Sleep(0.1f);
		PerformMagicAction();
		Sleep(0.3f);
		thePlayer.StopEffect('q104_spell');
		parent.SetMiscStateActionsBlocked(false);
	}

	latent function PerformHorseRidingAction() {
		var horseComp : W3HorseComponent;
		var inJump, inCanter, inGallop, leftSide : bool;
		var target : CActor;
		var actionType : ENR_MagicAction;
		var aspectName : name;
		var angleDist : float;

		horseComp = thePlayer.GetUsedHorseComponent();
		if (horseComp) {
			inJump = horseComp.OnCheckHorseJump();
			inCanter = horseComp.inCanter;
			inGallop = horseComp.inGallop;
		}
		NR_Debug("PerformHorseRidingAction: horseComp = " + horseComp + ", inJump = " + inJump + ", inCanter = " + inCanter + ", inGallop = " + inGallop);
	
		actionType = ENR_LightAbstract;
		aspectName = 'AttackHorse';
		parent.CorrectAspectAction(actionType, aspectName);
		parent.SetActionType(actionType);
		parent.SetMiscStateActionsBlocked(true);
		// inCanter > inGallop !

		leftSide = false;
		target = thePlayer.GetTarget();
		if (target) {
			angleDist = AngleDistance( thePlayer.GetHeading(), VecHeading( target.GetWorldPosition() - thePlayer.GetWorldPosition() ) );
			leftSide = (angleDist < 0.f);
		}

		if (inGallop || inCanter) {
			if (leftSide)
				thePlayer.ActionPlaySlotAnimationAsync( 'VEHICLE_SLOT', 'horse_magic_attack_gallop_left_underhand', 0.2, 0.3 );
			else
				thePlayer.ActionPlaySlotAnimationAsync( 'VEHICLE_SLOT', 'horse_magic_attack_gallop_right_underhand', 0.2, 0.3 );
		} else {
			if (leftSide)
				thePlayer.ActionPlaySlotAnimationAsync( 'VEHICLE_SLOT', 'horse_magic_attack_idle_left_underhand', 0.3, 0.5 );
			else
				thePlayer.ActionPlaySlotAnimationAsync( 'VEHICLE_SLOT', 'horse_magic_attack_idle_right_underhand', 0.3, 0.5 );
		}
	}
	// horse: thePlayer.GetUsedHorseComponent().GetUserCombatManager()
	//                   W3HorseComponent         
}

// !! QuenImpulse()

// dt - time passed,
// currentPos - current position (updated -> use for teleporting)
// targetPos - position is where entity is going to currently (updated)
// reachPos is where entity should go ideally
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

// pos is input wanted position, is corrected after func call
// set upMaxZ/downMaxZ to somewhat very small but > 0.f
latent function NR_GetSafeTeleportPoint(out pos : Vector, optional allowUnderwater : bool, optional upMaxZ : float, optional downMaxZ : float) : bool {
	var waterZ, newZ 	: float;
	var world         	: CWorld;

	world = theGame.GetWorld();
	// from IsPointSuitableForTeleport()
	//if ( !world.NavigationFindSafeSpot( pos, 0.5f, 0.5f*3, newPos ) )
	//{
	//NR_Debug("NR_GetSafeTeleportPoint::!NavigationFindSafeSpot");
	if (upMaxZ < 0.001f)
		upMaxZ = 7.f;

	if (downMaxZ < 0.001f)
		downMaxZ = 7.f;

	if ( world.NavigationComputeZ(pos, pos.Z - downMaxZ, pos.Z + upMaxZ, newZ) )
	{
		NR_Debug("NR_GetSafeTeleportPoint: NavigationComputeZ = " + newZ);
		pos.Z = newZ;
	}

	waterZ = world.GetWaterLevel( pos, true );
	NR_Debug("NR_GetSafeTeleportPoint: waterZ = " + waterZ);

	// make sure that floor pos found + it's above water + it's in zTolerance (7) range
	if ( world.PhysicsCorrectZ(pos, newZ) && (allowUnderwater || newZ > waterZ) && AbsF(newZ - pos.Z) < 7.f ) {
		NR_Debug("NR_GetSafeTeleportPoint: PhysicsCorrectZ = " + newZ);
		pos.Z = newZ;
		return true;
	}

	return false;
}

// actor is used to calculate capsule radius and height
latent function NR_GetTeleportMaxArchievablePoint( actor : CActor, from : Vector, to : Vector ) : Vector {
	var moveVec, result, normal : Vector;
	var newZ : float;
	var capsuleRadius : float;
	var capsuleHeight : float;

	capsuleRadius = ((CMovingPhysicalAgentComponent)actor.GetMovingAgentComponent()).GetCapsuleRadius();
	capsuleHeight = ((CMovingPhysicalAgentComponent)actor.GetMovingAgentComponent()).GetCapsuleHeight();
	from.Z += capsuleHeight * 0.75f;
	to.Z += capsuleHeight * 0.75f;
	NR_Debug("NR_GetTeleportMaxArchievablePoint: capsuleHeight = " + capsuleHeight);

	// to avoid stopping inside actor body
	moveVec = VecNormalize(to - from);
	from += moveVec * 1.f;
	if ( theGame.GetWorld().StaticTrace(from, to, /*capsuleRadius,*/ result, normal, NR_GetStandartCollisionNames()) ) {
		NR_Debug("NR_GetTeleportMaxArchievablePoint: StaticTrace = true, result = " + VecToString(result) + ", to = " + VecToString(to));
	} else {
		NR_Debug("NR_GetTeleportMaxArchievablePoint: StaticTrace = false");
		result = to;
	}

	if ( theGame.GetWorld().PhysicsCorrectZ(result, newZ) ) {
		result.Z = newZ;
	}
	// result.Z -= capsuleHeight * 0.75f;
	// result -= moveVec * capsuleRadius;
	return result;
}

function NR_GetStandartCollisionNames() : array<name> {
	var standartCollisions : array<name>;

	standartCollisions.PushBack('Debris');
	standartCollisions.PushBack('Character');
	standartCollisions.PushBack('CommunityCollidables');
	standartCollisions.PushBack('Terrain');
	standartCollisions.PushBack('Static');
	standartCollisions.PushBack('Projectile');		
	standartCollisions.PushBack('ParticleCollider'); 
	standartCollisions.PushBack('Ragdoll');
	standartCollisions.PushBack('Destructible');
	standartCollisions.PushBack('RigidBody');
	standartCollisions.PushBack('Foliage');
	standartCollisions.PushBack('Boat');
	standartCollisions.PushBack('BoatDocking');
	standartCollisions.PushBack('Door');
	standartCollisions.PushBack('Platforms');
	standartCollisions.PushBack('Corpse');
	standartCollisions.PushBack('Fence');
	standartCollisions.PushBack('Water');
	return standartCollisions;
}

latent function NR_ShowLightningFx(from : Vector, to : Vector, showHitFx : bool, optional lightningFxName, hitFxName : name) {
    var nr_manager : NR_MagicManager = NR_GetMagicManager();
    var action : NR_MagicLightning;

    action = new NR_MagicLightning in nr_manager;
    action.drainStaminaOnPerform = false;
    nr_manager.AddActionScripted(action);
    action.OnInit();
    action.OnPrepare();
    if ( IsNameValid(lightningFxName) )
    	action.m_fxNameMain = lightningFxName;
    if ( IsNameValid(hitFxName) )
    	action.m_fxNameHit = hitFxName;

    action.OnPerformReboundFromPosToPos(to, from, showHitFx);
    action.OnPerformed(true);
}

latent function NR_StartLightningToNode(from : Vector, to : CNode, lightningFxName : name, optional hitFxName : name, optional stopAfter : float) : CEntity {
    var template : CEntityTemplate;
    var lightningEntity, hitEntity : CEntity;

    template = (CEntityTemplate)LoadResourceAsync("nr_lightning_fx", false);
    lightningEntity = theGame.CreateEntity(template, from);
   	NR_Debug("NR_StartLightningToNode: lightningFxName = " + lightningFxName + ", to = " + to + " = " + lightningEntity.PlayEffect(lightningFxName, to));

    if (IsNameValid(hitFxName)) {
    	template = (CEntityTemplate)LoadResourceAsync("nr_dummy_hit_fx", false);
    	hitEntity = theGame.CreateEntity(template, to.GetWorldPosition(), to.GetWorldRotation());
    	Sleep(0.1f);
    	NR_Debug("NR_StartLightningToNode: hitFxName = " + hitFxName + " = " + hitEntity.PlayEffect(hitFxName));
    	hitEntity.DestroyAfter(5.f);
    }
    
    if (stopAfter > 0.f) {
    	lightningEntity.StopAllEffectsAfter(stopAfter);
    }

    return lightningEntity;
}

/*
please prefer node-targeted version
latent function NR_StartLightningToPos(from : Vector, to : Vector, lightningFxName : name, optional hitFxName : name, optional stopAfter : float) : CEntity {
    var template : CEntityTemplate;
    var lightningEntity, hitEntity : CEntity;

    template = LoadResourceAsync("nr_lightning_fx", false);
    lightningEntity = theGame.CreateEntity(template, from);

    template = LoadResourceAsync("nr_dummy_hit_fx", false);
    hitEntity = theGame.CreateEntity(template, to);

   	lightningEntity.PlayEffect(lightningFxName, hitEntity);

    if (IsNameValid(hitFxName)) {
    	template = LoadResourceAsync("nr_dummy_hit_fx", false);
    	hitEntity = theGame.CreateEntity(template, to);
    	Sleep(0.1f);
    	hitEntity.PlayEffect(hitFxName);
    }
    
    if (stopAfter > 0.f) {
    	lightningEntity.StopAllEffectsAfter(stopAfter);
    }

    return lightningEntity;
}
*/

latent function NR_CreatePortal( waypointTag : name, worldName : String, optional activeTime : float ) {
    var nr_manager : NR_MagicManager = NR_GetMagicManager();
    var action : NR_MagicFastTravelTeleport;
    var position : Vector;

    NR_Debug("NR_CreatePortal: waypointTag = " + waypointTag + ", worldName = " + worldName);
    if (!nr_manager)
        return;

    action = new NR_MagicFastTravelTeleport in nr_manager;
    action.drainStaminaOnPerform = false;
    //action.SetTravelData('newreplacers_prologue_snow_arena_center_wp', AN_Prologue_Village, theGame.GetCommonMapManager().GetCurrentArea());
    action.SetTravelData(waypointTag, AreaNameToType(worldName), theGame.GetCommonMapManager().GetCurrentArea());
    action.SetDoStaticTrace( false );
    if (activeTime > 1.f) {
    	action.SetActiveTime(activeTime);
    }
    nr_manager.AddActionScripted(action);
    action.OnInit();
    action.OnPrepare();
    action.OnPerform();
}

function NR_FindActorInScene(voicetag : name, out actorRes : CActor) : bool {
	var 	entities : array<CGameplayEntity>;
	var  		actor : CActor;
	var  		i 	: int;

	FindGameplayEntitiesInRange(entities, thePlayer, 5.f, 500);
	for (i = 0; i < entities.Size(); i += 1) {
		actor = (CActor)entities[i];
		NR_Debug("NR_FindActorInScene: actor: " + entities[i].GetReadableName() + ", " + actor.IsInNonGameplayCutscene() + ", " + actor.GetVoicetag());
		if (actor && actor.IsAlive() && actor.IsInNonGameplayCutscene() && actor.GetVoicetag() == voicetag) {
			actorRes = actor;
			return true;
		}
	}
	NR_Debug("NR_FindActorInScene: [" + voicetag + "] not found!");
	return false;
}
