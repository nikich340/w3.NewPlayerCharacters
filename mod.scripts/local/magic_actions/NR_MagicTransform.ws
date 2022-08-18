class NR_MagicTransform extends NR_MagicSpecialAction {
	var transformNPC 	: CNewNPC;
	var idleActionId 	: int;
	var resName 	: name;
	var appName 	: name;

	default actionType = ENR_SpecialLongTransform;
	default actionName = 'AttackHeavy';
	
	latent function OnInit() : bool {
		var phraseInputs : array<int>;
		var phraseChance : int;

		phraseChance = map[ST_Universal].getI("s_voicelineChance", 30);
		NRD("phraseChance = " + phraseChance);
		if ( phraseChance >= RandRange(100) + 1 ) {
			NRD("PlayScene!");
			phraseInputs.PushBack(11);
			phraseInputs.PushBack(12);
			phraseInputs.PushBack(13);
			PlayScene( phraseInputs );
		}

		return true;
	}
	latent function OnPrepare() : bool {
		super.OnPrepare();

		// load data from map
		s_specialLifetime = map[ST_Universal].getI("s_transformLifetime", 60);

		resourceName = map[sign].getN("transform_entity", resName);
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

		return OnPrepared(true);
	}
	latent function OnPerform() : bool {
		var aiTree 		: CAIIdleTree;
		var super_ret 	: bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		thePlayer.PlayEffect('teleport_appear');
		Sleep(0.3f);
		pos = thePlayer.GetWorldPosition();
		rot = thePlayer.GetWorldRotation();
		transformNPC = (CNewNPC)theGame.CreateEntity(entityTemplate, pos, rot);
		transformNPC.PlayEffect('appear');
		if (!transformNPC) {
			NRE("transformNPC is invalid.");
			return OnPerformed(false);
		}
		if (IsNameValid(appName)) {
			transformNPC.ApplyAppearance(appName);
		}

		transformNPC.AddTag('NR_TRANSFORM_NPC');
		//transformNPC.SetTemporaryAttitudeGroup('player', AGP_Default);
		transformNPC.SetAttitude( thePlayer, AIA_Friendly );

		thePlayer.CreateAttachment(transformNPC);
		thePlayer.SetTemporaryAttitudeGroup('animals_peacefull', AGP_Default);
		thePlayer.GotoState('NR_TransformIdle');

		GotoState('RunWait');
		return OnPerformed(true);
	}
	latent function BreakAction() {
		if (isPerformed) // don't react
			return;

		super.BreakAction();
		GotoState('Stop');
	}
}
state RunWait in NR_MagicTransform {
	event OnEnterState( prevStateName : name )
	{
		NRD("OnEnterState: " + this);
		parent.inPostState = true;
		RunWait();		
	}
	entry function RunWait() {
		Sleep( parent.s_specialLifetime );

		NRD("StopAction: " + this);
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}
state Stop in NR_MagicTransform {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		Stop();
	}
	entry function Stop() {
		parent.transformNPC.PlayEffect('disappear');
		Sleep(0.5f);
		parent.transformNPC.ResetTemporaryAttitudeGroup(AGP_Default);
		thePlayer.BreakAttachment();

		thePlayer.PlayEffect('teleport_appear');
		
		parent.transformNPC.Destroy();
		thePlayer.GotoState('Exploration');
	}
	event OnLeaveState( nextStateName : name )
	{
		// can be removed from cached/cursed actions
		parent.inPostState = false;
	}
}
state Cursed in NR_MagicTransform {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		Curse();
	}
	entry function Curse() {
		// TODO ? Sleep( parent.s_specialLifetime );
		// do nothing atm
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}
