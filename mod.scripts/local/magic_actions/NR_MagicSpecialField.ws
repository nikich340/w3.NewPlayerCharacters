class NR_MagicSpecialField extends NR_MagicSpecialAction {
	var l_fieldEntity : CEntity;
	var l_fieldFxName : name;
	var l_fieldCursedFxName : name;
	var l_pursue 	  : bool;
	var l_distance, l_distanceSq : float;
	var l_hostileSlowdown, l_friendlySlowdown : float;
	var l_victims : array<CActor>;
	var l_victimSlowdownIds : array<int>;
	var l_fieldMoveSpeed : float;

	default actionType = ENR_SpecialField;
	default actionSubtype = ENR_SpecialAbstractAlt;
	default l_fieldMoveSpeed = 3.f;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 25);

		if ( voicelineChance >= NR_GetRandomGenerator().nextRange(1, 100) ) {
			sceneInputs.PushBack(6);
			sceneInputs.PushBack(11);
			sceneInputs.PushBack(23);
			PlayScene( sceneInputs );
		}

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("Pursuit");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		entityTemplate = (CEntityTemplate)LoadResourceAsync( "nr_field_fx" );

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret : bool;
		var dk : float;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		pos = thePlayer.GetWorldPosition();
		rot = thePlayer.GetWorldRotation();
		l_fieldEntity = (CEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!l_fieldEntity) {
			NRE("l_fieldEntity is invalid, template = " + entityTemplate);
			return OnPerformed(false);
		}
		l_fieldFxName = FieldFxName();
		l_fieldCursedFxName = 'field_fx_red';
		l_pursue = IsActionAbilityUnlocked("Pursuit");
		l_distance = 10.f;
		l_distanceSq = l_distance * l_distance;

		dk = SkillTotalDamageMultiplier(/*invert*/ true);
		l_hostileSlowdown = MaxF(0.1f, dk);
		l_hostileSlowdown = l_hostileSlowdown - 0.24 / l_hostileSlowdown;

		l_friendlySlowdown = MinF(1.f, dk + (1.f - dk) * 0.7f);
		l_friendlySlowdown = l_friendlySlowdown - 0.24 / l_friendlySlowdown;

		NRD("NR_MagicSpecialField: dk = " + dk + ", l_hostileSlowdown = " + l_hostileSlowdown + ", l_friendlySlowdown = " + l_friendlySlowdown);
		GotoState('Active');

		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		if (l_fieldEntity) {
			l_fieldEntity.StopAllEffects();
			l_fieldEntity.DestroyAfter(3.f);
		}
	}

	// inverse - applies stronger slowdown on player and friendly actors
	latent function AddVictim(victim : CActor, optional allHostile : bool) {
		var slowdownCauserId : int;

		victim.AddTag('NR_MagicSpecialField');
		victim.PlayEffect('yrden_slowdown');  // yrden_shock ?
		if (victim == thePlayer || GetAttitudeBetween(victim, thePlayer) != AIA_Hostile) {
			if (!allHostile)
				slowdownCauserId = victim.SetAnimationSpeedMultiplier(l_friendlySlowdown);
			else
				slowdownCauserId = victim.SetAnimationSpeedMultiplier(l_hostileSlowdown);
		}
		else {
			slowdownCauserId = victim.SetAnimationSpeedMultiplier(l_hostileSlowdown);
		}

		l_victimSlowdownIds.PushBack(slowdownCauserId);
		l_victims.PushBack(victim);
	}

	function RemoveVictim(victim : CActor) {
		var index : int;

		index = l_victims.FindFirst(victim);
		if (index < 0) {
			NRE("Field: RemoveVictim: not found " + victim);
			return;
		}

		victim.RemoveTag('NR_MagicSpecialField');
		victim.ResetAnimationSpeedMultiplier(l_victimSlowdownIds[index]);
		victim.StopEffect('yrden_slowdown');  // yrden_shock ?

		l_victimSlowdownIds.Erase(index);
		l_victims.Erase(index);
	}

	latent function FieldFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'field_fx_yellow';
			case ENR_ColorOrange:
				return 'field_fx_orange';
			case ENR_ColorRed:
				return 'field_fx_red';
			case ENR_ColorPink:
				return 'field_fx_pink';
			case ENR_ColorViolet:
				return 'field_fx_violet';
			case ENR_ColorBlue:
				return 'field_fx_blue';
			case ENR_ColorGreen:
				return 'field_fx_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
				return 'field_fx_white';
			case ENR_ColorSeagreen:
			default:
				return 'field_fx_seagreen';
		}
	}
}

