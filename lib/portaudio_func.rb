module PortAudio
  def version
    C.version
  end
  module_function :version
  
  def version_text
    C.version_text
  end
  module_function :version_text
  
  def error_text(pa_err)
    C.error_text pa_err
  end
  module_function :error_text
  
  def initialize
    C.initialize
  end
  module_function :initialize
  
  def terminate
    C.terminate
  end
  module_function :terminate
  
  def sleep(msec)
    C.sleep msec
  end
  module_function :sleep
  
  def invoke
    status = yield
    if status != C::PA_NO_ERROR
      raise RuntimeError, PortAudio.error_text(status)
    end
  end
  module_function :invoke
  
  def sample_size(format)
    status = C.Pa_GetSampleSize(C::PA_SAMPLE_FORMAT_MAP[format])
    if status >= 0 then status
    else
      raise RuntimeError, PortAudio.error_text(status)
    end
  end
  module_function :sample_size
end