class NR_ApplyAppearanceIfPossibleInitializer extends ISpawnTreeScriptedInitializer {
	function Init( actor : CActor ) : bool
	{
		if ( actor.HasTag('nr_master_cat') ) {
			if ( theGame.GetDLCManager().IsDLCAvailable('dlc_fanimals') )
				actor.ApplyAppearance( 'cat_08' );
			else
				actor.ApplyAppearance( 'cat_vanilla_04' );
		}
		
		return true;
	}
}
