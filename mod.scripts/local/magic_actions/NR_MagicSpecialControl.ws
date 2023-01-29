statemachine class NR_MagicSpecialControl extends NR_MagicSpecialAction {
	// var controlledActor : CActor; use "target" var
	var wraithEntity	: CNewNPC;
	var wasHostile 		: bool;
	var isControlled	: bool;
	var s_controlNecroProb 	: int;
	var s_controlEffect 	: EEffectType;
	default actionType 	= ENR_SpecialControl;
	default wasHostile 	= false;
	default isControlled= false;
	
	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 40);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(8);
			phraseInputs.PushBack(9);
			phraseInputs.PushBack(10);
			PlayScene( phraseInputs );
		}

		return true;
	}

	latent function OnPrepare() : bool {
		var actors : array <CActor>;
		var targetIdx 	: int;
		var targetAngle, minAngle : float;
		var buffParams 	: SCustomEffectParams;
		super.OnPrepare(); // <-- target is updated here!

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );

		// load data from map
		s_specialLifetime = map[ST_Universal].getI("s_controlLifetime", 15);
		s_controlNecroProb = map[ST_Universal].getI("s_controlNecroProb", 100);
		s_controlEffect = (EEffectType)map[ST_Universal].getI("s_controlEffect", EET_AxiiGuardMe);
		NRD("onPrepare: s_controlEffect = " + s_controlEffect + ", s_specialLifetime = " + s_specialLifetime);
		
		actors = thePlayer.GetNPCsAndPlayersInCone(/*range*/ 25, /*coneDir*/ VecHeading(thePlayer.GetHeadingVector()), /*coneAngle*/ 120, /*maxResults*/ 99, , FLAG_OnlyAliveActors + FLAG_ExcludeTarget + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral + FLAG_TestLineOfSight);

		targetIdx = -1;
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
		}
		NRD("Final target: " + target);

		if (target) {
			// from AddMagic17Effect
			buffParams.effectType = EET_Slowdown; // EET_SlowdownAxii ?
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

	latent function OnPerform() : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		//thePlayer.LockToTarget( false );
		//thePlayer.EnableManualCameraControl( false, 'NR_MagicSpecialControl' );
		if ( !target ) {
			NRE("Control: NULL target.");

			entityTemplate = (CEntityTemplate)LoadResourceAsync("quests\part_1\quest_files\q203_him\entities\q203_geralt_head_component.w2ent", true);
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
			if (!dummyEntity) {
				NRE("Control: NULL dummyEntity.");
			}
		} else {
			entityTemplate = (CEntityTemplate)LoadResourceAsync("quests\part_1\quest_files\q203_him\entities\q203_geralt_head_component.w2ent", true);
			//pos = controlledActors[i].GetBoneWorldPosition('head');
			dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
			if (!dummyEntity) {
				NRE("Control: NULL dummyEntity.");
			}
			if ( !dummyEntity.CreateAttachment( target, 'head' ) ) {
				dummyEntity.CreateAttachment( target );
				NRD("Can't attach dummy to head slot: " + target);
			}
		}
		thePlayer.PlayEffect('mind_control', dummyEntity);
		GotoState('RunWait');
		
		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed) // entities are controlled and it shouldn't be changed on hit
			return;

		super.BreakAction();
		GotoState('Stop');
	}

	latent function TakeControl(npc : CNewNPC, bonuses : bool) {
		var bonusAbilityName : name;

		if (!npc || !npc.IsAlive())
			return;
		// from W3Effect_AxiiGuardMe
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		if ( npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			wasHostile = true;
			npc.ResetAttitude( thePlayer );
		}
		if ( npc.HasTag('animal') || npc.IsHorse() ) {
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Default);
		} else {
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Default);
		}
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');

		if (bonuses) {
			bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
			if (magicSkill >= ENR_SkillEnhanced) {
				npc.AddAbility(bonusAbilityName, true); // 1st bonus
			}
			if (magicSkill >= ENR_SkillMistress) {
				npc.AddAbility(bonusAbilityName, true); // 2nd bonus
			}
			NR_Notify("bonusAbilityName = " + bonusAbilityName);
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
		npc.StopEffect('axii_guardian');
	}
}
state RunWait in NR_MagicSpecialControl {
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
		var startTime 	: float;

		Sleep( 1.f );
		//NRD("EnableManualCameraControl: " + this);
		npc = (CNewNPC)parent.target;
		thePlayer.StopEffect('mind_control');

		if ( npc ) {
			npc.RemoveBuff(EET_Slowdown, true, "NR_MagicSpecialControl");
			parent.TakeControl( npc, /*bonuses*/ true );
			parent.isControlled = true;

			startTime = theGame.GetEngineTimeAsSeconds();
			// wait for time exceed or NPC's death
			while( npc.IsAlive() && theGame.GetEngineTimeAsSeconds() - startTime < parent.s_specialLifetime ) {
				Sleep(0.2f);
			}

			// reset control
			parent.StopControl( npc );
			parent.isControlled = false;

			/* Was hostile human OR is dead human + necro chance is lucky */
			if ( (parent.wasHostile || !npc.IsAlive()) && npc.IsHuman() && parent.s_controlNecroProb >= RandRange(100) + 1 ) {
				NRD("KILL AND SUMMON WRAITH!");
				npc.Kill('NR_MagicSpecialControl', /*ignoreImmortalityMode*/ true);
				Sleep(0.75f);
				parent.entityTemplate = (CEntityTemplate)LoadResourceAsync("wraith");
				parent.wraithEntity = (CNewNPC)theGame.CreateEntity( parent.entityTemplate, npc.GetWorldPosition(), npc.GetWorldRotation() );

				if (parent.magicSkill >= ENR_SkillMistress) {
					parent.wraithEntity.SetAppearance('wraith_03');
				} else if (parent.magicSkill >= ENR_SkillEnhanced) {
					parent.wraithEntity.SetAppearance('wraith_02');
				}
				parent.NR_AdjustMinionLevel( parent.wraithEntity, 1 );

				parent.TakeControl( parent.wraithEntity, /*bonuses*/ false );

				Sleep( parent.s_specialLifetime );
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
		if ( parent.isControlled ) {
			parent.StopControl( (CNewNPC)parent.target );
			parent.isControlled = false;
		}
		if ( parent.wraithEntity ) {
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
		if ( parent.wraithEntity ) {
			Sleep(0.5f);
			parent.StopControl( parent.wraithEntity );

			Sleep( parent.s_specialLifetime );
		} else {
			NRD("Curse: NULL wraithEntity!");
		}
		
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}
