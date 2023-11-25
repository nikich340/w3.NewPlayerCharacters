/*
 * Copyright (c) 2005-2023
 *
 * Mike Mirzayanov
 * https://github.com/MikeMirzayanov/testlib/blob/master/testlib.h
 *
 * Adapted for ws by nikich340
 *
 */

class NR_RandomGenerator extends CEntity {
	protected var seed : Uint64;
	const var __power_two : array<Uint64>;
	const var __int_max : int;
	const var __longlong_max : Uint64;
	const var defaultseed : Uint64;
	const var multiplier : Uint64;
    const var addend : Uint64;
    const var mask : Uint64;
    const var lim : int;

    // defined in w2ent
    //default __power_two = {1, 2, 4, 8, .., 2^63};
    //default __int_max = 2147483647;
    //default __longlong_max = 9223372036854775807;
    //default defaultseed = 3905348978240129619;
    //default multiplier = 25214903917;
    //default addend = 11;
    //default mask = 281474976710655;
    //default lim = 25;

    event OnSpawned( spawnData : SEntitySpawnData )
    {
        super.OnSpawned(spawnData);
        setSeed(getGameplayBasedSeed());
        NRD("NR_RandomGenerator: Spawned with seed = " + Uint64ToString(seed));
    }

    protected function getGameplayBasedSeed() : Uint64 {
        var newSeed : Uint64;
        var pos : Vector;
        var rot : EulerAngles;
        var engineTime : float;
        
        pos = thePlayer.GetWorldPosition();
        rot = thePlayer.GetWorldRotation();
        engineTime = theGame.GetEngineTimeAsSeconds();
        newSeed = defaultseed;
        newSeed *= IntToUint64((int)(engineTime * 10000));
        newSeed *= IntToUint64((int)AbsF(rot.Yaw * 10000));
        newSeed *= IntToUint64((int)AbsF(pos.X * 10000));
        newSeed *= IntToUint64((int)AbsF(pos.Y * 10000));
        newSeed *= IntToUint64((int)AbsF(pos.Z * 10000));
        newSeed *= IntToUint64(CalcSeed(theGame));

        return newSeed;
    }

    protected function shiftLeftU(n : Uint64, shift : int) : Uint64 {
    	return n * __power_two[shift];
    }

    protected function shiftLeft(n : int, shift : int) : int {
    	return Uint64ToInt(IntToUint64(n) * __power_two[shift]);
    }

    protected function shiftRight(n : int, shift : int) : int {
    	return Uint64ToInt(IntToUint64(n) / __power_two[shift]);
    }

    protected function shiftRightU(n : Uint64, shift : int) : Uint64 {
    	return n / __power_two[shift];
    }

    protected function MinU(a : Uint64, b : Uint64) : Uint64 {
        if (a < b)
            return a;
        else
            return b;
    }

    protected function MaxU(a : Uint64, b : Uint64) : Uint64 {
        if (a > b)
            return a;
        else
            return b;
    }

    protected function ClampU(v, minV, maxV : Uint64) : Uint64 {
        return MinU(MaxU(v, minV), maxV);
    }

    protected function nextBits(bits : int) : Uint64 {
    	var left, right : Uint64;
        if (bits <= 48) {
            seed = (seed * multiplier + addend) & mask;
            return shiftRightU(seed, (48 - bits));
        } else {
            if (bits > 63)
                NRE("random_t::nextBits(int bits): n must be less than 64");

            left = shiftLeftU(nextBits(31), 32);
            right = nextBits(32);

            return left ^ right;
        }
    }

    /* Returns encoded value (2147483647) */
    public function getIntMax() : int {
        return __int_max;
    }

    /* Returns encoded value (9223372036854775807) */
    public function getLongLongMax() : Uint64 {
        return __longlong_max;
    }

    /* Sets seed manually by given value (not recommended). */
    public function setSeed(_seed : Uint64) {
    	seed = (_seed ^ multiplier) & mask;
    }

    /* Random value in range [0, n-1]. */
    public function nextU(n : Uint64) : Uint64 {
    	var limit, bits : Uint64;
        if (n <= IntToUint64(0)) {
            NRE("random_t::next(long long n): n must be positive");
            return n;
        }

        limit = __longlong_max / n * n;

        bits = nextBits(63);
        while (bits >= limit) {
        	bits = nextBits(63);
        }

        return NR_ModuloUint64(bits, n); // bits % n
    }

