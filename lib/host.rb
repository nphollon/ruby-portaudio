module PortAudio
  class Host

    class << self
      def count
        PortAudio.invoke :host_api_count
      end
  
      def default
        new C.default_host_api
      end

      private :new
    end

    attr_reader :devices

    def initialize(index)
      @info = C::PaHostApiInfo.new( PortAudio.invoke(:host_api_info, index) )
      @devices = []
      (0...@info[:device_count]).each do |i|
        @devices << Device.new( C.host_api_device_index_to_device_index(index, i) )
      end
    end

    def name
      @info[:name]
    end

    def default_input
      index = @info[:default_input_device]
      @devices[index] unless C::PA_NO_DEVICE == index
    end    

    def default_output
      index = @info[:default_output_device]
      @devices[index] unless C::PA_NO_DEVICE == index
    end
  end
end