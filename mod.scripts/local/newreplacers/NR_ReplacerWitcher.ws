statemachine class NR_ReplacerWitcher extends W3PlayerWitcher {
	import var displayName : LocalizedString;
	protected var m_replacerType         : ENR_PlayerType;
	default m_replacerType      = ENR_PlayerWitcher;

	public function GetNameID() : int {
		return 452675;   // 0000452675|70994a4f|-1.000|Witcher
	}

	public function GetReplacerType() : ENR_PlayerType {
		return m_replacerType;
	}

	public function NR_GetInventoryTemplate() : String {
		if (NR_GetPlayerManager().IsRealEquipmentModeEnabled())
			return "nr_replacer_witcher_armormode_inv";
		else
			return "nr_replacer_witcher_inv";
	}

	public function NR_IsSlotDenied(slot : EEquipmentSlots) : bool
	{
		return false;
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		NR_Info("OnSpawned: " + m_replacerType);
		super.OnSpawned( spawnData );
	}
	
	public function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
	{
		var item : SItemUniqueId;

		if ( !GetItemEquippedOnSlot(slot, item) )
			return false;
		
		// NR_Debug("UnequipItemFromSlot: slot = " + slot + ", reequipped = " + reequipped);
		/* IsInNonGameplayCutscene() - don't unequip armor for scenes (bath, barber etc) */
		if ( IsInNonGameplayCutscene() ) {
			NR_GetPlayerManager().UnmountEquipment();
			// NR_Debug("UnequipItemFromSlot: slot = " + slot + ", ignoring (in scene).");
			return false;
		}

		if ( super.UnequipItemFromSlot(slot, reequipped) ) {
			NR_GetPlayerManager().RemoveSavedItem( item );
			return true;
		} else {
			return false;
		}
	}

	// EquipItem -> here
	public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{
		var ret : Bool;

		// NR_Debug("EquipItemInGivenSlot: [" + NR_stringByItemUID(inv, item) + "] slot = " + slot + " ignoreMounting = " + ignoreMounting + ", toHand = " + toHand);
		/*
		if (slot == EES_Armor || slot == EES_Boots || slot == EES_Gloves || slot == EES_Pants) {
			// NO! it breaks stats - use hiding components way
			// ignoreMounting = true;
		}
		*/
		if (NR_IsSlotDenied(slot)) {
			NR_Info("EquipItemInGivenSlot: slot " + slot + " is denied.");
			return false;
		}
		ret = super.EquipItemInGivenSlot(item, slot, ignoreMounting, toHand);
		NR_GetPlayerManager().UpdateSavedItem(item);

		if ( IsInNonGameplayCutscene() ) {
			NR_GetPlayerManager().UnmountEquipment();
		}

		return ret;
	}

	// I like this function, so I can't remove it :(
	/*public function // NR_DebugSlots() {
		var item : SItemUniqueId;
		var headManager : CHeadManagerComponent;
		var headName : name;
		var message : String;
	
		headManager = (CHeadManagerComponent)GetComponentByClassName( 'CHeadManagerComponent' );
		message += "<font>HEAD: " + headManager.GetCurHeadName() + "<br />";

		GetItemEquippedOnSlot( EES_SilverSword, item );
		message += "EES_SilverSword: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_SteelSword, item );
		message += "EES_SteelSword: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Armor, item );s
		message += "EES_Armor: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Boots, item );
		message += "EES_Boots " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Gloves, item );
		message += "EES_Gloves: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Pants, item );
		message += "EES_Pants: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Hair, item );
		message += "EES_Hair: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_Mask, item );
		message += "EES_Mask: " + NR_stringById(item) + "<br />";
		GetItemEquippedOnSlot( EES_RangedWeapon, item );
		message += "EES_RangedWeapon: " + NR_stringById(item) + "<br /></font>";
		
		NR_Notify(message, 60.0f);		
	}*/
}

function NR_GetWitcherReplacer() : NR_ReplacerWitcher
{
	return (NR_ReplacerWitcher)thePlayer;
}
