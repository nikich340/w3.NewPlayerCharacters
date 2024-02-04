class NR_TaskTeleportAction extends TaskTeleportAction
{
    protected latent function FindSuitablePoint( out newPosition : Vector, optional timeOut : float ) : bool
    {
        var currentPos          : Vector;
        var whereTo             : Vector;
        var randVec             : Vector;
        var teleportVec         : Vector;
        var attemps             : int;
        var teleportLength     : float;
        var npc                 : CNewNPC = GetNPC();
        var startTimeStamp      : float = GetLocalTime();
        
        if (timeOut > 1.f)
            timeOut = 1.f;

        currentPos = npc.GetWorldPosition();
        randVec = CalculateRandVec_Copy();
        whereTo = CalculateWhereToVec_Copy(randVec);
		teleportVec = whereTo - currentPos;
		teleportLength = VecLength2D(teleportVec);
        whereTo = NR_GetTeleportMaxArchievablePoint( npc, teleportVec, teleportLength );
        
        while ( !IsPointSuitableForTeleport(whereTo) )
        {
            if ( timeOut > 0 && ( startTimeStamp + timeOut < GetLocalTime() ) ) {
                NR_Error("IsPointSuitableForTeleport: Point not found, Time out! Attemps: " + attemps);
                return false;
            }
            
            SleepOneFrame();
            randVec = CalculateRandVec_Copy();
			whereTo = CalculateWhereToVec_Copy(randVec);
			teleportVec = whereTo - currentPos;
			teleportLength = VecLength2D(teleportVec);
			whereTo = NR_GetTeleportMaxArchievablePoint( npc, teleportVec, teleportLength );
            attemps += 1;
        }
        
        newPosition = whereTo;
        return true;
    }

    protected function IsPointSuitableForTeleport( out whereTo : Vector ) : bool
    {
        var npc             : CNewNPC = GetNPC();
        var target          : CNode;
        var newPos, normal  : Vector;
        var radius          : float;
        var waterDepth      : float;
        var z               : float;
        var waterZ, newZ    : float;
        var taggedEntities  : array<CGameplayEntity>;
        var i               : int;
        var world           : CWorld;

        //NR_Debug("NR_TaskTeleportAction::IsPointSuitableForTeleport(" + VecToString(whereTo) + ")");
        
        if ( overrideActorRadiusForNavigationTests )
            radius = MaxF( 0.01, actorRadiusForNavigationTests );
        else
            radius = npc.GetRadius();
        
        world = theGame.GetWorld();
		// checked by NR_GetSafeTeleportPoint
		/*
        if ( !world.NavigationFindSafeSpot( whereTo, radius, radius*3, newPos ) )
        {
            if ( world.NavigationComputeZ(whereTo, whereTo.Z - zTolerance, whereTo.Z + zTolerance, z) )
            {
                whereTo.Z = z;
                if ( !world.NavigationFindSafeSpot( whereTo, radius, radius*3, newPos ) )
                    return false;
            }
            else
            {
                // if no navigation data
                waterZ = world.GetWaterLevel( whereTo, true );
                
                // make sure that floor pos found + it's above water + it's in zTolerance range
                if ( world.PhysicsCorrectZ(whereTo, newZ) && newZ > waterZ && AbsF(newZ - whereTo.Z) < zTolerance ) {
                    //NR_Debug("NR_TaskTeleportAction::IsPointSuitableForTeleport(" + VecToString(whereTo) + ")::OK no navdata");
                    newPos = whereTo;
                    newPos.Z = newZ;
                } else {
                    return false;
                }
            }
        }
		*/
        
        if ( useCombatTarget )
        {
            target = GetCombatTarget();
        }
        else
        {
            target = GetActionTarget();
        }
        
        if ( testNavigationBetweenCombatTargetAndNewPosition && testLOSforNewPosition )
        {
            if ( !world.NavigationLineTest(newPos, target.GetWorldPosition(), radius ) && !world.NavigationLineTest( npc.GetWorldPosition(), newPos, radius ) )
                return false;
        }
        else
        {
            if ( testNavigationBetweenCombatTargetAndNewPosition && !world.NavigationLineTest(newPos, target.GetWorldPosition(), radius ) )
                return false;
                
            if ( testLOSforNewPosition && !world.NavigationLineTest(npc.GetWorldPosition(), newPos, radius ) ) {
                if ( !world.SweepTest(npc.GetWorldPosition(), newPos, radius, newPos, normal, NR_GetStandartCollisionNames()) ) {
                    return false;
                }
            }
        }
        
        if ( checkWaterLevel || minWaterDepthToAppear > 0 )
        {
            waterDepth = world.GetWaterDepth( newPos );
            
            if ( waterDepth == 10000 ) { waterDepth = 0; }
            if ( waterDepth > maxWaterDepthToAppear )
            {
                return false;
            }
            if ( minWaterDepthToAppear > 0 && waterDepth < minWaterDepthToAppear )
            {
                return false;
            }
        }

        if ( dontTeleportOutsideGuardArea && guardArea )
        {
            if ( !guardArea.TestPointOverlap( newPos ) )
            {
                return false;
            }
        }
        
        if ( IsNameValid( minDistanceFromEnititesWithTag ) )
        {
            FindGameplayEntitiesInRange( taggedEntities, npc, 10.0, 5, minDistanceFromEnititesWithTag );
            
            for ( i = 0; i < taggedEntities.Size(); i += 1 )
            {
                if ( VecDistance2D( newPos, taggedEntities[i].GetWorldPosition() ) < minDistanceFromTaggedEntities && taggedEntities[i] != npc )
                {
                    return false;
                }
            }
        }

        if ( world.PhysicsCorrectZ(newPos, newZ) ) {
            newPos.Z = newZ;
        }       
        
        if ( minDistanceFromLastPosition > 0 )
        {
            if ( VecDistance( lastPos, newPos ) > minDistanceFromLastPosition )
            {
                whereTo = newPos;
            }
        }
        else
        {
            whereTo = newPos;
            lastPos = newPos;
        }
        
        return true;
    }

    // "thanks" to that CDPR man who made these functions private..
    protected function CalculateRandVec_Copy() : Vector
    {
        var randVec                         : Vector = Vector(0.f,0.f,0.f);
        var npc                             : CNewNPC = GetNPC();
        var target                          : CActor = GetCombatTarget();
        var cameraToPlayerDistance          : float;
        var averageDistance                 : float;
        var heading                         : float;
        
        
        if ( teleportToActorHeading )
        {
            averageDistance = NR_GetRandomGenerator().nextRangeF( minDistance, maxDistance );
            requestedFacingDirectionNoiseAngle *= -1;
            heading = npc.GetHeading() + 180 + requestedFacingDirectionNoiseAngle;
            randVec = VecFromHeading( heading ) * averageDistance;
        }
        
        else if ( teleportAwayFromActorHeading )
        {
            averageDistance = NR_GetRandomGenerator().nextRangeF( minDistance, maxDistance );
            requestedFacingDirectionNoiseAngle *= -1;
            heading = npc.GetHeading() + requestedFacingDirectionNoiseAngle;
            randVec = VecFromHeading( heading ) * averageDistance;
        }
        else if ( teleportInFrontOfTarget )
        {
            randVec = VecConeRand( VecHeading( target.GetHeadingVector() ), 5, minDistance, maxDistance );
        }
        else if ( teleportInFrontOfOwner )
        {
            randVec = VecConeRand( VecHeading( npc.GetHeadingVector() ) + 180, 5 + requestedFacingDirectionNoiseAngle, minDistance, maxDistance );
        }
        else if ( teleportType == TT_ToSelf )
        {
            randVec = VecRingRand( minDistance,maxDistance );
        }
        else if ( teleportBehindTarget )
        {
            randVec = VecConeRand( VecHeading(target.GetHeadingVector())+180, 5, minDistance, maxDistance );
        }
        else if ( teleportOutsidePlayerFOV )
        {
            cameraToPlayerDistance = VecDistance( theCamera.GetCameraPosition(), thePlayer.GetWorldPosition() );
            if ( cameraToPlayerDistance*1.2 > minDistance )
            {
                minDistance = cameraToPlayerDistance*1.2;
                maxDistance = ( maxDistance + ( cameraToPlayerDistance - minDistance ))*1.2;
            }
            else
            {
                randVec = VecConeRand( theCamera.GetCameraHeading(), 45, minDistance, maxDistance );
            }
        }
        else if ( teleportWithinPlayerFOV )
        {
            randVec = VecConeRand( theCamera.GetCameraHeading(), 20, minDistance, maxDistance );
        }       
        else if ( teleportType == TT_FromLastPosition )
        {
            angle = NodeToNodeAngleDistance( npc.GetTarget(), npc );
            
            if ( alreadyTeleported )
            {
                distFromLastTelePos = VecDistance( lastTelePos, npc.GetWorldPosition() );
                minDistance = distFromLastTelePos - 2;
                maxDistance = distFromLastTelePos + 2;
                randVec = VecConeRand( angle, 30, minDistance, maxDistance );
            }
            else
            {
                randVec = VecRingRand(minDistance,maxDistance);
            }
        }
        else if ( maxDistance != 0 )
        {
            randVec = VecRingRand(minDistance,maxDistance);
        }
        return randVec;
    }

    // "thanks" again
    protected function CalculateWhereToVec_Copy( randVec : Vector ) : Vector
    {
        var whereTo         : Vector;
        var positionOffset  : Vector;
        var l_matrix        : Matrix;
        var npc             : CNewNPC = GetNPC();
        var target          : CNode; 
        
        if ( useCombatTarget )
            target = GetCombatTarget();
        else
            target = GetActionTarget();
        
        if ( teleportType == TT_ToPlayer )
        {
            if ( teleportToActorHeading || teleportAwayFromActorHeading )
            {
                whereTo = thePlayer.GetWorldPosition() + randVec;
            }
            else
            {
                whereTo = thePlayer.GetWorldPosition() - randVec;
            }
        }
        else if ( teleportType == TT_ToSelf || ( teleportType != TT_ToSelf && !target ) )
        {
            whereTo = npc.GetWorldPosition() - randVec;
        }
        else if ( teleportBehindTarget || teleportInFrontOfTarget )
        {
            whereTo = target.GetWorldPosition() + randVec;
        }
        else if ( teleportOutsidePlayerFOV )
        {
            whereTo = theCamera.GetCameraPosition() - randVec;
        }
        else if ( teleportWithinPlayerFOV )
        {
            whereTo = theCamera.GetCameraPosition() + randVec;
        }
        else if ( teleportType == TT_ToTarget || teleportType == TT_FromLastPosition )
        {
            if ( teleportToActorHeading || teleportAwayFromActorHeading )
            {
                whereTo = target.GetWorldPosition() + randVec;
            }
            else
            {
                whereTo = target.GetWorldPosition() - randVec;
            }
        }
        else if ( teleportType == TT_OnRightPlayerSide )
        {
            
            
            positionOffset.X = NR_GetRandomGenerator().nextRangeF( minDistance, maxDistance );
            
            whereTo = thePlayer.GetWorldPosition() + theCamera.GetCameraRight() * positionOffset.X;
        }
        else if ( teleportType == TT_OnLeftPlayerSide )
        {
            
            
            positionOffset.X = NR_GetRandomGenerator().nextRangeF( minDistance, maxDistance) *-1;
            
            whereTo = thePlayer.GetWorldPosition() + theCamera.GetCameraRight() * positionOffset.X;
        }
        else
        {
            whereTo = npc.GetWorldPosition() - randVec;
        }
        return whereTo;
    }
}
