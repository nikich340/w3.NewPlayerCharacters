class NR_MagicTeleport extends NR_MagicAction {
	protected var teleportCamera 	: CStaticCamera;
	protected var teleportPos 	: Vector;
	default actionType = ENR_Teleport;	
	default actionName 	= 'TeleportFar';
	default drainStaminaOnPerform = false; // drained in state Combat

	latent function SetTeleportPos(pos : Vector) {
		teleportPos = pos;
	}
	latent function OnPrepare() : bool {
		var template : CEntityTemplate;
		var shiftVec  : Vector;

		super.OnPrepare();

		thePlayer.PlayEffect( map[sign].getN("teleport_out_fx") );

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

		thePlayer.PlayEffect( map[sign].getN("teleport_in_fx") );
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
}
