/* This class for Sorceress solves magic attack entities, effects, hit effects, fist weapon etc
	instead of NPC's w2behtree and its CBTTask classes */

	/*ice_spear - карантир
sorceress_lightingball - желтый компактный фаерболл
snowball - снежок
eredin_meteorite - ледяной метеорит*/

enum ENR_MagicAttack {
		// dummy - when doesn't matter
	ENR_Unknown,
		// light
	ENR_Slash,
		// light "throw"
	ENR_Lightning,
	ENR_Projectile,
	ENR_ProjectileWithPrepare,
		// heavy
	ENR_Rock,	
	ENR_ArcaneExplosion,
	ENR_RipApart,
		// defense
	ENR_CounterPush,
	ENR_Teleport,
		// special
	ENR_SpecialControl, // axii - бессрочный контроль над противником? кроме боссов
	ENR_SpecialGolem,   // yrden - призыв случайного голема
	ENR_SpecialMeteor,   // igni - метеорит
	ENR_SpecialTornado, // aard - торнадо?
	ENR_SpecialSphere // quen - сфера наносит урон молниями?
}
struct SNR_MagicDef {
	var resourceName 	: name;
	var attackType 		: ENR_MagicAttack;
	// to handle attack correctly for some witcher sign: resourceName, attackType
}
struct SNR_MagicEvent {
	var eventName 		: name;
	var animName 		: name;
	var animTime 		: float;
	//var eventDuration	: float;
}
statemachine class NR_MagicManager {
	// set on Init
	public var aMap		: array<NR_Map>;
	var aCollisionGroups 	: array<name>;
	var handFXDef 			: array<SNR_MagicDef>;
	var teleportFXDef 		: array< array<SNR_MagicDef> >;
	var slashAttacksDef 	: array<SNR_MagicDef>;
	var rockAttacksDef 		: array<SNR_MagicDef>;
	var specialAttacksDef 	: array<SNR_MagicDef>;

	// shared stuff
	var aSign 			: ESignType;
	var aHandEffect 	: name;
	var i, j            : int;
	default aHandEffect = '';

	// shared a(ttack) stuff
	var aData 			: CPreAttackEventData;
	var aTeleportPos	: Vector;
	var aTeleportRot	: EulerAngles;
	var aTeleportCamera : CStaticCamera;
	var aName 			: String;
	default aName = "";

	var aEventsStack 	: array<SNR_MagicEvent>;

	// extra funs
	function Create_SNR_MDef(resourceName : name, optional attackType : ENR_MagicAttack) : SNR_MagicDef {
		var mDef : SNR_MagicDef;
		mDef.resourceName = resourceName;
		mDef.attackType = attackType;

		return mDef;
	}
	function Create_SNR_MDef_2D(resourceName1, resourceName2 : name) : array<SNR_MagicDef> {
		var vec : array<SNR_MagicDef>;
		vec.PushBack( Create_SNR_MDef(resourceName1) );
		vec.PushBack( Create_SNR_MDef(resourceName2) );
		return vec;
	}

	function InitDefault() {
		//aCollisionGroups.PushBack('Character');
		//aCollisionGroups.PushBack('CommunityCollidables');
		aCollisionGroups.PushBack('Terrain');
		aCollisionGroups.PushBack('Static');
		//aCollisionGroups.PushBack('Debris');
		aCollisionGroups.PushBack('Ragdoll');
		aCollisionGroups.PushBack('Destructible');
		aCollisionGroups.PushBack('RigidBody');
		aCollisionGroups.PushBack('Foliage');
		aCollisionGroups.PushBack('Boat');
		aCollisionGroups.PushBack('BoatDocking');
		aCollisionGroups.PushBack('Door');
		aCollisionGroups.PushBack('Platforms');
		aCollisionGroups.PushBack('Corpse');
		aCollisionGroups.PushBack('Fence');
		aCollisionGroups.PushBack('Water');

		aMap.Resize(6);
		for (i = 0; i < 6; i += 1) {
			aMap[i] = new NR_Map in thePlayer;
		}
		SetSlashAttacksDef();
		SetThrowAttacksDef();
		SetRockAttacksDef();
		SetHandFXDef();
		SetTeleportFXDef();
	}
	function SetThrowAttacksDef() {
		aMap[ST_Aard].setI("throw_attack_type", ENR_Lightning);
		aMap[ST_Aard].setN("lightning_fx", 'lightning_yennefer');
		aMap[ST_Aard].setN("throw_dummy_fx", 'hit_electric');

		aMap[ST_Yrden].setI("throw_attack_type", ENR_ProjectileWithPrepare);
		aMap[ST_Yrden].setN("throw_entity", 'arcane_projectile');
		
		aMap[ST_Igni].setI("throw_attack_type", ENR_ProjectileWithPrepare);
		aMap[ST_Igni].setN("throw_entity", 'sorceress_fireball');

		aMap[ST_Quen].setI("throw_attack_type", ENR_Lightning);
		aMap[ST_Quen].setN("lightning_fx", 'lightning_lynx');
		aMap[ST_Quen].setN("throw_dummy_fx", 'hit_electric');

		aMap[ST_Axii].setI("throw_attack_type", ENR_ProjectileWithPrepare);
		aMap[ST_Axii].setN("throw_entity", 'ice_spear');
	}
	function SetRockAttacksDef() {
		aMap[ST_Aard].setN("rock_proj", 'sorceress_stone_proj');
		aMap[ST_Aard].setN("rock_push_entity", 'keira_metz_cast');
				
		aMap[ST_Yrden].setN("rock_proj", 'sorceress_stone_proj');
		aMap[ST_Yrden].setN("rock_push_entity", 'keira_metz_cast');

		aMap[ST_Igni].setN("rock_proj", 'ep2_sorceress_stone_proj');
		aMap[ST_Igni].setN("rock_push_entity", 'lynx_cast');

		aMap[ST_Quen].setN("rock_proj", 'ep2_sorceress_stone_proj');
		aMap[ST_Quen].setN("rock_push_entity", 'lynx_cast');

		aMap[ST_Axii].setN("rock_proj", 'sorceress_wood_proj');
		aMap[ST_Axii].setN("rock_push_entity", 'keira_metz_cast');
	}
	function SetSlashAttacksDef() {
		aMap[ST_Aard].setN("slash_entity", 'magic_attack_lightning');
		aMap[ST_Yrden].setN("slash_entity", 'magic_attack_arcane');
		aMap[ST_Igni].setN("slash_entity", 'magic_attack_fire');
		aMap[ST_Quen].setN("slash_entity", 'ep2_magic_attack_lightning');
		aMap[ST_Axii].setN("slash_entity", 'magic_attack_lightning');
	}
	function SetHandFXDef() {
		aMap[ST_Aard].setN("hand_fx", 'hand_fx_yennefer');
		aMap[ST_Yrden].setN("hand_fx", 'hand_fx_philippa');
		aMap[ST_Igni].setN("hand_fx", 'hand_fx_triss');
		aMap[ST_Quen].setN("hand_fx", 'hand_fx_lynx');
		aMap[ST_Axii].setN("hand_fx", 'hand_fx_keira');
	}
	function SetTeleportFXDef(optional newTeleportFXDef : array< array<SNR_MagicDef> >) {
		aMap[ST_Aard].setN("teleport_in_fx", 'teleport_in_yennefer');
		aMap[ST_Aard].setN("teleport_out_fx", 'teleport_out_yennefer');

		aMap[ST_Yrden].setN("teleport_in_fx", 'teleport_in_triss');
		aMap[ST_Yrden].setN("teleport_out_fx", 'teleport_out_keira');

		aMap[ST_Igni].setN("teleport_in_fx", 'teleport_in_triss');
		aMap[ST_Igni].setN("teleport_out_fx", 'teleport_out_triss');

		aMap[ST_Quen].setN("teleport_in_fx", 'teleport_in_triss');
		aMap[ST_Quen].setN("teleport_out_fx", 'teleport_out_triss');

		aMap[ST_Axii].setN("teleport_in_fx", 'teleport_in_triss');
		aMap[ST_Axii].setN("teleport_out_fx", 'teleport_out_keira');
	}
	function UpdateFistsLevel(id: SItemUniqueId) {
		var playerLevel : int;
		var i : int;
		playerLevel = GetWitcherPlayer().GetLevel();
		NR_Debug("UpdateFistsLevel: Player Level: " + playerLevel);

		// vanilla logic from 'GenerateItemLevel', reduced to /5
		for (i = 1; i < 10; i += 1) {
			if (FactsQuerySum("StandAloneEP1") > 0 || FactsQuerySum("NewGamePlus") > 0) {
				NR_Notify("NewGamePlus || StandAloneEP1");
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_fixed_steel_dmg', true );
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_fixed_silver_dmg', true ); 
			} else {
				NR_Notify("NOT NewGamePlus || StandAloneEP1");
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_steel_dmg', true );
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_silver_dmg', true );
			}
		}
		PrintItem(thePlayer.inv, id);
	}
	function HandFX(enable: Bool, optional onlyIfActive: Bool) {
		var newHandEffect : name;

		// update sign
		aSign = GetWitcherPlayer().GetEquippedSign();

		if (aHandEffect == '' && onlyIfActive) {
			return;
		}

		newHandEffect = aMap[aSign].getN("hand_fx");

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
	function GetAttackType() : ENR_MagicAttack {
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
			NR_Debug("throw: aSign: = " + aSign);
			return aMap[aSign].getI("throw_attack_type", 0);
		} else if (StrStartsWith(aName, "woman_sorceress_attack_arcane")) {
			return ENR_ArcaneExplosion;
		} else {
			NR_Debug("Unknown attack: aName = " + aName);
			return ENR_Unknown;
		}
	}
	function OnPreAttackEvent(animName : name, out data : CPreAttackEventData)
	{
		//switch (GetAttackType()) {
		//	case ENR_Slash:
		// for any?
		if (aSign == ST_Igni) {
			data.hitFX 				= 'fire_hit';
			data.hitParriedFX 		= 'fire_hit';
			data.hitBackFX 			= 'fire_hit';
			data.hitBackParriedFX 	= 'fire_hit';
		} else if (aSign == ST_Quen) {
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
		//		break;
		//	default:
		//		break;
		//}
		// used only to decide Slash effect direction
		aData = data;
	}
}
state MagicLoop in NR_MagicManager {
	// a(ttack) stuff //
	var aTarget			: CActor;
	var aDestroyable	: W3DestroyableClue;
	var aPos 			: Vector;
	var aRot 			: EulerAngles;
	var aActive 		: bool;

	var aEffect 		: name;
	var aEffectHit		: name;
	var aDummyEntity	: CEntity;
	var aProjectiles 	: array<W3AdvancedProjectile>;
	var aStartPositions : array<Vector>;
	var aFinalPositions : array<Vector>;
	// loop stuff //
	var lStartTime 	: float;
	var lPrevTime 	: float;
	var lLoopActive	: bool;

	event OnEnterState( prevStateName : name )
	{
		MainLoop();
	}
	event OnLeaveState( prevStateName : name )
	{
	}
	function CleanaData() {
		parent.aName = "";
		aEffect = '';
		aEffectHit = '';
		aTarget = NULL;
		aDestroyable = NULL;
		lLoopActive = false;
		aStartPositions.Clear();
		aFinalPositions.Clear();
		// aDummyEntity = NULL; what for?

		while (aProjectiles.Size() > 0) {
			if (aProjectiles.Last())
				aProjectiles.Last().DestroyAfter(5.f);
			aProjectiles.PopBack();
		}
	}
	entry function MainLoop() {
		while(true) {
			while (parent.aEventsStack.Size() > 0) {
				NR_Debug("MAIN LOOP: event = " + parent.aEventsStack[0].eventName + ", time: " + EngineTimeToFloat(theGame.GetEngineTime()));
				switch (parent.aEventsStack[0].eventName) {
					case 'Spawn':
					case 'Prepare':
						Prepare( NameToString(parent.aEventsStack[0].animName) );
						break;
					case 'Shoot':
					case 'PerformMagicAttack':
						PerformMagicAttack();
						break;
					case 'BreakMagicAttack':
						BreakMagicAttack();
						break;
					case 'PrepareTeleport':
						PrepareTeleport();
						break;
					case 'PerformTeleport':
						PerformTeleport();
						break;
					case 'PerformLoop':
						PerformLoop();
						SleepOneFrame(); // because another loop event was added, stack is not empty
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

	latent function PrepareTeleport() {
		var template : CEntityTemplate;
		var shiftVec  : Vector;

		// update sign
		parent.aSign = GetWitcherPlayer().GetEquippedSign();

		thePlayer.PlayEffect( parent.aMap[parent.aSign].getN("teleport_out_fx") );

		shiftVec = parent.aTeleportPos - thePlayer.GetWorldPosition();
		template = (CEntityTemplate)LoadResourceAsync("nr_static_camera");
		// YEAH, that simple!
		parent.aTeleportCamera = (CStaticCamera)theGame.CreateEntity( template, theCamera.GetCameraPosition() + shiftVec, theCamera.GetCameraRotation() );
		if (!parent.aTeleportCamera) {
			NR_Notify("PrepareTeleport: No camera!!");
			return;
		}
		NR_Notify("PrepareTeleport: Run.");
		//parent.aTeleportCamera.activationDuration = 0.5f; // in w2ent already
		//parent.aTeleportCamera.deactivationDuration = 0.5f; // in w2ent already
		parent.aTeleportCamera.Run();
		
		Sleep(0.2f); // wait for effect a bit
		thePlayer.SetGameplayVisibility(false);
		thePlayer.SetVisibility(false);
		thePlayer.TeleportWithRotation(parent.aTeleportPos, parent.aTeleportRot);
	}
	latent function PerformTeleport() {
		thePlayer.PlayEffect( parent.aMap[parent.aSign].getN("teleport_in_fx") );

		if (!parent.aTeleportCamera) {
			NR_Notify("PerformTeleport: No camera!!");
			return;
		}
		NR_Notify("PerformTeleport.");
		Sleep(0.2f);  // wait for effect a bit
		thePlayer.SetGameplayVisibility(true);
		thePlayer.SetVisibility(true);

		Sleep(0.1f);
		parent.aTeleportCamera.Stop();
		parent.aTeleportCamera.DestroyAfter(5.f);
		// ready for new hits
		thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );
	}
	latent function PerformLoop() {
		var speed, prevSpeed, deltaTime		: float;
		var speedModifier					: float;
		var drawSpeedLimit					: float = 10.f;
		var drawEntityRotationSpeed			: float = 4.f;
		var entityToFinalPosDist			: float;
		var initialToFinalPosDist			: float;
		var calculateSpeedFromPullDuration	: float = 1.2f;
		var desiredAffectedEntityPos: Vector;
		var projPos					: Vector;
		var projRot					: EulerAngles;
		var rotationSpeedNoise		: float;
		var CreatedEntities			: array<CEntity>;
		var i 						: int;

		if (!lLoopActive) {
			return;
		}

		switch (parent.GetAttackType()) {
			case ENR_Rock:
				// dt = 1.2f
				if (EngineTimeToFloat(theGame.GetEngineTime()) - lStartTime > 2.f) {
					// TODO: drop rocks
					return;
				}
				deltaTime = EngineTimeToFloat(theGame.GetEngineTime()) - lPrevTime;
				lPrevTime = EngineTimeToFloat(theGame.GetEngineTime());
				if ( aProjectiles.Size() == 0 ) {
					NR_Debug("PerformLoop: Error! No projectiles.");
				}
				for ( i = aProjectiles.Size() - 1 ; i >= 0 ; i -= 1 )
				{
					projPos = aProjectiles[i].GetWorldPosition();
					entityToFinalPosDist = VecDistance( projPos, aFinalPositions[i] );
					
					rotationSpeedNoise = RandRangeF( 1, -1 );
					initialToFinalPosDist = VecDistance( aFinalPositions[i], aStartPositions[i] );
					
					speedModifier = initialToFinalPosDist / calculateSpeedFromPullDuration;
					prevSpeed = speedModifier;

					speed = prevSpeed - ( speedModifier * deltaTime );
					
					speed = MinF(drawSpeedLimit, MaxF(speed, 0.f));
					if ( speed > drawSpeedLimit )
					
					prevSpeed = speed;
					
					desiredAffectedEntityPos = projPos + VecNormalize( aFinalPositions[i] - projPos  ) * speed * deltaTime;
					projRot = aProjectiles[i].GetWorldRotation();
					projRot.Pitch += drawEntityRotationSpeed + rotationSpeedNoise;
					projRot.Yaw += drawEntityRotationSpeed + rotationSpeedNoise;
					if ( VecDistance( projPos, desiredAffectedEntityPos ) < entityToFinalPosDist )
					{
						aProjectiles[i].TeleportWithRotation( desiredAffectedEntityPos, projRot );
					}
					else
					{
						aProjectiles[i].TeleportWithRotation( projPos, projRot );
					}
				}
				parent.aEventsStack.PushBack( parent.aEventsStack[0] );
				break;

			default:
				break;
		}
	}

	/*latent function MakeAeltothHappy (howHappy : EHappiness) {
		var entityTemplate 			: CEntityTemplate;

		if (howHappy == EH_MakeHisDay)	
		{
			while ( WeNeedNiceRest() ) {
				SleepOneFrame();
			}
			entityTemplate = (CEntityTemplate)LoadResourceAsync('i_couldnt_trouble');
		}
	}*/

	latent function CalculateTargetPlacement(tryFindDestroyable : bool, makeStaticTrace : bool, targetOffsetZ : float, staticOffsetZ : float) {
		var Z						: float;
		var newPos, normalCollision : Vector;
		var foundDestroyable		: bool;

		// calculate real target rot,pos
		aRot = thePlayer.GetWorldRotation();
		if (aTarget) {
			aPos = aTarget.GetWorldPosition();
			// must be good for all enemies
			aPos.Z += targetOffsetZ;
			// drugs from CBTTask - not used
			/*matrix = MatrixBuiltTRS( aPos, aRot );
			aPos = VecTransform( matrix, Vector(0.f, 10.f, 0.f, 0.f) );*/
		} else {
			if (tryFindDestroyable) {
				foundDestroyable = FindDestroyableTarget();
			}
			if (foundDestroyable) {
				NR_Debug("Found destroyable!");
				aPos = aDestroyable.GetWorldPosition();
				aPos.Z += 0.7f;
			} else {
				NR_Debug("WARNING! No target, use ground pos.");
				aPos = thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 5.f;
				NR_Debug("Original Z = " + aPos.Z);

				// correct a bit with physics raycast
				if (theGame.GetWorld().PhysicsCorrectZ(aPos, Z)) {
					aPos.Z = Z;
					NR_Debug("PhysicsCorrectZ = " + aPos.Z);
				}
				aPos.Z += staticOffsetZ;

				// check where physics obstacle if needed
				if (makeStaticTrace && theGame.GetWorld().StaticTrace(thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f + Vector(0,0,1.5f), aPos, newPos, normalCollision, parent.aCollisionGroups)) {
					aPos = newPos;
				}
			}
		}
	}
	latent function Prepare(animName : String) {
		var attackType              : ENR_MagicAttack;
		var resourceName 			: name;
		var entityTemplate 			: CEntityTemplate;
		var entity 					: CEntity;
		var projectile				: W3AdvancedProjectile;
		//var matrix					: Matrix;
		var foundDestroyable		: Bool;
		// ROCK attack
		var i, numberOfCircles, numberToSpawn, numPerCircle : int;
		var startTime				: float;
		var raiseObjectsHeightNoise, spawnObjectsInConeAngle, coneAngle, coneWidth, spawnRadiusMin, spawnRadiusMax, circleRadiusMin, circleRadiusMax : float;
		var spawnPos, spawnCenter, normalCollision 	: Vector;
		var spawnRot 				: EulerAngles;

		// new attack starts !
		CleanaData();
		parent.aName = animName;
		aActive = true;
		aTarget = thePlayer.GetTarget();
		parent.aSign = GetWitcherPlayer().GetEquippedSign();

		NR_Notify("START MAGIC: aName = " + parent.aName + ", GetAttackType() = " + parent.GetAttackType());
		attackType = parent.GetAttackType();
		switch (attackType) {
			case ENR_Lightning:
				NR_Notify("Prepare -> ENR_Lightning");
			case ENR_Projectile:
				NR_Notify("Prepare -> ENR_Projectile");
			case ENR_ProjectileWithPrepare:
				NR_Notify("Prepare -> ENR_ProjectileWithPrepare");
				resourceName = parent.aMap[parent.aSign].getN("throw_entity");
				entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);

				if (attackType != ENR_Lightning) {
					spawnRot = thePlayer.GetWorldRotation();
					spawnPos = thePlayer.GetWorldPosition();
					// special case for frost line proj
					if (attackType == ENR_Projectile) {
						projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, spawnPos + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f, spawnRot );
					} else if (attackType == ENR_ProjectileWithPrepare) {
						aPos.Z += 1.f;
						projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, spawnPos, spawnRot );
						projectile.Init(thePlayer);
						projectile.CreateAttachment( thePlayer, 'r_weapon' );
					}
					//projectile.DestroyAfter(10.f); // TODO: catch interrupt!
					aProjectiles.PushBack(projectile);
				}
		
				if (attackType == ENR_Lightning) {
					entityTemplate = (CEntityTemplate)LoadResourceAsync('fx_dummy_entity');
					// lightning can destroy clues! if no attack target //
					CalculateTargetPlacement(true, true, 1.f, 0.f);
					aDummyEntity = theGame.CreateEntity( entityTemplate, aPos, aRot );
					((CGameplayEntity)aDummyEntity).AddTag( 'special_lightning_dummy_entity' );
					aDummyEntity.DestroyAfter( 3.f );
				} else {
					// not lightning //
					CalculateTargetPlacement(false, false, 1.f, 1.f);
				}
				break;
			case ENR_Slash:
				resourceName = parent.aMap[parent.aSign].getN("slash_entity");
				entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
				CalculateTargetPlacement(true, true, 1.f, 1.f);
				aDummyEntity = theGame.CreateEntity( entityTemplate, aPos, aRot );
				Prepare_GetSlashEffectName();

				if (aDummyEntity && aEffect != '') {
					aDummyEntity.PlayEffect(aEffect);
					aDummyEntity.DestroyAfter(5.f);
				} else {
					NR_Notify("WARNING! Can't start entity effect.");
				}
				break;
			case ENR_Rock:
				//parent.HandFX(false);
				resourceName = parent.aMap[parent.aSign].getN("rock_proj");
				entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
				// BTTaskPullObjectsFromGroundAndShoot, Keira Metz & Djinni //
				numberToSpawn			= 15;
				numberOfCircles 		= 1;
				spawnObjectsInConeAngle = 45.f;
				numPerCircle 			= FloorF( (float) numberToSpawn / (float) numberOfCircles );
				coneAngle 				= spawnObjectsInConeAngle / (float) numPerCircle;
				coneWidth 				= coneAngle;
				spawnRadiusMin			= 2;
				spawnRadiusMax			= 3;

				spawnCenter 			= thePlayer.GetWorldPosition();
				CalculateTargetPlacement(false, false, 1.f, 1.f);

				for	(i = 0; i < numberToSpawn; i += 1) {
					circleRadiusMin = spawnRadiusMin + ( 1.f / (float) numberOfCircles ) * ( spawnRadiusMax - spawnRadiusMin) ;
					circleRadiusMax = spawnRadiusMax - ( 1.f / (float) numberOfCircles ) * ( spawnRadiusMax - spawnRadiusMin) ;
					spawnPos = spawnCenter + VecConeRand( thePlayer.GetHeading() - ( spawnObjectsInConeAngle * 0.5f ) + ( coneAngle * i ), coneWidth, circleRadiusMin, circleRadiusMax );
					theGame.GetWorld().StaticTrace( spawnPos + Vector(0,0,5), spawnPos - Vector(0,0,5), spawnPos, normalCollision );
					spawnRot = VecToRotation( thePlayer.GetWorldPosition() - spawnPos);
					
					projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, spawnPos + Vector(0,0,0.3f), spawnRot );
					projectile.PlayEffect('glow');
					aStartPositions.PushBack( spawnPos );
					aProjectiles.PushBack(projectile);
					// SetProjectilesPullPositions
					raiseObjectsHeightNoise = 0.5f;
					spawnPos.Z += ((CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent()).GetCapsuleHeight() * RandRangeF( 1.f + raiseObjectsHeightNoise, 1.f - raiseObjectsHeightNoise );
					aFinalPositions.PushBack( spawnPos );
				}

				lLoopActive = true;
				lStartTime = EngineTimeToFloat(theGame.GetEngineTime());
				lPrevTime = EngineTimeToFloat(theGame.GetEngineTime());
				parent.aEventsStack[0].eventName = 'PerformLoop';
				parent.aEventsStack.PushBack( parent.aEventsStack[0] );
			default:
				NR_Notify("Prepare: Error! Unknown attack type!");
				break;
		}
	}	
	latent function PerformMagicAttack() {
		var effectName, effectNameSec : name;
		var resourceName 		: name;
		var entityTemplate 		: CEntityTemplate;
		var entity 				: CEntity;
		var aTargetNPC			: CNewNPC;
		var projectile			: W3AdvancedProjectile;
		var component 			: CComponent;
		var collisionGroups 	: array<name>;
		var pos					: Vector;
		var rot 				: EulerAngles;
		var i 					: int;
		// ROCK //
		var shootDirectionNoise : float = 2.5f;
		var drawSpeedLimit 		: float = 10.f;
		var randNoise 			: float = 0.5f;
		var range, distToTarget, distance3DToTarget, projectileFlightTime, npcToTargetAngle	: float;

		aActive = false;
		switch (parent.GetAttackType()) {
			case ENR_Slash:
				if (aTarget) {
					aTargetNPC = (CNewNPC) aTarget;
					if ( aEffectHit != '' && (!aTargetNPC || !aTargetNPC.HasAlternateQuen()) ) {
						aDummyEntity.PlayEffect(aEffectHit);
					}
					thePlayer.OnCollisionFromItem( aTarget );
				} else if (aDestroyable) {
					if (aDestroyable.reactsToIgni) {
						aDestroyable.OnIgniHit(NULL);
					} else {
						aDestroyable.OnAardHit(NULL);
					}
				}
				break;
			case ENR_Projectile:
				NR_Notify("PerformMagicAttack -> ENR_Projectile");
				projectile = aProjectiles.Last();
				projectile.Init(thePlayer);
				// continue v
			case ENR_ProjectileWithPrepare:
				NR_Notify("PerformMagicAttack -> ENR_ProjectileWithPrepare");
				projectile = aProjectiles.Last();
				aProjectiles.PopBack();
				if (!projectile) {
					NR_Notify("ERROR! No projectile to shoot.");
					break;
				}
				projectile.BreakAttachment();
				projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, aPos, 20.f, parent.aCollisionGroups );
				break;
			case ENR_Lightning:
				effectName = parent.aMap[parent.aSign].getN("lightning_fx");
				effectNameSec = parent.aMap[parent.aSign].getN("throw_dummy_fx");
				if (aTarget) {
					component = aTarget.GetComponent('torso3effect');
					if (component) {
						thePlayer.PlayEffect(effectName, component);
					} else {
						thePlayer.PlayEffect(effectName, aTarget);
					}

					aTargetNPC = (CNewNPC) aTarget;
					if ( aEffectHit != '' && (!aTargetNPC || !aTargetNPC.HasAlternateQuen()) ) {
						aDummyEntity.PlayEffect(effectNameSec);
					}
					thePlayer.OnCollisionFromItem(aTarget);
				} else if (aDestroyable) {
					if (aDestroyable.reactsToIgni) {
						aDestroyable.OnIgniHit(NULL);
					} else {
						aDestroyable.OnAardHit(NULL);
					}
					thePlayer.PlayEffect(effectName, aDestroyable);
					aDummyEntity.PlayEffect(effectNameSec);
				} else {
					thePlayer.PlayEffect(effectName, aDummyEntity);
					aDummyEntity.PlayEffect(effectNameSec);
				}
				break;
			case ENR_Rock:
				lLoopActive = false;
				// aard effect
				entityTemplate = (CEntityTemplate)LoadResourceAsync( parent.aMap[parent.aSign].getN("rock_push_entity") );
				pos = thePlayer.GetWorldPosition() + Vector(0, 0, 1.15);
				rot = thePlayer.GetWorldRotation();
				entity = theGame.CreateEntity( entityTemplate, pos, rot );
				entity.CreateAttachment( thePlayer );
				entity.PlayEffect( 'cone' ); // 'blast' 'cone'
				entity.DestroyAfter(5.f);

				for ( i = aProjectiles.Size() - 1 ; i >= 0 ; i -= 1 ) 
				{
					projectile = aProjectiles[i];
					aProjectiles.Erase(i);
					aStartPositions.Erase(i);
					aFinalPositions.Erase(i);
					projectile.Init( thePlayer );
					projectile.StopEffect( 'glow' );

					distToTarget = VecDistance2D( aPos, thePlayer.GetWorldPosition() );
					// shooting
					range = 100.f;
					if (aTarget) {
						npcToTargetAngle = NodeToNodeAngleDistance( aTarget, thePlayer );
						//pos = projectile.GetWorldPosition() + VecFromHeading( AngleNormalize180( thePlayer.GetHeading() - npcToTargetAngle + RandRangeF( shootDirectionNoise, -shootDirectionNoise ) ) ) * distToTarget;
						// a bit randomness
						pos = aPos + Vector(RandRangeF(randNoise, -randNoise), RandRangeF(randNoise, -randNoise), RandRangeF(randNoise, -randNoise));
						// gameplay event
						distance3DToTarget = VecDistance( thePlayer.GetWorldPosition(), aPos );		
						projectileFlightTime = distance3DToTarget / drawSpeedLimit;
						aTarget.SignalGameplayEventParamFloat( 'Time2DodgeProjectile', projectileFlightTime );
					} else {
						pos = aPos;
					}
					projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, pos, range, parent.aCollisionGroups );
				}
				//parent.HandFX(true);
				break;
			default:
				NR_Notify("Prepare: Error! Unknown attack type!");
				break;
		}
		// attack ends
		//CleanaData();
	}
	latent function BreakMagicAttack() {
		var projectile			: W3AdvancedProjectile;
		var pos, normal			: Vector;
		var range 				: float;
		var i 					: int;

		if (!aActive) {
			return;
		}
		aActive = false;
		switch (parent.GetAttackType()) {
			//case ENR_Slash:
			//	break;
			case ENR_Projectile:
			case ENR_ProjectileWithPrepare:
				while (aProjectiles.Size() > 0) {
					projectile = aProjectiles.Last();
					aProjectiles.PopBack();
					pos = projectile.GetWorldPosition();
					theGame.GetWorld().StaticTrace(pos + Vector(0,0,5), pos - Vector(0,0,5), pos, normal);
					projectile.BreakAttachment();
					projectile.ShootProjectileAtPosition( projectile.projAngle, 5.f, aPos, 20.f, parent.aCollisionGroups );
					projectile.DestroyAfter(5.f);
				}
				break;
			case ENR_Rock:
				for ( i = aProjectiles.Size() - 1 ; i >= 0 ; i -= 1 ) 
				{
					projectile = aProjectiles[i];
					aProjectiles.Erase(i);
					aStartPositions.Erase(i);
					aFinalPositions.Erase(i);
					projectile.Init( thePlayer );
					projectile.StopEffect( 'glow' );
					
					// dropping
					range = RandRangeF( 1, 0 );
					pos = projectile.GetWorldPosition() + projectile.GetHeadingVector() * range;
					projectile.ShootProjectileAtPosition( projectile.projAngle, 5, pos, range, parent.aCollisionGroups );
				}
				//parent.HandFX(true);
				break;
			default:
				break;
		}
	}
	latent function FindDestroyableTarget() : bool {
		var ents 	: array<CGameplayEntity>;
		var dEnt 	: W3DestroyableClue;
		var    i 	: int;
		var onLine 	: Bool;
		FindGameplayEntitiesInRange(ents, thePlayer, 20.f, 1000, '', 0, NULL, 'W3DestroyableClue');
		NR_Notify("Found destroyable: " + ents.Size());
		for (i = 0; i < ents.Size(); i += 1) {
			dEnt = (W3DestroyableClue)ents[i];
			// destroyable, not destroyed, reacts to aard or igni, is on line of sight, is in FOV
			if (dEnt && dEnt.destroyable && !dEnt.destroyed && (dEnt.reactsToAard || dEnt.reactsToIgni) && AbsF(theCamera.GetCameraHeading() - dEnt.GetHeading()) < 90) {
				onLine = OnLineOfSight(dEnt, 1.5f);
				// there must be no static obstacles
				if (onLine) {
					aDestroyable = dEnt;
					return true;
				}
			}
		}
		return false;
	}
	latent function OnLineOfSight(node : CNode, zOffset : float) : bool
	{
		var traceStartPos, traceEndPos, traceStopPos, normal : Vector;
		
		traceStartPos = thePlayer.GetWorldPosition();
		traceEndPos = node.GetWorldPosition();
		
		traceStartPos.Z += zOffset; // 1.8f for usual head height
		traceEndPos.Z += zOffset;
		if ( theGame.GetWorld().StaticTrace(traceStartPos, traceEndPos, traceStopPos, normal, parent.aCollisionGroups) ) {
			if( traceEndPos == traceStopPos ) {
				return true;
			}
			return false;
		} else {
			return true;
		}
	}
	latent function Prepare_GetSlashEffectName() {
		var A, B : name;
		switch ( parent.aData.swingType ) {
			case AST_Horizontal: {
				switch ( parent.aData.swingDir ) {
					case ASD_LeftRight: A = 'left';	B = 'blood_left';	break;
					case ASD_RightLeft: A = 'right'; B = 'blood_right'; 	break;
					default: break;
				}
				break;
			}
			case AST_Vertical: {
				switch ( parent.aData.swingDir ) {
					case ASD_UpDown: A = 'down';	B = 'blood_down';	break;
					case ASD_DownUp: A = 'up';		B = 'blood_up';		break;
					default: break;
				}
				break;
			}
			case AST_DiagonalUp: {
				switch ( parent.aData.swingDir ) {
					case ASD_LeftRight:	A = 'diagonal_up_left';		B = 'blood_diagonal_up_left'; 	break;
					case ASD_RightLeft:	A = 'diagonal_up_right';	B = 'blood_diagonal_up_right'; 	break;
					default: break;
				}
				break;
			}
			case AST_DiagonalDown: {
				switch ( parent.aData.swingDir ) {
					case ASD_LeftRight:	A = 'diagonal_down_left';	B = 'blood_diagonal_down_left';		break;
					case ASD_RightLeft:	A = 'diagonal_down_right';	B = 'blood_diagonal_down_right';	break;
					default: break;
				}
				break;
			}
			default: 	A = ''; 	break;
		}
		
		if( GetWitcherPlayer().GetEquippedSign() == ST_Yrden )
			A = 'cast_line';

		aEffect 	= A;
		aEffectHit 	= B;
	}
}
// !! QuenImpulse()