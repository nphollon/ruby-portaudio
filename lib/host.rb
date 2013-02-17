module PortAudio
  class Host
    def self.count
      C.Pa_GetHostApiCount()
    end
    
    def self.default
      new(C.Pa_GetDefaultHostApi())
    end
    
    class << self
      private :new
    end
    
    def initialize(index)
      @index = index
      infop = C.Pa_GetHostApiInfo(@index)
      if infop.null?
        err = C::PaHostErrorInfo.new(C.Pa_GetLastHostErrorInfo())
        raise RuntimeError, err[:error_text]
      end
      @info = C::PaHostApiInfo.new(infop) unless infop.null?
    end
    
    def name
      @info[:name]
    end
    
    def devices
      @devices ||= DeviceCollection.new(@index, @info)
    end
    
    class DeviceCollection
      include Enumerable
      
      def initialize(host_index, host_info)
        @host_index, @host_info = host_index, host_info
      end
      
      def count
        @host_info[:device_count]
      end
      alias_method :size, :count
      
      def [](index)
        case index
        when (0 ... count)
          Device.new(C.Pa_HostApiDeviceIndexToDeviceIndex(@host_index, index))
        end
      end
      
      def each
        0.upto(count) { |i| yield self[i] }
      end
      
      def default_input
        index = @host_info[:default_input_device]
        self[index] unless C::PA_NO_DEVICE == index
      end
      
      def default_output
        index = @host_info[:default_output_device]
        self[index] unless C::PA_NO_DEVICE == index
      end
    end
  end
end