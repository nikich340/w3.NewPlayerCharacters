statemachine class NR_MagicSpecialTornado extends NR_MagicSpecialAction {
	var m_tornadoEntity 	: NR_TornadoEntity;
	var m_caster 		: CActor;
	var s_pursue, s_respectCaster, s_freeze : bool;
	
	default actionType = ENR_SpecialTornado;
	default actionSubtype = ENR_SpecialAbstract;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 40);

		if ( voicelineChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(14);
			sceneInputs.PushBack(15);
			sceneInputs.PushBack(16);
			sceneInputs.PushBack(17);
			PlayScene( sceneInputs );
		}

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 5) {
			ActionAbilityUnlock("Pursuit");
			ActionAbilityUnlock("Freezing");
			ActionAbilityUnlock("DamageControl");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		s_pursue = IsActionAbilityUnlocked("Pursuit");
		s_respectCaster = IsActionAbilityUnlocked("DamageControl");
		s_freeze = IsActionAbilityUnlocked("Freezing");
		m_caster = thePlayer;

		// load action-specific resources
		m_fxNameMain = TornadoFxName();
		m_fxNameExtra = TornadoCursedFxName();
		resourceName = 'nr_tornado';
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

		return OnPrepared(true);
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var caster 		: CActor;
		var super_ret 	: bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		if (IsInSetupScene()) {
			pos = MidPosInScene(/*far*/ true);
			s_lifetime = 5.f;
			s_curseChance = 0;
			target = NULL;
		} else {
			pos += VecRingRand(0.f, 1.f);
		}
		m_tornadoEntity = (NR_TornadoEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		
		if (!m_tornadoEntity) {
			NRE("m_tornadoEntity is invalid!");
			return OnPerformed(false, scriptedPerform);
		}

		GotoState('Active');
		return OnPerformed(true, scriptedPerform);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		GotoState('Stop');
	}

	latent function TornadoFxName() : name {
		var typeName 	: name = map[sign].getN("style_" + ENR_MAToName(actionType));

		if (typeName == 'ofieri')
			return 'tornado_sand';
		else
			return 'tornado_water';
	}
	
	latent function TornadoCursedFxName() : name {
		var typeName 	: name = map[sign].getN("style_" + ENR_MAToName(actionType));

		if (typeName == 'ofieri')
			return 'tornado_sand_cursed';
		else
			return 'tornado_water_cursed';
	}
}

state Active in NR_MagicSpecialTornado {
	protected var startTime : float;

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	event OnEnterState( prevStateName : name )
	{
		NRD("Active: OnEnterState.");
		startTime = theGame.GetEngineTimeAsSeconds();
		parent.inPostState = true;
		MainLoop();		
	}

	entry function MainLoop() {
		parent.m_tornadoEntity.Activate( parent.m_caster, parent.target, parent.pos, parent.m_fxNameMain, parent.s_lifetime, /*respectCaster*/ parent.s_respectCaster, parent.s_pursue, parent.s_freeze );
		Sleep( parent.s_lifetime );
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("Active: OnLeaveState.");
	}
}

state Stop in NR_MagicSpecialTornado {
	event OnEnterState( prevStateName : name )
	{
		NRD("Stop: OnEnterState.");
		parent.inPostState = true;
		Stop();
		parent.inPostState = false;
	}

	entry function Stop() {
		parent.m_tornadoEntity.DestroyAfter(5.f);
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("Stop: OnLeaveState.");
		// can be removed from cached/cursed actions TODO CHECK
		parent.inPostState = false;
	}
}

state Cursed in NR_MagicSpecialTornado {
	event OnEnterState( prevStateName : name )
	{
		NRD("Cursed: OnEnterState.");
		parent.inPostState = true;
		Curse();
	}

	entry function Curse() {
		Sleep(0.5f);

		parent.m_tornadoEntity.m_metersPerSec *= 0.5f;
		parent.m_tornadoEntity.Activate( parent.m_caster, parent.m_caster, parent.m_caster.GetWorldPosition(), parent.m_fxNameExtra, parent.s_lifetime * 0.5f, /*respectCaster*/ false, parent.s_pursue, parent.s_freeze );
		Sleep( parent.s_lifetime * 0.5f );
		parent.StopAction();
	}

	event OnLeaveState( nextStateName : name )
	{
		NRD("Cursed: OnLeaveState.");
	}
}
