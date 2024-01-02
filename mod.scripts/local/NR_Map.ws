/* Map structure based on array struct (we have no other choice), so O(N) and no templating 
	Stores primitive type (Int, Float, String or Name) under key-String */
/*
 Example usage:
	var map : NR_Map;
	map = new NR_Map in thePlayer;
	map.setI("some integer", 10);
	map.setS("some string", "my_str");
	map.setN("some name", 'my_name');
	map.setF("some float", 0.5f);
	LogChannel('DEBUG', "map[some name] = " + map.getN("some name"));
	LogChannel('DEBUG', "map[non existing name] = " + map.getN("non existing name", 'default_value'));
*/

enum ENR_UnionType {
	ENR_NULL,
	ENR_Name,
	ENR_String,
	ENR_Int,
	ENR_Float,
	ENR_Object
}

struct NR_Union {
	var type : ENR_UnionType;
	var key  : String;
	var hash : Uint64;
	var valN : name;
	var valS : String;
	var valI : int;
	var valF : float;
	var valO : IScriptable;
}

function NR_Union(_key : String, _type : ENR_UnionType, optional _valN : name, optional _valS : String, optional _valI : int, optional _valF : float, optional _valO : IScriptable) : NR_Union {
	var u : NR_Union;

	u.key = _key;
	u.hash = NR_PolyRollHash(_key);
	u.type = _type;
	switch (_type) {
		case ENR_Int:
			u.valI = _valI;
			break;
		case ENR_Float:
			u.valF = _valF;
			break;
		case ENR_Name:
			u.valN = _valN;
			break;
		case ENR_String:
			u.valS = _valS;
			break;
		case ENR_Object:
			u.valO = _valO;
			break;
		default:
			break;
	}
	return u;
}

class NR_Map {
	protected var values 	: array<NR_Union>;
	protected var i 		: int;

	/* API */ public function getKeys() : array<String> {
		var keys : array<String>;

		for (i = 0; i < values.Size(); i += 1) {
			keys.PushBack(values[i].key);
		}

		return keys;
	}

	protected function keyIndex(_key : String) : int {
		var _hash : Uint64;

		_hash = NR_PolyRollHash(_key);
		for (i = 0; i < values.Size(); i += 1) {
			if (values[i].hash == _hash && values[i].key == _key)
				return i;
		}
		return -1;
	}

	/* API */ public function valueType(_key : String) : ENR_UnionType {
		i = keyIndex(_key);
		if (i < 0)
			return ENR_NULL;

		return values[i].type;
	}

	/* API */ public function removeKey(_key : String) : bool {
		i = keyIndex(_key);
		if (i < 0)
			return false;

		values.Erase(i);
		return true;
	}

	/* API */ public function hasKey(_key : String) : bool {
		i = keyIndex(_key);
		return (i >= 0);
	}

	/* API */ public function getI(_key : String, optional defaultValue : int) : int {
		i = keyIndex(_key);
		if (i < 0)
			return defaultValue;
		return values[i].valI;
	}

	/* API */ public function getF(_key : String, optional defaultValue : float) : float {
		i = keyIndex(_key);
		if (i < 0)
			return defaultValue;
		return values[i].valF;
	}

	/* API */ public function getN(_key : String, optional defaultValue : name) : name {
		i = keyIndex(_key);
		if (i < 0)
			return defaultValue;
		return values[i].valN;
	}

	/* API */ public function getS(_key : String, optional defaultValue : String) : String {
		i = keyIndex(_key);
		if (i < 0)
			return defaultValue;
		return values[i].valS;
	}

	/* API */ public function getO(_key : String, optional defaultValue : IScriptable) : IScriptable {
		i = keyIndex(_key);
		if (i < 0)
			return defaultValue;
		return values[i].valO;
	}

	/* API */ public function setF(_key : String, _valF : float) : bool {
		i = keyIndex(_key);
		if (i < 0) {
			values.PushBack(NR_Union(_key, ENR_Float, , , , _valF));
			return true;
		}
		if (values[i].type == ENR_Float) {
			values[i].valF = _valF;
			return true;
		} else {
			return false;
		}		
	}

	/* API */ public function setI(_key : String, _valI : int) : bool {
		i = keyIndex(_key);
		if (i < 0) {
			values.PushBack(NR_Union(_key, ENR_Int, , , _valI));
			return true;
		}
		if (values[i].type == ENR_Int) {
			values[i].valI = _valI;
			return true;
		} else {
			return false;
		}		
	}

	/* API */ public function setN(_key : String, _valN : name) : bool {
		i = keyIndex(_key);
		if (i < 0) {
			values.PushBack(NR_Union(_key, ENR_Name, _valN));
			return true;
		}
		if (values[i].type == ENR_Name) {
			values[i].valN = _valN;
			return true;
		} else {
			return false;
		}		
	}

	/* API */ public function setS(_key : String, _valS : String) : bool {
		i = keyIndex(_key);
		if (i < 0) {
			values.PushBack(NR_Union(_key, ENR_String, , _valS));
			return true;
		}
		if (values[i].type == ENR_String) {
			values[i].valS = _valS;
			return true;
		} else {
			return false;
		}		
	}

	/* API */ public function setO(_key : String, _valO : IScriptable) : bool {
		i = keyIndex(_key);
		if (i < 0) {
			values.PushBack(NR_Union(_key, ENR_Object, , , , , _valO));
			return true;
		}
		if (values[i].type == ENR_Object) {
			values[i].valO = _valO;
			return true;
		} else {
			return false;
		}		
	}
}
