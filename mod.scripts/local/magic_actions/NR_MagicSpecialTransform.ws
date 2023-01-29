class NR_MagicSpecialTransform extends NR_MagicSpecialAction {
	var transformNPC 	: CNewNPC;
	var idleActionId 	: int;
	var appearanceName 	: name;
	default actionType = ENR_SpecialTransform;
	
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
		var appNames 	: array<name>;
		super.OnPrepare();

		// load data from map
		s_specialLifetime = map[ST_Universal].getI("s_transformLifetime", 60);

		resourceName = map[ST_Universal].getN("s_transformEntity", 'nr_transform_cat');
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

		if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') )
			appearanceName = map[ST_Universal].getN("s_transformAppearance", 'cat_20');
		else
			appearanceName = map[ST_Universal].getN("s_transformAppearance", 'cat_vanilla_01');

		if ( map[ST_Universal].getI("s_transformAppearanceRandom", 1) > 0 ) {
			if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') ) {
				GetAppearanceNames( entityTemplate, appNames );
			} else {
				appNames.PushBack('cat_vanilla_01');
				appNames.PushBack('cat_vanilla_02');
				appNames.PushBack('cat_vanilla_03');
			}
			appearanceName = appNames[ RandRange(appNames.Size(), 0) ];
		}

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
		if (!transformNPC) {
			NRE("transformNPC is invalid.");
			return OnPerformed(false);
		}
		transformNPC.PlayEffect('appear');
		transformNPC.ApplyAppearance( appearanceName );
		transformNPC.AddTag('NR_TRANSFORM_NPC');
		transformNPC.SetAttitude( thePlayer, AIA_Friendly );

		thePlayer.CreateAttachment(transformNPC);
		thePlayer.GotoState('NR_Transformed');

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
state RunWait in NR_MagicSpecialTransform {
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
state Stop in NR_MagicSpecialTransform {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		Stop();
	}
	entry function Stop() {
		parent.transformNPC.PlayEffect('disappear');
		Sleep(0.5f);
		//parent.transformNPC.ResetTemporaryAttitudeGroup(AGP_Default);
		thePlayer.BreakAttachment();

		thePlayer.PlayEffect('teleport_appear');
		
		parent.transformNPC.Destroy();
		thePlayer.GotoState('Exploration');
	}
	event OnLeaveState( nextStateName : name )
	{
		// can be removed from cached/cursed actions
		NRD("NR_MagicSpecialTransform: Stop: OnLeaveState");
		parent.inPostState = false;
	}
}
state Cursed in NR_MagicSpecialTransform {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		Curse();
	}
	entry function Curse() {
		// TODO ?
		// do nothing atm
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}
