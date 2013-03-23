require 'spec_helper'
require_relative '../portaudio'

describe "Stream" do
  let(:device) { PortAudio::Device.default_output_device }

  describe "write" do
    it "does not support int24 format" do
      expect do
        device.open_stream(frames_per_buffer: 1, format: :int24).write {}
      end.to raise_error(NotImplementedError, "int24 format not yet supported")
    end

    it "supports float32" do
      mock = double(call: true)
      mock.should_receive(:call)
      stream = device.open_stream(frames_per_buffer: 1)
      stream.start
      stream.write do
        mock.call
        0
      end
    end

    it "supports int32" do
      mock = double(call: true)
      mock.should_receive(:call)
      stream = device.open_stream(format: :int32, frames_per_buffer: 1)
      stream.start
      stream.write do
        mock.call
        0
      end
    end

    it "supports int16" do
      mock = double(call: true)
      mock.should_receive(:call)
      stream = device.open_stream(format: :int16, frames_per_buffer: 1)
      stream.start
      stream.write do
        mock.call
        0
      end
    end

    it "supports int8" do
      mock = double(call: true)
      mock.should_receive(:call)
      stream = device.open_stream(format: :int8, frames_per_buffer: 1)
      stream.start
      stream.write do
        mock.call
        0
      end
    end

    it "supports uint8" do
      mock = double(call: true)
      mock.should_receive(:call)
      stream = device.open_stream(format: :uint8, frames_per_buffer: 1)
      stream.start
      stream.write do
        mock.call
        0
      end
    end

    it "yields nothing to block" do
      stream = device.open_stream(frames_per_buffer: 1)
      stream.start
      stream.write do |t|
        t.should be_nil
        0
      end
    end

    it "yields multiple times based on number of frames and channels" do
      t = 0
      stream = device.open_stream(frames_per_buffer: 5, channels: 3)
      stream.start
      stream.write do
        t += 1
      end
      t.should == 15
    end
  end

  describe "stopped?" do
    let(:stream) { device.open_stream }
    subject { stream }

    it { should be_stopped }

    it "is not stopped if start has been successfully called" do
      stream.start
      stream.should_not be_stopped
      stream.stop
    end

    it "is stopped if stop has been successfully called" do
      stream.start
      stream.stop
      stream.should be_stopped
    end

    it "is stopped if stop! has been successfully called" do
      stream.start
      stream.stop!
      stream.should be_stopped
    end
  end

  describe "active?" do
    let(:stream) { device.open_stream }
    subject { stream }

    it { should_not be_active }

    it "is active if start has been successfully called" do
      stream.start
      stream.should be_active
      stream.stop
    end

    it "is not active if stop has been successfully called" do
      stream.start
      stream.stop
      stream.should_not be_active
    end

    it "is not active if stop! has been successfully called" do
      stream.start
      stream.stop!
      stream.should_not be_active
    end
  end

  describe "buffer" do
    it "should be initialized to 0s" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 256, 1, 1, 1, 0, 0)
      stream.buffer.each do |f|
        f.should be_within(1e-6).of(0)
      end
    end

    it "should have a length determined by channels and frames_per_buffer" do
      stream = PortAudio::Stream.new(device.id, 2, 1, 44100, 256, 1, 1, 1, 0, 0)
      stream.buffer.length.should == 512
    end

    describe "filling the buffer" do
      specify "float32" do
        stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 10, 1, 1, 1, 0, 0)
        i = -1
        stream.start
        stream.write do
          i += 1
          i * 0.1
        end
        stream.stop
        i = -1
        stream.buffer.each do |f|
          i += 1
          f.should be_within(1e-6).of(0.1*i)
        end
      end

      specify "int32" do
        stream = PortAudio::Stream.new(device.id, 1, 2, 44100, 10, 1, 1, 1, 0, 0)
        i = -1
        stream.start
        stream.write do
          i += 1
        end
        stream.stop
        i = -1
        stream.buffer.each do |f|
          i += 1
          f.should be_within(1e-6).of(i)
        end
      end

      specify "int16" do
        stream = PortAudio::Stream.new(device.id, 1, 8, 44100, 10, 1, 1, 1, 0, 0)
        i = -1
        stream.start
        stream.write do
          i += 1
        end
        stream.stop
        i = -1
        stream.buffer.each do |f|
          i += 1
          f.should be_within(1e-6).of(i)
        end
      end

      specify "int8" do
        stream = PortAudio::Stream.new(device.id, 1, 16, 44100, 10, 1, 1, 1, 0, 0)
        i = -1
        stream.start
        stream.write do
          i += 1
        end
        stream.stop
        i = -1
        stream.buffer.each do |f|
          i += 1
          f.should be_within(1e-6).of(i)
        end
      end

      specify "uint8" do
        stream = PortAudio::Stream.new(device.id, 1, 32, 44100, 10, 1, 1, 1, 0, 0)
        i = -1
        stream.start
        stream.write do
          i += 1
        end
        stream.stop
        i = -1
        stream.buffer.each do |f|
          i += 1
          f.should be_within(1e-6).of(i)
        end
      end
    end
  end

  describe "device" do
    it "should be device x if stream was opened with device ID x" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 1, 1, 0, 0)
      stream.device.should == device
    end
  end

  describe "channel_count" do
    it "should equal 'channel_count' parameter to open" do
      (1...127).each do |i|
        stream = PortAudio::Stream.new(device.id, i, 1, 44100, 0, 1, 1, 1, 0, 0)
        stream.channel_count.should == i
      end
    end
  end

  describe "format" do
    it "should be float32 if 'format' parameter is 1" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 1, 1, 0, 0)
      stream.format.should == :float32
    end

    it "should be int32 if 'format' parameter is 2" do
      stream = PortAudio::Stream.new(device.id, 1, 2, 44100, 0, 1, 1, 1, 0, 0)
      stream.format.should == :int32
    end

    it "should be int24 if 'format' parameter is 4" do
      stream = PortAudio::Stream.new(device.id, 1, 4, 44100, 0, 1, 1, 1, 0, 0)
      stream.format.should == :int24
    end

    it "should be int16 if 'format' parameter is 8" do
      stream = PortAudio::Stream.new(device.id, 1, 8, 44100, 0, 1, 1, 1, 0, 0)
      stream.format.should == :int16
    end

    it "should be int8 if 'format' parameter is 16" do
      stream = PortAudio::Stream.new(device.id, 1, 16, 44100, 0, 1, 1, 1, 0, 0)
      stream.format.should == :int8
    end

    it "should be uint8 if 'format' parameter is 32" do
      stream = PortAudio::Stream.new(device.id, 1, 32, 44100, 0, 1, 1, 1, 0, 0)
      stream.format.should == :uint8
    end

    it "should raise error if 'format' is anything else" do
      expect { PortAudio::Stream.new(device.id, 1, 0, 44100, 0, 1, 1, 1, 0, 0) }.to raise_error(IOError)
    end
  end

  describe "sample_rate" do
    it "should equal sample_rate parameter to open" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 1, 1, 0, 0)
      stream.sample_rate.should be_within(1e-6).of(44100)
    end
  end

  describe "frames_per_buffer" do
    it "should equal 'frames_per_buffer' parameter to open" do
      (1...127).each do |i|
        stream = PortAudio::Stream.new(device.id, 1, 1, 44100, i, 1, 1, 1, 0, 0)
        stream.frames_per_buffer.should == i
      end
    end 
  end

  describe "clipping" do
    it "should be true if 'clipping' parameter is 1" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 1, 1, 0, 0)
      stream.clipping.should be_true
    end

    it "should be false if 'clipping' parameter is 0" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 0, 1, 1, 0, 0)
      stream.clipping.should be_false
    end
  end

  describe "dithering" do
    it "should be true if 'dithering' parameter is 1" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 1, 1, 0, 0)
      stream.dithering.should be_true
    end

    it "should be false if 'dithering' parameter is 0" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 0, 1, 0, 0)
      stream.dithering.should be_false
    end
  end

  describe "output_priming" do
    it "should be true if 'output_priming' parameter is 1" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 1, 1, 0, 0)
      stream.output_priming.should be_true
    end

    it "should be false if 'output_priming' parameter is 0" do
      stream = PortAudio::Stream.new(device.id, 1, 1, 44100, 0, 1, 1, 0, 0, 0)
      stream.output_priming.should be_false
    end
  end

  describe "latency" do
    it "should be device default_low_output_latency by default" do
      stream = device.open_stream
      stream.latency.should be_within(1e-6).of(device.default_low_output_latency)
    end

    it "should be close to suggested_latency" do
      stream = device.open_stream(suggested_latency: 0.07)
      stream.latency.should be_within(1e-2).of(0.07)
    end

    it "should be device default_low_output_latency if suggested_latency is too low" do
      stream = device.open_stream(suggested_latency: 0.01)
      stream.latency.should be_within(1e-6).of(device.default_low_output_latency)
    end
  end

  describe "flags_encoded" do
    it "should be 0 by default" do
      stream = device.open_stream
      stream.flags_encoded.should == 0
    end

    it "should be 1 if no clipping" do
      stream = device.open_stream(clipping: false)
      stream.flags_encoded.should == 1
    end

    it "should be 2 if no dithering" do
      stream = device.open_stream(dithering: false)
      stream.flags_encoded.should == 2
    end

    it "should be 3 if no clipping and no dithering" do
      stream = device.open_stream(clipping: false, dithering: false)
      stream.flags_encoded.should == 3
    end

    it "should be 8 if output_priming" do
      stream = device.open_stream(output_priming: true)
      stream.flags_encoded.should == 8
    end

    it "should be 9 if output_priming and no clipping" do
      stream = device.open_stream(clipping: false, output_priming: true)
      stream.flags_encoded.should == 9
    end

    it "should be 10 if output_priming and no dithering" do
      stream = device.open_stream(dithering: false, output_priming: true)
      stream.flags_encoded.should == 10
    end

    it "should be 11 if output_priming and no clipping and no dithering" do
      stream = device.open_stream(clipping: false, dithering: false, output_priming: true)
      stream.flags_encoded.should == 11
    end
  end
end