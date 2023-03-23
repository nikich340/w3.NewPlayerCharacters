class NR_MagicTeleport extends NR_MagicAction {
	protected var teleportCamera 	: CStaticCamera;
	protected var teleportPos 	: Vector;
	protected var oldCameraPos 	: Vector;
	default actionType = ENR_Teleport;

	latent function SetTeleportPos(pos : Vector) {
		teleportPos = pos;
	}

	latent function OnPrepare() : bool {
		var shiftVec  : Vector;

		super.OnPrepare();
		m_fxNameMain = TeleportOutFxName();
		m_fxNameExtra = TeleportInFxName();
		NRD("TELEPORT IN FX = " + m_fxNameMain + ", OUT = " + m_fxNameExtra);
		thePlayer.PlayEffect( m_fxNameMain );

		if ( IsInSetupScene() ) {
			Sleep(0.1f);
			thePlayer.SetGameplayVisibility(false);
			thePlayer.SetVisibility(false);
			return OnPrepared(true);
		}

		thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
		thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_Default );
		pos = thePlayer.GetWorldPosition();
		rot = thePlayer.GetWorldRotation();
		oldCameraPos = theCamera.GetCameraPosition();
		shiftVec = teleportPos - thePlayer.GetWorldPosition();
		entityTemplate = (CEntityTemplate)LoadResourceAsync("nr_static_camera");
		// YEAH, that simple!
		teleportCamera = (CStaticCamera)theGame.CreateEntity( entityTemplate, theCamera.GetCameraPosition() + shiftVec, theCamera.GetCameraRotation() );
		if ( !teleportCamera ) {
			NRE("Prepare: No valid teleport camera.");
			return OnPrepared(false);
		}
		//parent.aTeleportCamera.activationDuration = 0.5f; // in w2ent already
		//parent.aTeleportCamera.deactivationDuration = 0.5f; // in w2ent already
		Sleep(0.1f);
		teleportCamera.RunAndWait(0.15f);
		
		// ? Sleep(0.2f); // wait for effect a bit
		thePlayer.SetGameplayVisibility(false);
		thePlayer.SetVisibility(false);
		// camera auto-rotates to player heading, so set it to camera rotation to make it smooththeCamera
		thePlayer.TeleportWithRotation( teleportPos, VecToRotation(theCamera.GetCameraForwardOnHorizontalPlane()) );

		return OnPrepared(true);
	}

	latent function OnPerform() : bool {
		var super_ret : bool;
		super_ret = super.OnPerform();
		if (!super_ret) {
			return OnPerformed(false);
		}

		thePlayer.PlayEffect( m_fxNameExtra );
		if (FactsQuerySum("nr_magic_TeleportAutoPush") > 0 && RandRange(100) < 50) {
			PerformAutoPush();
		}

		if (IsInSetupScene()) {
			Sleep(0.2f);  // wait for effect a bit
			thePlayer.SetGameplayVisibility(true);
			thePlayer.SetVisibility(true);
			return OnPerformed(true);
		}

		if ( !teleportCamera ) {
			NRE("Perform: No valid teleport camera.");
			return OnPerformed(false);
		}
		Sleep(0.2f);  // wait for effect a bit
		thePlayer.SetGameplayVisibility(true);
		thePlayer.SetVisibility(true);

		Sleep(0.1f);
		teleportCamera.Stop();
		teleportCamera.DestroyAfter(5.f);
		// ready for new hits
		thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );
		thePlayer.SetImmortalityMode( AIM_None, AIC_Default );

		return OnPerformed(true);
	}

	latent function PerformAutoPush() {
		var nr_manager : NR_MagicManager = NR_GetMagicManager();
		var action : NR_MagicCounterPush;

		action = new NR_MagicCounterPush in nr_manager;
		action.drainStaminaOnPerform = false;
		nr_manager.AddActionManual(action);
		action.OnInit();
		action.OnPrepare();
		action.OnPerform();
	}

	latent function BreakAction() {
		// do not break if player is invulnerable ?
		if (isPrepared) {
			return;
		}

		super.BreakAction();
		if (teleportCamera) {
			thePlayer.Teleport(pos);
			teleportCamera.Teleport(oldCameraPos);
			teleportCamera.activationDuration = 0.1f;
			teleportCamera.deactivationDuration = 0.1f;
			teleportCamera.RunAndWait(0.1f);
			teleportCamera.Stop();
			teleportCamera.DestroyAfter(5.f);
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
