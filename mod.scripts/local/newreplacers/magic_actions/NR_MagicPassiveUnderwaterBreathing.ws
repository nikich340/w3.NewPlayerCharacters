statemachine class NR_MagicPassiveUnderwaterBreathing extends NR_MagicPassiveAction {
}

state Run in NR_MagicPassiveUnderwaterBreathing {
	var l_breathingBubble : NR_BreathingBubble;

	entry function RunPassive() {
		var bubbleTemplate : CEntityTemplate;
		var MAC : CMovingPhysicalAgentComponent;

		thePlayer.AddBuffImmunity(EET_Drowning, 'NR_MagicPassiveUnderwaterBreathing', false);
		thePlayer.AddBuffImmunity(EET_AirDrainDive, 'NR_MagicPassiveUnderwaterBreathing', false);

		MAC = (CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent();
		bubbleTemplate = (CEntityTemplate)LoadResource("nr_breathing_bubble");
		l_breathingBubble = (NR_BreathingBubble)theGame.CreateEntity(bubbleTemplate, thePlayer.GetWorldPosition());
		if ( !l_breathingBubble.CreateAttachment(thePlayer, 'head') ) {
			NR_Error("NR_MagicPassiveUnderwaterBreathing.RunPassive: can't attach bubble!");
			return;
		}
		l_breathingBubble.Init(0.35f, 1.f);

		while (true) {
			Sleep(0.1f);
			if ( MAC.IsDiving() ) {
				if ( !l_breathingBubble.IsActive() )
					l_breathingBubble.Activate();
			} else {
				if ( l_breathingBubble.IsActive() )
					l_breathingBubble.Deactivate();
			}
		}
	}
}
