require "portaudio.rb"

begin
  PortAudio.init
  PortAudio.default_output_device.open do |s|
    time = 0
    while time < 2
      time += 1.0/44100
      s << (Math.cos(time * 2 * Math::PI * 440.0) * Math.cos(time * 2 * Math::PI))
    end
  end
  PortAudio.terminate
rescue Exception => err
  puts err.class
  puts err.message
  puts err.backtrace
end