exec function tanim(idx : int) {
	var demoTemplate : CEntityTemplate;
	var demo : NR_AnimsDemo;

	demo = (NR_AnimsDemo)theGame.GetEntityByTag('NR_AnimsDemo'); 
	if (!demo) {
		demoTemplate = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_anims_demo.w2ent", true);
		demo = (NR_AnimsDemo) theGame.CreateEntity(demoTemplate, thePlayer.GetWorldPosition());
		demo.AddTag('NR_AnimsDemo');
		demo.init();
		demo.GotoState('CamFollow');
	}
	demo.setup(1, 1, 0);
	demo.playAnim(idx);
}
exec function animDemo(_repeatTimes : int, _pause : float, _returnToOrig : bool) {
	var demoTemplate : CEntityTemplate;
	var demo : NR_AnimsDemo;

	demo = (NR_AnimsDemo)theGame.GetEntityByTag('NR_AnimsDemo'); 
	if (!demo) {
		demoTemplate = (CEntityTemplate)LoadResource("dlc/dlcnewreplacers/data/entities/nr_anims_demo.w2ent", true);
		demo = (NR_AnimsDemo) theGame.CreateEntity(demoTemplate, thePlayer.GetWorldPosition());
		demo.AddTag('NR_AnimsDemo');
		demo.init();
		demo.GotoState('CamFollow');
	}
	demo.setup(_repeatTimes, _pause, _returnToOrig);
	demo.startDemo();
}

statemachine class NR_AnimsDemo extends CEntity {
	var anims 	  : array<name>;
	var durations : array<float>;
	var isAdditives : array<bool>;
	var pause : float;
	var repeatTimes : int;
	var returnToOrig : bool;
	var origPos : Vector;
	var origRot : EulerAngles;
	var currentIdx : int;
	var currentRepeat : int;
	var camera : CStaticCamera;

	function addAnim(animName : name, duration : float, isAdditive : bool) {
		anims.PushBack(animName);
		durations.PushBack(duration);
		isAdditives.PushBack(isAdditive);
	}


    















































    function addAnims() {
		addAnim('woman_sorceress_attack_arcane_lp_03', 1.83333, false);
		addAnim('woman_sorceress_attack_throw_rp_01', 1.83333, false);
		addAnim('woman_sorceress_attack_push_lp_02', 0.733333, false);
		addAnim('woman_sorceress_attack_push_rp', 0.8, false);
		addAnim('woman_sorceress_attack_rock_bhand_lp', 2.73333, false);
		addAnim('woman_sorceress_attack_rock_bhand_rp', 2.73333, false);
		addAnim('woman_sorceress_attack_rock_lhand_lp', 2.73333, false);
		addAnim('woman_sorceress_attack_rock_lhand_rp', 2.73333, false);
		addAnim('woman_sorceress_attack_rock_rhand_lp', 2.73333, false);
		addAnim('woman_sorceress_attack_rock_rhand_rp', 2.73333, false);
		addAnim('woman_sorceress_attack_slash_left_lp', 2, false);
		addAnim('woman_sorceress_attack_slash_left_rp', 1.8, false);
		addAnim('woman_sorceress_attack_slash_right_lp', 2, false);
		addAnim('woman_sorceress_attack_slash_right_rp', 2, false);
		addAnim('woman_sorceress_attack_throw_lp_04', 1.83333, false);
		addAnim('woman_sorceress_attack_throw_rp_01', 1.83333, false);
		addAnim('woman_sorceress_attack_throw_rp_03', 1.83333, false);
		addAnim('woman_sorceress_rip_apart_kill_lp', 3.86667, false);
		addAnim('woman_sorceress_rip_apart_kill_rp', 3.86667, false);
		addAnim('woman_sorceress_teleport_lp', 2.16667, false);
		addAnim('woman_sorceress_teleport_rp', 2.16667, false);
    }





	function init() {
		addAnims();
		NR_Notify("Init: added anims: " + anims.Size());
		camera = NR_getStaticCamera();
		camera.activationDuration = 0;
		camera.deactivationDuration = 0;
	}
	function setup(_repeatTimes : int, _pause : float, _returnToOrig : bool) {
		repeatTimes =_repeatTimes;
		pause = _pause;
		returnToOrig = _returnToOrig;
		origPos = thePlayer.GetWorldPosition();
		origRot = thePlayer.GetWorldRotation();

		currentRepeat = 0;
		currentIdx = 0;
	}
	function startDemo() {
		AddTimer('PlayNextAnim', 1.0f);
		AddTimer('RestoreOrigin', 1.0f);
	}
	function playAnim(idx : int) {
		var line : String;
		line = "Playing anim(" + (idx + 1) + "/" + anims.Size() + "): ";
		thePlayer.PlayerStartAction( 1, anims[idx] );

		if (isAdditives[idx]) {
			line += "_ADD_";
		}
		line += "[" + anims[idx] + "]";
		NR_Notify(line, durations[idx]);
	}
	timer function RestoreOrigin( delta : float, id : int ) {
		//NR_Notify("RestoreOrigin: currentRepeat: " + currentRepeat + ", currentIdx: " + currentIdx);
		thePlayer.TeleportWithRotation(origPos, origRot);
		camera.Run();
		camera.Stop();
		//theCamera.Reset();
	}
	timer function PlayNextAnim( delta : float, id : int ) {
		currentRepeat += 1;
		//NR_Notify("PlayNextAnim: currentRepeat: " + currentRepeat + ", currentIdx: " + currentIdx);
		if (currentRepeat > repeatTimes) {
			currentRepeat = 1;
			currentIdx += 1;

			if (currentIdx < anims.Size()) {
				playAnim(currentIdx);
				if (returnToOrig) {
					AddTimer('RestoreOrigin', durations[currentIdx] + pause, false);
					AddTimer('PlayNextAnim', durations[currentIdx] + 2*pause, false);
				} else {
					AddTimer('PlayNextAnim', durations[currentIdx] + pause, false);
				}
			}
		} else {
			if (currentIdx < anims.Size()) {
				playAnim(currentIdx);
				if (returnToOrig) {
					AddTimer('RestoreOrigin', durations[currentIdx] + pause, false);
					AddTimer('PlayNextAnim', durations[currentIdx] + 2*pause, false);
				} else {
					AddTimer('PlayNextAnim', durations[currentIdx] + pause, false);
				}
			}
		}
	}
}

