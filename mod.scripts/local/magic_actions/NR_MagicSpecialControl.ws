statemachine class NR_MagicSpecialControl extends NR_MagicSpecialAction {
	// var controlledActor : CActor; use "target" var
	var wraithEntity	: CNewNPC;
	var isControlled	: bool;
	
	default actionType 	= ENR_SpecialControl;
	default actionSubtype 	= ENR_SpecialAbstract;
	default isControlled= false;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 40);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			sceneInputs.PushBack(8);
			sceneInputs.PushBack(9);
			sceneInputs.PushBack(10);
			PlayScene( sceneInputs );
		}

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
				NRD("Control: filter actor: [" + i + "], vecAngle: " + targetAngle);
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
		NRD("Final target: " + target);

		if (target) {
			// from AddMagic17Effect
			buffParams.effectType = EET_SlowdownAxii;
			buffParams.creator = thePlayer;
			buffParams.sourceName = "NR_MagicSpecialControl";
			buffParams.duration = 5.f;
			buffParams.effectValue.valueAdditive = 0.999f;
			//buffParams.customFXName = 'axii_slowdown';
			buffParams.isSignEffect = true;
			target.AddEffectCustom(buffParams);
		}

		return OnPrepared(true);
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}

		//thePlayer.LockToTarget( false );
		//thePlayer.EnableManualCameraControl( false, 'NR_MagicSpecialControl' );
		entityTemplate = (CEntityTemplate)LoadResourceAsync("quests\part_1\quest_files\q203_him\entities\q203_geralt_head_component.w2ent", true);
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		if (!dummyEntity) {
			NRE("Control: NULL dummyEntity.");
		}
		if ( target ) {
			if ( !dummyEntity.CreateAttachment( target, 'head' ) ) {
				dummyEntity.CreateAttachment( target );
				NRD("Can't attach dummy to head slot: " + target);
			}
		}
		thePlayer.PlayEffect('mind_control', dummyEntity);
		GotoState('Active');
		
		return OnPerformed(true, scriptedPerform);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		GotoState('Stop');
	}

	latent function TakeControl(npc : CNewNPC) {
		var bonusAbilityName : name;

		if (!npc || !npc.IsAlive())
			return;
		// from W3Effect_AxiiGuardMe
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		if ( npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			// wasHostile = true;
			npc.ResetAttitude( thePlayer );
		}
		if ( npc.HasTag('animal') || npc.IsHorse() ) {
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Default);
		} else {
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Default);
		}
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');

		
		if (IsActionAbilityUnlocked("Upscaling")) {
			bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
			npc.AddAbility(bonusAbilityName, true);
			npc.SetLevel(npc.GetLevel() + 3);
			NRD("Control: bonusAbilityName = " + bonusAbilityName);
		}			

		if (npc.IsHorse())
			npc.GetHorseComponent().ResetPanic();
		npc.OnAxiied( thePlayer );
		npc.AddTag('NR_SpecialControl');
		npc.PlayEffect('axii_guardian');
	}
	
	latent function StopControl(npc : CNewNPC) {
		var bonusAbilityName : name;

		if (!npc || !npc.IsAlive())
			return;
		npc.ResetAttitude(thePlayer);
		npc.ResetTemporaryAttitudeGroup(AGP_Default);
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);

		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
		npc.RemoveAbilityAll(bonusAbilityName);
		if (IsActionAbilityUnlocked("Upscaling")) {
			npc.SetLevel(npc.GetLevel() - 3);
		}
		npc.StopEffect('axii_guardian');
	}
}
state Active in NR_MagicSpecialControl {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		NRD("OnEnterState: " + this);
		parent.inPostState = true;
		RunWait();
	}
	entry function RunWait() {
		var buffParams 	: SCustomEffectParams;
		var result 		: EEffectInteract;
		var npc 		: CNewNPC;

		Sleep( 0.5f );
		//NRD("EnableManualCameraControl: " + this);
		npc = (CNewNPC)parent.target;
		thePlayer.StopEffect('mind_control');

		if ( npc ) {
			npc.RemoveBuff(EET_SlowdownAxii, true, "NR_MagicSpecialControl");
			parent.TakeControl( npc );
			parent.isControlled = true;

			startTime = theGame.GetEngineTimeAsSeconds();
			// wait for time exceed or NPC's death
			while( npc.IsAlive() && GetLocalTime() < parent.s_lifetime ) {
				Sleep(0.2f);
			}

			// reset control
			parent.StopControl( npc );
			parent.isControlled = false;

			/* Target is dead human */
			if ( npc.IsHuman() && !npc.IsAlive() ) {
				//npc.Kill('NR_MagicSpecialControl', /*ignoreImmortalityMode*/ true);
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
		} else {
			NRD("NULL target: " + this);
		}
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}

state Stop in NR_MagicSpecialControl {
	event OnEnterState( prevStateName : name )
	{
		NRD("OnEnterState: " + this);
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
		NRD("OnLeaveState: " + this);
		// can be removed from cached/cursed actions
		parent.inPostState = false;
	}
}

state Cursed in NR_MagicSpecialControl {
	event OnEnterState( prevStateName : name )
	{
		NRD("OnEnterState: " + this);
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
		NRD("OnLeaveState: " + this);
	}
}
