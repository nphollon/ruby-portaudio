require 'inline'

module PortAudio
  class Stream
    inline do |builder|
      PortAudio.prepare_builder(builder)

      builder.prefix <<-EOC
        typedef struct Stream {
          void *stream_pointer;
          void *buffer;
          int device_id;
          int channel_count;
          unsigned long format_id;
          double sample_rate;
          unsigned long frames_per_buffer;
          int clipping;
          int dithering;
          int output_priming;
          double latency;
        } Stream;

        void allocate_stream_buffer(Stream *stream) {
          
        }

        void free_stream(Stream *stream) {
          Pa_CloseStream(stream->stream_pointer);
          free(stream->buffer);
          free(stream);
        }

        unsigned long get_flags(Stream *stream) {
          return paNoFlag |
                (!stream->clipping) * paClipOff |
                (!stream->dithering) * paDitherOff |
                (stream->output_priming) * paPrimeOutputBuffersUsingStreamCallback;
        }

        Stream * get_stream(VALUE self) {
          Stream *stream;
          Data_Get_Struct(self, Stream, stream);
          return stream;
        }

        void * get_stream_pointer(VALUE self) {
          return get_stream(self)->stream_pointer;
        }

        void write_float32(Stream *stream, unsigned long limit) {
          unsigned long i;
          for (i = 0; i < limit; i++)
            ((float *)stream->buffer)[i] = (float)NUM2DBL( rb_yield(Qnil) );
        }

        void write_int32(Stream *stream, unsigned long limit) {
          unsigned long i;
          for (i = 0; i < limit; i++)
            ((long *)stream->buffer)[i] = FIX2LONG( rb_yield(Qnil) );
        }

        void write_int16(Stream *stream, unsigned long limit) {
          unsigned long i;
          for (i = 0; i < limit; i++)
            ((short *)stream->buffer)[i] = FIX2INT( rb_yield(Qnil) );
        }

        void write_int8(Stream *stream, unsigned long limit) {
          unsigned long i;
          for (i = 0; i < limit; i++)
            ((signed char *)stream->buffer)[i] = (signed char)FIX2INT( rb_yield(Qnil) );
        }

        void write_uint8(Stream *stream, unsigned long limit) {
          unsigned long i;
          for (i = 0; i < limit; i++)
            ((unsigned char *)stream->buffer)[i] = (unsigned char)FIX2INT( rb_yield(Qnil) );
        }
      EOC

      builder.c_singleton <<-EOC
        VALUE new(const int device_id, const int channel_count, const unsigned long format_id, double sample_rate,
                  unsigned long frames_per_buffer, int clipping, int dithering, int output_priming,
                  const double suggested_latency) {
          Stream *stream = malloc(sizeof(Stream));
          stream->device_id = device_id;
          stream->channel_count = channel_count;
          stream->format_id = format_id;
          stream->sample_rate = sample_rate;
          stream->frames_per_buffer = frames_per_buffer;
          stream->clipping = clipping;
          stream->dithering = dithering;
          stream->output_priming = output_priming;

          stream->buffer = malloc( Pa_GetSampleSize(format_id) * frames_per_buffer * channel_count);
          int i;
          for (i = 0; i < frames_per_buffer*channel_count; i++) {
            switch (format_id) {
              case paFloat32:
                ((float *)stream->buffer)[i] = 0;
                break;
              case paInt32:
                ((long *)stream->buffer)[i] = 0;
                break;
              case paInt16:
                ((short *)stream->buffer)[i] = 0;
                break;
              case paInt8:
                ((signed char *)stream->buffer)[i] = 0;
                break;
              case paUInt8:
                ((unsigned char *)stream->buffer)[i] = 0;
                break;
            }
          }

          initialize_before_call( Pa_GetHostApiCount );
          PaStreamParameters params = { device_id, channel_count, format_id, suggested_latency, 0 };
          PaStreamFlags flags = get_flags(stream);
          check_error_code( Pa_OpenStream(&stream->stream_pointer, 0, &params, sample_rate,
                                          0, flags, 0, 0) );

          stream->latency = Pa_GetStreamInfo(stream->stream_pointer)->outputLatency;

          return Data_Wrap_Struct(self, 0, free_stream, stream);
        }
      EOC

      builder.struct_name = "Stream"
      builder.reader :device_id, "int"
      builder.reader :channel_count, "int"
      builder.reader :format_id, "unsigned long"
      builder.reader :sample_rate, "double"
      builder.reader :frames_per_buffer, "unsigned long"
      builder.reader :latency, "double"

      builder.c <<-EOC
        VALUE clipping() {
          return (get_stream(self)->clipping) ? Qtrue : Qfalse;
        }
      EOC

      builder.c <<-EOC
        VALUE dithering() {
          return (get_stream(self)->dithering) ? Qtrue : Qfalse;
        }
      EOC

      builder.c <<-EOC
        VALUE output_priming() {
          return (get_stream(self)->output_priming) ? Qtrue : Qfalse;
        }
      EOC

      builder.c <<-EOC
        VALUE buffer() {
          Stream *stream = get_stream(self);
          unsigned long length = stream->channel_count * stream->frames_per_buffer;
          VALUE * value_buffer = malloc(sizeof(VALUE) * length);
          int i;
          for (i = 0; i < length; i++) {
            switch (stream->format_id) {
              case (paFloat32):
                value_buffer[i] = rb_float_new(((float *)stream->buffer)[i]);
                break;
              case (paInt32):
                value_buffer[i] = rb_float_new(((long *)stream->buffer)[i]);
                break;
              case (paInt16):
                value_buffer[i] = rb_float_new(((short *)stream->buffer)[i]);
                break;
              case (paInt8):
                value_buffer[i] = rb_float_new(((signed char *)stream->buffer)[i]);
                break;
              case (paUInt8):
                value_buffer[i] = rb_float_new(((unsigned char *)stream->buffer)[i]);
                break;
            }
          }
          VALUE rb_buffer = rb_ary_new4(length, value_buffer);
          free(value_buffer);
          return rb_buffer;
        }
      EOC

      builder.c <<-EOC
        unsigned long flags_encoded() {
          return get_flags(get_stream(self));
        }
      EOC

      builder.c <<-EOC
        void start() {
          check_error_code( Pa_StartStream(get_stream_pointer(self)) );
        }
      EOC

      builder.c <<-EOC
        void stop() {
          check_error_code( Pa_StopStream(get_stream_pointer(self)) );
        }
      EOC

      builder.c <<-EOC
        void stop_bang() {
          check_error_code( Pa_AbortStream(get_stream_pointer(self)) );
        }
      EOC

      builder.c <<-EOC
        VALUE stopped_eh() {
          return check_error_code( Pa_IsStreamStopped(get_stream_pointer(self)) ) ? Qtrue : Qfalse;
        }
      EOC

      builder.c <<-EOC
        VALUE active_eh() {
          return check_error_code( Pa_IsStreamActive(get_stream_pointer(self)) ) ? Qtrue : Qfalse;
        }
      EOC

      builder.c <<-EOC
        double time() {
          return Pa_GetStreamTime(get_stream_pointer(self));
        }
      EOC

      builder.c <<-EOC
        double cpu_load() {
          return Pa_GetStreamCpuLoad(get_stream_pointer(self));
        }
      EOC

      builder.c <<-EOC
        long frames_available() {
          return check_error_code( Pa_GetStreamWriteAvailable(get_stream_pointer(self)) );
        }
      EOC

      builder.c <<-EOC
        void write() {
          Stream *stream = get_stream(self);
          unsigned long limit = stream->frames_per_buffer * stream->channel_count;

          switch (get_stream(self)->format_id) {
            case paFloat32:
              write_float32(stream, limit);
              break;
            case paInt32:
              write_int32(stream, limit);
              break;
            case paInt16:
              write_int16(stream, limit);
              break;
            case paInt8:
              write_int8(stream, limit);
              break;
            case paUInt8:
              write_uint8(stream, limit);
              break;
            default:
              rb_raise(rb_eNotImpError, "int24 format not yet supported");
          }

          Pa_WriteStream(stream->stream_pointer, stream->buffer, limit);
        }
      EOC
    end

    def device
      PortAudio::Device.find_by_id device_id
    end

    def format
      FORMAT_HEX_CODE.key format_id
    end
  end
end