module PortAudio
  def version_number
    C.Pa_GetVersion()
  end
  module_function :version_number
  
  def version_text
    C.Pa_GetVersionText()
  end
  module_function :version_text
  
  def error_text(pa_err)
    C.Pa_GetErrorText(pa_err)
  end
  module_function :error_text
  
  def init
    C.Pa_Initialize()
  end
  module_function :init
  
  def terminate
    C.Pa_Terminate()
  end
  module_function :terminate
  
  def sleep(msec)
    C.Pa_Sleep(msec)
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