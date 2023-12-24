statemachine class NR_MagicSpecialControl extends NR_MagicSpecialAction {
	// var controlledActor : CActor; use "target" var
	var wraithEntity	: CNewNPC;
	var isControlled	: bool;
	var wasHostile 		: bool;
	
	default actionType 	= ENR_SpecialControl;
	default actionSubtype 	= ENR_SpecialAbstract;
	default isControlled= false;
	
	latent function OnInit() : bool {
		sceneInputs.PushBack(8);
		sceneInputs.PushBack(9);
		sceneInputs.PushBack(10);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("Upscaling");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		var actors : array <CActor>;
		var targetIdx 	: int;
		var targetAngle, minAngle : float;
		var buffParams 	: SCustomEffectParams;
		super.OnPrepare(); // <-- target is updated here!

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );

		//actors = thePlayer.GetNPCsAndPlayersInCone(/*range*/ 25, /*coneDir*/ thePlayer.GetHeading(), /*coneAngle*/ 120, /*maxResults*/ 99, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral);

		/*targetIdx = -1;
		minAngle = 361.f;
		if ( target && target.HasTag('NR_SpecialControl') ) {
			target = NULL;
		}
		if ( !target ) {
			for (i = 0; i < actors.Size(); i += 1) {
				targetAngle = VecGetAngleBetween(thePlayer.GetHeadingVector(), actors[i].GetWorldPosition() - thePlayer.GetWorldPosition());
				NR_Debug("Control: filter actor: [" + i + "], vecAngle: " + targetAngle);
				if ( !actors[i].HasTag('NR_SpecialControl') 
					&& minAngle > targetAngle ) 
				{
					targetIdx = i;
					minAngle = targetAngle;
				}
			}
			if (targetIdx >= 0) {
				target = actors[targetIdx];
			}
		}*/

		if (target) {
			// from AddMagic17Effect
			buffParams.effectType = EET_SlowdownAxii;
			buffParams.creator = thePlayer;
			buffParams.sourceName = "NR_MagicSpecialControl";
			buffParams.duration = 5.f;
			buffParams.effectValue.valueBase = 1.f;
			buffParams.effectValue.valueMultiplicative = 1.f;
			buffParams.effectValue.valueAdditive = 1.f;
			//buffParams.customFXName = 'axii_slowdown';
			buffParams.isSignEffect = true;
			target.AddEffectCustom(buffParams);
		}

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret 	: bool;
		var slotName 	: name;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		//thePlayer.LockToTarget( false );
		//thePlayer.EnableManualCameraControl( false, 'NR_MagicSpecialControl' );
		entityTemplate = (CEntityTemplate)LoadResourceAsync("quests\part_1\quest_files\q203_him\entities\q203_geralt_head_component.w2ent", true);
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		if (!dummyEntity) {
			NR_Error(actionType + ".OnPerform: NULL dummyEntity.");
		}
		if ( target ) {
			slotName = 'head';
			if ( !target.HasSlot(slotName) )
				slotName = 'CEffectDummyComponent0';

			if ( !dummyEntity.CreateAttachment( target, slotName ) ) {
				dummyEntity.CreateAttachment( target );
				NR_Error(actionType + ".OnPerform: can't attach dummy to head slot: " + target);
			}
		}
		thePlayer.PlayEffect('mind_control', dummyEntity);
		GotoState('Active');
		
		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		GotoState('Stop');
	}

	latent function TakeControl(npc : CNewNPC) {
		var bonusAbilityName 	: name;
		var buffParams 			: SCustomEffectParams;
		var buffResult 			: EEffectInteract;

		if (!npc || !npc.IsAlive())
			return;

		if ( npc.GetAttitude( thePlayer ) == AIA_Hostile ) {
			wasHostile = true;
		}

		if ( npc.HasAttitudeTowards( thePlayer ) && npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			npc.ResetAttitude( thePlayer );
		}

		// from W3Effect_AxiiGuardMe
		/*
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		if ( npc.HasAttitudeTowards( thePlayer ) && npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			wasHostile = true;
			npc.ResetAttitude( thePlayer );
		}

		if ( npc.HasTag('animal') || npc.IsHorse() ) {
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
		} else {
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
		}
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');	

		if (npc.IsHorse())
			npc.GetHorseComponent().ResetPanic();
		npc.OnAxiied( thePlayer );
		npc.AddTag('NR_SpecialControl');
		if (wasHostile)
			npc.PlayEffect('axii_guardian');
		else
			npc.PlayEffect('axii_confusion');
		*/

		// NEW
		buffParams.creator = thePlayer;
		buffParams.sourceName = "NR_MagicSpecialControl";  // "axii_" + S_Magic_5
		buffParams.customPowerStatValue.valueBase = 1.f;
		buffParams.customPowerStatValue.valueMultiplicative = 1.f;
		buffParams.customPowerStatValue.valueAdditive = 1.f;
		buffParams.isSignEffect = true;
		buffParams.duration = s_lifetime;
		if (wasHostile)
			buffParams.effectType = EET_AxiiGuardMe;
		else
			buffParams.effectType = EET_Confusion;

		buffResult = npc.AddEffectCustom(buffParams);
		if ( buffResult == EI_Undefined || buffResult == EI_Deny )
		{
			NR_Error(actionType + ".TakeControl: hostile = " + wasHostile + ", failed on npc = " + npc);
			return;
		}

		npc.OnAxiied( thePlayer );
		npc.AddTag('NR_MagicSpecialControl');
		if (IsActionAbilityUnlocked("Upscaling")) {
			bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
			npc.AddAbility(bonusAbilityName, true);
			npc.SetLevel(npc.GetLevel() + 3);
		}

		NR_Debug(actionType + ".TakeControl: hostile = " + wasHostile + ", success on npc = " + npc);
	}
	
	latent function StopControl(npc : CNewNPC) {
		var bonusAbilityName : name;

		if (!npc || !npc.IsAlive())
			return;

		// npc.ResetAttitude(thePlayer);
		/*
		npc.ResetTemporaryAttitudeGroup(AGP_Axii);
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);

		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
		npc.RemoveAbilityAll(bonusAbilityName);
		if (IsActionAbilityUnlocked("Upscaling")) {
			npc.SetLevel(npc.GetLevel() - 3);
		}
		if (wasHostile)
			npc.StopEffect('axii_guardian');
		else
			npc.StopEffect('axii_confusion');
		*/
		npc.RemoveAllBuffsWithSource("NR_MagicSpecialControl");
		npc.RemoveTag('NR_MagicSpecialControl');
		if (IsActionAbilityUnlocked("Upscaling")) {
			npc.SetLevel(npc.GetLevel() - 3);
		}
	}
}
state Active in NR_MagicSpecialControl {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		NR_Debug("OnEnterState: " + this);
		parent.inPostState = true;
		RunWait();
	}
	entry function RunWait() {
		var buffParams 	: SCustomEffectParams;
		var result 		: EEffectInteract;
		var npc 		: CNewNPC;

		Sleep( 0.5f );
		//NR_Debug("EnableManualCameraControl: " + this);
		npc = (CNewNPC)parent.target;
		thePlayer.StopEffect('mind_control');

		if ( npc ) {
			npc.RemoveBuff(EET_SlowdownAxii, true, "NR_MagicSpecialControl");
			parent.TakeControl( npc );
			parent.isControlled = true;

			startTime = theGame.GetEngineTimeAsSeconds();
			// wait for time exceed or NPC's death
			while ( npc.IsAlive() && GetLocalTime() < parent.s_lifetime ) {
				Sleep(0.2f);
			}

			// reset control
			parent.StopControl( npc );
			parent.isControlled = false;

			/* Target is dead human */
			/* TOREMOVE ?
			if ( npc.IsHuman() && !npc.IsAlive() ) {
				Sleep(0.5f);
				parent.entityTemplate = (CEntityTemplate)LoadResourceAsync("wraith");
				parent.wraithEntity = (CNewNPC)theGame.CreateEntity( parent.entityTemplate, npc.GetWorldPosition(), npc.GetWorldRotation() );

				if (parent.IsActionAbilityUnlocked("Upscaling")) {
					parent.wraithEntity.SetAppearance('wraith_02');
				}
				parent.NR_AdjustMinionLevel( parent.wraithEntity, 1 );
				parent.TakeControl( parent.wraithEntity );

				Sleep( parent.s_lifetime );
			}
			*/
		} else {
			NR_Debug("NULL target: " + this);
		}
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("OnLeaveState: " + this);
	}
}

