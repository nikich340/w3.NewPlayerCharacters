class NR_LocalizedStringStorage extends CEntity {
	editable var stringValues	: array<LocalizedString>;
	editable var stringIds		: array<int>;

	public function GetLocalizedStringById(id : int) : LocalizedString {
		var i : int;
		var null : LocalizedString;

		if (id <= 0)
			return null;
		for (i = 0; i < stringIds.Size(); i += 1) {
			if (stringIds[i] == id) {
				return stringValues[i];
			}
		}
		NR_Debug("NR_LocalizedStringStorage: id NOT found: " + IntToString(id));
		return null;
	}
}
