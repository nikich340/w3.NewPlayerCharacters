statemachine class NR_MagicSpecialPolymorphism extends NR_MagicSpecialAction {
	var transformNPC 	: CNewNPC;
	var idleActionId 	: int;
	var appearanceName 	: name;
	
	default actionType = ENR_SpecialPolymorphism;
	default actionSubtype = ENR_SpecialAbstractAlt;
	
	latent function OnInit() : bool {
		var sceneInputs : array<int>;
		var voicelineChance : int = map[ST_Universal].getI("voiceline_chance_" + ENR_MAToName(actionType), 40);

		if ( voicelineChance >= NR_GetRandomGenerator().nextRange(1, 100) ) {
			NRD("PlayScene!");
			sceneInputs.PushBack(11);
			sceneInputs.PushBack(12);
			sceneInputs.PushBack(13);
			PlayScene( sceneInputs );
		}

		return true;
	}

	latent function OnPrepare() : bool {
		var animalType 	: name;
		var appNames 	: array<name>;
		super.OnPrepare();

		m_fxNameMain = TransformFxName();
		animalType = map[sign].getN("style_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat');
		if (animalType == 'cat') {
			resourceName = "nr_transform_cat";
			entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );

			// Dhu's cats: https://www.nexusmods.com/witcher3/mods/3527
			if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') )
				appearanceName = map[sign].getN("cat_app_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat_20');
			else
				appearanceName = map[sign].getN("cat_app_" + ENR_MAToName(ENR_SpecialPolymorphism), 'cat_vanilla_01');

			if ( appearanceName == 'random' ) {
				if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') ) {
					GetAppearanceNames( entityTemplate, appNames );
					appNames.Remove('cat_vanilla_01');
					appNames.Remove('cat_vanilla_02');
					appNames.Remove('cat_vanilla_03');
				} else {
					appNames.PushBack('cat_vanilla_01');
					appNames.PushBack('cat_vanilla_02');
					appNames.PushBack('cat_vanilla_03');
				}
				appearanceName = appNames[ NR_GetRandomGenerator().next(appNames.Size()) ];
			}
		} else {
			NRE("NR_MagicSpecialPolymorphism: Unknown animalType = " + animalType);
			return OnPrepared(false);
		}
		// TODO #C: more types
		
		return OnPrepared(true);
	}

	latent function OnPerform(optional scriptedPerform : bool) : bool {
		var aiTree 		: CAIIdleTree;
		var super_ret 	: bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false, scriptedPerform);
		}

		thePlayer.PlayEffect(m_fxNameMain);
		Sleep(0.3f);
		pos = thePlayer.GetWorldPosition();
		rot = thePlayer.GetWorldRotation();
		transformNPC = (CNewNPC)theGame.CreateEntity(entityTemplate, pos, rot);
		if (!transformNPC) {
			NRE("transformNPC is invalid.");
			return OnPerformed(false, scriptedPerform);
		}
		transformNPC.PlayEffect('appear');
		transformNPC.ApplyAppearance( appearanceName );
		transformNPC.AddTag('NR_TRANSFORM_NPC');
		transformNPC.SetAttitude( thePlayer, AIA_Friendly );

		if (IsInSetupScene()) {
			// fast transform without changing thePlayer state
			pos.Z += 2.f;
			((CMovingPhysicalAgentComponent)transformNPC.GetMovingAgentComponent()).SetAnimatedMovement(false);
			// ((CMovingPhysicalAgentComponent)transformNPC.GetMovingAgentComponent()).SetGravity(false);
			transformNPC.Teleport(pos);

			NR_GetMagicManager().HandFX(false);
			thePlayer.SetVisibility(false);
			Sleep(2.5f);
			transformNPC.PlayEffect('disappear');
			Sleep(0.5f);
			thePlayer.PlayEffect(m_fxNameMain);
			thePlayer.SetVisibility(true);
			NR_GetMagicManager().HandFX(true, false);

			transformNPC.Destroy();
			return OnPerformed(true, scriptedPerform);
		}

		thePlayer.CreateAttachment(transformNPC);
		thePlayer.GotoState('NR_Transformed');

		GotoState('Active');
		return OnPerformed(true, scriptedPerform);
	}
	
	latent function BreakAction() {
		if (isPerformed)
			return;

		super.BreakAction();
		GotoState('Stop');
	}

	latent function TransformFxName() : name {
		var color : ENR_MagicColor = NR_GetActionColor();

		switch (color) {
			//case ENR_ColorBlack:
			//	return 'black';
			//case ENR_ColorGrey:
			//	return 'grey';
			case ENR_ColorYellow:
				return 'teleport_appear_yellow';
			case ENR_ColorOrange:
				return 'teleport_appear_orange';
			case ENR_ColorRed:
				return 'teleport_appear_red';
			case ENR_ColorPink:
				return 'teleport_appear_pink';
			case ENR_ColorBlue:
				return 'teleport_appear_blue';
			case ENR_ColorSeagreen:
				return 'teleport_appear_seagreen';
			case ENR_ColorGreen:
				return 'teleport_appear_green';
			//case ENR_ColorSpecial1:
			//	return 'special1';
			//case ENR_ColorSpecial2:
			//	return 'special2';
			//case ENR_ColorSpecial3:
			//	return 'special3';
			case ENR_ColorWhite:
				return 'teleport_appear_white';
			case ENR_ColorViolet:
			default:
				return 'teleport_appear_violet';
		}
	}
}

state Active in NR_MagicSpecialPolymorphism {
	event OnEnterState( prevStateName : name )
	{
		NRD("OnEnterState: " + this);
		parent.inPostState = true;
		RunActive();		
	}
	entry function RunActive() {
		Sleep( parent.s_lifetime );

		NRD("StopAction: " + this);
		parent.StopAction(); // -> Stop/Cursed if wasn't from another source
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}

state Stop in NR_MagicSpecialPolymorphism {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		RunStop();
	}
	entry function RunStop() {
		parent.transformNPC.PlayEffect('disappear');
		Sleep(0.5f);
		//parent.transformNPC.ResetTemporaryAttitudeGroup(AGP_Default);
		thePlayer.BreakAttachment();

		thePlayer.PlayEffect(parent.m_fxNameMain);
		
		parent.transformNPC.Destroy();
		thePlayer.GotoState('Exploration');
		parent.inPostState = false;
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("NR_MagicSpecialPolymorphism: Stop: OnLeaveState");
	}
}

state Cursed in NR_MagicSpecialPolymorphism {
	event OnEnterState( prevStateName : name )
	{
		parent.inPostState = true;
		RunCursed();
	}
	entry function RunCursed() {
		// do nothing
		parent.StopAction();
	}
	event OnLeaveState( nextStateName : name )
	{
		NRD("OnLeaveState: " + this);
	}
}
