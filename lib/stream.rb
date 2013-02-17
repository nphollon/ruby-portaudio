module PortAudio
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
end