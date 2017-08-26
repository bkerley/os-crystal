{% if flag?(:x86) || flag?(:x86_64) %}
require "./x86/loader"
require "./x86/OutputConsole"
{% elsif flag?(:arm) && flag?(:none) && flag?(:eabi) %}
require "./arm-none-eabi/OutputConsole"
{% end %}

led_pin = 13
output_mode = 1
high_output = 1
low_output = 0

Teensy3.pinMode(led_pin, output_mode)

while true
  Teensy3.delay 1500
  Teensy3.digitalWrite led_pin, high_output
  Teensy3.delay 500
  Teensy3.digitalWrite led_pin, low_output
end
