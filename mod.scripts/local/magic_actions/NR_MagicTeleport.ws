class NR_MagicTeleport extends NR_MagicAction {
	protected var teleportCamera 	: CStaticCamera;
	protected var teleportPos 	: Vector;
	default actionType = ENR_Teleport;
	default drainStaminaOnPerform = false; // drained in state Combat

	latent function SetTeleportPos(pos : Vector) {
		teleportPos = pos;
	}

	latent function OnPrepare() : bool {
		var template : CEntityTemplate;
		var shiftVec  : Vector;

		super.OnPrepare();

		thePlayer.PlayEffect( TeleportOutFxName() );

		shiftVec = teleportPos - thePlayer.GetWorldPosition();
		template = (CEntityTemplate)LoadResourceAsync("nr_static_camera");
		// YEAH, that simple!
		teleportCamera = (CStaticCamera)theGame.CreateEntity( template, theCamera.GetCameraPosition() + shiftVec, theCamera.GetCameraRotation() );
		if ( !teleportCamera ) {
			NRE("Prepare: No valid teleport camera.");
			return OnPrepared(false);
		}
		//parent.aTeleportCamera.activationDuration = 0.5f; // in w2ent already
		//parent.aTeleportCamera.deactivationDuration = 0.5f; // in w2ent already
		teleportCamera.RunAndWait(0.2f);
		
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

		thePlayer.PlayEffect( TeleportInFxName() );
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

	latent function BreakAction() {
		// do not break if player is invulnerable
		if (isPrepared) {
			return;
		}
		super.BreakAction();
		if (teleportCamera) {
			thePlayer.SetGameplayVisibility(true);
			thePlayer.SetVisibility(true);
			thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );
			thePlayer.SetImmortalityMode( AIM_None, AIC_Default );
			teleportCamera.Stop();
			teleportCamera.Destroy();
		}
	}

	latent function TeleportOutFxName() : name {
		var color 	: ENR_MagicColor = NR_GetActionColor();
		var fx_type : name			 = map[sign].getN("fx_type_" + ENR_MAToName(actionType));
		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'triss':
						return 'teleport_out_triss_yellow';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_yellow';
				}
			case ENR_ColorOrange:
				switch (fx_type) {
					case 'triss':
						return 'teleport_out_triss_orange';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_orange';
				}
			case ENR_ColorRed:
				switch (fx_type) {
					case 'triss':
						return 'teleport_out_triss_red';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_red';
				}
			case ENR_ColorPink:
				switch (fx_type) {
					case 'triss':
						return 'teleport_out_triss_pink';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_pink';
				}
			case ENR_ColorViolet:
				switch (fx_type) {
					case 'triss':
						return 'teleport_out_triss_violet';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_violet';
				}
			case ENR_ColorBlue:
				switch (fx_type) {
					case 'triss':
						return 'teleport_out_triss_blue';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_blue';
				}
			case ENR_ColorSeagreen:
				switch (fx_type) {
					case 'triss':
						return 'teleport_out_triss_seagreen';
					case 'yennefer':
					default:
						return 'teleport_out_yennefer_seagreen';
				}
			case ENR_ColorGreen:
				switch (fx_type) {
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
		var fx_type : name			 = map[sign].getN("fx_type_" + ENR_MAToName(actionType));
		switch (color) {
			//case ENR_ColorBlack:
			//	return 'ENR_ColorBlack';
			//case ENR_ColorGrey:
			//	return 'ENR_ColorGrey';
			case ENR_ColorYellow:
				switch (fx_type) {
					case 'triss':
						return 'teleport_in_triss_yellow';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_yellow';
				}
			case ENR_ColorOrange:
				switch (fx_type) {
					case 'triss':
						return 'teleport_in_triss_orange';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_orange';
				}
			case ENR_ColorRed:
				switch (fx_type) {
					case 'triss':
						return 'teleport_in_triss_red';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_red';
				}
			case ENR_ColorPink:
				switch (fx_type) {
					case 'triss':
						return 'teleport_in_triss_pink';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_pink';
				}
			case ENR_ColorViolet:
				switch (fx_type) {
					case 'triss':
						return 'teleport_in_triss_violet';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_violet';
				}
			case ENR_ColorBlue:
				switch (fx_type) {
					case 'triss':
						return 'teleport_in_triss_blue';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_blue';
				}
			case ENR_ColorSeagreen:
				switch (fx_type) {
					case 'triss':
						return 'teleport_in_triss_seagreen';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_seagreen';
				}
			case ENR_ColorGreen:
				switch (fx_type) {
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
					case 'triss':
						return 'teleport_in_triss_white';
					case 'yennefer':
					default:
						return 'teleport_in_yennefer_white';
				}
		}
	}
}
