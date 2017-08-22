{% if flag?(:x86) || flag?(:x86_64) %}
require "./x86/loader"
require "./x86/OutputConsole"
{% elsif flag?(:arm) && flag?(:none) && flag?(:eabi) %}
require "./arm-none-eabi/OutputConsole"
{% end %}

puts "Kernel booting with Crystal!"
puts
puts "<3"
