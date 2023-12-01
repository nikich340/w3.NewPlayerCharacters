class NR_MagicWaterTrap extends NR_MagicAction {
	var l_target 		: CActor;
	var l_trapEntity 	: CEntity;
	var s_lifetime 	 	: float;
	var s_anchor 	 	: bool;

	default actionType = ENR_WaterTrap;
	default actionSubtype = ENR_LightAbstract;
	
	latent function OnInit() : bool {
		sceneInputs.PushBack(26);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		//if (newLevel == 5) {
		//	ActionAbilityUnlock("Anchor");
		//}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		s_anchor = IsActionAbilityUnlocked("Anchor");
		s_lifetime = 7.f * SkillDurationMultiplier(false);
		entityTemplate = (CEntityTemplate)LoadResourceAsync( "nr_fairytale_shield_fx" );
		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var buffParams : SCustomEffectParams;
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );

		l_trapEntity = (CEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!l_trapEntity) {
			NRE("l_trapEntity is invalid, template = " + entityTemplate);
			return OnPerformed(false);
		}
		NRD("MagicTrap: target = " + target + ", IsSwimming = " + target.IsSwimming() + ", can stagger = " + target.IsImmuneToBuff(EET_Stagger) + ", can immobilize = " + target.IsImmuneToBuff(EET_Immobilized));
		if (target && target.IsSwimming()) {
			l_target = target;
			buffParams.effectType = EET_Frozen;
			buffParams.creator = thePlayer;
			buffParams.sourceName = 'NR_MagicWaterTrap';
			buffParams.duration = s_lifetime + 0.1f;
			buffParams.customFXName = 'axii_slowdown';
			buffParams.effectValue.valueAdditive = 0.999f;
			buffParams.isSignEffect = true;
			l_target.AddEffectCustom(buffParams);
			l_trapEntity.CreateAttachment(l_target,,/*relativePos*/ Vector(0,0,1.f));
		}

		GotoState('Loop');
		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		if (l_trapEntity) {
			l_trapEntity.StopAllEffects();
			l_trapEntity.DestroyAfter(5.f);
		}
	}
}

state Loop in NR_MagicWaterTrap {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{		
		parent.inPostState = true;
		startTime = theGame.GetEngineTimeAsSeconds();
		LoopMove();
	}

	event OnLeaveState( nextStateName : name )
	{		
		parent.inPostState = false;
	}	

	entry function LoopMove()
	{	
		var groundPos, newPos : Vector;
		var newRot : EulerAngles;
		var moveYawSpeed, moveYaw, lastTime, deltaTime, moveZSpeed, moveZ : float;

		parent.l_trapEntity.PlayEffect('shield');
		groundPos = parent.SnapToGround(parent.l_target.GetWorldPosition()) + 1.f;
		//moveZSpeed = 0.1f;
		moveYawSpeed = 45.f;
		lastTime = GetLocalTime();

		while (GetLocalTime() < parent.s_lifetime) {
			SleepOneFrame();
			deltaTime = GetLocalTime() - lastTime;
			lastTime = GetLocalTime();

			//moveZ = moveZSpeed * deltaTime;
			moveYaw = moveYawSpeed * deltaTime;

			newPos = parent.l_target.GetWorldPosition();
			newRot = parent.l_target.GetWorldRotation();
			//newPos.Z -= moveZ;
			newRot.Yaw -= moveYaw;
			parent.l_target.TeleportWithRotation(newPos, newRot);
		}
		parent.l_trapEntity.StopEffect('shield');
		parent.l_trapEntity.BreakAttachment();
		parent.l_trapEntity.DestroyAfter(5.f);
	}
}
