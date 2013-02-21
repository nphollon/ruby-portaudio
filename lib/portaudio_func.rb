module PortAudio
  extend self

  def sleep(msec)
    C.sleep msec
  end
  
  def sample_size(format)
    invoke :sample_size, C::PA_SAMPLE_FORMAT_MAP[format]
  end

  def host_count
    PortAudio.invoke :host_api_count
  end

  def default_host
    host C.default_host_api
  end

  def host(index)
    info = C::PaHostApiInfo.new( PortAudio.invoke(:host_api_info, index) )
    devices = []
    (0...info[:device_count]).each do |i|
      devices << PortAudio.device( C.host_api_device_index_to_device_index(index, i) )
    end

    {name: info[:name], devices: devices}
  end

  def default_output_device
    device PortAudio::C.default_output_device
  end

  def default_input_device
    device PortAudio::C.default_input_device
  end

  def device(index)
    info = C::PaDeviceInfo.new( PortAudio.invoke :device_info, index )
    {
      index: index,
      name: info[:name],
      max_output_channels: info[:max_output_channels],
      max_input_channels: info[:max_input_channels],
      default_sample_rate: info[:default_sample_rate],
      default_low_input_latency: info[:default_low_input_latency],
      default_low_output_latency: info[:default_low_output_latency],
      default_high_input_latency: info[:default_high_input_latency],
      default_high_output_latency: info[:default_high_output_latency]
    }
  end

  def invoke(method, *args)
    return_value = C.send method, *args
    if (return_value.respond_to?(:<) and return_value < 0)
      raise_error
    elsif return_value.respond_to?(:null?) and return_value.null?
      raise_error
    end
    return_value
  end
  
  def raise_error
    err = C::PaHostErrorInfo.new(C.last_host_error_info())
    raise RuntimeError, err[:error_text]
  end
  
  def version
    C.version
  end
  
  def version_text
    C.version_text
  end

end