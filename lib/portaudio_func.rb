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
    status = C.send method, *args
    raise RuntimeError, C.error_text(status) if status < 0
    status
  end
  module_function :invoke
  
  def sample_size(format)
    invoke :sample_size, C::PA_SAMPLE_FORMAT_MAP[format]
  end
  module_function :sample_size
end