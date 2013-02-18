module PortAudio
  def version
    C.version
  end
  module_function :version
  
  def version_text
    C.version_text
  end
  module_function :version_text
  
  def sleep(msec)
    C.sleep msec
  end
  module_function :sleep
  
  def invoke(method, *args)
    status = C.send(method, *args)
    raise RuntimeError, C.error_text(status) unless status == C::PA_NO_ERROR
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