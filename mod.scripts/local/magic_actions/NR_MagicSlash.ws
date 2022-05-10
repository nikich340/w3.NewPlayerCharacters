class NR_MagicSlash extends NR_MagicAction {
	var swingType, swingDir	: int; 
	default actionType = ENR_Slash;

	latent function SetSwingData(newSwingType : int, newSwingDir : int) {
		swingType = newSwingType;
		swingDir = newSwingDir;
	}
	latent function onPrepare() : bool {
		super.onPrepare();

		resourceName = map[sign].getN("slash_entity");
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		NR_CalculateTarget(	/*tryFindDestroyable*/ true, /*makeStaticTrace*/ true, 
							/*targetOffsetZ*/ 1.f, /*staticOffsetZ*/ 1.f );
		dummyEntity = theGame.CreateEntity( entityTemplate, pos, rot );
		onPrepare_GetSlashEffectNames();

		if (dummyEntity && effectName != '') {
			dummyEntity.PlayEffect(effectName);
			dummyEntity.DestroyAfter(5.f);
		} else {
			NRE("DummyEntity or effectName is invalid.");
			return onPrepared(false);
		}

		return onPrepared(true);
	}
	latent function onPerform() : bool {
		var targetNPC : CNewNPC;

		var super_ret : bool;
		super_ret = super.onPerform();
		if (!super_ret) {
			return onPerformed(false);
		}
		if (target) {
			targetNPC = (CNewNPC) target;
			if ( effectHitName != '' && (!targetNPC || !targetNPC.HasAlternateQuen()) ) {
				dummyEntity.PlayEffect(effectHitName);
			}
			thePlayer.OnCollisionFromItem( target );
		} else if (destroyable) {
			if (destroyable.reactsToIgni) {
				destroyable.OnIgniHit(NULL);
			} else {
				destroyable.OnAardHit(NULL);
			}
		}

		return onPerformed(true);
	}
	latent function BreakAction() {
		super.BreakAction();
		if (dummyEntity) {
			dummyEntity.Destroy();
		}
	}
	latent function onPrepare_GetSlashEffectNames() 
	{
		var A, B : name;
		switch ( swingType ) {
			case AST_Horizontal: {
				switch ( swingDir ) {
					case ASD_LeftRight: A = 'left';	B = 'blood_left';	break;
					case ASD_RightLeft: A = 'right'; B = 'blood_right'; 	break;
					default: break;
				}
				break;
			}
			case AST_Vertical: {
				switch ( swingDir ) {
					case ASD_UpDown: A = 'down';	B = 'blood_down';	break;
					case ASD_DownUp: A = 'up';		B = 'blood_up';		break;
					default: break;
				}
				break;
			}
			case AST_DiagonalUp: {
				switch ( swingDir ) {
					case ASD_LeftRight:	A = 'diagonal_up_left';		B = 'blood_diagonal_up_left'; 	break;
					case ASD_RightLeft:	A = 'diagonal_up_right';	B = 'blood_diagonal_up_right'; 	break;
					default: break;
				}
				break;
			}
			case AST_DiagonalDown: {
				switch ( swingDir ) {
					case ASD_LeftRight:	A = 'diagonal_down_left';	B = 'blood_diagonal_down_left';		break;
					case ASD_RightLeft:	A = 'diagonal_down_right';	B = 'blood_diagonal_down_right';	break;
					default: break;
				}
				break;
			}
			default: 	A = ''; 	break;
		}
		
		if( sign == ST_Yrden ) // philippa - TODO!!!
			A = 'cast_line';

		effectName 	  = A;
		effectHitName = B;
	}
}