state CamFollow in NR_AnimsDemo {
	event OnEnterState( prevStateName : name )
	{
		TrackCameraLoop();
	} 
	
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
	}
	
	entry function TrackCameraLoop()
	{
		/*var pos : Vector;
		var camera: CStaticCamera;

		camera = NR_getStaticCamera();
		while (1) {
			pos = thePlayer.GetWorldPosition();
			pos.X += 2.0;
			pos.Y -= 0.4;
			pos.Z -= 0.3;
			camera.Teleport( pos );
			Sleep(0.0333);
		}*/
	}
}



exec function tcam0(_allow : bool) {
	var camera : CCustomCamera;
	camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
	camera.SetAllowAutoRotation(_allow);
}

exec function tcam1(_name : name) {
	var camera : CCustomCamera;
	camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
	camera.ChangePreset(_name);
}

exec function getposs()
{
	NR_Notify("Player pos: " + VecToString(thePlayer.GetWorldPosition()));
}

exec function setupPlayer() {
	var camera : CStaticCamera;
	var comp   : CCameraComponent;
	var pos : Vector;
	var rot : EulerAngles;

	pos = Vector(-125.45, 192.56, 0.47);
	rot = EulerAngles(0, 110, 0);

	thePlayer.TeleportWithRotation( pos, rot );
	theGame.SetGameTime( GameTimeCreate(9, 9, 0, 0 ), true );

	camera = NR_getStaticCamera();
	camera.BreakAttachment();
	pos.X += 2.5;
	pos.Y -= 0.5;
	pos.Z -= 0.3;
	rot.Yaw -= 45.0;
	camera.TeleportWithRotation( pos, rot );
	comp = (CCameraComponent)camera.GetComponentByClassName('CCameraComponent');
	//comp.fov = 45;
	camera.activationDuration = 1.0;
	camera.deactivationDuration = 1.0;
	camera.Run();

	//camera.FollowWithRotation(thePlayer);
	//camera.CreateAttachment( thePlayer, , Vector(2,0.4,0.3), EulerAngles(0,-45.0,0.0) );
}

