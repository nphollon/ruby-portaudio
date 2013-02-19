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
    return_value = C.send method, *args
    check_for_error_code(return_value) if return_value.respond_to?(:<)
    check_for_null_pointer(return_value) if return_value.respond_to?(:null?)
    return_value
  end
  module_function :invoke
  
  def sample_size(format)
    invoke :sample_size, C::PA_SAMPLE_FORMAT_MAP[format]
  end
  module_function :sample_size

  def check_for_error_code(status)
    raise RuntimeError, C.error_text(status) if status < 0
  end
  module_function :check_for_error_code

  def check_for_null_pointer(pointer)
    if pointer.null?
      err = C::PaHostErrorInfo.new(C.last_host_error_info())
      raise RuntimeError, err[:error_text]
    end
  end
  module_function :check_for_null_pointer
end