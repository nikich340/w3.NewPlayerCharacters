statemachine class NR_TornadoEntity extends CEntity {
	public var m_causer 				: CActor;
	public var m_target 				: CActor;
	public var m_targetPos				: Vector;
	public var m_duration				: float;

	event OnSpawned( spawnData : SEntitySpawnData )
	{
	}
	// if target is NULL, then static pos is used
	public function Init(causer : CActor, target : CActor, targetPos : Vector, duration : float) {
		m_causer = causer;
		m_target = target;
		m_targetPos = targetPos;
		m_duration = duration;
		GotoState('Active');
	}
}

state Active in NR_TornadoEntity {
	protected var startTime 		: float;
	protected var affectedEntities 	: array<CGameplayEntity>;

	public var affectEnemiesInRange 	: float;
	public var castingLoopTime 			: float;
	public var damageMultiplier 		: float;
	public var victimTestInterval 		: float;
	public var debuffInterval 			: float;
	public var damageInterval 			: float;
	public var moveSpeed	 			: float;
	public var slowdownRatio			: float;
	public var effects 					: array<EEffectType>;

	default affectEnemiesInRange 		= 2.5f;
	default damageMultiplier 			= 0.01f;
	default victimTestInterval 			= 0.1f;
	default debuffInterval 				= 0.25f;
	default damageInterval				= 0.25f;
	default moveSpeed 					= 2.5f; // "meters" per 1 sec
	default slowdownRatio 				= 0.8f;

	event OnEnterState( prevStateName : name )
	{
		MainLoop();
	}
	event OnLeaveState( nextStateName : name )
	{
	}
	function GetLocalTime() : float {
		return EngineTimeToFloat(theGame.GetEngineTime()) - startTime;
	}
	entry function MainLoop() {
		var params 					: SCustomEffectParams;
		var action 					: W3DamageAction;
		var movementAdjustor 		: CMovementAdjustor;
		var ticket 					: SMovementAdjustmentRequestTicket;
		var attributeName 			: name;
		var victims 				: array<CGameplayEntity>;
		var actorVictim				: CActor;
		var damage 					: float;
		var lastMoveTime 			: float;
		var lastShakeTime 			: float;
		var lastDebuffTime 			: float;
		var lastDamageTime 			: float;
		var timeStamp 				: float;
		var lastVictimsTestTime 	: float;
		var distToTarget 			: float;
		var camShakeStrength		: float;
		var res 					: bool;
		var i, j					: int;
		var moveRatio 				: float;
		var moveTime 				: float;
		var moveDir 				: Vector;
		var moveDirLen 				: float;
		var currentPos				: Vector;

		// TODO!
		effects.PushBack(EET_Bleeding);
		effects.PushBack(EET_Slowdown);
		params.duration = -1;
		params.creator = parent.m_causer;
		params.sourceName = parent.m_causer.GetName();
		parent.PlayEffect('tornado_sand');

		attributeName = GetBasicAttackDamageAttributeName(theGame.params.ATTACK_NAME_LIGHT, theGame.params.DAMAGE_NAME_PHYSICAL);
		damage = CalculateAttributeValue( parent.m_causer.GetAttributeValue( attributeName ) );
		NRD("tornado: attributeName = " + attributeName);
		NRD("tornado: damage1 = " + damage);
		damage = CalculateAttributeValue( parent.m_causer.GetAttributeValue( 'light_attack_damage_vitality' ) );
		NRD("tornado: damage2 = " + damage);
		damage *= damageMultiplier;
		NRD("tornado: damage3 = " + damage);
		if (damage < 1) {
			// TODO! Correct way to calculate Vitality/Essence damage according to player level?
			damage = 20.f;
		}

		action = new W3DamageAction in this;
		currentPos = parent.GetWorldPosition();

		startTime = EngineTimeToFloat(theGame.GetEngineTime());
		lastMoveTime = 0.f;
		lastShakeTime = 0.f;
		lastVictimsTestTime = 0.f;
		lastDebuffTime = 0.f;
		lastDamageTime = 0.f;

		while( GetLocalTime() < parent.m_duration )
		{
			SleepOneFrame();

			moveTime = GetLocalTime() - lastMoveTime;
			if (moveTime > 0.1f) {
				if (parent.m_target) {
					// smooth move to target
					parent.m_targetPos = VecInterpolate( parent.m_targetPos, parent.m_target.GetWorldPosition(), 0.7 );
				} else {
					// random smooth move
					parent.m_targetPos = VecInterpolate( parent.m_targetPos, parent.m_targetPos + VecRingRand(0.5f, 1.5f), 0.7 );
				}
				moveDir = parent.m_targetPos - currentPos;
				NRD("tornado: target = " + VecToString(parent.m_targetPos) + ", currentPos = " + VecToString(currentPos));
				moveDirLen = MaxF( EPSILON(), VecDistance(currentPos, parent.m_targetPos) ); // eps if diff too small
				if (moveDirLen <= moveSpeed * moveTime) {
					currentPos = parent.m_targetPos;
					moveRatio = 1.f; // for debug
				} else {
					moveRatio = (moveSpeed * moveTime) / moveDirLen;
					moveRatio = MaxF(moveRatio, 0.1f); // -> increase speed if distance is too big
					currentPos = currentPos + moveDir * moveRatio;
				}
				NRD("tornado: moveTime = " + moveTime + ", moveDirLen = " + moveDirLen + ", moveRatio = " + moveRatio);
				parent.Teleport(currentPos);
				lastMoveTime = GetLocalTime();
			}			
			
			///NRD("tornado: GetLocalTime = " + GetLocalTime());
			// recheck affected entities
			if ( lastVictimsTestTime + victimTestInterval < GetLocalTime() )
			{
				victims.Clear();
				FindGameplayEntitiesInRange( victims, this.parent, affectEnemiesInRange, 99, , FLAG_OnlyAliveActors );
				for ( i = 0 ; i < affectedEntities.Size() ; i += 1 )
				{
					actorVictim = (CActor)affectedEntities[i];
					if (!actorVictim || actorVictim == parent.m_causer)
						continue;

					if ( !victims.Contains(affectedEntities[i]) ) {
						for ( j = 0; j < effects.Size(); j += 1 ) {
							if (actorVictim.HasBuff(effects[j])) {
								actorVictim.RemoveBuff(effects[j]);
								NRD("tornado:Remove effect [" + effects[j] + "] from: " + actorVictim);
							}
						}
					}
				}

				for ( i = 0 ; i < victims.Size() ; i += 1 )
				{
					actorVictim = (CActor)victims[i];
					if (!actorVictim || !actorVictim.IsAlive() || actorVictim == parent.m_causer)
						continue;

					for ( j = 0; j < effects.Size(); j += 1 ) {
						if (!actorVictim.HasBuff(effects[j])) {
							params.effectType = effects[j];
							actorVictim.AddEffectCustom(params);
							NRD("tornado:Add effect [" + effects[j] + "] from: " + actorVictim);
						}
					}
				}
				affectedEntities = victims;
				lastVictimsTestTime = GetLocalTime();
			}
			
			if ( lastDamageTime + damageInterval < GetLocalTime() )
			{
				
				for ( i = 0 ; i < affectedEntities.Size() ; i += 1 )
				{
					actorVictim = (CActor)affectedEntities[i];
					NRD("tornado: damage => " + actorVictim);
					if ( actorVictim == parent.m_causer || actorVictim.IsCurrentlyDodging() )
						continue;
					
					action.Initialize( parent.m_causer, actorVictim, this, parent.m_causer.GetName(), EHRT_None, CPS_Undefined, false, true, false, false );
					action.SetHitAnimationPlayType(EAHA_ForceNo);
					action.attacker = parent.m_causer;
					action.SetSuppressHitSounds(true);
					action.SetHitEffect( '' );
					action.SetIgnoreArmor(true);
					action.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, damage );
					action.SetIsDoTDamage( damageInterval );
					theGame.damageMgr.ProcessAction( action );
					
					parent.m_causer.SignalGameplayEventParamObject( 'DamageInstigated', action );
					
					//if ( ((W3PlayerWitcher)actorVictim).IsQuenActive( false ) )
					//	((W3PlayerWitcher)actorVictim).FinishQuen( false );
				}
				lastDamageTime = GetLocalTime();
			}
		}

		NRD("tornado: Stopping");
		parent.StopEffect('tornado_sand');
		for ( i = 0 ; i < affectedEntities.Size() ; i += 1 )
		{
			actorVictim = (CActor)affectedEntities[i];
			if (!actorVictim)
				continue;

			for ( j = 0; j < effects.Size(); j += 1 ) {
				if (actorVictim.HasBuff(effects[j])) {
					actorVictim.RemoveBuff(effects[j]);
					NRD("tornado: Stop Remove effect [" + effects[j] + "] from: " + actorVictim);
				}
			}
		}
		parent.DestroyAfter(5.f);
	}
}


exec function tornado() {
	var entityTemplate : CEntityTemplate;
	var tornadoEntity : NR_TornadoEntity;

	entityTemplate = (CEntityTemplate)LoadResource( 'nr_tornado' );
	tornadoEntity = (NR_TornadoEntity)theGame.CreateEntity(entityTemplate, thePlayer.GetWorldPosition());
	tornadoEntity.Init(NULL, thePlayer, thePlayer.GetWorldPosition(), 15.f);
}