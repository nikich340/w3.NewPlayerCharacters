/* String hashing algos and Uint64 helper methods */

/* API */ function NR_CharCode(char : String) : int {
	switch (char) {
	    case "_":
	        return 1;
	    case " ":
	        return 2;
	    case "a":
	        return 3;
	    case "b":
	        return 4;
	    case "c":
	        return 5;
	    case "d":
	        return 6;
	    case "e":
	        return 7;
	    case "f":
	        return 8;
	    case "g":
	        return 9;
	    case "h":
	        return 10;
	    case "i":
	        return 11;
	    case "j":
	        return 12;
	    case "k":
	        return 13;
	    case "l":
	        return 14;
	    case "m":
	        return 15;
	    case "n":
	        return 16;
	    case "o":
	        return 17;
	    case "p":
	        return 18;
	    case "q":
	        return 19;
	    case "r":
	        return 20;
	    case "s":
	        return 21;
	    case "t":
	        return 22;
	    case "u":
	        return 23;
	    case "v":
	        return 24;
	    case "w":
	        return 25;
	    case "x":
	        return 26;
	    case "y":
	        return 27;
	    case "z":
	        return 28;
	    case "A":
	        return 29;
	    case "B":
	        return 30;
	    case "C":
	        return 31;
	    case "D":
	        return 32;
	    case "E":
	        return 33;
	    case "F":
	        return 34;
	    case "G":
	        return 35;
	    case "H":
	        return 36;
	    case "I":
	        return 37;
	    case "J":
	        return 38;
	    case "K":
	        return 39;
	    case "L":
	        return 40;
	    case "M":
	        return 41;
	    case "N":
	        return 42;
	    case "O":
	        return 43;
	    case "P":
	        return 44;
	    case "Q":
	        return 45;
	    case "R":
	        return 46;
	    case "S":
	        return 47;
	    case "T":
	        return 48;
	    case "U":
	        return 49;
	    case "V":
	        return 50;
	    case "W":
	        return 51;
	    case "X":
	        return 52;
	    case "Y":
	        return 53;
	    case "Z":
	        return 54;
	    case "0":
	        return 55;
	    case "1":
	        return 56;
	    case "2":
	        return 57;
	    case "3":
	        return 58;
	    case "4":
	        return 59;
	    case "5":
	        return 60;
	    case "6":
	        return 61;
	    case "7":
	        return 62;
	    case "8":
	        return 63;
	    case "9":
	        return 64;
	    case ":":
	        return 65;
	    case "\\":
	    case "/":
	        return 66;
	    case ".":
	        return 67;
	    // should never happen
	    default:
	    	NR_Error("NR_CharCode: unsupported: " + char);
	    	return 68;
	}
}

// returns x % y
/* API */ function NR_ModuloUint64(x : Uint64, y : Uint64) : Uint64 {
	var p : Uint64;
	
	if (x < y)
		return x;

	p = x / y;
	return x - p * y;
}

// returns string representation of uint64
// Use vanilla Uint64ToString!
/*
function NR_Uint64ToString(value : Uint64) : String {
	var str : String;
	var zero, ten : Uint64;
	var d : int;

	zero = IntToUint64(0);
	ten = IntToUint64(10);

	if (value == zero)
		return "0";
	while (value > IntToUint64(0)) {
		d = Uint64ToInt(NR_ModuloUint64(value, ten));
		str = IntToString(d) + str;
		value /= ten;
	}
	return str;
}
*/

// uses simple polynomial rolling algo to get uint64 hash
/* API */ function NR_PolyRollHash(text : String) : Uint64 {
	var P, PPow, MOD, hash : Uint64;
	var i, code : int;

	hash = IntToUint64(0);
	P = IntToUint64(1);
	PPow = IntToUint64(67);
	// 2^57 - 13 == 2^29 * 2^28 - 13
	MOD = IntToUint64(536870912) * IntToUint64(268435456) - IntToUint64(13);

	for (i = 0; i < StrLen(text); i += 1) {
		code = NR_CharCode(StrMid(text, i, 1));
		hash = NR_ModuloUint64(hash + IntToUint64(code) * P, MOD);
		P = NR_ModuloUint64(P * PPow, MOD);
	}

	return hash;
}

// uses simple polynomial rolling algo to get uint64 hash (another module)
/* API */ function NR_PolyRollHash2(text : String) : Uint64 {
	var P, PPow, MOD, hash : Uint64;
	var i, code : int;

	hash = IntToUint64(0);
	P = IntToUint64(1);
	PPow = IntToUint64(67);
	// 2^57 - 25 == 2^29 * 2^28 - 25
	MOD = IntToUint64(536870912) * IntToUint64(268435456) - IntToUint64(25);

	for (i = 0; i < StrLen(text); i += 1) {
		code = NR_CharCode(StrMid(text, i, 1));
		hash = NR_ModuloUint64(hash + IntToUint64(code) * P, MOD);
		P = NR_ModuloUint64(P * PPow, MOD);
	}

	return hash;
}

// example: prints hashes of given string
exec function nr_printhash(text : String) {
	var hash1, hash2 : Uint64;
	hash1 = NR_PolyRollHash(text);
	hash2 = NR_PolyRollHash2(text);
	NR_Notify("hash1 = (" + Uint64ToString(hash1) + "), hash2 = (" + Uint64ToString(hash2) + ")");
}
