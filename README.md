Ruby-ffi
====

Simple automatic D to Ruby-FFI binding generator.

Installation
-------

`dub add-local rubyffi`

Not required to run examples.

How-To
------

It is relatively straight-forward to get up and running exporting your D code to run in Ruby via the FFI gem.

```d

import rubyffi;
mixin rubyffi!__MODULE__;

export extern(C) {
    @Ruby int add(int a, int b) {
        return a + b;
    }
    
    @Ruby("sayHello") cstr testString() {
        return "Hello";
    }
}
```

The @Ruby attribute signals to the rubyffi mixin to generate bindings for that particular function.

As you can see it is also possible to specify a "fiendly" name for the function to avoid name conflicts.

Please see the dub.json files in the example folders for recommended configuration settings.

Use

`dub build --build=release`

To compile your library.

You can then use

`dub build --config=bindgen --force --vquiet 2> app.rb`

To generate the bindings from your code as needed.  Dub is not required but it makes the process easier.

### Using from Ruby

Make sure to have the FFI gem installed.

```ruby
#!/usr/bin/ruby
require 'ffi'
require './app'

p APP.add(2, 1)  #Output 3
p APP.sayHello() #Output "Hello"
```

And that's it!

### To-Do

* Increase robustness at converting types into Ruby FFI appropriate forms.
* Investigate generating Ruby FFI bindings for structs.
