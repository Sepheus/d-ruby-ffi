#!/usr/bin/ruby
#Some simple binding examples being run.
require 'ffi'
require './app'

p APP.add(2, 1)
APP.hello("Seph")
p APP.testString
p APP.ptrTest.read_int
APP.ptrTest.write_int(10)
p APP.ptrTest.read_int