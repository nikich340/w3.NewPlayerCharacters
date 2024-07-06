class NR_QuestCond_PlayerManagerReady extends CQuestScriptedCondition
{	
	function Evaluate() : bool
	{
		return NR_GetPlayerManager().IsReady();
	}
}
