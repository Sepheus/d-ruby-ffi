/**
This mixin provides the @Ruby attribute and cstr convenience alias.
The binding generation will only be mixed in and invoked if bindgen is specified as a version during compilation.
Invocation will output the binding code to stderr so you will need to pipe 2> to a file to capture it.

License: $(HTTP opensource.org/licenses/MIT, MIT)
Author: $(HTTP sepheus.github.io, Sepheus)
**/
mixin template rubyffi(string mod)  {	
    struct Ruby { string name; }
    alias cstr = const(char*);
    
    version(bindgen) {
        import std.format : _fmt = format;
        pragma(msg, _bindGen());
    
        private string _bindGen() pure {		
            return "require 'ffi'\n" ~ _module(mod);
        }
    
        private string _module(string mod) pure {
            import std.uni : toUpper;
            immutable module_ = "module %s\n\textend FFI::Library\n\tffi_lib \"#{Dir.pwd}/lib%s.%s\"\n%send";
            immutable init = "\n\n%1$s::rt_init\n\nat_exit do\n\t%1$s::rt_term\nend";
            version(Windows) { return module_._fmt(mod.toUpper, mod, "dll", _body()); }
            version(linux) { return (module_ ~ init)._fmt(mod.toUpper, mod, "so", _body()); }
        }
    
        private string _body() pure {
            immutable fun = "\tattach_function :%s, [], :%s\n";
            version(linux) { return fun._fmt("rt_init", "int") ~ fun._fmt("rt_term", "int") ~ _func(); }
            version(Windows) { return _func(); }
        }
    
        private string _func() pure {
            import std.traits : getSymbolsByUDA, ReturnType, functionLinkage, Parameters;
            string res;
            immutable fun = "\tattach_function %s:%s, [%s], :%s\n";
            static foreach(i, func; getSymbolsByUDA!(mixin(mod), Ruby)) {
                static if(functionLinkage!func == "C") {
                    res ~= fun._fmt(_friend!func, __traits(identifier, func), _params!(Parameters!func), _rt!(ReturnType!func));
                }
            }
            return res;
        }
    
        private string _friend(T...)() pure {
            string res;
            static foreach(attr; __traits(getAttributes, T)) {
                static if(is(typeof(attr) == Ruby)) { res ~= ":" ~ attr.name ~ ", "; }
            }
            return res;
        }
    
        private string _params(T...)() pure {
            string res;
            static foreach(param; T) {   
                res ~= (":" ~ _rt!param ~ ", ");
            }
            return T.length > 0 ? res[0..$-2] : res;
        }
    
        private string _rt(T)() pure {
            import std.traits : isPointer, Unqual;
            alias U = Unqual!T;
            return (is(T == cstr) ? "string"  :
                    isPointer!T   ? "pointer" :
                    is(U == ubyte)? "uint8"   :
                    is(U == byte) ? "int8"    :
                    U.stringof);
        }
    }
    
    
    version(unittest) {} else
    {
        version(Windows) {
            import core.sys.windows.windows : BOOL, HINSTANCE, ULONG, LPVOID, DLL_PROCESS_ATTACH, DLL_PROCESS_DETACH, DLL_THREAD_ATTACH, DLL_THREAD_DETACH;
            import core.sys.windows.dll : dll_process_attach, dll_process_detach, dll_thread_attach, dll_thread_detach;
            HINSTANCE g_hInst;
            extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) {
                switch (ulReason) {
                case DLL_PROCESS_ATTACH:
                    g_hInst = hInstance;
                    dll_process_attach( hInstance, true );
                    break;

                case DLL_PROCESS_DETACH:
                    dll_process_detach( hInstance, true );
                    break;

                case DLL_THREAD_ATTACH:
                    dll_thread_attach( true, true );
                    break;

                case DLL_THREAD_DETACH:
                    dll_thread_detach( true, true );
                    break;

                    default:
                }
                return true;
            }
        }
    }
}