exec function tanim(idx : int, _repeatTimes : int, _pause : float) {
	var demoTemplate : CEntityTemplate;
	var demo : NR_AnimsDemo;

	demo = new NR_AnimsDemo in theGame;
	demo.init();

	demo.setup(_repeatTimes, _pause, 0);
	demo.playAnim(idx);
}
exec function animDemo(_repeatTimes : int, _pause : float, _returnToOrig : bool) {
	var demoTemplate : CEntityTemplate;
	var demo : NR_AnimsDemo;

	demo = new NR_AnimsDemo in theGame;
	demo.init();

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
		addAnim('locomotion_salsa_cycle_01', 1.83333, false);
	}

	function init() {
		addAnims();
		theGame.GetGuiManager().ShowNotification("Init: added anims: " + anims.Size());
		//camera = NR_getStaticCamera();
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
		theGame.GetGuiManager().ShowNotification(line);
	}
	timer function RestoreOrigin( delta : float, id : int ) {
		//NR_Notify("RestoreOrigin: currentRepeat: " + currentRepeat + ", currentIdx: " + currentIdx);
		thePlayer.TeleportWithRotation(origPos, origRot);
	}
	timer function PlayNextAnim( delta : float, id : int ) {
		currentRepeat += 1;
		theGame.GetGuiManager().ShowNotification("PlayNextAnim: currentRepeat: " + currentRepeat + ", currentIdx: " + currentIdx);
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
