statemachine class NR_MagicSpecialTornado extends NR_MagicSpecialAction {
	var m_tornadoEntity 	: NR_TornadoEntity;
	var m_caster 		: CActor;
	var s_pursue, s_respectCaster, s_freeze, s_suck : bool;
	
	default actionType = ENR_SpecialTornado;
	default actionSubtype = ENR_SpecialAbstract;
	
	latent function OnInit() : bool {
		sceneInputs.PushBack(14);
		sceneInputs.PushBack(15);
		sceneInputs.PushBack(16);
		sceneInputs.PushBack(17);
		super.OnInit();

		return true;
	}

	protected function SetSkillLevel(newLevel : int) {
		if (newLevel == 1) {
			ActionAbilityUnlock("Pursuit");
		}
		if (newLevel == 2) {
			ActionAbilityUnlock("Suck");
		}
		if (newLevel == 4) {
			ActionAbilityUnlock("DamageControl");
		}
		if (newLevel == 7) {
			ActionAbilityUnlock("Freezing");
		}
		super.SetSkillLevel(newLevel);
	}

	latent function OnPrepare() : bool {
		super.OnPrepare();

		s_pursue = IsActionAbilityUnlocked("Pursuit");
		s_respectCaster = IsActionAbilityUnlocked("DamageControl");
		s_freeze = IsActionAbilityUnlocked("Freezing");
		s_suck = IsActionAbilityUnlocked("Suck");
		m_caster = thePlayer;

		// load action-specific resources
		m_fxNameMain = TornadoFxName();
		m_fxNameExtra = TornadoCursedFxName();
		resourceName = 'nr_tornado';
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var caster 		: CActor;
		var super_ret 	: bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		if (IsInSetupScene()) {
			pos = MidPosInScene(/*far*/ true);
			s_lifetime = 5.f;
			target = NULL;
		} else {
			NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
			pos += VecRingRand(0.f, 1.f);
		}
		m_tornadoEntity = (NR_TornadoEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		m_tornadoEntity.m_dk = 20.f * SkillTotalDamageMultiplier();

		su_oneliner = SU_onelinerEntity(
			"",
			m_tornadoEntity
		);
		su_oneliner.setOffset( Vector(0, 0, 1.5f) );
		su_oneliner.setRenderDistance( 100 );
		su_oneliner.visible = false;
		
		if (!m_tornadoEntity) {
			NR_Error("m_tornadoEntity is invalid!");
			return OnPerformed(false);
		}

		GotoState('Active');
		return OnPerformed(true);
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
	/*
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		MainLoop();		
	}
	*/

	entry function ActiveLoop() {
		parent.m_tornadoEntity.Activate( parent.m_caster, parent.target, parent.pos, parent.m_fxNameMain, parent.s_lifetime, 
			parent.s_respectCaster, parent.s_suck, parent.s_pursue, parent.s_freeze );
		
		Sleep(0.5f);
		parent.su_oneliner.visible = true;
		while ( GetLocalTime() < parent.s_lifetime ) {
			UpdateOnelinerTime(, "#FCFF34");
	    	Sleep(0.1f);
		}
		parent.su_oneliner.visible = false;
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}

	/*
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState(nextStateName);
	}
	*/
}

state Cursed in NR_MagicSpecialTornado {
	entry function CursedLoop() {
		Sleep(0.5f);

		parent.m_tornadoEntity.m_metersPerSec *= 0.5f;
		parent.m_tornadoEntity.Activate( 
			parent.m_caster, 
			parent.m_caster, 
			parent.m_caster.GetWorldPosition(), 
			parent.m_fxNameExtra, 
			parent.s_lifetime * 0.5f, 
			/*respectCaster*/ false, 
			parent.s_suck, 
			parent.s_pursue, 
			parent.s_freeze
		);

		Sleep(0.5f);
		parent.su_oneliner.visible = true;
		while ( GetLocalTime() < parent.s_lifetime * 0.5f ) {
	    	UpdateOnelinerTime();
	    	Sleep(0.1f);
		}
		parent.su_oneliner.visible = false;
		parent.StopAction();
	}
}

state Stop in NR_MagicSpecialTornado {
	entry function StopLoop() {
		parent.su_oneliner.unregister();
		parent.m_tornadoEntity.DestroyAfter(5.f);
	}
}