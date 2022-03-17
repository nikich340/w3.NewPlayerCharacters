exec function sspawn(id : int, optional hostile : Bool, optional level : Bool) {
	var ent : CEntity;
	var pos : Vector;
	var template : CEntityTemplate;
	var npc : CNewNPC;

	if (id == 1) {
		template = (CEntityTemplate)LoadResource("characters/npc_entities/main_npc/triss.w2ent", true);
	} else if (id == 2) {
		template = (CEntityTemplate)LoadResource("quests\main_npcs\yennefer.w2ent", true);
	} else if (id == 3) {
		template = (CEntityTemplate)LoadResource("quests\secondary_npcs\philippa_eilhart.w2ent", true);
	} else if (id == 4) {
		template = (CEntityTemplate)LoadResource("quests\secondary_npcs\keira_metz.w2ent", true);
	} else if (id == 5) {
		template = (CEntityTemplate)LoadResource("quests\part_1\quest_files\q104_mine\characters\q104_evil_keira.w2ent", true);
	} else if (id == 6) {
		template = (CEntityTemplate)LoadResource("quests\secondary_npcs\margarita.w2ent", true);
	} else if (id == 7) {
		template = (CEntityTemplate)LoadResource("quests\secondary_npcs\fringilla_vigo.w2ent", true);
	} else if (id == 11) {
		template = (CEntityTemplate)LoadResource("quests\main_npcs\avallach.w2ent", true);
	} else if (id == 12) {
		template = (CEntityTemplate)LoadResource("dlc\ep1\data\quests\quest_files\q601_intro\characters\q601_ofir_mage.w2ent", true);
	} else if (id == 13) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\quests\main_quests\quest_files\q701_wine_festival\characters\q701_00_nml_bandit_1h_sword_02_leader.w2ent", true);
	} else if (id == 14) {
		template = (CEntityTemplate)LoadResource("dlc\ep1\data\quests\main_npcs\olgierd.w2ent", true);
	}
	else if (id == 21) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\living_world\enemy_templates\water_hag_late.w2ent", true);
	}
	else if (id == 22) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\living_world\enemy_templates\wraith_late.w2ent", true);
	}
	else if (id == 23) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\living_world\enemy_templates\alghoul.w2ent", true);
	}
	else if (id == 24) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\living_world\enemy_templates\bear_late.w2ent", true);
	}
	else if (id == 25) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\living_world\enemy_templates\wyvern.w2ent", true);
	}
	else if (id == 26) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\quests\main_npcs\dettlaff_van_eretein_vampire.w2ent", true);
	}
	else if (id == 27) {
		template = (CEntityTemplate)LoadResource("dlc\bob\data\quests\main_npcs\dettlaff_van_eretein_monster.w2ent", true);
	}
	if (!template) {
		NR_Notify("Invalid id! 1+ for women, 11+ for men, 21+ for monsters");
		return;
	}

	pos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);
	ent = theGame.CreateEntity(template, pos );
	npc = (CNewNPC) ent;
	/*npc.SetImmortalityMode( AIM_None, AIC_Combat );
	npc.SetImmortalityMode( AIM_None, AIC_Default );
	npc.SetImmortalityMode( AIM_None, AIC_Fistfight );
	npc.SetImmortalityMode( AIM_None, AIC_IsAttackableByPlayer );*/

	if (hostile) {
		npc.SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
		npc.SetAttitude( thePlayer, AIA_Hostile );
		thePlayer.SetAttitude( npc, AIA_Hostile );
	}
	if (level) {
		npc.SetLevel( GetWitcherPlayer().GetLevel() );
	}
}

