class NR_MagicTeleport extends NR_MagicAction {
	default isDamaging 	= false;
	protected var teleportCamera 	: CStaticCamera;
	protected var teleportPos 	: Vector;
	protected var oldCameraPos 	: Vector;
	protected var l_breakEventReceived 	: bool;
	protected var l_performEventReceived : bool;
	
	default performsToLevelup = 150; // action-specific
	default actionType = ENR_Teleport;

	function SetTeleportPos(pos : Vector) {
		teleportPos = pos;
	}

	// 0.74 of 2.5 s
	latent function OnPrepare() : bool {
		var super_ret : bool;

		super_ret = super.OnPrepare();
		if (!super_ret) {
			return OnPrepared(false);
		}

		m_fxNameMain = TeleportOutFxName();
		m_fxNameExtra = TeleportInFxName();
		thePlayer.PlayEffect( m_fxNameMain );

		if ( IsInSetupScene() ) {
			Sleep(0.1f);
			thePlayer.SetGameplayVisibility(false);
			thePlayer.SetVisibility(false);
			return OnPrepared(true);
		}

		GotoState('Teleporting');
		return OnPrepared(true);
	}

	// 1.04 of 2.5 s
	latent function OnPerform() : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		if (IsInSetupScene()) {
			Sleep(0.2f);  // wait for effect a bit
			thePlayer.SetGameplayVisibility(true);
			thePlayer.SetVisibility(true);
			return OnPerformed(true);
		}

		l_performEventReceived = true;
		return OnPerformed(true);
	}

	latent function BreakAction() {
		// do not break if player is already invulnerable
		if (GetCurrentStateName() == 'Teleporting') {
			l_breakEventReceived = true;
			return;
		}

		super.BreakAction();
		if (teleportCamera) {
			// stop at current position
			teleportCamera.Stop();
			teleportCamera.DestroyAfter(5.f);

			thePlayer.Teleport( teleportCamera.GetCameraPosition() );
			thePlayer.PlayEffect( m_fxNameExtra );
		}
		thePlayer.SetGameplayVisibility(true);
		thePlayer.SetVisibility(true);
		thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );
		thePlayer.SetImmortalityMode( AIM_None, AIC_Default );
	}

	latent function TeleportOutFxName() : name {
		var color 	: ENR_MagicColor = NR_GetActionColor();
		var fx_type : name			 = map[sign].getN("style_" + ENR_MAToName(actionType));
		
		if (fx_type == 'ofieri')
			return 'teleport_out_sand';
		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_yellow';
					case 'triss':
						return 'teleport_out_triss_yellow';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_yellow';
				}
			case ENR_ColorOrange:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_orange';
					case 'triss':
						return 'teleport_out_triss_orange';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_orange';
				}
			case ENR_ColorRed:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_red';
					case 'triss':
						return 'teleport_out_triss_red';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_red';
				}
			case ENR_ColorPink:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_pink';
					case 'triss':
						return 'teleport_out_triss_pink';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_pink';
				}
			case ENR_ColorViolet:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_violet';
					case 'triss':
						return 'teleport_out_triss_violet';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_violet';
				}
			case ENR_ColorBlue:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_blue';
					case 'triss':
						return 'teleport_out_triss_blue';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_blue';
				}
			case ENR_ColorSeagreen:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_seagreen';
					case 'triss':
						return 'teleport_out_triss_seagreen';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_seagreen';
				}
			case ENR_ColorGreen:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_green';
					case 'triss':
						return 'teleport_out_triss_green';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_green';
				}
			//case ENR_ColorSpecial1:
			//	return 'ENR_ColorSpecial1';
			//case ENR_ColorSpecial2:
			//	return 'ENR_ColorSpecial2';
			//case ENR_ColorSpecial3:
			//	return 'ENR_ColorSpecial3';
			case ENR_ColorWhite:
			default:	
				switch (fx_type) {
					case 'hermit':
						return 'teleport_out_water_white';
					case 'triss':
						return 'teleport_out_triss_white';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_white';
				}
		}
	}

	latent function TeleportInFxName() : name {
		var color 	: ENR_MagicColor = NR_GetActionColor();
		var fx_type : name			 = map[sign].getN("style_" + ENR_MAToName(actionType));
		
		if (fx_type == 'ofieri')
			return 'teleport_in_sand';
		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_yellow';
					case 'triss':
						return 'teleport_in_triss_yellow';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_yellow';
				}
			case ENR_ColorOrange:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_orange';
					case 'triss':
						return 'teleport_in_triss_orange';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_orange';
				}
			case ENR_ColorRed:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_red';
					case 'triss':
						return 'teleport_in_triss_red';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_red';
				}
			case ENR_ColorPink:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_pink';
					case 'triss':
						return 'teleport_in_triss_pink';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_pink';
				}
			case ENR_ColorViolet:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_violet';
					case 'triss':
						return 'teleport_in_triss_violet';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_violet';
				}
			case ENR_ColorBlue:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_blue';
					case 'triss':
						return 'teleport_in_triss_blue';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_blue';
				}
			case ENR_ColorSeagreen:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_seagreen';
					case 'triss':
						return 'teleport_in_triss_seagreen';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_seagreen';
				}
			case ENR_ColorGreen:
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_green';
					case 'triss':
						return 'teleport_in_triss_green';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_green';
				}
			//case ENR_ColorSpecial1:
			//	return 'ENR_ColorSpecial1';
			//case ENR_ColorSpecial2:
			//	return 'ENR_ColorSpecial2';
			//case ENR_ColorSpecial3:
			//	return 'ENR_ColorSpecial3';
			case ENR_ColorWhite:
			default:	
				switch (fx_type) {
					case 'hermit':
						return 'teleport_in_water_white';
					case 'triss':
						return 'teleport_in_triss_white';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_white';
				}
		}
	}
}

