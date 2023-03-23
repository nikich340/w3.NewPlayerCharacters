statemachine class NR_MagicSpecialTornado extends NR_MagicSpecialAction {
	var tornadoEntity 			: NR_TornadoEntity;
	var s_tornadoPursue 		: bool;
	var s_tornadoRespectCaster	: bool;
	default actionType = ENR_SpecialTornado;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 0);

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

	latent function OnPrepare() : bool {
		super.OnPrepare();

		s_specialLifetime = map[ST_Universal].getI("s_tornadoLifetime", 15);
		s_tornadoPursue = (bool)map[ST_Universal].getI("s_tornadoPursue", 1);
		s_tornadoRespectCaster = (bool)map[ST_Universal].getI("s_tornadoRespectCaster", 1);
		NRD("onPrepare: s_specialLifetime = " + s_specialLifetime + ", s_tornadoPursue = " + s_tornadoPursue + ", s_tornadoRespectCaster = " + s_tornadoRespectCaster);

		// load action-specific resources
		m_fxNameMain = TornadoFxName();
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

		NR_CalculateTarget(	/*tryFindDestroyable*/ false, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 0.f, /*staticOffsetZ*/ 0.f );
		pos += VecRingRand(1.0f, 2.0f);
		tornadoEntity = (NR_TornadoEntity)theGame.CreateEntity(entityTemplate, pos, rot);
		
		if (!tornadoEntity) {
			NRE("tornadoEntity is invalid!");
			return OnPerformed(false);
		}

		caster = NULL;
		if (s_tornadoRespectCaster) {
			caster = thePlayer;
		}
		NRD("onPerform: Init tornado!");

		tornadoEntity.AddTag('NR_TORNADO');
		tornadoEntity.Init(caster, target, pos, s_tornadoPursue, 'tornado_sand');
		GotoState('RunWait');

		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		GotoState('Stop');
	}

	latent function TornadoFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor(ENR_SpecialAbstract);

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			case ENR_ColorWhite:
				return 'tornado_sand_white';
			case ENR_ColorYellow:
				return 'tornado_sand_yellow';
			case ENR_ColorOrange:
				return 'tornado_sand_orange';
			case ENR_ColorRed:
				return 'tornado_sand_red';
			case ENR_ColorPink:
				return 'tornado_sand_pink';
			case ENR_ColorViolet:
				return 'tornado_sand_violet';
			case ENR_ColorBlue:
				return 'tornado_sand_blue';
			case ENR_ColorSeagreen:
				return 'tornado_sand_seagreen';
			case ENR_ColorGreen:
				return 'tornado_sand_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorGrey:
			default:
				return 'tornado_sand_grey';
		}
	}
}
state RunWait in NR_MagicSpecialTornado {
	event OnEnterState( prevStateName : name )
	{
		NRD("RunWait: OnEnterState.");
		parent.inPostState = true;
		RunWait();		
	}
	entry function RunWait() {
		Sleep( parent.s_specialLifetime );
		NRD("RunWait: Stop tornado!");
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("RunWait: OnLeaveState.");
	}
}
state Stop in NR_MagicSpecialTornado {
	event OnEnterState( prevStateName : name )
	{
		NRD("Stop: OnEnterState.");
		parent.inPostState = true;
		Stop();
	}
	entry function Stop() {
		parent.tornadoEntity.Stop();
		parent.tornadoEntity.DestroyAfter(5.f);
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("Stop: OnLeaveState.");
		// can be removed from cached/cursed actions
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
		parent.tornadoEntity.Stop();
		Sleep(0.5f);

		parent.tornadoEntity.Init(NULL, thePlayer, thePlayer.GetWorldPosition(), parent.s_tornadoPursue, 'tornado_sand_red');
		Sleep( parent.s_specialLifetime );
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("Cursed: OnLeaveState.");
	}
}
