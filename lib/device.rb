require 'inline'

module PortAudio
  class Device
    inline do |builder|
      PortAudio.prepare_builder(builder)

      builder.prefix <<-EOC
        void free_device(PaDeviceInfo *device) {
          free(device);
        }

        VALUE build_device(VALUE class, const PaDeviceInfo *const_device) {
          PaDeviceInfo *device = malloc(sizeof(PaDeviceInfo));

          if (const_device == NULL) {
            device->name = "";
            device->maxInputChannels = 0;
            device->maxOutputChannels = 0;
            device->defaultLowInputLatency = 0;
            device->defaultLowOutputLatency = 0;
            device->defaultHighInputLatency = 0;
            device->defaultHighOutputLatency = 0;
            device->defaultSampleRate = 0;
            device->hostApi = -1;
          } else {
            device->name = const_device->name;
            device->maxInputChannels = const_device->maxInputChannels;
            device->maxOutputChannels = const_device->maxOutputChannels;
            device->defaultLowInputLatency = const_device->defaultLowInputLatency;
            device->defaultLowOutputLatency = const_device->defaultLowOutputLatency;
            device->defaultHighInputLatency = const_device->defaultHighInputLatency;
            device->defaultHighOutputLatency = const_device->defaultHighOutputLatency;
            device->defaultSampleRate = const_device->defaultSampleRate;
            device->hostApi = const_device->hostApi;
          }

          return Data_Wrap_Struct(class, 0, free_device, device);
        }
      EOC

      builder.c_singleton <<-EOC
        int count() {
          return initialize_before_call( Pa_GetDeviceCount );
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE find_by_id(int index) {
          int device_count = initialize_before_call( Pa_GetDeviceCount );
          if (index >= device_count || index < 0)
            rb_raise(rb_eRangeError, "Device index out of range");
          
          return build_device(self, Pa_GetDeviceInfo(index));
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE default_output_device() {
          int device_index = initialize_before_call( Pa_GetDefaultOutputDevice );
          return rb_funcall(self, rb_intern("find_by_id"), 1, INT2FIX(device_index));
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE default_input_device() {
          int device_index = initialize_before_call( Pa_GetDefaultInputDevice );
          return rb_funcall(self, rb_intern("find_by_id"), 1, INT2FIX(device_index));
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE new() {
          return build_device(self, 0);
        }
      EOC

      builder.struct_name = "PaDeviceInfo"
      builder.accessor :name, "char *"
      builder.accessor :max_input_channels, "int", :maxInputChannels
      builder.accessor :max_output_channels, "int", :maxOutputChannels
      builder.accessor :default_low_input_latency, "double", :defaultLowInputLatency
      builder.accessor :default_low_output_latency, "double", :defaultLowOutputLatency
      builder.accessor :default_high_input_latency, "double", :defaultHighInputLatency
      builder.accessor :default_high_output_latency, "double", :defaultHighOutputLatency
      builder.accessor :default_sample_rate, "double", :defaultSampleRate
      builder.accessor :host_api_id, "int", :hostApi

      builder.c <<-EOC
        VALUE host_api() {
          PaDeviceInfo *device;
          Data_Get_Struct(self, PaDeviceInfo, device);
          if (device->hostApi < 0)
            return Qnil;
          else {
            return rb_funcall(HOST, rb_intern("find_by_id"), 1, INT2FIX(device->hostApi));
          }
        }
      EOC
    end

    private_class_method :new
    private :name=, :max_input_channels=, :max_output_channels=, :default_low_input_latency=, :default_low_output_latency=,
            :default_high_input_latency=, :default_high_output_latency=, :default_sample_rate=, :host_api_id=

    def self.all
      device_list = []
      (0...count).each { |i| device_list << find_by_id(i) }
      device_list
    end

    def ==(other)
      begin
        host_api_id == other.host_api_id and
        name == other.name and
        max_input_channels == other.max_input_channels and
        max_output_channels == other.max_output_channels and
        default_low_input_latency == other.default_low_input_latency and
        default_low_output_latency == other.default_low_output_latency and
        default_high_input_latency == other.default_high_input_latency and
        default_high_output_latency == other.default_high_output_latency and
        default_sample_rate == other.default_sample_rate
      rescue NoMethodError
        false
      end
    end
  end
end