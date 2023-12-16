class NR_QuestCond_PlayerManagerReady extends CQuestScriptedCondition
{	
	function Evaluate() : bool
	{
		var ret : bool;

		ret = NR_GetPlayerManager().IsReady();
		NR_Debug("NR_QuestCond_PlayerManagerReady.Evaluate: " + ret);
		return ret;
	}
}
