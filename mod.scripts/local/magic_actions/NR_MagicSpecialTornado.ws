statemachine class NR_MagicSpecialTornado extends NR_MagicSpecialAction {
	var tornadoEntity 			: NR_TornadoEntity;
	var s_tornadoPursue 		: bool;
	var s_tornadoRespectCaster	: bool;

	default actionType = ENR_SpecialTornado;
	default actionName 	= 'AttackSpecialAard';
	
	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 100);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(14);
			phraseInputs.PushBack(15);
			phraseInputs.PushBack(16);
			phraseInputs.PushBack(17);
			PlayScene( phraseInputs );
		}

		return true;
	}
	latent function OnPrepare() : bool {
		super.OnPrepare();

		// load data from map
		s_specialLifetime = map[ST_Universal].getI("s_tornadoLifetime", 15);
		s_tornadoPursue = (bool)map[ST_Universal].getI("s_tornadoPursue", 1);
		s_tornadoRespectCaster = (bool)map[ST_Universal].getI("s_tornadoRespectCaster", 1);
		NRD("onPrepare: s_specialLifetime = " + s_specialLifetime + ", s_tornadoPursue = " + s_tornadoPursue + ", s_tornadoRespectCaster = " + s_tornadoRespectCaster);

		// load action-specific resources
		resourceName = map[sign].getN("tornado_entity");
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
		tornadoEntity.AddTag('NR_TORNADO');
		if (!tornadoEntity) {
			NRE("tornadoEntity is invalid!");
			return OnPerformed(false);
		}

		caster = NULL;
		if (s_tornadoRespectCaster) {
			caster = thePlayer;
		}
		NRD("onPerform: Init tornado!");
		tornadoEntity.Init(caster, target, pos, s_tornadoPursue, 'tornado_sand');
		GotoState('RunWait');

		return OnPerformed(true);
	}

	latent function BreakAction() {
		if (isPerformed) // tornado is independent from caster
			return;

		super.BreakAction();
		GotoState('Stop');
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
