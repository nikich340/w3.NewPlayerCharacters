class W3SignOwnerSorceress extends W3SignOwnerPlayer {
	public function InitCastSign( signEntity : W3SignEntity ) : bool
	{
		// player.OnProcessCastingOrientation( false );
		// player.SetBehaviorVariable( 'alternateSignCast', 0 );
		// player.SetBehaviorVariable( 'IsCastingSign', 1 );
						
			
		player.BreakPheromoneEffect();
			
		return true;
	}
}