state Teleporting in NR_MagicTeleport {
	protected var startTime : float;

	event OnEnterState( prevStateName : name )
	{		
		parent.inPostState = true;
		TeleportingRun();
	}

	event OnLeaveState( nextStateName : name )
	{
		parent.inPostState = false;
	}

	function GetLocalTime() : float {
		return theGame.GetEngineTimeAsSeconds() - startTime;
	}

	entry function TeleportingRun()
	{
		var shiftVec  : Vector;
		var timeWait  : float;

		startTime = theGame.GetEngineTimeAsSeconds();
		timeWait = 0.5f * thePlayer.GetAnimationTimeMultiplier();
		NR_Info("TeleportingRun: timeWait = " + timeWait);
		// to make ignore hits
		thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
		thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_Default );
		thePlayer.EnableCollisions( false );
		thePlayer.EnableCharacterCollisions( false );
		thePlayer.SetGameplayVisibility( false );
		
		parent.pos = thePlayer.GetWorldPosition();
		parent.rot = thePlayer.GetWorldRotation();
		parent.oldCameraPos = theCamera.GetCameraPosition();
		shiftVec = parent.teleportPos - thePlayer.GetWorldPosition();
		parent.entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_static_camera");
		// YEAH, that simple!
		parent.teleportCamera = (CStaticCamera)theGame.CreateEntity( parent.entityTemplate, theCamera.GetCameraPosition() + shiftVec, theCamera.GetCameraRotation() );
		if ( !parent.teleportCamera ) {
			NR_Error("TeleportingRun: No valid teleport camera.");
		}
		parent.teleportCamera.activationDuration = 0.4f; // in w2ent already
		parent.teleportCamera.deactivationDuration = 0.4f; // in w2ent already
		Sleep(0.1f);
		parent.teleportCamera.Run();
		Sleep(0.1f);
		thePlayer.SetVisibility( false );

		// camera auto-rotates to player heading, so set it to camera rotation to make it smooth theCamera
		thePlayer.TeleportWithRotation( parent.teleportPos, VecToRotation(theCamera.GetCameraForwardOnHorizontalPlane()) );
		
		while (true) {
			SleepOneFrame();
			if (parent.l_breakEventReceived) {
				NR_Info("TeleportingRun: l_breakEventReceived = " + parent.l_breakEventReceived);
				// stop at current position
				parent.teleportCamera.Stop();
				parent.teleportCamera.DestroyAfter(5.f);

				// use old position
				thePlayer.Teleport( parent.pos );
				thePlayer.PlayEffect( parent.m_fxNameExtra );
				Sleep(0.05f);
				thePlayer.SetVisibility( true );
				break;
			}

			if (GetLocalTime() > timeWait || parent.l_performEventReceived) {
				NR_Info("TeleportingRun: l_performEventReceived = " + parent.l_performEventReceived + ", GetLocalTime = " + GetLocalTime());
				thePlayer.PlayEffect( parent.m_fxNameExtra );
				if (thePlayer.IsInCombat() && parent.IsActionAbilityEnabled("AutoCounterPush") && parent.SkillLevel() * 2 + 10 >= NR_GetRandomGenerator().nextRange(1, 100)) {
					PerformAutoPush();
				}

				// NR_Info("TeleportingRun: l_performEventReceived: before, camera running = " + parent.teleportCamera.IsRunning());
				Sleep(0.1f);  // wait for effect a bit
				thePlayer.SetVisibility( true );

				// NR_Info("TeleportingRun: l_performEventReceived: inter, camera running = " + parent.teleportCamera.IsRunning());
				Sleep(0.05f);
				// NR_Info("TeleportingRun: l_performEventReceived: after, camera running = " + parent.teleportCamera.IsRunning());
				parent.teleportCamera.Stop();
				parent.teleportCamera.DestroyAfter(5.f);
				break;
			}
		}
		// ready for new hits
		thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );
		thePlayer.SetImmortalityMode( AIM_None, AIC_Default );
		thePlayer.EnableCollisions( true );
		thePlayer.EnableCharacterCollisions( true );
		thePlayer.SetGameplayVisibility( true );

		GotoState('Finished');
	}

	latent function PerformAutoPush() {
		var nr_manager : NR_MagicManager = NR_GetMagicManager();
		var action : NR_MagicCounterPush;

		NR_Info("TeleportingRun.PerformAutoPush");
		action = new NR_MagicCounterPush in nr_manager;
		action.drainStaminaOnPerform = false;
		nr_manager.AddActionScripted(action);
		action.OnInit();
		action.OnPrepare();
		action.OnPerform();
	}
}

state Finished in NR_MagicTeleport {
}