    /*
     * Weighted next. If type == 0 than it is usual "next()".
     *
     * If type = 1, than it returns "max(next(), next())"
     * (the number of "max" functions equals to "type").
     *
     * If type < 0, than "max" function replaces with "min".
     */
    public function wnextU(n : Uint64, type : int) : Uint64 {
        var i : int;
        var result : Uint64;

        result = nextU(n);
        for (i = 0; i < type; i += 1)
            result = MaxU(result, nextU(n));

        for (i = 0; i < -type; i += 1)
            result = MinU(result, nextU(n));

        return result;
    }

    /* Returns random value in range [from,to]. */
    public function nextRangeU(from : Uint64, to : Uint64) : Uint64 {
        return nextU(to - from + IntToUint64(1)) + from;
    }

    /* Returns weighted random value in range [from,to]. */
    public function wnextRangeU(from : Uint64, to : Uint64, type : int) : Uint64 {
        return wnextU(to - from + IntToUint64(1), type) + from;
    }

    /* Random value in range [0, n-1]. */
    public function next(n : int) : int {
    	var limit, bits : Uint64;
        if (n <= 0)
            NRE("random_t::next(long long n): n must be positive");

        limit = IntToUint64(__int_max / n * n);

        bits = nextBits(31);
        while (bits >= limit) {
            bits = nextBits(31);
        }

        return Uint64ToInt(NR_ModuloUint64(bits, IntToUint64(n))); // bits % n
    }

    /* Random weighted value in range [0, n-1]. */
    public function wnext(n : int, type : int) : int {
        var i, result : int;

        result = next(n);
        for (i = 0; i < type; i += 1)
            result = Max(result, next(n));

        for (i = 0; i < -type; i += 1)
            result = Min(result, next(n));

        return result;
    }


    /* Returns random value in range [from,to]. */
    public function nextRange(from : int, to : int) : int {
        return next(to - from + 1) + from;
    }

    /* Returns weighted random value in range [from,to]. */
    public function wnextRange(from : int, to : int, type : int) : int {
        return wnext(to - from + 1, type) + from;
    }

    /* Random double value in range [0, 1). */
    public function nextF() : float {
        var left, right : int;
        left = shiftLeft(Uint64ToInt(nextBits(14)), 15);
        right = Uint64ToInt(nextBits(15));

        return ClampF((float)(left + right) / (float)Uint64ToInt(__power_two[29]), 0.0, 1.0);
    }

    /* Weighted random double value in range [0, 1). */
    public function wnextF(type : int) : float {
        var i : int;
        var result : float;

        result = nextF();
        for (i = 0; i < type; i += 1)
            result = MaxF(result, nextF());

        for (i = 0; i < -type; i += 1)
            result = MinF(result, nextF());

        return result;
    }

    /* Random double value in range [from, to). */
    public function nextRangeF(from : float, to : float) : float {
        return (to - from) * nextF() + from;
    }

    /* Weighted random double value in range [from, to). */
    public function wnextRangeF(from : float, to : float, type : int) : float {
        return (to - from) * wnextF(type) + from;
    }
}

/* API */ function NR_GetRandomGenerator() : NR_RandomGenerator {
    var template : CEntityTemplate;
    var generator : NR_RandomGenerator;

    generator = (NR_RandomGenerator)theGame.GetEntityByTag('NR_RandomGenerator');
    if (!generator) {
        template = (CEntityTemplate)LoadResource("nr_random_generator", false);
        generator = (NR_RandomGenerator)theGame.CreateEntity(template, thePlayer.GetWorldPosition() /*, , , , , PM_Persist*/ );
        generator.AddTag('NR_RandomGenerator');
    }

    return generator;
}

// usage examples
exec function nr_testrandom() {
    var generator : NR_RandomGenerator;

    generator = NR_GetRandomGenerator();
    NRD("nr_testrandom: rand int = " + generator.next(2147483647));
    NRD("nr_testrandom: rand uint64 = " + Uint64ToString( generator.nextU(generator.getLongLongMax()) ));
    NRD("nr_testrandom: rand float = " + generator.nextF());

    NRD("nr_testrandom: rand weighted int in range(-100, 100) = " + generator.wnextRange(-100, 100, 5));
    NRD("nr_testrandom: rand weighted uint64 in range(0, 500) = " + Uint64ToString( generator.wnextRangeU(IntToUint64(0), IntToUint64(500), -5) ));
    NRD("nr_testrandom: rand weighted float in range(-1000, 1000) = " + generator.wnextRangeF(-1000.f, 1000.f, -10));
}
