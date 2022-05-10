/* Map structure based on array struct (we have no other choice), so O(N) and no templating 
	Stores primitive type (Int, Float, String or Name) under key-String */


enum ENR_UnionType {
	ENR_NULL,
	ENR_Name,
	ENR_String,
	ENR_Int,
	ENR_Float
	//ENR_Vector ?
}
struct NR_Union {
	var type : ENR_UnionType;
	var key  : String;
	var valN : name;
	var valS : String;
	var valI : int;
	var valF : float;
}
function NR_Union(_key : String, _type : ENR_UnionType, optional _valN : name, optional _valS : String, optional _valI : int, optional _valF : float) : NR_Union {
	var u : NR_Union;
	u.key = _key;
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
		default:
			break;
	}
	return u;
}
class NR_Map {
	saved var values 	: array<NR_Union>;
	var i 				: int;
	function keyIndex(_key : String) : int {
		for (i = 0; i < values.Size(); i += 1) {
			if (values[i].key == _key)
				return i;
		}
		return -1;
	}
	function keyType(_key : String) : ENR_UnionType {
		i = keyIndex(_key);
		if (i < 0)
			return ENR_NULL;

		return values[i].type;
	}
	function keyRemove(_key : String) : bool {
		i = keyIndex(_key);
		if (i < 0)
			return false;

		values.Erase(i);
		return true;
	}
	function getI(_key : String, optional defaultValue : int) : int {
		i = keyIndex(_key);
		//NRD("getN: key = " + _key + ", defaultValue = " + defaultValue);
		if (i < 0)
			return defaultValue;
		return values[i].valI;
	}
	function getF(_key : String, optional defaultValue : float) : float {
		i = keyIndex(_key);
		if (i < 0)
			return defaultValue;
		return values[i].valF;
	}
	function getN(_key : String, optional defaultValue : name) : name {
		var start, end : float;
		start = EngineTimeToFloat(theGame.GetEngineTime());

		i = keyIndex(_key);

		end = EngineTimeToFloat(theGame.GetEngineTime());
		//NRD("getN: key = " + _key + ", defaultValue = " + defaultValue + ", time = " + (end - start));
		if (i < 0)
			return defaultValue;
		return values[i].valN;
	}
	function getS(_key : String, optional defaultValue : String) : String {
		i = keyIndex(_key);
		if (i < 0)
			return defaultValue;
		return values[i].valS;
	}

	function setF(_key : String, _valF : float) : bool {
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
	function setI(_key : String, _valI : int) : bool {
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
	function setN(_key : String, _valN : name) : bool {
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
	function setS(_key : String, _valS : String) : bool {
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
}
