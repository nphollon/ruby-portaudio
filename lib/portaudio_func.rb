require 'inline'

module PortAudio
  SAMPLE_SIZE = { float32: 4, int32: 4, int24: 3, int16: 2, int8: 1, uint8: 1 }

  def self.prepare_builder(builder)
    builder.add_link_flags "/usr/lib/i386-linux-gnu/libportaudio.a -lasound -ljack"
    builder.include '"portaudio.h"'

    builder.prefix <<-EOC
      int check_error_code(int error_code) {
        if (error_code < 0)
          rb_raise(rb_eIOError, "%s", Pa_GetErrorText(error_code));
        return error_code;
      }

      int initialize_before_call(int (*func)()) {
        int return_value = func();
        if (return_value == paNotInitialized || return_value == paNoDevice) {
          Pa_Initialize();
          return_value = func();
        }
        return check_error_code(return_value);
      }

      #define PORTAUDIO rb_const_get(rb_cObject, rb_intern("PortAudio"))
      #define HOST rb_const_get(PORTAUDIO, rb_intern("Host"))
      #define DEVICE rb_const_get(PORTAUDIO, rb_intern("Device"))
    EOC
  end

  inline do |builder|
    prepare_builder(builder)

    builder.c_singleton <<-EOC
      void init() {
        Pa_Initialize();
      }
    EOC

    builder.c_singleton <<-EOC
      void terminate() {
        check_error_code( Pa_Terminate() );
      }
    EOC

    builder.c_singleton <<-EOC
      int version() {
        return Pa_GetVersion();
      }
    EOC

    builder.c_singleton <<-EOC
      char * version_text() {
        return Pa_GetVersionText();
      }
    EOC

    builder.c_singleton <<-EOC
      void sleep(long msec) {
        Pa_Sleep(msec);
      }
    EOC
  end
  
  def self.sample_size(format)
    SAMPLE_SIZE[format]
  end

  def self.default_output_device
  end

  def self.default_input_device
  end
end