module PortAudio
  class Host
    def self.count
      C.Pa_GetHostApiCount()
    end
    
    def self.default
      new(C.Pa_GetDefaultHostApi())
    end
    
    class << self
      private :new
    end
    
    def initialize(index)
      @index = index
      infop = C.Pa_GetHostApiInfo(@index)
      if infop.null?
        err = C::PaHostErrorInfo.new(C.Pa_GetLastHostErrorInfo())
        raise RuntimeError, err[:error_text]
      end
      @info = C::PaHostApiInfo.new(infop) unless infop.null?
    end
    
    def name
      @info[:name]
    end
    
    def devices
      @devices ||= DeviceCollection.new(@index, @info)
    end
    
    class DeviceCollection
      include Enumerable
      
      def initialize(host_index, host_info)
        @host_index, @host_info = host_index, host_info
      end
      
      def count
        @host_info[:device_count]
      end
      alias_method :size, :count
      
      def [](index)
        case index
        when (0 ... count)
          Device.new(C.Pa_HostApiDeviceIndexToDeviceIndex(@host_index, index))
        end
      end
      
      def each
        0.upto(count) { |i| yield self[i] }
      end
      
      def default_input
        index = @host_info[:default_input_device]
        self[index] unless C::PA_NO_DEVICE == index
      end
      
      def default_output
        index = @host_info[:default_output_device]
        self[index] unless C::PA_NO_DEVICE == index
      end
    end
  end
  
  class Device
    def self.count
      C.Pa_GetDeviceCount()
    end
    
    def self.default_input
      index = C.Pa_GetDefaultInputDevice()
      new(index) unless C::PA_NO_DEVICE == index
    end
    
    def self.default_output
      index = C.Pa_GetDefaultOutputDevice()
      new(index) unless C::PA_NO_DEVICE == index
    end
    
    def initialize(index)
      @index = index
      infop = C.Pa_GetDeviceInfo(@index)
      raise RuntimeError, "Device not found" if infop.null?
      @info = C::PaDeviceInfo.new(infop)
    end
    
    attr_reader :index
    
    def name
      @info[:name]
    end
    
    def max_input_channels
      @info[:max_input_channels]
    end
    
    def max_output_channels
      @info[:max_output_channels]
    end
    
    def default_low_input_latency
      @info[:default_low_input_latency]
    end
    
    def default_low_output_latency
      @info[:default_low_output_latency]
    end
    
    def default_high_input_latency
      @info[:default_high_input_latency]
    end
    
    def default_high_output_latency
      @info[:default_high_output_latency]
    end
    
    def default_sample_rate
      @info[:default_sample_rate]
    end
  end
  
  class Stream
    def self.format_supported?(options)
      if options[:input]
        in_params = C::PaStreamParameters.from_options(options[:input])
      end
      
      if options[:output]
        out_params = C::PaStreamParameters.from_options(options[:output])
      end
      
      sample_rate = options[:sample_rate]
      err = C.Pa_IsFormatSupported(in_params, out_params, sample_rate)
      
      case err
        when C::PA_FORMAT_IS_SUPPORTED then true
        else false
      end
    end
    
    def self.open(options)
      if options[:input]
        in_params = C::PaStreamParameters.from_options(options[:input])
      end
      
      if options[:output]
        out_params = C::PaStreamParameters.from_options(options[:output])
      end
      
      sample_rate = options[:sample_rate]
      frames    = options[:frames]    || C::PA_FRAMES_PER_BUFFER_UNSPECIFIED
      flags     = options[:flags]     || C::PA_NO_FLAG
      callbackp = options[:callback]  || FFI::Pointer.new(0) # default: blocking mode
      user_data = options[:user_data] || FFI::Pointer.new(0)
      FFI::MemoryPointer.new(:pointer) do |streamp|
        PortAudio.invoke {
          C.Pa_OpenStream(streamp,
            in_params, out_params,
            sample_rate, frames, flags,
            callbackp, user_data)
        }
        
        return new(streamp.read_pointer)
      end
    end
    
    class << self
      private :new
    end
    
    def initialize(pointer)
      @stream = pointer
      infop = C.Pa_GetStreamInfo(@stream)
      raise RuntimeError, "Invalid stream" if infop.null?
      @info = C::PaStreamInfo.new(infop)
    end
    
    def close
      PortAudio.invoke { C.Pa_CloseStream(@stream) }
    end
    
    def start
      PortAudio.invoke { C.Pa_StartStream(@stream) }
    end
    
    def stop
      PortAudio.invoke { C.Pa_StopStream(@stream) }
    end
    
    def abort
      PortAudio.invoke { C.Pa_AbortStream(@stream) }
    end
    
    def stopped?
      status = C.Pa_IsStreamStopped(@stream)
      case status
        when 1 then true
        when 0 then false
        else
          raise RuntimeError, PortAudio.error_text(status)
      end
    end
    
    def active?
      status = C.Pa_IsStreamActive(@stream)
      case status
        when 1 then true
        when 0 then false
        else
          raise RuntimeError, PortAudio.error_text(status)
      end
    end
    
    def time
      C.Pa_GetStreamTime(@stream)
    end
    
    def cpu_load
      C.Pa_GetStreamCpuLoad(@stream)
    end
    
    def read
      raise NotImplementedError, "Stream#read is not implemented" # TODO ;)
    end
    
    def write(buffer)
      C.Pa_WriteStream(@stream, buffer.to_ptr, buffer.frames)
    end
    alias_method :<<, :write
  end
  
  # A memory buffer for interleaved PCM data
  class SampleBuffer
    attr_reader :channels, :format, :frames, :size
    
    def initialize(options = {})
      @channels, @format, @frames = options.values_at(:channels, :format, :frames)
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