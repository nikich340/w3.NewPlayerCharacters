statemachine class NR_ReplacerSorceress extends NR_ReplacerWitcheress {
	var magicMan : NR_MagicManager;

	default replacerName      = "nr_replacer_sorceress";
	default inventoryTemplate = "nr_replacer_sorceress_inv";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		magicMan = new NR_MagicManager in this;
		magicMan.InitDefault();
		magicMan.GotoState('MagicLoop');

		super.OnSpawned( spawnData );
	}

	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool {
		var magicEvent : SNR_MagicEvent;
		magicEvent.eventName = 'BreakMagicAttack';
        magicMan.aEventsStack.PushBack(magicEvent);

        NR_Notify("ReactToBeingHit, damage = " + damageAction.DealsAnyDamage());
        
        return super.ReactToBeingHit(damageAction, buffNotApplied);
	}
	public function ReactToReflectedAttack( target : CGameplayEntity)
	{
		NR_Notify("BLOCK ReactToReflectedAttack!");
		//super.ReactToReflectedAttack(target);
	}

	function SetEquippedSign( signType : ESignType )
	{
		NR_Notify("Selected sign: " + signType);
		super.SetEquippedSign(signType);

		// must be processed in sync
		magicMan.HandFX(true, true);
	}

	protected function PrepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
	{
		var ret : Bool;
		ret = super.PrepareAttackAction(hitTarget, animData, weaponId, parried, countered, parriedBy, 
			attackAnimationName, hitTime, weaponEntity, attackAction);

		// Avoid reflecting damage (it's not really fistfight)
		attackAction.SetCannotReturnDamage( true );
		return ret;
	}
}

exec function sw() {
	var ids : array<SItemUniqueId>;
	ids = thePlayer.GetInventory().AddAnItem('fists_fire', 1, true, true, false);
	NR_Notify("Mount: " + thePlayer.GetInventory().MountItem( ids[0] ));
}
exec function scheck() {
	NR_Notify("State: " + NameToString(thePlayer.GetCurrentStateName()));
}
