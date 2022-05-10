abstract statemachine class NR_MagicAction {
	var resourceName 	: String;
	var entityTemplate 	: CEntityTemplate;
	var destroyable		: W3DestroyableClue;
	var dummyEntity 	: CEntity;
	var effectName 		: name;
	var effectHitName	: name;
	var target			: CActor;
	var pos 			: Vector;
	var rot 			: EulerAngles;
	var sign 			: ESignType;
	var standartCollisions 	: array<name>;

	public var map 			: array<NR_Map>;
	public var actionType 	: ENR_MagicAction;
	public var isPrepared		: bool;
	public var isPerformed	: bool;
	public var isBroken		: bool;

	default actionType 	= ENR_Unknown;
	default isPrepared 	= false;
	default isPerformed = false;
	default isBroken	= false;

	latent function onPrepare() : bool {
		// load and calculate data
		target 		= thePlayer.GetTarget();
		sign 		= GetWitcherPlayer().GetEquippedSign();
		//standartCollisions.PushBack('Debris');
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

		return !isBroken;
	}
	function onPrepared(result : bool) : bool {
		isPrepared = result;
		return result;
	}
	latent function onPerform() : bool {
		// perform action, fx
		return isPrepared && !isBroken;
	}
	function onPerformed(result : bool) : bool {
		isPerformed = result;
		return result;
	}
	latent function BreakAction() {
		// should not be launched on successful perform!
		// makes cleanup if action was interrupted
		isBroken = true;
	}
	latent function NR_CalculateTarget(tryFindDestroyable : bool, makeStaticTrace : bool, targetOffsetZ : float, staticOffsetZ : float)
	{
		var Z						: float;
		var newPos, normalCollision : Vector;
		var foundDestroyable		: bool;

		// calculate real target rot,pos
		rot = thePlayer.GetWorldRotation();
		if (target) {
			pos = target.GetWorldPosition();
			// must be good for all enemies
			pos.Z += targetOffsetZ;
			// drugs from CBTTask - not used
			/*matrix = MatrixBuiltTRS( pos, rot );
			pos = VecTransform( matrix, Vector(0.f, 10.f, 0.f, 0.f) );*/
		} else {
			if (tryFindDestroyable) {
				foundDestroyable = NR_FindDestroyableTarget();
			}
			if (foundDestroyable) {
				NRD("Found destroyable!");
				pos = destroyable.GetWorldPosition();
				pos.Z += 0.7f;
			} else {
				NRD("WARNING! No target, use ground pos.");
				//pos = thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 5.f;
				pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 5.f;
				NRD("Original Z = " + pos.Z);

				// correct a bit with physics raycast
				if (theGame.GetWorld().PhysicsCorrectZ(pos, Z)) {
					pos.Z = Z;
					NRD("PhysicsCorrectZ = " + pos.Z);
				}
				pos.Z += staticOffsetZ;

				// check where physics obstacle if needed
				if (makeStaticTrace && theGame.GetWorld().StaticTrace(thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f + Vector(0,0,1.5f), pos, newPos, normalCollision, standartCollisions)) {
					pos = newPos;
				}
			}
		}
	}
	latent function NR_FindDestroyableTarget() : bool 
	{
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
				onLine = NR_OnLineOfSight(dEnt, 1.5f);
				// there must be no static obstacles
				if (onLine) {
					destroyable = dEnt;
					return true;
				}
			}
		}
		return false;
	}
	latent function NR_OnLineOfSight(node : CNode, zOffset : float) : bool
	{
		var traceStartPos, traceEndPos, traceStopPos, normal : Vector;
		
		traceStartPos = thePlayer.GetWorldPosition();
		traceEndPos = node.GetWorldPosition();
		
		traceStartPos.Z += zOffset; // 1.8f for usual head height
		traceEndPos.Z += zOffset;
		if ( theGame.GetWorld().StaticTrace(traceStartPos, traceEndPos, traceStopPos, normal, standartCollisions) ) {
			if( traceEndPos == traceStopPos ) {
				return true;
			}
			return false;
		} else {
			return true;
		}
	}
	function NR_IsAlternateSignCast() : bool {
		// is correct only after 0.2s of anim start!
		return theInput.GetActionValue( 'CastSignHold' ) > 0.f;
	}
}
