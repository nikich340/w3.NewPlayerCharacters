/* Remove swords stuff after scene is ended */
state PlayerDialogScene in NR_ReplacerSorceress
{
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		parent.ExterminateSwordStuff();
		NR_Debug("NR_ReplacerSorceress::PlayerDialogScene.OnBlockingSceneEnded: output = " + output.action);

		if (output.action == SSOA_EnterCombatSteel || output.action == SSOA_EnterCombatSilver)
			output.action = SSOA_EnterCombatFists;
		super.OnBlockingSceneEnded(output);
	}
}
