module PortAudio
  class Stream
    def initialize(pointer)
      @stream = pointer
      @info = C::PaStreamInfo.new(PortAudio.invoke :stream_info, @stream)
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