exec function ndrain(st : EStaminaActionType, optional mult : float) {
	GetWitcherPlayer().DrainStamina(st,,,,,mult);
}
exec function eproj() {
	var entityTemplate : CEntityTemplate;
	var proj : W3AdvancedProjectile;
	var collisionGroups : array<name>;

	collisionGroups.PushBack('Ragdoll');
	collisionGroups.PushBack('Terrain');
	collisionGroups.PushBack('Static');
	collisionGroups.PushBack('Water');

	entityTemplate = (CEntityTemplate)LoadResource('eredin_frost_proj');
	proj = (W3AdvancedProjectile)theGame.CreateEntity(entityTemplate, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
	proj.Init(thePlayer);
	proj.ShootProjectileAtPosition(proj.projAngle, proj.projSpeed, thePlayer.GetWorldPosition() + theCamera.GetCameraDirection() * 10.f, 20.f, collisionGroups);
}

exec function head1() {
	var heading : float;
	var vecH, vecR : Vector;
	heading = thePlayer.GetHeading();
	vecH = thePlayer.GetHeadingVector();
	vecR = thePlayer.GetWorldRight();

	NR_Notify("PLAYER: heading = " + heading + ", vecH = " + VecToString(vecH) + ", vecR = " + VecToString(vecR));
}

exec function head2() {
	var heading : float;
	var vecH, vecR : Vector;
	heading = theCamera.GetCameraHeading();
	vecH = theCamera.GetCameraDirection();
	vecR = theCamera.GetCameraRight();

	NR_Notify("CAMERA: heading = " + heading + ", vecH = " + VecToString(vecH) + ", vecR = " + VecToString(vecR));
}

exec function tp1() {
	var pos : Vector;
	var rot : EulerAngles;
	pos = thePlayer.GetWorldPosition();
	rot = thePlayer.GetWorldRotation();
	pos.X += 1;
	thePlayer.TeleportWithRotation(pos, rot);
}
exec function eff(eName : name) {
	thePlayer.PlayEffect(eName);
}
function EulerToString(euler: EulerAngles) : String {
	return "[" + FloatToStringPrec(euler.Pitch,3) + ", " + FloatToStringPrec(euler.Yaw,3) + ", " + FloatToStringPrec(euler.Roll,3) + "]";
}
function PrintPosRot(nname:String, pos:Vector, rot:EulerAngles) {
	NR_Notify(nname + ": " + VecToString(pos) + "; " + EulerToString(rot));
}

exec function tcam3(optional test : int, optional fl1 : float, optional fl2 : float, optional fl3 : float) {
	var currRotation, currVelocity : EulerAngles;
	var topCamera : CCustomCamera;
	var preset : SCustomCameraPreset;
	var camera : CStaticCamera;
	var pos, pos2 : Vector;
	var rot : EulerAngles;

	PrintPosRot("thePlayer", thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation());
	NR_Notify("thePlayer: heading: " + VecToString(thePlayer.GetHeadingVector()));
	PrintPosRot("theCamera", theCamera.GetCameraPosition(), theCamera.GetCameraRotation());
	NR_Notify("theCamera: fov = "+theCamera.GetFov()+"heading = " + theCamera.GetCameraHeading() + ", headingVec: " + VecToString(theCamera.GetCameraDirection()));
	topCamera = (CCustomCamera) theCamera.GetTopmostCameraObject();
	preset = topCamera.GetActivePreset();
	PrintPosRot("TopmostCamera", topCamera.GetWorldPosition(), topCamera.GetWorldRotation());
	NR_Notify("TopmostCamera:Preset: [" + NameToString(preset.pressetName) + "] distance: " + preset.distance + ", offset: " + VecToString(preset.offset));
	NR_Notify("TopmostCamera:PivotPos: [" + topCamera.GetActivePivotPositionController().controllerName + "] offset = " + topCamera.GetActivePivotPositionController().offsetZ + ", PivotRot: [" + topCamera.GetActivePivotRotationController().controllerName + "] minPitch = " + topCamera.GetActivePivotRotationController().minPitch + ", maxPitch = " + topCamera.GetActivePivotRotationController().maxPitch);
	NR_Notify("TopmostCamera:PivotDist: [" + topCamera.GetActivePivotDistanceController().controllerName + "] minDist = " + topCamera.GetActivePivotDistanceController().minDist + ", maxDist = " + topCamera.GetActivePivotDistanceController().maxDist);

	pos = theCamera.GetCameraPosition() - thePlayer.GetWorldPosition();
	NR_Notify("raw DIFF: " + VecToString(pos) + ", VecDistance: " + VecDistance(theCamera.GetCameraPosition(), thePlayer.GetWorldPosition()));

	camera = NR_getStaticCamera();
	camera.activationDuration = 1.f;
	camera.deactivationDuration = 1.f;
	if (test == -3) {
		((CCustomCamera)theCamera.GetTopmostCameraObject()).GetActivePivotPositionController().SetDesiredPosition(Vector(fl1, fl2, fl3));
	} else if (test == -2) {
		((CCustomCamera)theCamera.GetTopmostCameraObject()).GetActivePivotDistanceController().SetDesiredDistance(fl1);
	} else if (test == -1) {
		camera.Stop();
	} else if (test == 1) {


		
		camera.TeleportWithRotation(theCamera.GetCameraPosition(), theCamera.GetCameraRotation());
		camera.Run();


	} else if (test == 2) {
		camera = NR_getStaticCamera();
		camera.TeleportWithRotation(topCamera.GetWorldPosition(), topCamera.GetWorldRotation());
		camera.Run();
	} else if (test == 3) {
		camera = NR_getStaticCamera();
		pos = theCamera.GetCameraPosition();
		rot = theCamera.GetCameraRotation();
		rot.Pitch = AngleNormalize(rot.Pitch - 180);
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 4) {
		camera = NR_getStaticCamera();
		pos = theCamera.GetCameraPosition();
		rot = theCamera.GetCameraRotation();
		rot.Yaw = AngleNormalize(rot.Yaw - 180);
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 5) {
		camera = NR_getStaticCamera();
		pos = theCamera.GetCameraPosition();
		rot = theCamera.GetCameraRotation();
		rot.Pitch = AngleNormalize(rot.Pitch - 180);
		rot.Yaw = AngleNormalize(rot.Yaw - 180);
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 6) {
		camera = NR_getStaticCamera();
		pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * fl1;
		pos.Z += fl2;

		rot = thePlayer.GetWorldRotation();
		rot.Pitch += fl3;
		rot.Yaw -= 180.0;
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 7) {
		camera = NR_getStaticCamera();
		pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * fl1;
		pos.Z += fl2;

		rot = thePlayer.GetWorldRotation();
		rot.Pitch += fl3;
		//rot.Yaw -= 180.0;
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	} else if (test == 8) {
		camera = NR_getStaticCamera();
		pos = thePlayer.GetWorldPosition() + thePlayer.GetHeadingVector() * -2.11;
		pos.Z += 0.62;

		rot = thePlayer.GetWorldRotation();
		rot.Pitch += 9.5;
		rot.Yaw -= 180.0;
		camera.TeleportWithRotation(pos, rot);
		camera.Run();
	}
}

function NR_getStaticCamera(): CStaticCamera {
	var template: CEntityTemplate;
	var camera: CStaticCamera;

	camera = (CStaticCamera)theGame.GetEntityByTag('NR_CAMERA');
	if (!camera) {
		template = (CEntityTemplate)LoadResource("nr_static_camera");
		camera = (CStaticCamera)theGame.CreateEntity( template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
		camera.AddTag('NR_CAMERA');
		NR_Notify("Camera created!");
	}
	return camera;
}

exec function tcam2(cmd : String, optional val : float, optional val2 : float, optional val3 : float) {
	var camera : CStaticCamera;
	var comp   : CCameraComponent;
	var pos : Vector;
	var rot : EulerAngles;

	camera = NR_getStaticCamera();
	if (cmd == "toplayer") {
		camera.TeleportWithRotation( thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
	} else if (cmd == "posoff") {
		pos = camera.GetWorldPosition();
		if (val)
			pos.X += val;
		if (val2)
			pos.Y += val2;
		if (val3)
			pos.Z += val3;
		camera.TeleportWithRotation( pos, camera.GetWorldRotation() );
	} else if (cmd == "rotoff") {
		rot = camera.GetWorldRotation();
		if (val)
			rot.Pitch += val;
		if (val2)
			rot.Yaw += val2;
		if (val3)
			rot.Roll += val3;
		camera.TeleportWithRotation( camera.GetWorldPosition(), rot );
	} else if (cmd == "run") {
		camera.Run();
	} else if (cmd == "stop") {
		camera.Stop();
	} else if (cmd == "zoom" && val > 0.1) {
		camera.SetZoom(val);
	} else if (cmd == "fov" && val > 0.1) {
		camera.SetFov(val);
	} else if (cmd == "act" && val > 0.1) {
		camera.activationDuration = val;
	} else if (cmd == "deact" && val > 0.1) {
		camera.deactivationDuration = val;
	} else if (cmd == "timeout" && val > 0.1) {
		camera.timeout = val;
	} else if (cmd == "fadein" && val > 0.1) {
		camera.fadeStartDuration = val;
	} else if (cmd == "fadeout" && val > 0.1) {
		camera.fadeEndDuration = val;
	} else if (cmd == "reset") {
		camera.ResetRotation();
	} else if (cmd == "focus") {
		camera.FocusOn(thePlayer);
	} else if (cmd == "lookat") {
		camera.LookAt(thePlayer);
	} else if (cmd == "follow") {
		camera.CreateAttachment(thePlayer);
	} else if (cmd == "unfollow") {
		camera.BreakAttachment();
	} else {
		NR_Notify("Unknown command!");
	}
}