statemachine class NR_ReplacerWitcher extends W3PlayerWitcher {
	import var displayName : LocalizedString;
	protected var m_replacerType         : ENR_PlayerType;
	public var inventoryTemplate   		 : String;
	
	default m_replacerType      = ENR_PlayerWitcher;
	default inventoryTemplate 	= "nr_replacer_witcher_inv";

	public function GetNameID() : int {
		return 452675;   // 0000452675|70994a4f|-1.000|Witcher
	}

	public function GetReplacerType() : ENR_PlayerType {
		return m_replacerType;
	}

	public function NR_IsSlotDenied(slot : EEquipmentSlots) : bool
	{
		return false;
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		NR_Debug("OnSpawned: " + m_replacerType);
		super.OnSpawned( spawnData );
	}

	// TODO: check why it here!
	/*protected function ShouldMount(slot : EEquipmentSlots, item : SItemUniqueId, category : name):bool
	{
		NR_Notify("ShouldMount? slot: " + slot + ", item: " + GetInventory().GetItemName(item));
		return super.ShouldMount(slot, item, category);
	}*/
	/*protected function ShouldMount(slot : EEquipmentSlots, item : SItemUniqueId, category : name):bool
	{
		var NR_mountAllowed : bool = true;
		// prevent mounting clothes which overlaps with replacer template parts
		if (slot == EES_Armor || slot == EES_Boots || slot == EES_Gloves || slot == EES_Pants) {
			NR_mountAllowed = false;
		}

		return NR_mountAllowed && super.ShouldMount(slot, item, category);
	}*/
	
	public function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
	{
		var item : SItemUniqueId;
		var nrPlayerManager : NR_PlayerManager = NR_GetPlayerManager();

		if ( !GetItemEquippedOnSlot(slot, item) )
			return false;
		
		NR_Debug("UnequipItemFromSlot: slot = " + slot + ", reequipped = " + reequipped);
		/* IsInNonGameplayCutscene() - don't unequip armor for scenes (bath, barber etc) */
		if ( IsInNonGameplayCutscene() ) {
			NR_Debug("UnequipItemFromSlot: slot = " + slot + ", ignoring (in scene).");
			return false;
		}

		if ( super.UnequipItemFromSlot(slot, reequipped) ) {
			nrPlayerManager.RemoveSavedItem( item );
			return true;
		} else {
			return false;
		}
	}

	// EquipItem -> here
	public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{
		var ret : Bool;

		NR_Debug("EquipItemInGivenSlot: [" + NR_stringByItemUID(inv, item) + "] slot = " + slot + " ignoreMounting = " + ignoreMounting + ", toHand = " + toHand);
		if (slot == EES_Armor || slot == EES_Boots || slot == EES_Gloves || slot == EES_Pants) {
			ignoreMounting = true;
		}
		if (NR_IsSlotDenied(slot)) {
			NR_Debug("EquipItemInGivenSlot: slot is denied.");
			return false;
		}
		ret = super.EquipItemInGivenSlot(item, slot, ignoreMounting, toHand);
		NR_GetPlayerManager().UpdateSavedItem(item);

		return ret;
	}
	
	/* WRAPPER: TODO: Check why it here? */
	public function SetupCombatAction( action : EBufferActionType, stage : EButtonStage )
	{
		NR_Debug("NR_ReplacerWitcher: SetupCombatAction: " + action + ", stage: " + stage);
		if ( !IsInState('NR_Transformed') ) {
			super.SetupCombatAction(action, stage);
		}
	}

	// I like this function, so I can't remove it :(
	/*public function NR_DebugSlots() {
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
