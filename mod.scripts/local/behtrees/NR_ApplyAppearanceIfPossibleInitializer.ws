class NR_ApplyAppearanceIfPossibleInitializer extends ISpawnTreeScriptedInitializer {
	function Init( actor : CActor ) : bool
	{
		if ( actor.HasTag('nr_master_cat') ) {
			NR_Debug("NR_ApplyAppearanceIfPossibleInitializer: DLC = " + theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals'));
			if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') )
				actor.ApplyAppearance( 'cat_08' );
		}
		
		return true;
	}
}
