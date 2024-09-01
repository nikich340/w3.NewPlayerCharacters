statemachine class NR_MagicPassiveAction extends NR_MagicAction {
	public function StopAction() {
		GotoState('Stop');
	}
}

state Run in NR_MagicPassiveAction {
	event OnEnterState( prevStateName : name )
	{
		NR_Info("NR_MagicPassiveAction::Run.OnEnterState.");
		RunPassive();
	}

	entry function RunPassive() {}

	event OnLeaveState( nextStateName : name )
	{
		NR_Info("NR_MagicPassiveAction::Run.OnLeaveState.");
	}
}

state Stop in NR_MagicPassiveAction {
}
