import rubyffi;
import std.stdio : writeln;
import std.string : toStringz;
import std.conv : to;
mixin rubyffi!__MODULE__;

export extern(C) {
	int a = 99;
	@Ruby int add(int a, int b) {
		return a + b;
	}
	@Ruby void hello(cstr name) {
		("Hello " ~ name.to!string).writeln;
	}
	
	@Ruby cstr testString() {
	    return "Hello";
	}
	
	@Ruby("ptrTest") int* test() {
	    return &a;
	}
}

unittest { 
	import std.string;
	assert(1.add(2) == 3);
	assert(testString() == "Hello");
	assert(*test() == 99);
	*test() = 10;
	assert(*test() == 10);
}