function NR_Notify(message : String, optional seconds : float)
{
	if (seconds < 1.f)
		seconds = 3.f;
    theGame.GetGuiManager().ShowNotification(message, seconds * 1000.f, false);
    NR_Debug(message);
}

quest function NR_Notify_Quest(message : String, optional seconds : float) {
	NR_Notify(message, seconds);
}

function NR_Debug(message : String, optional removeOnRelease : bool)
{
    LogChannel('NR_DEBUG', "(" + FloatToStringPrec(theGame.GetEngineTimeAsSeconds(), 3) + "): " + message);
}

function NR_Error(message : String)
{
    LogChannel('NR_ERROR', "(" + FloatToStringPrec(theGame.GetEngineTimeAsSeconds(), 3) + "): " + message);
}

function NR_stringByItemUID(inv : CInventoryComponent, itemId : SItemUniqueId) : String {
	if ( inv.IsIdValid(itemId) )
		return NameToString( inv.GetItemName(itemId) );
	else
		return "<invalid>";
}


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
		case ENR_SpecialServant:
			return 'ENR_SpecialServant';
		case ENR_SpecialMeteor:
			return 'ENR_SpecialMeteor';
		case ENR_SpecialTornado:
			return 'ENR_SpecialTornado';
		case ENR_SpecialShield:
			return 'ENR_SpecialShield';
		case ENR_Teleport:
			return 'ENR_Teleport';
		case ENR_HandFx:
			return 'ENR_HandFx';
		case ENR_FastTravelTeleport:
			return 'ENR_FastTravelTeleport';
		case ENR_SpecialLightningFall:
			return 'ENR_SpecialLightningFall';
		case ENR_SpecialMeteorFall:
			return 'ENR_SpecialMeteorFall';
		case ENR_SpecialLumos:
			return 'ENR_SpecialLumos';
		case ENR_SpecialPolymorphism:
			return 'ENR_SpecialPolymorphism';
		case ENR_SpecialField:
			return 'ENR_SpecialField';
		case ENR_WaterTrap:
			return 'ENR_WaterTrap';
		default:
			NR_Error("ENR_NameToMA: UNKNOWN action = " + action);
			return 'ENR_Unknown';
	}
}

function ENR_MAToLocString(action : ENR_MagicAction) : String {
	var id : int;
	switch (action) {
		case ENR_LightAbstract:
			id = 2115940118;
			break;
		case ENR_ThrowAbstract:
			id = 2115940140;
			break;
		case ENR_Slash:
			id = 2115940122;
			break;
		case ENR_Lightning:
			id = 2115940141;
			break;
		case ENR_Projectile:
			id = 2115940142;
			break;
		case ENR_ProjectileWithPrepare:
			id = 2115940142;
			break;
		case ENR_HeavyAbstract:
			id = 2115940146;
			break;
		case ENR_Rock:
			id = 2115940148;
			break;
		case ENR_BombExplosion:
			id = 2115940149;
			break;
		case ENR_RipApart:
			id = 2115940160;
			break;
		case ENR_CounterPush:
			id = 2115940151;
			break;
		case ENR_SpecialAbstract:
			id = 2115940152;
			break;
		case ENR_SpecialAbstractAlt:
			id = 2115940158;
			break;
		case ENR_SpecialControl:
			id = 2115940154;
			break;
		case ENR_SpecialServant:
			id = 2115940157;
			break;
		case ENR_SpecialMeteor:
			id = 2115940155;
			break;
		case ENR_SpecialTornado:
			id = 2115940153;
			break;
		case ENR_SpecialShield:
			id = 2115940156;
			break;
		case ENR_Teleport:
			id = 2115940589;
			break;
		case ENR_HandFx:
			id = 2115940143;
			break;
		case ENR_FastTravelTeleport:
			id = 2115940145;
			break;
		case ENR_SpecialLightningFall:
			id = 2115940162;
			break;
		case ENR_SpecialMeteorFall:
			id = 2115940164;
			break;
		case ENR_SpecialLumos:
			id = 2115940165;
			break;
		case ENR_SpecialField:
			id = 2115940163;
			break;
		case ENR_SpecialPolymorphism:
			id = 2115940166;
			break;
		case ENR_WaterTrap:
			id = 2115940168;
			break;
		default:
			id = 147158; // error
			break;
	}

	return GetLocStringById(id);
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
		case 'ENR_SpecialServant':
			return ENR_SpecialServant;
		case 'ENR_SpecialMeteor':
			return ENR_SpecialMeteor;
		case 'ENR_SpecialTornado':
			return ENR_SpecialTornado;
		case 'ENR_SpecialShield':
			return ENR_SpecialShield;
		case 'ENR_Teleport':
			return ENR_Teleport;
		case 'ENR_HandFx':
			return ENR_HandFx;
		case 'ENR_FastTravelTeleport':
			return ENR_FastTravelTeleport;
		case 'ENR_SpecialLightningFall':
			return ENR_SpecialLightningFall;
		case 'ENR_SpecialMeteorFall':
			return ENR_SpecialMeteorFall;
		case 'ENR_SpecialField':
			return ENR_SpecialField;
		case 'ENR_SpecialLumos':
			return ENR_SpecialLumos;
		case 'ENR_SpecialPolymorphism':
			return ENR_SpecialPolymorphism;
		case 'ENR_WaterTrap':
			return ENR_WaterTrap;
		default:
			NR_Notify("ENR_NameToMA: UNKNOWN name = " + actionName);
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
		case ENR_ColorRandom:
			return 'ENR_ColorRandom';
		default:
			return 'ENR_ColorWhite';
	}
}

