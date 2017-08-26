require "./teensy3"
require "../core/string"

struct OutputConsole
  def print(str)
    Teensy3.usb_serial_write str.bytes, str.size
  end

  def puts(str="")
    print(str)
    Teensy3.usb_serial_putchar 0x0a
  end

  def puti(integer)
    Teensy3.usb_serial_putchar(0x30 + integer)
    Teensy3.usb_serial_putchar 0x0a
  end
end

STDOUT = OutputConsole.new

def print(str)
  STDOUT.print(str)
end

def puts(str="")
  STDOUT.puts(str)
end

def puti(integer)
  STDOUT.puti(integer)
end
