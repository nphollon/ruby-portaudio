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
      case @format
      when :float32
        @buffer.get_float32(index)
      else
        raise NotImplementedError, "Unsupported sample format #{@format}"
      end
    end
    
    def []=(frame, channel, sample)
      index = (channel * @sample_size) + (frame * @frame_size)
      case @format
      when :float32
        @buffer.put_float32(index, sample)
      else
        raise NotImplementedError, "Unsupported sample format #{@format}"
      end
    end
    
    def fill
      samples = []
      for frame in 0 ... @frames
        for channel in 0 ... @channels
          samples << yield(frame, channel)
        end
      end
      @buffer.put_array_of_float32(0, samples)
      self
    end
  end
end