function NR_FinalizeColor(color : ENR_MagicColor) : ENR_MagicColor {
	if (color != ENR_ColorRandom)
		return color;
	
	return (ENR_MagicColor)NR_GetRandomGenerator().nextRange(2, 10);
}

function ENR_MCToStringShort(color : ENR_MagicColor) : String {
	return StrLower( StrMid(NameToString(ENR_MCToName(color)), 9) );
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
		case 'ENR_ColorRandom':
			return ENR_ColorRandom;
		default:
			return ENR_ColorWhite;
	}
}

function NR_StrRed(str : String, optional dark : bool) : String {
	if (!dark)
		return "<font color=\"#FF0000\">" + str + "</font>";
	else
		return "<font color=\"#990000\">" + str + "</font>";
}

function NR_StrGreen(str : String, optional dark : bool) : String {
	if (!dark)
		return "<font color=\"#00FF00\">" + str + "</font>";
	else
		return "<font color=\"#009900\">" + str + "</font>";
}

function NR_StrYellow(str : String, optional dark : bool) : String {
	if (!dark)
		return "<font color=\"#FFFF00\">" + str + "</font>";
	else
		return "<font color=\"#999900\">" + str + "</font>";
}

function NR_StrBlue(str : String, optional dark : bool) : String {
	if (!dark)
		return "<font color=\"#0000FF\">" + str + "</font>";
	else
		return "<font color=\"#000099\">" + str + "</font>";
}

function NR_StrLightBlue(str : String, optional dark : bool) : String {
	if (!dark)
		return "<font color=\"#00FFFF\">" + str + "</font>";
	else
		return "<font color=\"#009999\">" + str + "</font>";
}

