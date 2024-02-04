class NR_MeteorProjectile extends W3FireballProjectile
{
	editable var explosionRadius 		: float;
	editable var markerEntityTemplate	: CEntityTemplate;
	editable var craterEntityTemplate	: CEntityTemplate;
	editable var destroyMarkerAfter		: float;
	editable var m_markerFxName 		: name;
	editable var m_damageName 			: name;
	editable var m_damageEffectDuration : float;
	public var m_respectCaster : bool;
	public var m_shakeStrength : float;
	protected var markerEntity : CEntity;
	protected var craterEntity : CEntity;
	
	default m_respectCaster = true;
	default m_damageName = 'ElementalDamage';
	default m_damageEffectDuration = 2.f;
	default m_shakeStrength = 3.f;
	default projSpeed = 10;
	default projAngle = 0;
	default explosionRadius = 3.f;
	default destroyMarkerAfter = 2.f;
	
	protected function VictimCollision( victim : CGameplayEntity )
	{
		
	}

	protected function DealDamageToVictim( victim : CGameplayEntity )
	{
		var action : W3DamageAction;
		var dEnt : W3DestroyableClue;
		var actor : CActor;
		
		action = new W3DamageAction in theGame;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Heavy,CPS_Undefined,false,true,false,false);
		action.AddDamage( m_damageName, projDMG * 0.5f );
		action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, projDMG * 0.5f );

		if ( projEfect != EET_Undefined )
		{
			if ( m_damageEffectDuration > 0 )
				action.AddEffectInfo( projEfect, m_damageEffectDuration );
			else
				action.AddEffectInfo( projEfect );
		}
		action.SetCanPlayHitParticle( false );
		theGame.damageMgr.ProcessAction( action );
		delete action;
		
		actor = (CActor)victim;
		if (actor) {
			actor.SignalGameplayEvent('IgniHitReceived');
		} else {
			dEnt = (W3DestroyableClue)dEnt;
			if (dEnt && dEnt.destroyable && !dEnt.destroyed) {
				dEnt.ProcessDestruction();
			}
		}
		collidedEntities.PushBack(victim);
	}
	
	protected function DeactivateProjectile( optional victim : CGameplayEntity)
	{
		if ( !isActive )
			return;
		
		Explode();
		
		
		if ( markerEntity )
		{
			markerEntity.StopAllEffects();
			markerEntity.DestroyAfter( destroyMarkerAfter );
		}
		
		super.DeactivateProjectile(victim);
		
	}
	
	protected function Explode()
	{
		var entities 		: array<CGameplayEntity>;
		var i				: int;
		
		FindGameplayEntitiesInCylinder( entities, this.GetWorldPosition(), explosionRadius, 2.f, 99 , '', FLAG_ExcludeTarget, this );
		
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			if ( !collidedEntities.Contains(entities[i]) && (!m_respectCaster || GetAttitudeBetween(entities[i], caster) == AIA_Hostile) )
				DealDamageToVictim(entities[i]);
		}
		
		GCameraShake( m_shakeStrength, explosionRadius * 2, GetWorldPosition() );
	}
	
	protected function ProjectileHitGround()
	{
		var entities 		: array<CGameplayEntity>;
		var i				: int;
		var landPos			: Vector;
		
		landPos = this.GetWorldPosition();
		
		FindGameplayEntitiesInSphere( entities, landPos, 2, 99, '', FLAG_ExcludeTarget, this );
		
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			entities[i].ApplyAppearance( "hole" );			
			if ( theGame.GetWorld().GetWaterLevel( landPos ) > landPos.Z )
			{
				entities[i].PlayEffect('explosion_water');			
			}
			else
			{
				entities[i].PlayEffect(onCollisionFxName);
			}
		}
		theGame.GetSurfacePostFX().AddSurfacePostFXGroup( landPos, /*in*/ 0.2f, /*active*/ 10.f, /*out*/ 2.f, 5.f, /*type*/ (int)(projEfect != EET_Frozen && projEfect != EET_SlowdownFrost) );
		//if (craterEntity) {
		//	craterEntity.ApplyAppearance("hole");
		//	craterEntity.DestroyAfter(30.f);
		//}

		super.ProjectileHitGround();
	}
	
	event OnProjectileShot( targetCurrentPosition : Vector, optional target : CNode )
	{
		var createMarkerHelper, createCraterHelper : CCreateEntityHelper;
	
		super.OnProjectileShot(targetCurrentPosition, target);
		
		createMarkerHelper = new CCreateEntityHelper in this;
		createMarkerHelper.SetPostAttachedCallback( this, 'OnMarkerCreated' );
		theGame.CreateEntityAsync( createMarkerHelper, markerEntityTemplate, targetCurrentPosition, EulerAngles(0,0,0) );
		
		//createCraterHelper = new CCreateEntityHelper in this;
		//createCraterHelper.SetPostAttachedCallback( this, 'OnCraterCreated' );
		//theGame.CreateEntityAsync( createCraterHelper, craterEntityTemplate, targetCurrentPosition, EulerAngles(0,0,0) );
	}

	event OnMarkerCreated( entity : CEntity )
	{
		markerEntity = entity;
		if ( markerEntity ) {
			markerEntity.PlayEffect(m_markerFxName);
			theGame.GetBehTreeReactionManager().CreateReactionEvent( this, 'MeteorMarker', destroyMarkerAfter, explosionRadius, 0.1f, 999, true );
		}
	}

	event OnCraterCreated( entity : CEntity )
	{
		craterEntity = entity;
	}
}

/*
class NR_MeteorProjectile_CreateMarkerEntityHelper extends CCreateEntityHelper
{	
	var owner : NR_MeteorProjectile;

	event OnMarkerCreated( entity : CEntity )
	{
		if ( owner )
		{
			owner.SetMarkerEntity( entity );
			theGame.GetBehTreeReactionManager().CreateReactionEvent( owner, 'MeteorMarker', owner.destroyMarkerAfter, owner.explosionRadius, 0.1f, 999, true );
		}
	}

	event OnCraterCreated( entity : CEntity )
	{
		if ( owner )
		{
			owner.SetCraterEntity( entity );
		}
	}
}
*/