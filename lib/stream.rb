module PortAudio
  class Stream

    class << self
      def format_supported?(options)
        in_params = C::PaStreamParameters.from_options(options[:input]) if options[:input]
        out_params = C::PaStreamParameters.from_options(options[:output]) if options[:output]
        C.is_format_supported(in_params, out_params, options[:sample_rate]) == C::PA_FORMAT_IS_SUPPORTED
      end
      
      def open(options)
        in_params = C::PaStreamParameters.from_options(options[:input]) if options[:input]
        out_params = C::PaStreamParameters.from_options(options[:output]) if options[:output]
        
        sample_rate = options[:sample_rate]
        frames    = options[:frames]    || C::PA_FRAMES_PER_BUFFER_UNSPECIFIED
        flags     = options[:flags]     || C::PA_NO_FLAG
        callbackp = options[:callback]  || FFI::Pointer.new(0) # default: blocking mode
        user_data = options[:user_data] || FFI::Pointer.new(0)

        FFI::MemoryPointer.new(:pointer) do |streamp|
          PortAudio.invoke :open_stream, streamp, in_params, out_params, sample_rate, frames,
            flags, callbackp, user_data          
          return new(streamp.read_pointer)
        end
      end
      
      private :new
    end
    
    def initialize(pointer)
      @stream = pointer
      infop = C.stream_info(@stream)
      raise RuntimeError, "Invalid stream" if infop.null?
      @info = C::PaStreamInfo.new(infop)
    end
    
    def close
      PortAudio.invoke :close_stream, @stream
    end
    
    def start
      PortAudio.invoke :start_stream, @stream
    end
    
    def stop
      PortAudio.invoke :stop_stream, @stream
    end
    
    def abort
      PortAudio.invoke :abort_stream, @stream
    end
    
    def stopped?
      1 == PortAudio.invoke(:is_stream_stopped, @stream)
    end
    
    def active?
      1 == PortAudio.invoke(:is_stream_active, @stream)
    end
    
    def time
      C.stream_time(@stream)
    end
    
    def cpu_load
      C.stream_cpu_load(@stream)
    end
    
    def read
      raise NotImplementedError, "Stream#read is not implemented" # TODO ;)
    end
    
    def write(buffer)
      C.Pa_WriteStream(@stream, buffer.to_ptr, buffer.frames)
    end
    alias_method :<<, :write
  end
end