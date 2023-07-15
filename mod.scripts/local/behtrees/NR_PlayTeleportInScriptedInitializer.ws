class NR_PlayTeleportInScriptedInitializer extends ISpawnTreeScriptedInitializer {
	function Init( actor : CActor ) : bool
	{
		actor.PlayEffect( 'teleport_in' );
		return true;
	}
}
