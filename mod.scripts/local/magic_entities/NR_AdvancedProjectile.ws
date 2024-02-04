class NR_AdvancedProjectile extends W3AdvancedProjectile
{
	editable var initFxName 				: name;
	editable var onCollisionFxName 			: name;
	editable var spawnEntityTemplate 		: CEntityTemplate;
	editable var customDuration 			: float;
	editable var onCollisionVictimFxName 	: name;
	editable var immediatelyStopVictimFX 	: bool;
	editable var m_dealDamageInRange 		: float;
	editable var m_damageName 				: name;
	editable var m_respectCaster 			: bool;
	
	private var projectileHitGround : bool;
	
	default projDMG = 40.f;
	default projEfect = EET_SlowdownFrost;
	default customDuration = 2.0;
	default m_dealDamageInRange = 1.0;
	default m_damageName = 'ElementalDamage';
	default m_respectCaster = true;

	event OnProjectileInit()
	{
		this.PlayEffect(initFxName);
		projectileHitGround = false;
		isActive = true;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		if ( !isActive )
		{
			return true;
		}
		
		if ( collidingComponent )
			victim = ( CGameplayEntity )collidingComponent.GetEntity();
		else
			victim = NULL;
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
		
		if ( victim && !projectileHitGround && !collidedEntities.Contains( victim ) )
		{
			VictimCollision(victim);
		}
		// ? hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) || hitCollisionsGroups.Contains( 'Water' )
		else if ( !victim && !ignore ) 
		{
			ProjectileHitGround();
		}
	}
	
	protected function DestroyRequest()
	{
		StopEffect( initFxName );
		PlayEffect( onCollisionFxName );
		DestroyAfter( 2.f );
	}
	
	protected function PlayCollisionEffect()
	{
		// ? if ( victim == thePlayer && thePlayer.GetCurrentlyCastSign() == ST_Quen && ((W3PlayerWitcher)thePlayer).IsCurrentSignChanneled() )
		PlayEffect(onCollisionFxName);
	}
	
	protected function VictimCollision(victim : CGameplayEntity)
	{
		DealDamageToVictim(victim);
		PlayCollisionEffect();
		DeactivateProjectile();
	}
	
	protected function DealDamageToVictim(victim : CGameplayEntity)
	{
		var targetSlowdown 	: CActor;		
		var action : W3DamageAction;
		
		if (m_respectCaster && (victim == caster || GetAttitudeBetween(victim, caster) == AIA_Friendly))
			return;
		
		action = new W3DamageAction in this;
		action.Initialize( ( CGameplayEntity)caster, victim, this, caster.GetName(), EHRT_Light, CPS_SpellPower, false, true, false, false );
		action.AddDamage( m_damageName, projDMG );
		
		if ( projEfect != EET_Undefined )
		{
			if ( customDuration > 0 )
				action.AddEffectInfo( projEfect, customDuration );
			else
				action.AddEffectInfo( projEfect );
		}
		
		action.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction( action );
		delete action;	
		
		if ( IsNameValid( onCollisionVictimFxName ) )
			victim.PlayEffect( onCollisionVictimFxName );
		if ( immediatelyStopVictimFX )
			victim.StopEffect( onCollisionVictimFxName );
		
		collidedEntities.PushBack(victim);
	}
	
	protected function DeactivateProjectile()
	{
		isActive = false;
		this.StopEffect( initFxName );
		this.DestroyAfter( 5.f );
	}
	
	protected function ProjectileHitGround()
	{
		var ent : CEntity;
		var damageAreaEntity : CDamageAreaEntity;
		var i 				: int;
		var actorsAround 	: array<CActor>;
		
		this.PlayEffect( onCollisionFxName );
		if ( spawnEntityTemplate )
		{
			
			ent = theGame.CreateEntity( spawnEntityTemplate, this.GetWorldPosition(), this.GetWorldRotation() );
			damageAreaEntity = (CDamageAreaEntity)ent;
			if ( damageAreaEntity )
			{
				damageAreaEntity.owner = (CActor)caster;
				this.StopEffect( initFxName );
				projectileHitGround = true;
			}
		}
		else
		{
			actorsAround = GetActorsInRange( this, m_dealDamageInRange, , , true );
			for( i = 0; i < actorsAround.Size(); i += 1 )
			{
				DealDamageToVictim( actorsAround[i] );
			}
		}
		PlayCollisionEffect();
		DeactivateProjectile();
	}
}
