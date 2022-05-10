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

//action - stamina action type
//fixedValue - fixed value to drain, used only when ESAT_FixedValue is used
//abilityName - name of the ability to use when passing ESAT_Ability
//dt - if set then then stamina cost is treated as cost per second and thus multiplied by dt
//costMult - if set (other than 0 or 1) then the actual cost is multiplied by this value

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

	// shared stuff
	public var aEventsStack 	: array<SNR_MagicEvent>;
	public var aData 			: CPreAttackEventData;
	public var aIsAlternate 	: Bool;
	public var aTeleportPos		: Vector;
	
	protected var aHandEffect 	: name;
	protected var i            	: int;
	protected var aName 			: String;
	default aHandEffect = '';
	default aName = "";
	
	function InitDefaults() {
		sMap.Resize(6);
		for (i = 0; i < 6; i += 1) {
			sMap[i] = new NR_Map in thePlayer;
		}
		SetSlashAttacksDef();
		SetThrowAttacksDef();
		SetRockAttacksDef();
		SetBombAttacksDef();
		SetSpecialAttacksDef();
		SetHandFXDef();
		SetTeleportFXDef();
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
		sMap[ST_Aard].setN("meteor_entity", 'eredin_meteorite');
		sMap[ST_Yrden].setN("meteor_entity", 'meteor_strong');
		sMap[ST_Igni].setN("meteor_entity", 'ciri_meteor');
		sMap[ST_Quen].setN("meteor_entity", 'ciri_meteor');
		sMap[ST_Axii].setN("meteor_entity", 'ciri_meteor');
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
	function UpdateFistsLevel(id: SItemUniqueId) {
		var playerLevel : int;
		var i : int;
		playerLevel = GetWitcherPlayer().GetLevel();
		NRD("UpdateFistsLevel: Player Level: " + playerLevel);

		// vanilla logic from 'GenerateItemLevel', reduced to /5
		for (i = 1; i < playerLevel; i += 1) {
			if (FactsQuerySum("StandAloneEP1") > 0 || FactsQuerySum("NewGamePlus") > 0) {
				NR_Notify("NewGamePlus || StandAloneEP1");
				thePlayer.inv.AddItemCraftedAbility(id, 'nr_autogen_dmg', true );
				//thePlayer.inv.AddItemCraftedAbility(id, 'autogen_fixed_steel_dmg', true );
				//thePlayer.inv.AddItemCraftedAbility(id, 'autogen_fixed_silver_dmg', true ); 
			} else {
				NR_Notify("NOT NewGamePlus || StandAloneEP1");
				thePlayer.inv.AddItemCraftedAbility(id, 'nr_autogen_dmg', true );
				//thePlayer.inv.AddItemCraftedAbility(id, 'autogen_steel_dmg', true );
				//thePlayer.inv.AddItemCraftedAbility(id, 'autogen_silver_dmg', true );
			}
		}
		PrintItem(thePlayer.inv, id);
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
		var sign : ESignType;

		sign = GetWitcherPlayer().GetEquippedSign();
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
			NRD("throw: sign: = " + sign);
			return sMap[sign].getI("throw_attack_type", (int)ENR_Lightning);
		} else if (StrStartsWith(aName, "woman_sorceress_attack_arcane")) {
			return ENR_BombExplosion;
		} else if (StrStartsWith(aName, "woman_sorceress_special_attack_fireball")) {
			return ENR_SpecialMeteor;
		} else if (StrStartsWith(aName, "woman_sorceress_taunt_02")) { // !!! temp
			return ENR_SpecialSphere;
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
		} else {
			data.hitFX 				= 'hit_electric';
			data.hitParriedFX 		= 'hit_electric';
			data.hitBackFX 			= 'hit_electric';
			data.hitBackParriedFX 	= 'hit_electric';
		}
		aData = data;
	}
}
state MagicLoop in NR_MagicManager {
	var mAction : NR_MagicAction;

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
	latent function PrepareMagicAction(animName : String) {
		var type : ENR_MagicAction;

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
				//mAction = new NR_MagicSpecialMeteor in thePlayer;
				break;
			case ENR_SpecialMeteor:
				mAction = new NR_MagicSpecialMeteor in thePlayer;
				break;
			case ENR_SpecialTornado:
				//mAction = new NR_MagicSpecialMeteor in thePlayer;
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