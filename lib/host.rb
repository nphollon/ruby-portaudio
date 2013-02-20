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
        @devices << PortAudio.device( C.host_api_device_index_to_device_index(index, i) )
      end
    end

    def name
      @info[:name]
    end

    def default_input
      @devices[@info[:default_input_device]]
    end    

    def default_output
      @devices[@info[:default_output_device]]
    end
  end
end