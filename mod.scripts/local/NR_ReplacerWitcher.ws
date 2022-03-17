statemachine class NR_ReplacerWitcher extends W3PlayerWitcher {
	public  var replacerName         : String;
	public  var inventoryTemplate    : String;
	private var deniedInventorySlots : array<name>;
	
	default replacerName      = "nr_replacer_witcher";
	default inventoryTemplate = "nr_replacer_witcher_inv";

	public function SetTeleportedOnBoatToOtherHUB( val : bool )
	{
		NR_Debug("SetTeleportedOnBoatToOtherHUB: " + val);
		super.SetTeleportedOnBoatToOtherHUB( val );
	}


	public function NR_IsSlotDenied(slot : EEquipmentSlots) : bool
	{
		return deniedInventorySlots.Contains( SlotEnumToName(slot) );
	}

	function printInv() {
		var inv : CInventoryComponent;
		var ids : array<SItemUniqueId>;
		var i, j : int;
		var result : String;
		var equippedOnSlot : EEquipmentSlots;
		var tags : array<name>;

		inv = GetInventory();
		inv.GetAllItems(ids);

		for (i = 0; i < ids.Size(); i += 1) {
			result = "item[" + i + "] ";

			equippedOnSlot = GetItemSlot( ids[i] );

			if(equippedOnSlot != EES_InvalidSlot)
			{
				result += "(slot " + equippedOnSlot + ") ";
			}
			if ( inv.IsItemHeld(ids[i]) )
			{
				result += "(held) ";
			}
			if ( inv.IsItemMounted(ids[i]) )
			{
				result += "(mounted) ";
			}
			if ( inv.GetItemTags(ids[i], tags) )
			{
				result += "{";
				for (j = 0; j < tags.Size(); j += 1) {
					result += tags[j] + ",";
				}
				result += "} ";
				tags.Clear();
			}
			result += inv.GetItemName(ids[i]);
			NR_Notify(result);
		}
	}
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		//var nrPlayerManager : NR_PlayerManager;
		//printInv();		

		NR_Debug(replacerName + " onSpawned!");
		super.OnSpawned( spawnData );

		//nrPlayerManager = NR_GetPlayerManager();
		//nrPlayerManager.AddTimer('NR_FixReplacer', 0.2f, false);
	}

	/*event OnDestroyed()
	{
		NR_Notify("OnDestroyed!");
		super.OnDestroyed();
	}*/
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
	event OnBlockingSceneEnded( optional output : CStorySceneOutput)
	{
		NR_GetPlayerManager().SetInStoryScene( false );
		super.OnBlockingSceneEnded( output );
	}
	public function UnequipItemFromSlot(slot : EEquipmentSlots, optional reequipped : bool) : bool
	{
		var item : SItemUniqueId;
		var nrPlayerManager : NR_PlayerManager;

		nrPlayerManager = NR_GetPlayerManager();

		/* IsInNonGameplayCutscene() - don't unequip armor for scenes (bath, barber etc) */
		if ( !GetItemEquippedOnSlot(slot, item) )
			return false;

		if ( IsInNonGameplayCutscene() ) {
			nrPlayerManager.SetInStoryScene( true );
			nrPlayerManager.AddTimer('NR_FixReplacer', 0.2f, false);
			NR_Debug("SCENE unequip - call fix");
			return false;
		}

		if ( super.UnequipItemFromSlot(slot, reequipped) ) {
			nrPlayerManager.RemoveSavedItem( item );
			return true;
		} else {
			return false;
		}
	}
	public function EquipItemInGivenSlot(item : SItemUniqueId, slot : EEquipmentSlots, ignoreMounting : bool, optional toHand : bool) : bool
	{
		var ret : Bool;
		NR_Debug("EquipItemInGivenSlot: slot = " + slot + " ignoreMounting = " + ignoreMounting);
		if (slot == EES_Armor || slot == EES_Boots || slot == EES_Gloves || slot == EES_Pants) {
			ignoreMounting = true;
		}
		ret = super.EquipItemInGivenSlot(item, slot, ignoreMounting, toHand);
		NR_GetPlayerManager().UpdateSavedItem(item);

		return ret;
	}
	/*public function EquipItem(item : SItemUniqueId, optional slot : EEquipmentSlots, optional toHand : bool) : bool
	{
		NR_Notify("EquipItem: slot = " + slot);;
		return super.EquipItem(item, slot, toHand);
	}*/

	/*private function NR_stringById(itemId : SItemUniqueId) : String {
		if ( inv.IsIdValid(itemId) )
			return NameToString( inv.GetItemName(itemId) );
		else
			return "<invalid>";
	}
	public function NR_DebugSlots() {
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
		GetItemEquippedOnSlot( EES_Armor, item );
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