/* Update magic hint info */
state Swimming in NR_ReplacerSorceress
{
	event OnEnterState( prevStateName : name )
	{
		parent.magicManager.UpdateMagicControlHints( thePlayer.GetCurrentStateName() );
		super.OnEnterState( prevStateName );
	}

	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState( nextStateName );
		parent.magicManager.UpdateMagicControlHints( nextStateName );
	}
}
