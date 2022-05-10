class NR_MagicTeleport extends NR_MagicAction {
	protected var teleportCamera 	: CStaticCamera;
	protected var teleportPos 	: Vector;
	default actionType = ENR_Teleport;	

	latent function SetTeleportPos(pos : Vector) {
		teleportPos = pos;
	}
	latent function onPrepare() : bool {
		var template : CEntityTemplate;
		var shiftVec  : Vector;

		super.onPrepare();

		thePlayer.PlayEffect( map[sign].getN("teleport_out_fx") );

		shiftVec = teleportPos - thePlayer.GetWorldPosition();
		template = (CEntityTemplate)LoadResourceAsync("nr_static_camera");
		// YEAH, that simple!
		teleportCamera = (CStaticCamera)theGame.CreateEntity( template, theCamera.GetCameraPosition() + shiftVec, theCamera.GetCameraRotation() );
		if ( !teleportCamera ) {
			NRE("Prepare: No valid teleport camera.");
			return onPrepared(false);
		}
		//parent.aTeleportCamera.activationDuration = 0.5f; // in w2ent already
		//parent.aTeleportCamera.deactivationDuration = 0.5f; // in w2ent already
		teleportCamera.RunAndWait(0.2f);
		
		// ? Sleep(0.2f); // wait for effect a bit
		thePlayer.SetGameplayVisibility(false);
		thePlayer.SetVisibility(false);
		thePlayer.TeleportWithRotation(teleportPos, thePlayer.GetWorldRotation());

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
		}

		thePlayer.PlayEffect( map[sign].getN("teleport_in_fx") );
		if ( !teleportCamera ) {
			NRE("Perform: No valid teleport camera.");
			return onPerformed(false);
		}
		Sleep(0.2f);  // wait for effect a bit
		thePlayer.SetGameplayVisibility(true);
		thePlayer.SetVisibility(true);

		Sleep(0.1f);
		teleportCamera.Stop();
		teleportCamera.DestroyAfter(5.f);
		// ready for new hits
		thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );

		return onPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (teleportCamera) {
			thePlayer.SetGameplayVisibility(true);
			thePlayer.SetVisibility(true);
			thePlayer.SetImmortalityMode( AIM_None, AIC_Combat );
			teleportCamera.Stop();
			teleportCamera.Destroy();
		}
	}
}