state Stop in NR_MagicSpecialControl {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("OnEnterState: " + this);
		parent.inPostState = true;
		Stop();
	}
	entry function Stop() {
		if ( parent.isControlled && parent.target.IsAlive() ) {
			parent.StopControl( (CNewNPC)parent.target );
			parent.isControlled = false;
		}
		if ( parent.wraithEntity && parent.wraithEntity.IsAlive() ) {
			parent.StopControl( parent.wraithEntity );
			parent.wraithEntity.Kill('NR_MagicSpecialControl', /*ignoreImmortalityMode*/ true);
		}
	}
	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("OnLeaveState: " + this);
		// can be removed from cached/cursed actions
		parent.inPostState = false;
	}
}

state Cursed in NR_MagicSpecialControl {
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("OnEnterState: " + this);
		parent.inPostState = true;
		Curse();
	}
	entry function Curse() {
		if ( parent.isControlled ) {
			parent.StopControl( (CNewNPC)parent.target );
			parent.isControlled = false;
		}
		Sleep(1.f);

		if ( parent.wraithEntity && parent.wraithEntity.IsAlive() ) {
			// kill friendly wraith
			parent.StopControl( parent.wraithEntity );
			parent.wraithEntity.Kill('NR_MagicSpecialControl', /*ignoreImmortalityMode*/ true);
		} 
		// spawn new hostile wraith
		parent.entityTemplate = (CEntityTemplate)LoadResourceAsync("wraith");
		parent.wraithEntity = (CNewNPC)theGame.CreateEntity( parent.entityTemplate, parent.target.GetWorldPosition(), parent.target.GetWorldRotation() );
		parent.wraithEntity.SetAppearance('wraith_03');
		parent.wraithEntity.SetLevel( Max(1, thePlayer.GetLevel() - 5 - parent.SkillLevel() / 2) );
		Sleep( parent.s_lifetime * 0.5f );
		
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NR_Debug("OnLeaveState: " + this);
	}
}
