/* I have to change some params which are hard-coded in vanilla states */
state HorseRiding in NR_ReplacerSorceress
{
	event OnEnterState( prevStateName : name )
	{
		parent.AddTimer('NR_SetTargetDist', 0.5f);
		parent.AddAnimEventCallback('InitAction',			'OnAnimEventMagic');
		parent.AddAnimEventCallback('Prepare',				'OnAnimEventMagic');
		parent.AddAnimEventCallback('Spawn',				'OnAnimEventMagic');
		parent.AddAnimEventCallback('Shoot',				'OnAnimEventMagic');
		parent.AddAnimEventCallback('PerformMagicAttack',	'OnAnimEventMagic');
		super.OnEnterState( prevStateName );
	}
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		parent.NR_SetTargetDist(0.0, 0);
		parent.RemoveAnimEventCallback('InitAction');
		parent.RemoveAnimEventCallback('Prepare');
		parent.RemoveAnimEventCallback('Spawn');
		parent.RemoveAnimEventCallback('Shoot');
		parent.RemoveAnimEventCallback('PerformMagicAttack');
	}
}