state Active in NR_MagicSpecialField {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.inPostState = true;
		RunActive();
	}

	entry function RunActive() {
		var i : int;
		var pos, currentPos, targetPos, reachPos : Vector;
		var moveTime, lastMoveTime, distSq : float;
		var actor : CActor;
		var areaEntities : array<CGameplayEntity>;

		parent.l_fieldEntity.PlayEffect(parent.l_fieldFxName);
		lastMoveTime = GetLocalTime();
		currentPos = parent.l_fieldEntity.GetWorldPosition();
		reachPos = currentPos;
		targetPos = currentPos;

		while (GetLocalTime() < parent.s_lifetime) {
			SleepOneFrame();
			/* move field */
			moveTime = GetLocalTime() - lastMoveTime;
			if (moveTime < 0.03f)
				continue;

			if (parent.l_pursue) {
				reachPos = thePlayer.GetWorldPosition();

				NR_SmoothMoveToTarget(moveTime, parent.l_fieldMoveSpeed, currentPos, targetPos, reachPos);
				NRD("Field: moveTime = " + moveTime + ", currentPos = " + VecToString(currentPos));
				parent.l_fieldEntity.Teleport(currentPos);
			}
			lastMoveTime = GetLocalTime();

			/* process actors */
			// remove old victims if out
			for ( i = parent.l_victims.Size() - 1; i >= 0; i -= 1 )
			{
				distSq = VecDistanceSquared2D(currentPos, parent.l_victims[i].GetWorldPosition());
				if ( !parent.l_victims[i].IsAlive() || distSq > parent.l_distanceSq ) {
					parent.RemoveVictim(parent.l_victims[i]);
				}
			}

			// add new victims if in
			areaEntities.Clear();
			FindGameplayEntitiesInRange( areaEntities, parent.l_fieldEntity, parent.l_distance, 99, , FLAG_OnlyAliveActors );
			for ( i = 0; i < areaEntities.Size(); i += 1 )
			{
				actor = (CActor)areaEntities[i];
				if (!actor || !actor.IsAlive())
					continue;

				if ( !parent.l_victims.Contains(actor) ) {
					parent.AddVictim(actor);
				}
			}
		}

		parent.StopAction();
	}

	event OnLeaveState( nextStateName : name )
	{
		var i : int;

		for ( i = parent.l_victims.Size() - 1; i >= 0; i -= 1 )
		{
			parent.RemoveVictim(parent.l_victims[i]);
		}
	}
}

state Stop in NR_MagicSpecialField {
	event OnEnterState( prevStateName : name )
	{
		NRD("Stop: OnEnterState.");
		parent.inPostState = true;
		RunStop();
		parent.inPostState = false;
	}

	entry function RunStop() {
		parent.l_fieldEntity.StopEffect(parent.l_fieldCursedFxName);
		parent.l_fieldEntity.StopEffect(parent.l_fieldFxName);
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("Stop: OnLeaveState.");
		// can be removed from cached/cursed actions TODO CHECK
		parent.inPostState = false;
	}
}

state Cursed in NR_MagicSpecialField {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		NRD("Cursed: OnEnterState.");
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.inPostState = true;
		RunCursed();
	}

	entry function RunCursed() {
		var i : int;
		var pos, currentPos, targetPos, reachPos : Vector;
		var moveTime, lastMoveTime, distSq : float;
		var actor : CActor;
		var areaEntities : array<CGameplayEntity>;

		parent.l_fieldEntity.PlayEffect(parent.l_fieldCursedFxName);
		lastMoveTime = GetLocalTime();
		currentPos = parent.l_fieldEntity.GetWorldPosition();
		reachPos = currentPos;
		targetPos = currentPos;

		while (GetLocalTime() < parent.s_lifetime * 0.5f) {
			SleepOneFrame();
			/* move field */
			moveTime = GetLocalTime() - lastMoveTime;
			if (moveTime < 0.03f)
				continue;

			if (parent.l_pursue) {
				reachPos = thePlayer.GetWorldPosition();

				NR_SmoothMoveToTarget(moveTime, parent.l_fieldMoveSpeed, currentPos, targetPos, reachPos);
				NRD("Field: moveTime = " + moveTime + ", currentPos = " + VecToString(currentPos));
				parent.l_fieldEntity.Teleport(currentPos);
			}
			lastMoveTime = GetLocalTime();

			/* process actors */
			// remove old victims if out
			for ( i = parent.l_victims.Size() - 1; i >= 0; i -= 1 )
			{
				distSq = VecDistanceSquared2D(currentPos, parent.l_victims[i].GetWorldPosition());
				if ( !parent.l_victims[i].IsAlive() || distSq > parent.l_distanceSq ) {
					parent.RemoveVictim(parent.l_victims[i]);
				}
			}

			// add new victims if in
			areaEntities.Clear();
			FindGameplayEntitiesInRange( areaEntities, parent.l_fieldEntity, parent.l_distance, 99, , FLAG_OnlyAliveActors );
			for ( i = 0; i < areaEntities.Size(); i += 1 )
			{
				actor = (CActor)areaEntities[i];
				if (!actor || !actor.IsAlive())
					continue;

				if ( !parent.l_victims.Contains(actor) ) {
					parent.AddVictim(actor, /*allHostile*/ true);
				}
			}
		}

		parent.StopAction();
	}

	event OnLeaveState( nextStateName : name )
	{
		var i : int;
		NRD("Cursed: OnLeaveState.");

		for ( i = parent.l_victims.Size() - 1; i >= 0; i -= 1 )
		{
			parent.RemoveVictim(parent.l_victims[i]);
		}
	}
}
