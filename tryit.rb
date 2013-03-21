require_relative './portaudio'

device = PortAudio::Device.default_output_device
stream = device.open_stream(frames_per_buffer: 256)
stream.start

t = 0
1000.times do
  stream.write do
    t += 1.0/44100
    Math.sin(t * 880 * Math::PI)*Math.sin(t*10*Math::PI)
  end
end
stream.stop