/* I have to change some params which are hard-coded in vanilla states */
state HorseRiding in NR_ReplacerSorceress
{
	event OnEnterState( prevStateName : name )
	{
		NR_Debug("NR_ReplacerSorceress.HorseRiding: OnEnterState from " + prevStateName);
		parent.AddTimer('NR_SetTargetDist', 0.5f);
		if (parent.NR_IsQuenActive()) {
			parent.NR_ReattachQuen(true);
		}
		super.OnEnterState( prevStateName );
	}

	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		parent.NR_SetTargetDist(0.0, 0);
		parent.magicManager.SetMiscStateActionsBlocked(false);
		if (parent.NR_IsQuenActive()) {
			parent.NR_ReattachQuen(false);
		}
	}
}
