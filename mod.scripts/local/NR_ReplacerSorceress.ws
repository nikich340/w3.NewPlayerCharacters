statemachine class NR_ReplacerSorceress extends NR_ReplacerWitcheress {
	var magicMan : NR_MagicManager;

	default replacerName      = "nr_replacer_sorceress";
	default inventoryTemplate = "nr_replacer_sorceress_inv";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		magicMan = new NR_MagicManager in this;
		magicMan.InitDefault();
		magicMan.GotoState('MagicLoop');

		//AddAnimEventCallback('FX_out',	'OnAnimEventMagic2');
		//AddAnimEventCallback('FX_out',	'OnAnimEventMagic2');
		//AddAnimEventCallback('Appear',	'OnAnimEventMagic2');

		super.OnSpawned( spawnData );
	}
	event OnAnimEventMagic2( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var magicEvent : SNR_MagicEvent;

		magicEvent.eventName = animEventName;
		magicEvent.animName = GetAnimNameFromEventAnimInfo(animInfo);
		magicEvent.animTime = GetLocalAnimTimeFromEventAnimInfo(animInfo);
		//magicEvent.eventDuration = GetEventDurationFromEventAnimInfo(animInfo);
		NR_Notify("OnAnimEventMagic2:: eventName = " + magicEvent.eventName + ", animName = " + magicEvent.animName);
		// will be auto-processed async in next frame
		magicMan.aEventsStack.PushBack(magicEvent);
	}
	public function ReactToBeingHit(damageAction : W3DamageAction, optional buffNotApplied : bool) : bool {
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

		// Avoid reflecting damage from horns
		attackAction.SetCannotReturnDamage( true );
		return ret;
	}
}

/*exec function sproj(resName : name) {
	var sorc : NR_ReplacerSorceress;
	sorc = (NR_ReplacerSorceress) thePlayer;
	if (sorc) {
		sorc.magicMan.testProjName = resName;
	}
}*/
exec function s0() {
	thePlayer.GotoState( 'CombatSorceress', false );
}

exec function sw() {
	var ids : array<SItemUniqueId>;
	ids = thePlayer.GetInventory().AddAnItem('fists_fire', 1, true, true, false);
	NR_Notify("Mount: " + thePlayer.GetInventory().MountItem( ids[0] ));
}

exec function sff() {
	thePlayer.GotoState( 'CombatFists', false );
}
exec function scheck() {
	NR_Notify("State: " + NameToString(thePlayer.GetCurrentStateName()));
}
exec function scheck2() {
	if ((NR_ReplacerSorceress)thePlayer) {
		NR_Notify("NR_ReplacerSorceress!");
	}
	
}
//'Disappear'
exec function se(eventName : name) {
	thePlayer.RaiseForceEvent(eventName);
}

exec function s1() {
	var ret : Bool;
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	ret = thePlayer.RaiseForceEvent('Disappear');
	NR_Notify("Ret = " + ret);
}
exec function s2() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('Appear');
}
exec function s3(bIsGuarded : bool) {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.SetBehaviorVariable('bIsGuarded', (int)bIsGuarded);
	thePlayer.RaiseForceEvent('Walk');
}
exec function s4() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('Hit');
}
exec function s5() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('Idle');
}
exec function s6() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('CriticalState');
}
exec function s7(type : EAttackType) {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.SetBehaviorVariable('AttackType', (int)type); // 20
	thePlayer.RaiseForceEvent('Attack');
}
exec function s8() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('Taunt');
}
exec function s9() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('ParryPerform');
}
exec function s10() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('Rotate');
}
exec function s11(npcPose : ENpcPose, bIsGuarded : bool) {
	thePlayer.SetBehaviorVariable('npcPose', (int)npcPose);
	thePlayer.SetBehaviorVariable('bIsGuarded', (int)bIsGuarded);
	thePlayer.RaiseForceEvent('Idle');
}
exec function s12() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.RaiseForceEvent('StartFlee');
}
exec function s13() {
	thePlayer.SetBehaviorVariable('npcPose', (int)ENP_RightFootFront);
	thePlayer.SetBehaviorVariable('DeathType', (int)EDT_Agony);
	thePlayer.SetBehaviorVariable('AgonyType', (int)AT_ThroatCut);
	thePlayer.SetBehaviorVariable('HitReactionDirection', (int)EHRD_Forward);
	thePlayer.RaiseForceEvent('Death');
}

exec function sstance( stance : float )
{
	thePlayer.SetBehaviorVariable( 'combatIdleStance', stance );
	thePlayer.SetBehaviorVariable( 'CombatStanceForOverlay', stance );
}
/*
if ( animEventName == 'CombatStanceLeft' )
{
	owner.SetBehaviorVariable( 'npcPose', (int)ENP_RightFootFront);
	return true;
}
else if ( animEventName == 'CombatStanceRight' )
{
	owner.SetBehaviorVariable( 'npcPose', (int)ENP_LeftFootFront);
	return true;
}
else if ( animEventName == 'PunchHand_Left' )
{
	owner.SetBehaviorVariable( 'punchHand', 0.0f );
}		
else if ( animEventName == 'PunchHand_Right' )
{
	owner.SetBehaviorVariable( 'punchHand', 1.0f );
}
*/

/*
enum ENpcPose
{
	ENP_LeftFootFront,
	ENP_RightFootFront
}
*/