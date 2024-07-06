statemachine class NR_MagicPassiveAction extends NR_MagicAction {
}

state Run in NR_MagicPassiveAction {
	event OnEnterState( prevStateName : name )
	{		
		RunPassive();
	}

	entry function RunPassive() {}

	event OnLeaveState( nextStateName : name )
	{
	}
}
