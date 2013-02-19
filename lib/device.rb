module PortAudio
  class Device    
    def initialize(index)
      @index = index
      @info = C::PaDeviceInfo.new( PortAudio.invoke :device_info, @index )
    end
    
    attr_reader :index
    
    def name
      @info[:name]
    end
    
    def max_input_channels
      @info[:max_input_channels]
    end
    
    def max_output_channels
      @info[:max_output_channels]
    end
    
    def default_low_input_latency
      @info[:default_low_input_latency]
    end
    
    def default_low_output_latency
      @info[:default_low_output_latency]
    end
    
    def default_high_input_latency
      @info[:default_high_input_latency]
    end
    
    def default_high_output_latency
      @info[:default_high_output_latency]
    end
    
    def default_sample_rate
      @info[:default_sample_rate]
    end
  end
end