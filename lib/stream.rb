require 'inline'

module PortAudio
  class Stream
    inline do |builder|
      PortAudio.prepare_builder(builder)

      builder.prefix <<-EOC
        typedef struct Stream {
          void *stream_pointer;
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

        void free_stream(Stream *stream) {
          Pa_CloseStream(stream->stream_pointer);
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
    end
    
    def device
      PortAudio::Device.find_by_id device_id
    end

    def format
      FORMAT_HEX_CODE.key format_id
    end
  end
end