statemachine class NR_ReplacerWitcheress extends NR_ReplacerWitcher {
	default m_replacerType      = ENR_PlayerWitcheress;
	default inventoryTemplate 	= "nr_replacer_witcheress_inv";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );

		AddAnimEventCallback( 'SlideToTarget', 	'OnAnimEvent_SlideToTarget' );
	}
	
	public function GetNameID() : int {
		return 2115940101; // 2115940101|00000000||Witcheress
	}
	
	/* from Ciri replacer class - fix sliding to target */
	event OnAnimEvent_SlideToTarget( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var minDistance			: float;
		
		if( !HasAbility('Ciri_Rage') )
			return false;
		
		if ( animEventType == AET_DurationStart )
			slideNPC = (CNewNPC)slideTarget;
		
		if ( !slideNPC )
			return false;
		
		if ( VecDistanceSquared(this.GetWorldPosition(),slideNPC.GetWorldPosition()) > 12*12 )
			return false;
		
		if ( animEventType == AET_DurationStart && slideNPC.GetGameplayVisibility() )
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelAll();
			slideTicket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
			movementAdjustor.BindToEventAnimInfo( slideTicket, animInfo );
			
			movementAdjustor.ScaleAnimation( slideTicket );
			minSlideDistance = this.GetRadius() + slideNPC.GetRadius() + 0.01f;
			movementAdjustor.SlideTowards( slideTicket, slideNPC, minSlideDistance, minSlideDistance );					
		}
		else if ( !slideNPC.GetGameplayVisibility() )
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			slideNPC = NULL;
		}
		else 
		{
			movementAdjustor = GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.SlideTowards( slideTicket, slideNPC, minSlideDistance, minSlideDistance );				
		}
	}
}
