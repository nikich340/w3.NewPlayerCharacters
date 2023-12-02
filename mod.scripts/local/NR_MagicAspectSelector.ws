/* Part of NR_MagicManager : selects aspect name according to set ratio */
/* Example: you want 3 'throw' attacks and 2 'slash' after:
	selector = new NR_MagicAttackSelector in this;
	selector.AddAttack('throw', 3);
	selector.AddAttack('slash', 2);
	// then as many times as you want
	selector.SelectAttack();
*/

class NR_MagicAspectSelector {
	private var attackNames 	: array<name>;
	private var attackCounts 	: array<int>;

	private var currentAttackCounts : array<int>;
	private var currentAttackIndex : int;

	public function AddAttack(aName : name, repeats : int) {
		attackNames.PushBack(aName);
		attackCounts.PushBack(repeats);
		RefillCurrent();
	}
	public function Reset() {
		attackNames.Clear();
		attackCounts.Clear();
		currentAttackCounts.Clear();
		currentAttackIndex = 0;
	}
	public function RefillCurrent() {
		currentAttackCounts = attackCounts;
		currentAttackIndex = 0;
	}
	public function SelectAttack() : name {
		if ( currentAttackCounts.Size() == 0 ) {
			NR_Error("NR_MagicAttackSelector.SelectAttack(): empty currentAttackCounts!");
			return '';
		}
		while (currentAttackCounts[currentAttackIndex] == 0) {
			/* Use next attack */
			currentAttackIndex += 1;
			if (currentAttackIndex >= currentAttackCounts.Size()) {
				/* Start again from first attack */
				RefillCurrent();
			}
		}
		/* Decrease left attacks count and return name */
		currentAttackCounts[currentAttackIndex] -= 1;
		if (currentAttackIndex >= attackNames.Size() || currentAttackIndex < 0)
			NR_Error("NR_MagicAspectSelector::SelectAttack -> invalid index");

		return attackNames[currentAttackIndex];
	}
}