function NR_PercToHex(perc : int) : String {
	switch (perc) {
		case 100:
			return "FF";
		case 99:
			return "FC";
		case 98:
			return "FA";
		case 97:
			return "F7";
		case 96:
			return "F5";
		case 95:
			return "F2";
		case 94:
			return "F0";
		case 93:
			return "ED";
		case 92:
			return "EB";
		case 91:
			return "E8";
		case 90:
			return "E6";
		case 89:
			return "E3";
		case 88:
			return "E0";
		case 87:
			return "DE";
		case 86:
			return "DB";
		case 85:
			return "D9";
		case 84:
			return "D6";
		case 83:
			return "D4";
		case 82:
			return "D1";
		case 81:
			return "CF";
		case 80:
			return "CC";
		case 79:
			return "C9";
		case 78:
			return "C7";
		case 77:
			return "C4";
		case 76:
			return "C2";
		case 75:
			return "BF";
		case 74:
			return "BD";
		case 73:
			return "BA";
		case 72:
			return "B8";
		case 71:
			return "B5";
		case 70:
			return "B3";
		case 69:
			return "B0";
		case 68:
			return "AD";
		case 67:
			return "AB";
		case 66:
			return "A8";
		case 65:
			return "A6";
		case 64:
			return "A3";
		case 63:
			return "A1";
		case 62:
			return "9E";
		case 61:
			return "9C";
		case 60:
			return "99";
		case 59:
			return "96";
		case 58:
			return "94";
		case 57:
			return "91";
		case 56:
			return "8F";
		case 55:
			return "8C";
		case 54:
			return "8A";
		case 53:
			return "87";
		case 52:
			return "85";
		case 51:
			return "82";
		case 50:
			return "80";
		case 49:
			return "7D";
		case 48:
			return "7A";
		case 47:
			return "78";
		case 46:
			return "75";
		case 45:
			return "73";
		case 44:
			return "70";
		case 43:
			return "6E";
		case 42:
			return "6B";
		case 41:
			return "69";
		case 40:
			return "66";
		case 39:
			return "63";
		case 38:
			return "61";
		case 37:
			return "5E";
		case 36:
			return "5C";
		case 35:
			return "59";
		case 34:
			return "57";
		case 33:
			return "54";
		case 32:
			return "52";
		case 31:
			return "4F";
		case 30:
			return "4D";
		case 29:
			return "4A";
		case 28:
			return "47";
		case 27:
			return "45";
		case 26:
			return "42";
		case 25:
			return "40";
		case 24:
			return "3D";
		case 23:
			return "3B";
		case 22:
			return "38";
		case 21:
			return "36";
		case 20:
			return "33";
		case 19:
			return "30";
		case 18:
			return "2E";
		case 17:
			return "2B";
		case 16:
			return "29";
		case 15:
			return "26";
		case 14:
			return "24";
		case 13:
			return "21";
		case 12:
			return "1F";
		case 11:
			return "1C";
		case 10:
			return "1A";
		case 9:
			return "17";
		case 8:
			return "14";
		case 7:
			return "12";
		case 6:
			return "0F";
		case 5:
			return "0D";
		case 4:
			return "0A";
		case 3:
			return "08";
		case 2:
			return "05";
		case 1:
			return "03";
		case 0:
		default:
			return "00";
	}
}

// creates formatted string where perc = [0-100]% of color intensity
function NR_StrRGB(str : String, redPerc : int, greenPerc : int, bluePerc : int) : String {
	return "<font color=\"#" + NR_PercToHex(redPerc) + NR_PercToHex(greenPerc) + NR_PercToHex(bluePerc) + "\">" + str + "</font>";
}

function NR_ENRSlotByCategory(category : name) : ENR_AppearanceSlots {
	switch (category) {
		case 'armor':
			return ENR_GSlotArmor;
		case 'gloves':
			return ENR_GSlotGloves;
		case 'pants':
			return ENR_GSlotPants;
		case 'boots':
			return ENR_GSlotBoots;
		case 'head':
			return ENR_GSlotHead;
		case 'hair':
			return ENR_GSlotHair;
		default:
			return ENR_GSlotUnknown;
	}
}

function NR_CategoryByENRSlot(slot : ENR_AppearanceSlots) : name {
	switch (slot) {
		case ENR_GSlotArmor:
			return 'armor';
		case ENR_GSlotGloves:
			return 'gloves';
		case ENR_GSlotPants:
			return 'pants';
		case ENR_GSlotBoots:
			return 'boots';
		case ENR_GSlotHead:
			return 'head';
		case ENR_GSlotHair:
			return 'hair';
		default:
			return 'UNKNOWN';
	}
}

function NR_EEquipmentSlotToENRSlot(slot : EEquipmentSlots) : ENR_AppearanceSlots {
	switch (slot) {
		case EES_Armor:
			return ENR_GSlotArmor;
		case EES_Gloves:
			return ENR_GSlotGloves;
		case EES_Pants:
			return ENR_GSlotPants;
		case EES_Boots:
			return ENR_GSlotBoots;
		default:
			return ENR_GSlotUnknown;
	}
}

function NR_PlaySceneF(path : string, optional input : string) {
	var scene : CStoryScene;
    var null: String;

    if (input == null) {
		input = "Input";
	}
	
    // -> SET SCENE PATH
    scene = (CStoryScene)LoadResource(path, true);
	if ( !scene ) {
		NR_Error("NR_PlaySceneF: !scene = " + path);
		return;
	}
	NR_Debug("NR_PlaySceneF: path = [" + input + "] " + path);
    theGame.GetStorySceneSystem().PlayScene(scene, input);
}
