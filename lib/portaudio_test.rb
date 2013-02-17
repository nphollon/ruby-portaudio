require 'ffi'
require 'portaudio'

if __FILE__ == $0
  PortAudio.init
  
  block_size = 1024
  sr   = 44100
  step = 1.0/sr
  time = 0.0
  
  stream = PortAudio::Stream.open(
             :sample_rate => sr,
             :frames => block_size,
             :output => {
               :device => PortAudio::Device.default_output,
               :channels => 1,
               :sample_format => :float32
              })
  
  buffer = PortAudio::SampleBuffer.new(
             :format   => :float32,
             :channels => 1,
             :frames   => block_size)
  
  playing = true
  Signal.trap('INT') { playing = false }
  puts "Ctrl-C to exit"
  
  stream.start
  
  loop do
    stream << buffer.fill { |frame, channel|
      time += step
      Math.cos(time * 2 * Math::PI * 440.0) * Math.cos(time * 2 * Math::PI)
    }
    
    break unless playing
  end
  
  stream.stop
end
