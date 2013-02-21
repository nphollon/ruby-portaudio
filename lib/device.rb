module PortAudio
  class Device
    attr_reader :index, :name, :default_sample_rate, :max_input_channels, :max_output_channels,
      :default_low_input_latency, :default_low_output_latency, :default_high_input_latency,
      :default_high_output_latency

    def initialize(index)
      @index = index

      info = C::PaDeviceInfo.new( PortAudio.invoke :device_info, @index )
      
      @name = info[:name]
      @default_sample_rate = info[:default_sample_rate]
      @max_input_channels = info[:max_input_channels]
      @max_output_channels = info[:max_output_channels]
      @default_low_input_latency = info[:default_low_input_latency]
      @default_low_output_latency = info[:default_low_output_latency]
      @default_high_input_latency = info[:default_high_input_latency]
      @default_high_output_latency = info[:default_high_output_latency]
    end

    def format_supported?(options={})
      params = C::PaStreamParameters.new
      params[:device] = @index
      params[:channel_count] = options[:channels] || 1
      params[:sample_format] = C::PA_SAMPLE_FORMAT_MAP[ options[:sample_format] || :uint8 ]
      sample_rate = options[:sample_rate] || @default_sample_rate

      if options[:input]
        C.is_format_supported(params, nil, sample_rate) == C::PA_FORMAT_IS_SUPPORTED
      else
        C.is_format_supported(nil, params, sample_rate) == C::PA_FORMAT_IS_SUPPORTED
      end
    end
  end
end