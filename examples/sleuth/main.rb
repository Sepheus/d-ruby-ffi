#!/usr/bin/ruby
require 'ffi'
require './app'

def decrypt(k, dn)
	kp = FFI::MemoryPointer.new :uchar, k.length
	dp = FFI::MemoryPointer.new :uchar, dn.length
	kp.put_array_of_uchar 0, k.bytes
	dp.put_array_of_uchar 0, dn.bytes
	APP
		.decrypt_p(kp, k.length, dp, dn.length)
		.read_array_of_uchar(dn.length/2)
end

datanode = IO.binread("data.node")

key = "0000-VGNS-CLAW-BEES-K-RADZ-KON-CULT-A3LG-TOA-S038-S27-D118-WULF-O47-DEW-J009-S01-BNDR-WOLF-EIRE-RYAN-PNDA-SKY-YMCA-GL13-MOA-F09-KRPY-3UP-MG91-MAK-LAW-S692-TEXX-BOB-WURF-AIR-JEDI-WPX-RAZ4-M0A-SOCW-XENO-GUS-SSDD-ES91-117-U190-ENZO-IIII-RC0N"

IO.binwrite("out.mp4",decrypt(key,datanode).reverse.pack("C*"))