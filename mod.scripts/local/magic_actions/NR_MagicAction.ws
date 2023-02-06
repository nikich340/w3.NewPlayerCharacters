abstract statemachine class NR_MagicAction {
	protected var resourceName 	: String;
	protected var entityTemplate 	: CEntityTemplate;
	protected var destroyable		: W3DestroyableClue;
	protected var dummyEntity 	: CEntity;
	protected var pos 			: Vector;
	protected var rot 			: EulerAngles;
	protected var m_effectColor : ENR_MagicColor;
	protected var    	  i, j 	: int;
	protected var standartCollisions : array<name>;
	protected var m_fxNameMain   : name;
	protected var m_fxNameExtra  : name;


	public var m_fxNameHit	: name;
	public var sign 			: ESignType;
	public var target			: CActor;  // == Willey when in scene
	public var map 			: array<NR_Map>;
	public var magicSkill	: ENR_MagicSkill;
	public var actionType 	: ENR_MagicAction;
	public var isPrepared	: bool;
	public var isPerformed	: bool;
	public var isBroken		: bool;
	public var inPostState	: bool;
	public var isCursed		: bool;
	public var drainStaminaOnPerform : bool;
	const  var ST_Universal	 : int;

	default actionType 	= ENR_Unknown;
	default isPrepared 	= false;
	default isPerformed = false;
	default isBroken	= false;
	default inPostState	= false;
	default isCursed 	= false;
	default drainStaminaOnPerform 	= true;
	default ST_Universal 			= 5; // EnumGetMax(ESignType); 

	latent function OnInit() : bool {
		/*
		var phraseInputs : array<int>;
		var phraseChance : int = 60;

		phraseInputs.PushBack(1);
		...
		if ( phraseChance >= RandRange(100) + 1 )
			PlayScene( phraseInputs);
		*/
		return true;
	}
	latent function PlayScene(inputs : array<int>) : bool {
		var scene : CStoryScene;
		var path : String;
		var input_index : int;

		if (inputs.Size() == 0) {
			NRD("action = " + actionType + ": No scene inputs");
			return false;
		}
		path = "dlc/dlcnewreplacers/data/scenes/02.magic_lines.w2scene";
		scene = (CStoryScene)LoadResource(path, true);
		if (!scene) {
			NRE("PlayScene: NULL scene!");
			return false;
		}
		input_index = inputs[ RandRange( inputs.Size() ) ];
		//NR_Notify("Play scene: [" + "spell_" + IntToString(input_index) + "]");

		theGame.GetStorySceneSystem().PlayScene(scene, "spell_" + IntToString(input_index));
		return true;
	}
	latent function OnPrepare() : bool {
		// load and calculate data
		if (!IsInSetupScene()) {
			target 	= thePlayer.GetTarget();
			//sign 	= GetWitcherPlayer().GetEquippedSign();
		}
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
	function OnPrepared(result : bool) : bool {
		isPrepared = result;
		return result;
	}
	latent function OnPerform() : bool {
		// perform action, fx
		return isPrepared && !isBroken;
	}
	function OnPerformed(result : bool) : bool {
		var magicManager : NR_MagicManager;

		isPerformed = result;
		if (result && drainStaminaOnPerform) {
			magicManager = NR_GetMagicManager();
			// TODO with actionType
			//if (magicManager)
			//	magicManager.DrainStaminaForAction(actionName);
		}
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
				//if (makeStaticTrace && theGame.GetWorld().StaticTrace(thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 1.f + Vector(0,0,1.5f), pos, newPos, normalCollision, standartCollisions)) {
				if (makeStaticTrace && theGame.GetWorld().StaticTrace(thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.f + Vector(0,0,1.5f), pos, newPos, normalCollision, standartCollisions)) {
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

	latent function TraceToPoint(from : Vector, to : Vector) : Vector
	{
		var resultPos, normal : Vector;

		if ( theGame.GetWorld().StaticTrace(from, to, resultPos, normal, standartCollisions) ) {
			return resultPos;
		} else {
			return to;
		}
	}

	// [playerLevel - 2step, playerLevel - step, playerLevel, playerLevel + step, playerLevel + 2step]
	latent function NR_AdjustMinionLevel(npc : CNewNPC, optional step : int) {
		var newLevel : int;

		if (!step) {
			step = 3;
		}
		newLevel = GetWitcherPlayer().GetLevel() - 2 * step;
		newLevel += step * ((int)magicSkill - (int)ENR_SkillNovice);
		if (npc) {
			NRD("Set level (" + newLevel + ") to: " + npc);
			npc.SetLevel(newLevel);
		}
	}

	function IsInSetupScene() : bool {
		return map[ST_Universal].getI("setup_scene_active", 0);
	}

	// get action color enum for current action type
	function NR_GetActionColor(optional customActionType : ENR_MagicAction) : ENR_MagicColor {
		if (customActionType != ENR_Unknown)
			return (ENR_MagicColor)map[sign].getI("color_" + ENR_MAToName(customActionType), ENR_ColorWhite);
		
		return (ENR_MagicColor)map[sign].getI("color_" + ENR_MAToName(actionType), ENR_ColorWhite);
	}
}
