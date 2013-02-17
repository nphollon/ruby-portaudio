require 'ffi'

module PortAudio
  module C
    extend FFI::Library
    
    case RUBY_PLATFORM
    when /darwin/i
      ffi_lib '/System/Library/Frameworks/AudioUnit.framework/AudioUnit'
      ffi_lib '/System/Library/Frameworks/CoreAudio.framework/CoreAudio'
      ffi_lib '/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox'
      ffi_lib '/System/Library/Frameworks/CoreServices.framework/CoreServices'
    end
    
    ffi_lib 'portaudio'
    
    PA_ERROR = :int
    PA_NO_ERROR = 0
    
    PA_DEVICE_INDEX = :int
    PA_NO_DEVICE = (2 ** FFI::Platform::LONG_SIZE) - 1
    
    PA_HOST_API_TYPE_ID = :int
    
    PA_HOST_API_INDEX = :int

    PA_TIME = :double
    
    PA_SAMPLE_FORMAT = :ulong
    PA_SAMPLE_FORMAT_MAP = {
      :float32 => 0x00000001,
      :int32   => 0x00000002,
      :int24   => 0x00000004,
      :int16   => 0x00000008,
      :int8    => 0x00000010,
      :uint8   => 0x00000020,
      :custom  => 0x00010000
    }
    
    PA_NON_INTERLEAVED = 0x80000000

    PA_FORMAT_IS_SUPPORTED = 0
    
    PA_FRAMES_PER_BUFFER_UNSPECIFIED = 0
    
    PA_STREAM_FLAGS = :ulong
    PA_NO_FLAG                 = 0
    PA_CLIP_OFF                = 0x00000001
    PA_DITHER_OFF              = 0x00000002
    PA_NEVER_DROP_INPUT        = 0x00000004
    PA_PRIME_OUTPUT_BUFFERS_USING_STREAM_CALLBACK =
                                 0x00000008
    PA_PLATFORM_SPECIFIC_FLAGS = 0xFFFF0000
    
    PA_STREAM_CALLBACK_FLAGS = :ulong
    PA_INPUT_UNDERFLOW  = 0x00000001
    PA_INPUT_OVERFLOW   = 0x00000002
    PA_OUTPUT_UNDERFLOW = 0x00000004
    PA_OUTPUT_OVERFLOW  = 0x00000008
    PA_PRIMING_OUTPUT   = 0x00000010
    
    PA_STREAM_CALLBACK_RESULT = :int
    PA_CONTINUE = 0
    PA_COMPLETE = 1
    PA_ABORT    = 2
    
    PA_STREAM_CALLBACK = :pointer
    
    PA_STREAM_FINISHED_CALLBACK = :pointer

    class PaHostApiInfo < FFI::Struct
      layout :struct_version, :int,
             :type, PA_HOST_API_TYPE_ID,
             :name, :string,
             :device_count, :int,
             :default_input_device, PA_DEVICE_INDEX,
             :default_output_device, PA_DEVICE_INDEX
    end
    
    class PaHostErrorInfo < FFI::Struct
      layout :host_api_type, PA_HOST_API_TYPE_ID,
             :error_code, :long,
             :error_text, :string
    end
        
    class PaDeviceInfo < FFI::Struct
      layout :struct_version, :int,
             :name, :string,
             :host_api, PA_HOST_API_INDEX,
             :max_input_channels, :int,
             :max_output_channels, :int,
             :default_low_input_latency, PA_TIME,
             :default_low_output_latency, PA_TIME,
             :default_high_input_latency, PA_TIME,
             :default_high_output_latency, PA_TIME,
             :default_sample_rate, :double
    end
    
    class PaStreamParameters < FFI::Struct
      layout :device, PA_DEVICE_INDEX,
             :channel_count, :int,
             :sample_format, PA_SAMPLE_FORMAT,
             :suggested_latency, PA_TIME,
             :host_specific_stream_info, :pointer
      
      def self.from_options(options)
        params = C::PaStreamParameters.new
        params[:device] = case options[:device]
          when Integer then options[:device]
          when Device  then options[:device].index
        end
        params[:channel_count] = options[:channels]
        params[:sample_format] = C::PA_SAMPLE_FORMAT_MAP[options[:sample_format]]
        params
      end
    end
        
    class PaStreamInfo < FFI::Struct
      layout :struct_version, :int,
             :input_latency, PA_TIME,
             :output_latency, PA_TIME,
             :sample_rate, :double
    end
    
    attach_function :version,       :Pa_GetVersion, [], :int
    attach_function :version_text,  :Pa_GetVersionText, [], :string
    attach_function :error_text,    :Pa_GetErrorText, [PA_ERROR], :string
    attach_function :initialize,    :Pa_Initialize, [], PA_ERROR
    attach_function :terminate,     :Pa_Terminate, [], PA_ERROR
    attach_function :Pa_GetHostApiCount, [], PA_DEVICE_INDEX
    attach_function :Pa_GetDefaultHostApi, [], PA_DEVICE_INDEX
    attach_function :Pa_GetHostApiInfo, [:int], :pointer
    attach_function :Pa_HostApiTypeIdToHostApiIndex, [PA_HOST_API_TYPE_ID], PA_HOST_API_INDEX
    attach_function :Pa_HostApiDeviceIndexToDeviceIndex, [PA_HOST_API_INDEX, :int], PA_DEVICE_INDEX
    attach_function :Pa_GetLastHostErrorInfo, [], PaHostErrorInfo
    attach_function :Pa_GetDeviceCount, [], PA_DEVICE_INDEX
    attach_function :Pa_GetDefaultInputDevice, [], PA_DEVICE_INDEX
    attach_function :Pa_GetDefaultOutputDevice, [], PA_DEVICE_INDEX
    attach_function :Pa_GetDeviceInfo, [PA_DEVICE_INDEX], :pointer
    attach_function :Pa_IsFormatSupported, [:pointer, :pointer, :double], PA_ERROR
    attach_function :Pa_OpenStream, [:pointer, :pointer, :pointer, :double, :ulong, PA_STREAM_FLAGS, PA_STREAM_CALLBACK, :pointer], PA_ERROR
    attach_function :Pa_OpenDefaultStream, [:pointer, :int, :int, PA_SAMPLE_FORMAT, :double, :ulong, PA_STREAM_CALLBACK, :pointer], PA_ERROR
    attach_function :Pa_CloseStream, [:pointer], PA_ERROR
    attach_function :Pa_SetStreamFinishedCallback, [:pointer, :pointer], PA_ERROR
    attach_function :Pa_StartStream, [:pointer], PA_ERROR
    attach_function :Pa_StopStream, [:pointer], PA_ERROR
    attach_function :Pa_AbortStream, [:pointer], PA_ERROR
    attach_function :Pa_IsStreamStopped, [:pointer], PA_ERROR
    attach_function :Pa_IsStreamActive, [:pointer], PA_ERROR
    attach_function :Pa_GetStreamInfo, [:pointer], :pointer
    attach_function :Pa_GetStreamTime, [:pointer], PA_TIME
    attach_function :Pa_GetStreamCpuLoad, [:pointer], :double
    attach_function :Pa_ReadStream, [:pointer, :pointer, :ulong], PA_ERROR
    attach_function :Pa_WriteStream, [:pointer, :pointer, :ulong], PA_ERROR
    attach_function :Pa_GetStreamReadAvailable, [:pointer], :long
    attach_function :Pa_GetStreamWriteAvailable, [:pointer], :long
    attach_function :Pa_GetSampleSize, [:ulong], PA_ERROR
    attach_function :Pa_Sleep, [:long], :void
  end
end