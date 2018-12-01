#!/usr/bin/ruby
require 'ffi'
require 'benchmark'
require './app'

datanode = IO.binread("data.node").bytes
key = "0000-VGNS-CLAW-BEES-K-RADZ-KON-CULT-A3LG-TOA-S038-S27-D118-WULF-O47-DEW-J009-S01-BNDR-WOLF-EIRE-RYAN-PNDA-SKY-YMCA-GL13-MOA-F09-KRPY-3UP-MG91-MAK-LAW-S692-TEXX-BOB-WURF-AIR-JEDI-WPX-RAZ4-M0A-SOCW-XENO-GUS-SSDD-ES91-117-U190-ENZO-IIII-RC0N".bytes

#Sleuth algorithm as written in Ruby to compare.
def rb_decrypt(key,datanode)
	output = Array.new(datanode.size / 2, 0)
	i = -1;
	output.map! {
			i += 1
			k = key[i % key.size];
			b = datanode[(i * 2) + 1] & 1
			(((datanode[i * 2] + (k & 1)) * 2) - b - k) % 256
	}
end

#Let us set up our pointers before we start making any calls.
def getPtrs(k, dn)
    kp = FFI::MemoryPointer.new :uchar, k.size
	dp = FFI::MemoryPointer.new :uchar, dn.size
	kp.put_array_of_uchar 0, k
    dp.put_array_of_uchar 0, dn
    return [kp, dp]
end

#Wrapper for D exported decrypt.
def d_decrypt(k, dn)
	APP
		.decrypt(k, k.size, dn, dn.size)
		.read_array_of_uchar(dn.size/2)
end

#Wrapper for D exported decrypt_p.
def d_decrypt_p(k, dn)
	APP
		.decrypt_p(k, k.size, dn, dn.size)
		.read_array_of_uchar(dn.size/2)
end

#Assign pointers.
kp, dp  = getPtrs(key, datanode)
kp2, dp2 = getPtrs(key, datanode)

Benchmark.bmbm(7) { |x|
    x.report("rb_decrypt:") { rb_decrypt(key,datanode) }
    x.report("d_decrypt:") { d_decrypt(kp, dp) }
    x.report("d_decrypt_p:") { d_decrypt_p(kp2, dp2) }
}