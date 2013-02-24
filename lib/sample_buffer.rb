module PortAudio  
  # A memory buffer for interleaved PCM data
  class SampleBuffer
    attr_reader :channels, :format, :frames, :size
    
    def initialize(options = {})
      @channels = options[:channels] || 1
      @format ||= options[:format] || :float32
      @frames ||= options[:frames] || 1024
      @sample_size = PortAudio.sample_size(@format)
      @frame_size = @channels * @sample_size
      @size = @sample_size * @channels * @frames
      @buffer = FFI::MemoryPointer.new(@size)
    end
    
    def dispose
      @buffer.free
      nil
    end
    
    def to_ptr
      @buffer
    end
    
    def [](frame, channel)
      index = (channel * @sample_size) + (frame * @frame_size)
      get_sample(index)
    end
    
    def []=(frame, channel, sample)
      index = (channel * @sample_size) + (frame * @frame_size)
      put_sample(index, sample)
    end

    def fill
      samples = []
      for frame in 0 ... @frames
        for channel in 0 ... @channels
          samples << yield(frame, channel)
        end
      end

      put_array_of_samples(0, samples)
      self
    end

    def get_sample(index)
      @buffer.send("get_#{format}", index)
    end

    def put_sample(index, sample)
      @buffer.send("put_#{format}", index, sample)
    end

    def put_array_of_samples(offset, samples)
      @buffer.send("put_array_of_#{format}", offset, samples)
    end
  end
end