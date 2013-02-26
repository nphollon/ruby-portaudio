module PortAudio
  extend self

  def init(silent=true)
    $stderr.reopen(File::NULL) if silent
    invoke :init
    $stderr.reopen(STDERR)
  end

  def terminate
    invoke :terminate
  end
  
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
      devices << Device.new( C.host_api_device_index_to_device_index(index, i) )
    end

    {name: info[:name], devices: devices}
  end

  def default_output_device
    Device.new(invoke :default_output_device)
  end

  def default_input_device
    Device.new PortAudio::C.default_input_device
  end

  def invoke(method, *args)
    return_value = C.send method, *args
    if (return_value.respond_to?(:<) and return_value < 0)
      raise APIError, C.error_text(return_value)
    elsif return_value.respond_to?(:null?) and return_value.null?
      err = C::PaHostErrorInfo.new(C.last_host_error_info)
      raise APIError, err[:error_text]
    end
    return_value
  end
  
  def version
    C.version
  end
  
  def version_text
    C.version_text
  end

  class APIError < IOError
  end
end