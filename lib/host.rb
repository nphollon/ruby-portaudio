require 'inline'

module PortAudio
  class Host
    API_TYPES = [:in_development, :direct_sound, :mme, :asio, :sound_manager, :core_audio, :in_development,
                :oss, :alsa, :al, :be_os, :wdmks, :jack, :wasapi, :audio_science_hpi]

    inline do |builder|
      PortAudio.prepare_builder(builder)

      builder.prefix <<-EOC
        void free_host_api(PaHostApiInfo *host) {
          free(host);
        }

        VALUE build_host_api(VALUE class, const PaHostApiInfo *const_host) {
          PaHostApiInfo *host = malloc(sizeof(PaHostApiInfo));

          if (const_host == NULL) {
            host->name = "";
            host->deviceCount = 0;
            host->type = 0;
            host->defaultOutputDevice = -1;
            host->defaultInputDevice = -1;
          } else {
            host->name = const_host->name;
            host->deviceCount = const_host->deviceCount;
            host->type = const_host->type;
            host->defaultOutputDevice = const_host->defaultOutputDevice;
            host->defaultInputDevice = const_host->defaultInputDevice;
          }

          return Data_Wrap_Struct(class, 0, free_host_api, host);
        }
      EOC

      builder.c_singleton <<-EOC
        int count() {
          return initialize_before_call( Pa_GetHostApiCount );
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE new() {
          return build_host_api(self, 0);
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE find_by_id(int index) {
          int api_count = initialize_before_call( Pa_GetHostApiCount );
          if ( index >= api_count || index < 0)
            rb_raise(rb_eRangeError, "Host API index out of range");

          return build_host_api(self, Pa_GetHostApiInfo(index));
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE default_api() {
          int api_index = initialize_before_call( Pa_GetDefaultHostApi );
          return rb_funcall(self, rb_intern("find_by_id"), 1, INT2FIX(api_index));          
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE find_by_type_id(int id) {
          initialize_before_call( Pa_GetHostApiCount );
          int api_index = check_error_code( Pa_HostApiTypeIdToHostApiIndex(id) );
          return rb_funcall(self, rb_intern("find_by_id"), 1, INT2FIX(api_index));
        }
      EOC

      builder.struct_name = "PaHostApiInfo"
      builder.accessor :name, "char *"
      builder.accessor :device_count, "int", :deviceCount
      builder.accessor :type_id, "int", :type
      builder.accessor :default_output_device_id, "int", :defaultOutputDevice
      builder.accessor :default_input_device_id, "int", :defaultInputDevice

      builder.c <<-EOC
        VALUE default_output_device() {
          PaHostApiInfo *host;
          Data_Get_Struct(self, PaHostApiInfo, host);
          if (host->defaultOutputDevice < 0)
            return Qnil;
          else {
            return rb_funcall(DEVICE, rb_intern("find_by_id"), 1, INT2FIX(host->defaultOutputDevice));
          }
        }
      EOC

      builder.c <<-EOC
        VALUE default_input_device() {
          PaHostApiInfo *host;
          Data_Get_Struct(self, PaHostApiInfo, host);
          if (host->defaultInputDevice < 0)
            return Qnil;
          else {
            return rb_funcall(DEVICE, rb_intern("find_by_id"), 1, INT2FIX(host->defaultInputDevice));
          }
        }
      EOC

      builder.c <<-EOC
        VALUE devices() {
          int i, device_count, api_index;
          PaHostApiInfo *host;
          VALUE rb_device_list;
          VALUE *device_array;

          Data_Get_Struct(self, PaHostApiInfo, host);
          device_count = host->deviceCount;
          device_array = malloc(sizeof(VALUE) * device_count);

          api_index = FIX2INT( rb_funcall(self, rb_intern("id"), 0) );

          for (i = 0; i < device_count; i++) {
            VALUE device_fixnum = INT2FIX( Pa_HostApiDeviceIndexToDeviceIndex(api_index, i) );
            device_array[i] = rb_funcall(DEVICE, rb_intern("find_by_id"), 1, device_fixnum);
          }

          rb_device_list = rb_ary_new4(device_count, device_array);
          free(device_array);
          return rb_device_list;
        }
      EOC

      builder.c <<-EOC
        int id() {
          PaHostApiInfo *host;
          Data_Get_Struct(self, PaHostApiInfo, host);
          return check_error_code( Pa_HostApiTypeIdToHostApiIndex(host->type) );
        }
      EOC
    end

    private_class_method :new
    private :type_id=, :name=, :device_count=, :default_input_device_id=, :default_output_device_id=

    def type
      API_TYPES[type_id] or API_TYPES[0]
    end

    def ==(other)
      begin
        self.type_id == other.type_id and
        self.name == other.name and
        self.device_count == other.device_count and
        self.default_output_device_id == other.default_output_device_id and
        self.default_input_device_id == other.default_input_device_id
      rescue NoMethodError
        false
      end
    end
  end
end