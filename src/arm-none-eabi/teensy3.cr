@[Link("teensy3")]
lib Teensy3
  fun usb_serial_write(buffer : UInt8*, size : UInt32) : Int32
  fun usb_serial_putchar(c : UInt8)

  fun delay(ms : UInt32)

  fun digitalWrite(pin : UInt8, val : UInt8)
  fun pinMode(pin : UInt8, mode : UInt8)
end
