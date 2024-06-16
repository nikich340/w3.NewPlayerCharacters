/* Update magic hint info */
state Swimming in NR_ReplacerSorceress
{
	event OnEnterState( prevStateName : name )
	{
		if (parent.magicManager)
			parent.magicManager.UpdateMagicControlHints( thePlayer.GetCurrentStateName() );
		super.OnEnterState( prevStateName );
	}

	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		if (parent.magicManager)
			parent.magicManager.UpdateMagicControlHints( nextStateName );
	}
}
