abstract statemachine class NR_MagicAction {
	protected var resourceName 	: String;
	protected var entityTemplate 	: CEntityTemplate;
	protected var destroyable		: W3DestroyableClue;
	protected var dummyEntity 	: CEntity;
	protected var damage 		: W3DamageAction;
	protected var damageVal 	: float;
	protected var pos 			: Vector;
	protected var rot 			: EulerAngles;
	protected var m_effectColor : ENR_MagicColor;
	protected var    	  i, j 	: int;
	protected var standartCollisions : array<name>;

	public var m_fxNameMain   	: name;
	public var m_fxNameExtra  	: name;
	public var m_fxNameHit		: name;
	public var sign 			: ESignType;
	public var target			: CActor;  // == Willey when in scene
	public var map 			: array<NR_Map>;
	public var magicSkill	: ENR_MagicSkill;
	public var actionType 	: ENR_MagicAction;
	public var actionSubtype: ENR_MagicAction;
	public var isPrepared	: bool;
	public var isPerformed	: bool;
	public var isBroken		: bool;
	public var inPostState	: bool;
	public var isCursed		: bool;
	public var isScripted 	: bool;
	public var isOnHorse 	: bool;
	public var drainStaminaOnPerform : bool;
	public var performsToLevelup : int;
	const  var ST_Universal	 : int;

	default actionType 	= ENR_Unknown;
	default actionSubtype = ENR_Unknown;
	default isPrepared 	= false;
	default isPerformed = false;
	default isBroken	= false;
	default inPostState	= false;
	default isCursed 	= false;
	default isScripted 	= false;
	default drainStaminaOnPerform 	= true;
	default performsToLevelup 		= 50; // action-specific
	default ST_Universal 			= 5; // EnumGetMax(ESignType);

	public function SetScripted(scripted : bool) {
		isScripted = scripted;
	}

	latent function OnInit() : bool {
		/*
		var phraseInputs : array<int>;
		var phraseChance : int = 60;

		phraseInputs.PushBack(1);
		...
		if ( phraseChance >= NR_GetRandomGenerator().nextRange(1, 100) )
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
		input_index = inputs[ NR_GetRandomGenerator().next( inputs.Size() ) ];
		//NR_Notify("Play scene: [" + "spell_" + IntToString(input_index) + "]");

		theGame.GetStorySceneSystem().PlayScene(scene, "spell_" + IntToString(input_index));
		return true;
	}

	latent function OnPrepare() : bool {
		// load and calculate data
		NRD("OnPrepare: " + actionType);
		if (!IsInSetupScene()) {
			target = thePlayer.GetTarget();
			//sign 	= GetWitcherPlayer().GetEquippedSign();
		}
		standartCollisions = NR_GetStandartCollisionNames();
		isOnHorse = thePlayer.IsUsingHorse();

		return !isBroken;
	}

	function OnPrepared(result : bool) : bool {
		isPrepared = result;

		if (isPrepared && target) {
			target.SignalGameplayEvent( 'DodgeSign' );
		}
		return result;
	}

	latent function OnPerform() : bool {
		// perform action, fx
		NRD("OnPerform: " + actionType + ", isPrepared: " + isPrepared);
		return isPrepared && !isBroken && !isPerformed;
	}

	function OnPerformed(result : bool) : bool {
		var magicManager : NR_MagicManager;

		isPerformed = result;
		NRD("OnPerformed: [" + ENR_MAToName(actionType) + "] result = " + result + ", isScripted = " + isScripted);
		if (result && drainStaminaOnPerform) {
			magicManager = NR_GetMagicManager();
			if (isOnHorse) {
				magicManager.DrainStaminaForAction(actionType, 2.f);
			} else {
				magicManager.DrainStaminaForAction(actionType);
			}
		}

		if (isPerformed && !isScripted && !IsInSetupScene()) {
			FactsAdd("nr_magic_performed_" + ENR_MAToName(actionType), 1);
			if (actionSubtype != ENR_Unknown)
				FactsAdd("nr_magic_performed_" + ENR_MAToName(actionSubtype), 1);
			//NRD("OnPerformed: " + "nr_magic_performed_" + ENR_MAToName(actionType) + "=" + FactsQuerySum("nr_magic_performed_" + ENR_MAToName(actionType)));
			CheckSkillLevelup();
		}
		//if (isOnHorse) {
		//	NR_GetMagicManager().SetMiscStateActionsBlocked(false);
		//}
		return result;
	}

	function CheckSkillLevelup() {
		var newSkillLevel : int;

		newSkillLevel = PerformedCount() / performsToLevelup;
		if (newSkillLevel > SkillLevel() && newSkillLevel <= 10) {
			SetSkillLevel(newSkillLevel);
			NR_GetMagicManager().ShowSkillLevelup( actionType );
		}
	}

	function PerformedCount() : int {
		return NR_GetMagicManager().GetActionPerformedCount(actionType);
	}

	function SetSkillLevel(newLevel : int) {
		NR_GetMagicManager().SetActionSkillLevel( actionType, newLevel);
	}

	function SkillLevel() : int {
		return NR_GetMagicManager().GetActionSkillLevel(actionType);
	}

	protected function ActionAbilityUnlock(abilityName : String) {
		NR_GetMagicManager().ActionAbilityUnlock(actionType, abilityName);
	}

	protected function IsActionAbilityUnlocked(abilityName : String) : bool {
		return NR_GetMagicManager().IsActionAbilityUnlocked(actionType, abilityName);
	}

	// + x% to damage
	// invert = false: [1.0, ..]
	// invert = true: [.., 1.0]
	function SkillTotalDamageMultiplier(optional invert : bool) : float {
		if (!invert)
			return (100.f + NR_GetMagicManager().GetGeneralDamageBonus() + NR_GetMagicManager().GetActionDamageBonus(actionType)) / 100.f;
		else
			return (100.f - NR_GetMagicManager().GetGeneralDamageBonus() - NR_GetMagicManager().GetActionDamageBonus(actionType)) / 100.f;
	}

	// - x% to stamina cost
	/*function SkillStaminaBonus() : int {
		return NR_GetMagicManager().GetGeneralStaminaBonus() + NR_GetMagicManager().GetActionStaminaBonus(actionType);
	}*/

	// + x% to duration
	function SkillDurationMultiplier(optional invert : bool) : float {
		if (!invert)
			return (100.f + NR_GetMagicManager().GetGeneralDurationBonus() + NR_GetMagicManager().GetActionDurationBonus(actionType)) / 100.f;
		else
			return (100.f - NR_GetMagicManager().GetGeneralDurationBonus() - NR_GetMagicManager().GetActionDurationBonus(actionType)) / 100.f;
	}
	
	function SkillMaxApplies() : int {
		return NR_GetMagicManager().GetActionMaxApplies(actionType);	
	}

	latent function BreakAction() {
		// should not be launched on successful perform!
		// makes cleanup if action was interrupted
		isBroken = true;
	}

	latent function NR_CalculateTarget(tryFindDestroyable : bool, makeStaticTrace : bool, targetOffsetZ : float, staticOffsetZ : float)
	{
		var Z						: float;
		var startPos, newPos, normalCollision : Vector;
		var foundDestroyable		: bool;

		if (isOnHorse) {
			staticOffsetZ *= 2;
		}
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
				NRD("Found destroyable target: " + destroyable);
				pos = destroyable.GetWorldPosition();
				pos.Z += 0.7f;
			} else {
				NRD("WARNING! No target, use ground pos.");
				//pos = thePlayer.GetWorldPosition() + theCamera.GetCameraForwardOnHorizontalPlane() * 5.f;
				if (isOnHorse)
					pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 15.f;
				else
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
				startPos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * 1.f + Vector(0,0,1.5f);
				if (isOnHorse)
					startPos += thePlayer.GetHeadingVector() * 3.f + Vector(0,0,1.f);

				if (makeStaticTrace && theGame.GetWorld().StaticTrace(startPos, pos, newPos, normalCollision, standartCollisions)) {
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
		for (i = 0; i < ents.Size(); i += 1) {
			dEnt = (W3DestroyableClue)ents[i];
			// destroyable, not destroyed, reacts to aard or igni, is on line of sight, *is in FOV
			if (dEnt && dEnt.destroyable && !dEnt.destroyed /*&& (dEnt.reactsToAard || dEnt.reactsToIgni) weird! && AbsF(theCamera.GetCameraHeading() - dEnt.GetHeading()) < 90*/) {
				// there must be no static obstacles
				onLine = NR_OnLineOfSight(thePlayer, dEnt, 1.f);
			
				if (onLine) {
					destroyable = dEnt;
					return true;
				}
			}
		}
		return false;
	}

	latent function NR_OnLineOfSight(nodeA : CNode, nodeB : CNode, zOffset : float) : bool
	{
		var traceStartPos, traceEndPos, traceStopPos, normal, traceDiff : Vector;
		
		traceStartPos = nodeA.GetWorldPosition();
		traceEndPos = nodeB.GetWorldPosition();
		
		traceDiff = VecNormalize(traceEndPos - traceStartPos);
		traceStartPos += traceDiff * 1.f;
		traceEndPos -= traceDiff * 1.f;
		traceStartPos.Z += zOffset; // 1.8f for usual head height
		traceEndPos.Z += zOffset;
		
		traceStopPos = TraceToPoint(traceStartPos, traceEndPos);
		return (traceStopPos == traceEndPos);
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

	latent function SnapToGround(pos : Vector) : Vector
	{
		var groundZ : float;
		if ( theGame.GetWorld().PhysicsCorrectZ(pos + Vector(0,0,5.f), groundZ) ) {
			pos.Z = groundZ;
		}
		
		return pos;
	}

	latent function GetDamage(minPerc : float, maxPerc : float, basicVitality : float, addVitality : float, basicEssence : float, addEssence : float, optional randMin : float, optional randMax : float, optional customTarget : CActor) : float {
		var damageTarget : CActor;
		var damage, maxDamage, minDamage : float;
		var levelDiff : float;

		if (customTarget) {
			damageTarget = customTarget;
		} else if (target) {
			damageTarget = target;
		}

		if (randMin < 0.1) {
			randMin = 0.8;
		}
		if (randMax < 0.1) {
			randMax = 1.2;
		}

		if (damageTarget) {
			levelDiff = Max(0, thePlayer.GetLevel() - damageTarget.GetLevel());
			maxDamage = damageTarget.GetMaxHealth() * maxPerc / 100.f + levelDiff * 1.f;
			minDamage = MaxF(damageTarget.GetMaxHealth() * 0.5f / 100.f, damageTarget.GetMaxHealth() * minPerc / 100.f + levelDiff * 0.1f);
		} else {
			levelDiff = 0;
			maxDamage = 1000000.f;
			minDamage = 1.f;
		}

		if (damageTarget.UsesVitality()) {
			damage = basicVitality + addVitality * thePlayer.GetLevel();
		} else {
			damage = basicEssence + addEssence * thePlayer.GetLevel();
		}
		damage = damage * NR_GetRandomGenerator().nextRangeF(randMin, randMax);

		if (damageTarget) {
			damage = MinF(maxDamage, damage);
			damage = MaxF(minDamage, damage);
		}
		NRD("GetDamage: action = " + ENR_MAToName(actionType) + ", target = " + damageTarget + " lvl diff = " + levelDiff + ", max health = " + damageTarget.GetMaxHealth());
		NRD("GetDamage: minDamage = " + minDamage + ", maxDamage = " + maxDamage + ", final damage = " + damage);
		return damage;
	}

	// [playerLevel - 2step, playerLevel - step, playerLevel, playerLevel + step, playerLevel + 2step]
	function NR_AdjustMinionLevel(npc : CNewNPC, optional step : int) {
		var newLevel : int;

		if (!step) {
			step = 2;
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

	function MidPosInScene(optional farFromCamera : bool) : Vector {
		var vecDiff, ret 	 : Vector;
		if (target)
			vecDiff = target.GetWorldPosition() - thePlayer.GetWorldPosition();
		ret = thePlayer.GetWorldPosition() + vecDiff * 0.5f;
		if (farFromCamera) {
 			vecDiff = ret - theCamera.GetCameraPosition();
 			ret += vecDiff;
		}
		return ret;
	}

	// get action color enum for current action type
	public function NR_GetActionColor(optional customActionType : ENR_MagicAction) : ENR_MagicColor {
		var prefix : String = "color_";
		var color : ENR_MagicColor;

		if (isOnHorse)
			 prefix += "horse_";

		if (customActionType != ENR_Unknown)
			color = (ENR_MagicColor)map[sign].getI(prefix + ENR_MAToName(customActionType), ENR_ColorWhite);
		else
			color = (ENR_MagicColor)map[sign].getI(prefix + ENR_MAToName(actionType), ENR_ColorWhite);

		return NR_FinalizeColor( color );
	}
	
	// interface for SpecialLong actions
	public function ContinueAction() {
	}
}
