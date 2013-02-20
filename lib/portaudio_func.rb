module PortAudio
  extend self

  def version
    C.version
  end
  
  def version_text
    C.version_text
  end
  
  def sleep(msec)
    C.sleep msec
  end
  
  def invoke(method, *args)
    return_value = C.send method, *args
    check_for_error_code(return_value) if return_value.respond_to?(:<)
    check_for_null_pointer(return_value) if return_value.respond_to?(:null?)
    return_value
  end
  
  def sample_size(format)
    invoke :sample_size, C::PA_SAMPLE_FORMAT_MAP[format]
  end
  
  def check_for_error_code(status)
    raise RuntimeError, C.error_text(status) if status < 0
  end
  
  def check_for_null_pointer(pointer)
    if pointer.null?
      err = C::PaHostErrorInfo.new(C.last_host_error_info())
      raise RuntimeError, err[:error_text]
    end
  end
  
  def device(index)
    info = C::PaDeviceInfo.new( PortAudio.invoke :device_info, index )
    device = {}
    device[:index] = index
    device[:name] = info[:name]
    device[:max_output_channels] = info[:max_output_channels]
    device[:max_input_channels] = info[:max_input_channels]
    device[:default_low_input_latency] = info[:default_low_input_latency]
    device[:default_low_output_latency] = info[:default_low_output_latency]
    device[:default_high_input_latency] = info[:default_high_output_latency]
    device[:default_high_output_latency] = info[:default_high_output_latency]
    device[:default_sample_rate] = info[:default_sample_rate]
    device
  end
end