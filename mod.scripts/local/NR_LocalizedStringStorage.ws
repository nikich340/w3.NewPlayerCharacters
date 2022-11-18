class NR_LocalizedStringStorage extends CEntity {
	editable var stringValues	: array<LocalizedString>;
	editable var stringKeys		: array<String>;
	editable var stringIds		: array<int>;

	public function GetLocalizedStringByKey(key : String) : LocalizedString {
		var i : int;
		var null : LocalizedString;

		if (key == "")
			return null;
		for (i = 0; i < stringKeys.Size(); i += 1) {
			if (stringKeys[i] == key) {
				return stringValues[i];
			}
		}
		NRD("NR_LocalizedStringStorage: Key NOT found: " + key);
		return null;
	}
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
		NRD("NR_LocalizedStringStorage: id NOT found: " + IntToString(id));
		return null;
	}
}
