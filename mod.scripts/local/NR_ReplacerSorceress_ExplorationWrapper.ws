/* I have to change some params which are hard-coded in vanilla states */
state Exploration in NR_ReplacerSorceress
{
	event OnEnterState( prevStateName : name )
	{
		parent.AddTimer('NR_SetTargetDist', 0.5f);
		super.OnEnterState( prevStateName );
	}
}