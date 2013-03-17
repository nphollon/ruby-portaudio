require 'inline'

module PortAudio
  class Host
    API_TYPES = [:in_development, :direct_sound, :mme, :asio, :sound_manager, :core_audio, :in_development,
                :oss, :alsa, :al, :be_os, :wdmks, :jack, :wasapi, :audio_science_hpi]

    inline do |builder|
      builder.add_link_flags "/usr/lib/i386-linux-gnu/libportaudio.a -lasound -ljack"
      builder.include '"portaudio.h"'

      builder.prefix <<-EOC
        void free_host_api(PaHostApiInfo *host) {
          free(host);
        }

        VALUE build_host_api(VALUE class, const char *name, int device_count, int type_id) {
          PaHostApiInfo *host = malloc(sizeof(PaHostApiInfo));

          host->name = name;
          host->deviceCount = device_count;
          host->type = type_id;

          return Data_Wrap_Struct(class, 0, free_host_api, host);
        }

        int check_error_code(int error_code) {
          if (error_code < 0)
            rb_raise(rb_eIOError, "%s", Pa_GetErrorText(error_code));
          return error_code;
        }

        int force_api_count() {
          int api_count = Pa_GetHostApiCount();
          if (api_count == -10000) {
            Pa_Initialize();
            api_count = Pa_GetHostApiCount();
          }
          return check_error_code( api_count );
        }
      EOC

      builder.c_singleton <<-EOC
        int count() {
          return force_api_count();
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE new() {
          return build_host_api(self, "", 0, 0);
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE find_by_index(int index) {
          int api_count = force_api_count();
          if ( index >= api_count || index < 0)
            rb_raise(rb_eIOError, "Host API index out of range");

          const PaHostApiInfo *const_host = Pa_GetHostApiInfo(index);
          return build_host_api(self, const_host->name, const_host->deviceCount, const_host->type);
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE default_api() {
          force_api_count();
          int api_index = check_error_code( Pa_GetDefaultHostApi() );
          return rb_funcall(self, rb_intern("find_by_index"), 1, INT2FIX(api_index));          
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE find_by_type_id(int id) {
          force_api_count();
          int api_index = check_error_code( Pa_HostApiTypeIdToHostApiIndex(id) );
          return rb_funcall(self, rb_intern("find_by_index"), 1, INT2FIX(api_index));
        }
      EOC

      builder.struct_name = "PaHostApiInfo"
      builder.accessor :name, "char *"
      builder.accessor :device_count, "int", :deviceCount
      builder.accessor :type_id, "int", :type
    end

    private :type_id=, :name=, :device_count=

    def type
      API_TYPES[type_id] or API_TYPES[0]
    end

    def default_output_device
    end

    def default_input_device
    end

    def ==(other)
      begin
        self.type_id == other.type_id and
        self.name == other.name and
        self.device_count == other.device_count
      rescue NoMethodError
        false
      end
    end
  end
end