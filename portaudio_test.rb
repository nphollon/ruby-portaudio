require 'ffi'
require 'portaudio'

begin
  PortAudio.init
  
  block_size = 1024
  sr   = 44100
  step = 1.0/sr
  time = 0.0
  
  device = PortAudio.default_output_device
  stream = device.open_stream(
            channels: 1,
            sample_format: :float32,
            sample_rate: sr,
            frames: block_size
          )
  
  buffer = PortAudio::SampleBuffer.new(
             :format   => :float32,
             :channels => 1,
             :frames   => block_size)
  
  playing = true
  Signal.trap('INT') { playing = false }
  puts "Ctrl-C to exit"
  
  stream.start
  
  while playing
    stream << buffer.fill { |frame, channel|
      time += step
      Math.cos(time * 2 * Math::PI * 440.0) * Math.cos(time * 2 * Math::PI)
    }
  end
  
  stream.stop
  stream.close
  PortAudio.terminate
rescue Exception => err
  puts err.class
  puts err.message
  puts err.backtrace
end
