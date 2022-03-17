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
	ENR_SpecialControl, // axii - бессрочный контроль над противником?
	ENR_SpecialGolem,   // yrden - призыв случайного голема
	ENR_SpecialMeteor,   // igni - метеорит
	ENR_SpecialFrost, // aard - ?
	ENR_SpecialSphere // quen - сфера наносит урон молниями?
	//ENR_SpecialTornado ?
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
	var handFXDef 			: array<SNR_MagicDef>;
	var teleportFXDef 		: array< array<SNR_MagicDef> >;
	var throwAttacksDef 	: array<SNR_MagicDef>;
	var specialAttacksDef 	: array<SNR_MagicDef>;

	var handEffect 		: name;
	default handEffect = '';
	var eqSign 			: ESignType;
	var aEventsStack 	: array<SNR_MagicEvent>;
	var teleportPos		: Vector;
	var teleportRot		: EulerAngles;
	var teleportCamera  : CStaticCamera;

	var aCollisionGroups: array<name>;
	var aName 			: String;
	var aData 			: CPreAttackEventData;
	var aEffect 		: name;
	var aEffectHit		: name;
	var aEffectEntity	: CEntity;
	var aDummyEntity	: CGameplayEntity;
	var aProjectiles 	: array<W3AdvancedProjectile>;
	var aTarget			: CActor;
	var aDestroyable	: W3DestroyableClue;
	var aPos 			: Vector;
	var aRot 			: EulerAngles;
	default aName = "";

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
		aCollisionGroups.PushBack('Character');
		//aCollisionGroups.PushBack('CommunityCollidables');
		aCollisionGroups.PushBack('Terrain');
		aCollisionGroups.PushBack('Static');
		//aCollisionGroups.PushBack('Debris');
		aCollisionGroups.PushBack('Ragdoll');
		aCollisionGroups.PushBack('Destructible');
		//aCollisionGroups.PushBack('RigidBody');
		//aCollisionGroups.PushBack('Foliage');
		//aCollisionGroups.PushBack('Boat');
		//aCollisionGroups.PushBack('BoatDocking');
		aCollisionGroups.PushBack('Door');
		//aCollisionGroups.PushBack('Platforms');
		//aCollisionGroups.PushBack('Corpse');
		//aCollisionGroups.PushBack('Fence');
		aCollisionGroups.PushBack('Water');
		SetThrowAttacksDef();
		SetHandFXDef();
		SetTeleportFXDef();
	}
	function SetThrowAttacksDef(optional newTrowAttacksDef : array<SNR_MagicDef>) {
		if (newTrowAttacksDef.Size() == 6) {
			throwAttacksDef = newTrowAttacksDef;
			return;
		}
		throwAttacksDef.PushBack( Create_SNR_MDef('fx_dummy_entity', ENR_Lightning) ); // Aard
		throwAttacksDef.PushBack( Create_SNR_MDef('arcane_projectile', ENR_ProjectileWithPrepare) ); // Yrden
		throwAttacksDef.PushBack( Create_SNR_MDef('sorceress_fireball', ENR_ProjectileWithPrepare) ); // Igni
		throwAttacksDef.PushBack( Create_SNR_MDef('ice_spear', ENR_ProjectileWithPrepare) ); // Quen
		throwAttacksDef.PushBack( Create_SNR_MDef('eredin_frost_proj', ENR_Projectile) ); // Axii
		throwAttacksDef.PushBack( Create_SNR_MDef('fx_dummy_entity', ENR_Lightning) ); // None - for a case?
	}
	function SetHandFXDef(optional newHandFXDef : array<SNR_MagicDef>) {
		if (newHandFXDef.Size() == 6) {
			handFXDef = newHandFXDef;
			return;
		}
		handFXDef.PushBack( Create_SNR_MDef('hand_fx_yennefer') ); // Aard
		handFXDef.PushBack( Create_SNR_MDef('hand_fx_philippa') ); // Yrden
		handFXDef.PushBack( Create_SNR_MDef('hand_fx_triss') ); // Igni
		handFXDef.PushBack( Create_SNR_MDef('hand_fx_keira') ); // Quen
		handFXDef.PushBack( Create_SNR_MDef('hand_fx_keira') ); // Axii
		handFXDef.PushBack( Create_SNR_MDef('hand_fx_keira') ); // None - for a case?
	}
	function SetTeleportFXDef(optional newTeleportFXDef : array< array<SNR_MagicDef> >) {
		if (newTeleportFXDef.Size() == 6) {
			teleportFXDef = newTeleportFXDef;
			return;
		}
		teleportFXDef.PushBack( Create_SNR_MDef_2D('teleport_out_yennefer', 'teleport_in_yennefer') ); // Aard
		teleportFXDef.PushBack( Create_SNR_MDef_2D('teleport_out_yennefer', 'teleport_in_yennefer') ); // Yrden
		teleportFXDef.PushBack( Create_SNR_MDef_2D('teleport_out_triss', 'teleport_in_triss') ); // Igni
		teleportFXDef.PushBack( Create_SNR_MDef_2D('teleport_out_keira', 'teleport_in_keira') ); // Quen
		teleportFXDef.PushBack( Create_SNR_MDef_2D('teleport_out_keira', 'teleport_in_keira') ); // Axii
		teleportFXDef.PushBack( Create_SNR_MDef_2D('teleport_out_keira', 'teleport_in_keira') ); // None - for a case?
	}
	function UpdateFistsLevel(id: SItemUniqueId) {
		var playerLevel : int;
		var i : int;
		playerLevel = GetWitcherPlayer().GetLevel();

		// vanilla logic from 'GenerateItemLevel', reduced to /3
		for (i = 1; i < playerLevel / 3; i += 1) {
			if (FactsQuerySum("StandAloneEP1") > 0 || FactsQuerySum("NewGamePlus") > 0) {
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_fixed_steel_dmg', true );
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_fixed_silver_dmg', true ); 
			} else {
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_steel_dmg', true );
				thePlayer.inv.AddItemCraftedAbility(id, 'autogen_silver_dmg', true );
			}
		}
	}
	function HandFX(enable: Bool, optional onlyIfActive: Bool) {
		var newHandEffect : name;

		// update sign
		eqSign = GetWitcherPlayer().GetEquippedSign();

		if (handEffect == '' && onlyIfActive) {
			return;
		}

		newHandEffect = handFXDef[eqSign].resourceName;

		if (!enable && handEffect != '') {
			thePlayer.StopEffect(handEffect);
			handEffect = '';
		} else if (enable && handEffect != newHandEffect) {
			if (handEffect != '') {
				thePlayer.StopEffect(handEffect);
			}
			
			thePlayer.PlayEffect(newHandEffect);
			handEffect = newHandEffect;
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
			return throwAttacksDef[eqSign].attackType;
		} else if (StrStartsWith(aName, "woman_sorceress_attack_arcane")) {
			return ENR_ArcaneExplosion;
		} else {
			return ENR_Unknown;
		}
	}
	function CleanaData() {
		aName = "";
		aEffect = '';
		aEffectHit = '';
		aTarget = NULL;
		aDestroyable = NULL;

		while (aProjectiles.Size() > 0) {
			aProjectiles.Last().Destroy();
			aProjectiles.PopBack();
		}
	}
	function PreAttackEvent(animName : name, out data : CPreAttackEventData)
	{
		//switch (GetAttackType()) {
		//	case ENR_Slash:
		// for any?
		if (eqSign == ST_Igni) {
			data.hitFX 				= 'fire_hit';
			data.hitParriedFX 		= 'fire_hit';
			data.hitBackFX 			= 'fire_hit';
			data.hitBackParriedFX 	= 'fire_hit';
		} else if (eqSign == ST_Quen) {
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
	event OnEnterState( prevStateName : name )
	{
		MainLoop();
	}
	event OnLeaveState( prevStateName : name )
	{
	}
	entry function MainLoop() {
		while(true) {
			while (parent.aEventsStack.Size() > 0) {
				switch (parent.aEventsStack[0].eventName) {
					case 'Prepare':
						Prepare( NameToString(parent.aEventsStack[0].animName) );
						break;
					case 'PerformMagicAttack':
						PerformMagicAttack();
						break;
					case 'PrepareTeleport':
						PrepareTeleport();
						break;
					case 'PerformTeleport':
						PerformTeleport();
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
		parent.eqSign = GetWitcherPlayer().GetEquippedSign();

		thePlayer.PlayEffect(parent.teleportFXDef[parent.eqSign][0].resourceName);

		shiftVec = parent.teleportPos - thePlayer.GetWorldPosition();
		template = (CEntityTemplate)LoadResourceAsync("nr_static_camera");
		// YEAH, that simple!
		parent.teleportCamera = (CStaticCamera)theGame.CreateEntity( template, theCamera.GetCameraPosition() + shiftVec, theCamera.GetCameraRotation() );
		if (!parent.teleportCamera) {
			NR_Notify("PrepareTeleport: No camera!!");
			return;
		}
		NR_Notify("PerformTeleport: Run.");
		parent.teleportCamera.activationDuration = 0.5f;
		parent.teleportCamera.deactivationDuration = 0.3f;
		parent.teleportCamera.Run();
		
		Sleep(0.15f); // wait for effect a bit
		thePlayer.SetGameplayVisibility(false);
		thePlayer.SetVisibility(false);
		thePlayer.TeleportWithRotation(parent.teleportPos, parent.teleportRot);
	}
	latent function PerformTeleport() {
		thePlayer.PlayEffect(parent.teleportFXDef[parent.eqSign][1].resourceName);

		if (!parent.teleportCamera) {
			NR_Notify("PerformTeleport: No camera!!");
			return;
		}
		NR_Notify("PerformTeleport.");
		Sleep(0.15f);  // wait for effect a bit
		thePlayer.SetGameplayVisibility(true);
		thePlayer.SetVisibility(true);
		///thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );

		Sleep(0.1f);
		parent.teleportCamera.Stop();
		parent.teleportCamera.DestroyAfter(10.f);
		//thePlayer.SetIsCurrentlyDodging(false);
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

	latent function Prepare(animName : String) {
		var attackType              : ENR_MagicAttack;
		var resourceName 			: name;
		var entityTemplate 			: CEntityTemplate;
		var entity 					: CEntity;
		var projectile				: W3AdvancedProjectile;
		//var matrix					: Matrix;
		var Z 						: float;
		var foundDestroyable		: Bool;

		// new attack starts !
		parent.CleanaData();
		parent.aName = animName;
		parent.aTarget = thePlayer.GetTarget();
		parent.eqSign = GetWitcherPlayer().GetEquippedSign();

		NR_Notify("START MAGIC: aName = " + parent.aName + ", GetAttackType() = " + parent.GetAttackType());
		attackType = parent.GetAttackType();
		switch (attackType) {
			case ENR_Lightning:
				NR_Notify("Prepare -> ENR_Lightning");
			case ENR_Projectile:
				NR_Notify("Prepare -> ENR_Projectile");
			case ENR_ProjectileWithPrepare:
				NR_Notify("Prepare -> ENR_ProjectileWithPrepare");
				resourceName = parent.throwAttacksDef[parent.eqSign].resourceName;
				entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);

				if (attackType != ENR_Lightning) {
					parent.aRot = thePlayer.GetWorldRotation();
					parent.aPos = thePlayer.GetWorldPosition();
					// special case for frost line proj
					if (attackType == ENR_Projectile) {
						projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, parent.aPos + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f, parent.aRot );
					} else if (attackType == ENR_ProjectileWithPrepare) {
						parent.aPos.Z += 1.f;
						projectile = (W3AdvancedProjectile)theGame.CreateEntity( entityTemplate, parent.aPos, parent.aRot );
						projectile.Init(thePlayer);
						projectile.CreateAttachment( thePlayer, 'r_weapon' );
					}
					//projectile.DestroyAfter(10.f); // ?
					parent.aProjectiles.PushBack(projectile);
				}
				// update to real target rot,pos
				parent.aRot = thePlayer.GetWorldRotation();
				if (parent.aTarget) {
					parent.aPos = parent.aTarget.GetWorldPosition();
					parent.aPos.Z += 1.f;
					// drugs from CBTTask
					/*matrix = MatrixBuiltTRS( parent.aPos, parent.aRot );
					parent.aPos = VecTransform( matrix, Vector(0.f, 10.f, 0.f, 0.f) );*/
				} else {
					foundDestroyable = FindDestroyableTarget();
					if (foundDestroyable) {
						parent.aPos = parent.aDestroyable.GetWorldPosition();
						parent.aPos.Z += 0.7;
					} else {
						NR_Notify("WARNING! No target, use fake pos.");
						parent.aPos = thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 5.f;
						NR_Notify("Original Z = " + parent.aPos.Z);
						// black magic to find ground point
						if (theGame.GetWorld().NavigationComputeZ(parent.aPos, parent.aPos.Z - 5.f, parent.aPos.Z + 5.f, Z)) {
							parent.aPos.Z = Z;
							NR_Notify("NavigationComputeZ = " + parent.aPos.Z);
						}
						if (theGame.GetWorld().PhysicsCorrectZ(parent.aPos, Z)) {
							parent.aPos.Z = Z;
							NR_Notify("PhysicsCorrectZ = " + parent.aPos.Z);
						}
						parent.aPos.Z += 1.f;
					}
				}
				
				if (attackType == ENR_Lightning) {
					parent.aDummyEntity = (CGameplayEntity)theGame.CreateEntity( entityTemplate, parent.aPos, parent.aRot );
					parent.aDummyEntity.AddTag( 'special_lightning_dummy_entity' );
					parent.aDummyEntity.DestroyAfter( 3.f );
				}
				break;
			case ENR_Slash:
				if (parent.eqSign == ST_Yrden) {
					resourceName = 'magic_attack_arcane';
				} else if (parent.eqSign == ST_Igni) {
					resourceName = 'magic_attack_fire';
				} else if (parent.eqSign == ST_Quen) {
					resourceName = 'ep2_magic_attack_lightning';
				} else {
					resourceName = 'magic_attack_lightning';
				}
				entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
				parent.aRot = thePlayer.GetWorldRotation();
				if (parent.aTarget) {
					parent.aPos = parent.aTarget.GetWorldPosition();
					parent.aPos.Z += 1.f; // from CBTTask
				} else {
					foundDestroyable = FindDestroyableTarget();
					if (foundDestroyable) {
						parent.aPos = parent.aDestroyable.GetWorldPosition();
						parent.aPos.Z += 0.7;
					} else {
						NR_Debug("WARNING! No target, use fake pos.");
						parent.aPos = thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 5.f;
						NR_Notify("Original Z = " + parent.aPos.Z);
						// black magic to find ground point
						if (theGame.GetWorld().NavigationComputeZ(parent.aPos, parent.aPos.Z - 5.f, parent.aPos.Z + 5.f, Z)) {
							parent.aPos.Z = Z;
							NR_Notify("NavigationComputeZ = " + parent.aPos.Z);
						}
						if (theGame.GetWorld().PhysicsCorrectZ(parent.aPos, Z)) {
							parent.aPos.Z = Z;
							NR_Notify("PhysicsCorrectZ = " + parent.aPos.Z);
						}
						parent.aPos.Z += 1.f;
					}
				}

				parent.aEffectEntity = theGame.CreateEntity( entityTemplate, parent.aPos, parent.aRot );
				Prepare_GetSlashEffectName();

				if (parent.aEffectEntity && parent.aEffect != '') {
					parent.aEffectEntity.PlayEffect(parent.aEffect);
					parent.aEffectEntity.DestroyAfter(5.f);
				} else {
					NR_Notify("WARNING! Can't start entity effect.");
				}
				break;
			default:
				break;
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

		parent.aEffect 	= A;
		parent.aEffectHit 	= B;
	}
	latent function PerformMagicAttack() {
		var aTargetNPC			: CNewNPC;
		var projectile			: W3AdvancedProjectile;
		var component 			: CComponent;
		var collisionGroups 	: array<name>;

		switch (parent.GetAttackType()) {
			case ENR_Slash:
				if (parent.aTarget) {
					aTargetNPC = (CNewNPC) parent.aTarget;
					if ( parent.aEffectHit != '' && (!aTargetNPC || !aTargetNPC.HasAlternateQuen()) ) {
						parent.aEffectEntity.PlayEffect(parent.aEffectHit);
					}
					thePlayer.OnCollisionFromItem( parent.aTarget );
				} else if (parent.aDestroyable) {
					if (parent.aDestroyable.reactsToIgni) {
						parent.aDestroyable.OnIgniHit(NULL);
					} else {
						parent.aDestroyable.OnAardHit(NULL);
					}
				}
				break;
			case ENR_Projectile:
				NR_Notify("PerformMagicAttack -> ENR_Projectile");
				projectile = parent.aProjectiles.Last();
				projectile.Init(thePlayer);
				// continue v
			case ENR_ProjectileWithPrepare:
				NR_Notify("PerformMagicAttack -> ENR_ProjectileWithPrepare");
				projectile = parent.aProjectiles.Last();
				if (!projectile) {
					NR_Notify("ERROR! No projectile to shoot.");
					break;
				}
				projectile.BreakAttachment();
				projectile.ShootProjectileAtPosition( projectile.projAngle, projectile.projSpeed, parent.aPos, 20.f, parent.aCollisionGroups );
				parent.aProjectiles.PopBack();
				break;

			case ENR_Lightning:
				if (parent.aTarget) {
					component = parent.aTarget.GetComponent('torso3effect');
					if (component) {
						thePlayer.PlayEffect('lightning', component);
					} else {
						thePlayer.PlayEffect('lightning', parent.aTarget);
					}

					aTargetNPC = (CNewNPC) parent.aTarget;
					if ( parent.aEffectHit != '' && (!aTargetNPC || !aTargetNPC.HasAlternateQuen()) ) {
						parent.aDummyEntity.PlayEffect('hit_electric');
					}
					thePlayer.OnCollisionFromItem(parent.aTarget);
				} else if (parent.aDestroyable) {
					if (parent.aDestroyable.reactsToIgni) {
						parent.aDestroyable.OnIgniHit(NULL);
					} else {
						parent.aDestroyable.OnAardHit(NULL);
					}
					thePlayer.PlayEffect('lightning', parent.aDestroyable);
				} else {
					thePlayer.PlayEffect('lightning', parent.aDummyEntity);
					parent.aDummyEntity.PlayEffect('hit_electric');
				}
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
			// destroyable, not destroyable, reacts to aard or igni, is on line of sight, is in FOV
			if (dEnt && dEnt.destroyable && !dEnt.destroyed && (dEnt.reactsToAard || dEnt.reactsToIgni) && AbsF(theCamera.GetCameraHeading() - dEnt.GetHeading()) < 90) {
				onLine = OnLineOfSight(dEnt);
				if (onLine) {
					parent.aDestroyable = dEnt;
					return true;
				}
			}
		}
		return false;
	}
	latent function OnLineOfSight(node : CNode) : bool
	{
		var traceStartPos, traceEndPos, traceStopPos, normal : Vector;
		
		traceStartPos = thePlayer.GetWorldPosition();
		traceEndPos = node.GetWorldPosition();
		
		traceStartPos.Z += 1.8;
		traceEndPos.Z += 1.8;
		if ( theGame.GetWorld().StaticTrace(traceStartPos, traceEndPos, traceStopPos, normal) ) {
			if( traceEndPos == traceStopPos ) {
				return true;
			}
			return false;
		} else {
			return true;
		}
	}
}
// !! QuenImpulse()