import rubyffi;
mixin rubyffi!__MODULE__;

export extern(C) {	
    @Ruby ubyte* decrypt(immutable(ubyte*) key, immutable size_t keyLen, immutable(ubyte*) datanode, size_t nodeLen) pure {
        import core.memory : GC;
        immutable nodeLength = nodeLen >> 1;
        ubyte *output = cast(ubyte*)GC.calloc(nodeLength);
        ubyte b = 0, k = 0;
        for (int i = 0; i < nodeLength; i++) {
            k = key[i % keyLen];
            b = datanode[(i << 1) + 1] & 1;
            output[i] = (((datanode[i << 1] + (k & 1)) << 1) - b - k) & 0xFF;
        }
        return output;
    }
    
    @Ruby ubyte* decrypt_p(immutable(ubyte*) key, immutable size_t keyLen, immutable(ubyte*) datanode, immutable size_t nodeLen) {
        import std.parallelism : parallel;
        ubyte[] output = new ubyte[nodeLen >> 1];
        foreach (i, ref decrypted; output.parallel) {
            immutable k = key[i % keyLen];
            immutable b = datanode[(i << 1) + 1] & 1;
            decrypted = (((datanode[i << 1] + (k & 1)) << 1) - b - k) & 0xFF;
        }
        return output.ptr;
    }
}

unittest { 
    import std.string;
    immutable data = "R\xC7Z\x86aC[Jd\xE17\xDFc;U\x89Z7Y\x1D[\x8Ec\x19;1a\xCF\\\x9F^Rb\xEE".representation;
    immutable key = "PASSWORD".representation;
    immutable result = "Super secret text";
    string dp = cast(string)decrypt_p(key.ptr, key.length, data.ptr, data.length)[0..(data.length >> 1)];
    string d = cast(string)decrypt(key.ptr, key.length, data.ptr, data.length)[0..(data.length >> 1)];
    assert(dp == result, "decrypt_f: wrong result.");
    assert(d == result, "decrypt: wrong result.");
}