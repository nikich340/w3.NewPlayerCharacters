statemachine class NR_BreathingBubble extends CGameplayEntity {
	var m_scale, m_targetScale, m_scalePerSec : float;
	var m_isActive : bool;
	var m_component : CMeshComponent;

	default m_targetScale 	= 1.0f;
	default m_scalePerSec 	= 0.5f; // 2 sec for 100%

	public function Init(targetScale : float, durationSeconds : float) {
		m_component = (CMeshComponent)GetComponent('bubble');
		m_targetScale = targetScale;
		m_scalePerSec = targetScale / durationSeconds;
		SetScale(0.f);
		m_isActive = false;
		NR_Debug("NR_BreathingBubble: Init, m_scalePerSec = " + m_scalePerSec);
	}

	protected function SetScale(newScale : float) {
		m_scale = newScale;
		m_component.SetScale( Vector(newScale, newScale, newScale) );
	}

	public function Activate() {
		if (!IsInState('Activating')) {
			GotoState('Activating');
		}
	}
	public function Deactivate() {
		if (!IsInState('Deactivating')) {
			GotoState('Deactivating');
		}
	}
}

state Activating in NR_BreathingBubble {
	event OnEnterState( prevStateName : name )
	{
		ActivatingLoop();
	}
	entry function ActivatingLoop() {
		var scale : float;
		var startTime, frameTime, prevFrameTime : float;

		scale = parent.m_scale;
		startTime = theGame.GetEngineTimeAsSeconds();
		prevFrameTime = startTime;

		NR_Debug("NR_BreathingBubble: start ActivatingLoop at " + startTime);
		while (scale < parent.m_targetScale) {
			SleepOneFrame();
			frameTime = theGame.GetEngineTimeAsSeconds();
			scale += parent.m_scalePerSec * (frameTime - prevFrameTime);
			if (scale > parent.m_targetScale) {
				scale = parent.m_targetScale;
			}
			parent.SetScale(scale);
			prevFrameTime = frameTime;
		}
		NR_Debug("NR_BreathingBubble: ActivatingLoop: target scale reached in " + (frameTime - startTime));
		parent.m_isActive = true;
	}
	event OnLeaveState( nextStateName : name )
	{
	}
}

state Deactivating in NR_BreathingBubble {
	event OnEnterState( prevStateName : name )
	{
		DeactivatingLoop();
	}
	entry function DeactivatingLoop() {
		var scale : float;
		var startTime, frameTime, prevFrameTime : float;

		scale = parent.m_scale;
		startTime = theGame.GetEngineTimeAsSeconds();
		prevFrameTime = startTime;

		NR_Debug("NR_BreathingBubble: start DeactivatingLoop at " + startTime);
		while (scale > 0.f) {
			SleepOneFrame();
			frameTime = theGame.GetEngineTimeAsSeconds();
			scale -= parent.m_scalePerSec * (frameTime - prevFrameTime);
			if (scale < 0.f) {
				scale = 0.f;
			}
			parent.SetScale(scale);
			prevFrameTime = frameTime;
		}
		NR_Debug("NR_BreathingBubble: DeactivatingLoop: target scale reached in " + (frameTime - startTime));
		parent.m_isActive = false;
	}
	event OnLeaveState( nextStateName : name )
	{
	}
}
