require 'spec_helper'
require_relative '../portaudio'

describe "Device" do
  context "class" do
    subject { PortAudio::Device }

    describe "count" do
      its (:count) { should == PortAudio::Host.default_api.device_count }
    end

    describe "find_by_id" do
      it "gives a range error if index is negative" do
        expect { subject.find_by_id(-1) }.to raise_error(RangeError, "Device index out of range")
      end

      it "gives a range error if index is larger than number of devices" do
        expect { subject.find_by_id(12) }.to raise_error(RangeError, "Device index out of range")
      end

      it "returns a device" do
        subject.find_by_id(0).should be_kind_of(PortAudio::Device)
      end
    end

    describe "default_output_device" do
      subject { PortAudio::Device.default_output_device }

      its (:name) { should == "default" }
      its (:default_sample_rate) { should be_within(1e-6).of(44100) }
      its (:max_input_channels) { should == 128 }
      its (:max_output_channels) { should == 128 }
      its (:default_low_input_latency) { should be_within(1e-6).of(0.042653) }
      its (:default_low_output_latency) { should be_within(1e-6).of(0.042653) }
      its (:default_high_input_latency) { should be_within(1e-6).of(0.046440) }
      its (:default_high_output_latency) { should be_within(1e-6).of(0.046440) }
      its (:host_api) { should == PortAudio::Host.default_api }
    end

    describe "default_input_device" do
      it "should be the same as default output device" do
        PortAudio::Device.default_input_device.should == PortAudio::Device.default_output_device
      end
    end

    describe "new" do
      it "should be private" do
        expect { subject.new }.to raise_error(NoMethodError)
      end
    end

    describe "all" do
      subject { PortAudio::Device.all }

      its (:length) { should == PortAudio::Device.count }

      it "should contain all devices" do
        (0...PortAudio::Device.count).each do |i|
          subject[i].should == PortAudio::Device.find_by_id(i)
        end
      end
    end
  end


  context "instance" do
    subject { PortAudio::Device.send :new }

    its (:name) { should == "" }
    its (:max_input_channels) { should == 0 }
    its (:max_output_channels) { should == 0 }
    its (:default_low_input_latency) { should == 0 }
    its (:default_low_output_latency) { should == 0 }
    its (:default_high_input_latency) { should == 0 }
    its (:default_high_output_latency) { should == 0 }
    its (:default_sample_rate) { should == 0 }
    its (:host_api_id) { should == -1 }
    its (:host_api) { should be_nil }

    describe "open_stream" do
      let(:device) { PortAudio::Device.default_output_device }
      subject { PortAudio::Stream }

      it "should call open" do
        subject.should_receive(:new).with(device.id, 1, 1, 44100, 0, 1, 1, 0, 0).and_call_original
        device.open_stream
      end

      it "has a channels option" do
        subject.should_receive(:new).with(device.id, 2, 1, 44100, 0, 1, 1, 0, 0)
        device.open_stream(channels: 2)
      end

      describe "format option" do
        specify ":float32 => 1" do
          subject.should_receive(:new).with(device.id, 1, 1, 44100, 0, 1, 1, 0, 0)
          device.open_stream(format: :float32)
        end

        specify ":int32 => 2" do
          subject.should_receive(:new).with(device.id, 1, 2, 44100, 0, 1, 1, 0, 0)
          device.open_stream(format: :int32)
        end
        
        specify ":int24 => 4" do
          subject.should_receive(:new).with(device.id, 1, 4, 44100, 0, 1, 1, 0, 0)
          device.open_stream(format: :int24)
        end

        specify ":int16 => 8" do
          subject.should_receive(:new).with(device.id, 1, 8, 44100, 0, 1, 1, 0, 0)
          device.open_stream(format: :int16)
        end

        specify ":int8 => 16" do
          subject.should_receive(:new).with(device.id, 1, 16, 44100, 0, 1, 1, 0, 0)
          device.open_stream(format: :int8)
        end

        specify ":uint8 => 32" do
          subject.should_receive(:new).with(device.id, 1, 32, 44100, 0, 1, 1, 0, 0)
          device.open_stream(format: :uint8)
        end

        specify "other formats raise exception" do
          expect { device.open_stream(format: :custom) }.to raise_error(TypeError)
        end
      end

      it "has a sample_rate option" do
        subject.should_receive(:new).with(device.id, 1, 1, 8000, 0, 1, 1, 0, 0)
        device.open_stream(sample_rate: 8000)
      end    

      it "has a frames_per_buffer option" do
        subject.should_receive(:new).with(device.id, 1, 1, 44100, 256, 1, 1, 0, 0)
        device.open_stream(frames_per_buffer: 256)
      end

      it "has a clipping option" do
        subject.should_receive(:new).with(device.id, 1, 1, 44100, 0, 0, 1, 0, 0)
        device.open_stream(clipping: false)
      end

      it "has a dithering option" do
        subject.should_receive(:new).with(device.id, 1, 1, 44100, 0, 1, 0, 0, 0)
        device.open_stream(dithering: false)
      end

      it "has a output_priming option" do
        subject.should_receive(:new).with(device.id, 1, 1, 44100, 0, 1, 1, 1, 0)
        device.open_stream(output_priming: true)
      end

      it "has a suggested_latency option" do
        subject.should_receive(:new).with(device.id, 1, 1, 44100, 0, 1, 1, 0, 0.5)
        device.open_stream(suggested_latency: 0.5)
      end
    end

    describe "supports_format?" do
      subject { PortAudio::Device.default_output_device }

      it "supports default params" do
        subject.supports_format?.should be_true
      end

      it "support output format that matches device parameters" do
        params = { channels: 1, format: :float32, sample_rate: 44100 }
        subject.supports_format?(params).should be_true
      end

      it "does not support channels > max_output_channels" do
        subject.supports_format?(channels: 129).should be_false
      end

      it "does not support arbitrary sample rates" do
        subject.supports_format?(sample_rate: 1234567890).should be_false
      end
    end

    describe "id" do
      it "should be the index of the device in Device.all" do
        devices = PortAudio::Device.all
        (0...PortAudio::Device.count).each do |i|
          devices[i].id.should == i
        end
      end
    end

    describe "name=" do
      it "should be private" do
        expect { subject.name = "name" }.to raise_error(NoMethodError)
      end
    end

    describe "max_input_channels=" do
      it "should be private" do
        expect { subject.max_input_channels = 1 }.to raise_error(NoMethodError)
      end
    end

    describe "max_output_channels=" do
      it "should be private" do
        expect { subject.max_output_channels = 1 }.to raise_error(NoMethodError)
      end
    end

    describe "default_low_input_latency=" do
      it "should be private" do
        expect { subject.default_low_input_latency = 100 }.to raise_error(NoMethodError)
      end
    end

    describe "default_low_output_latency=" do
      it "should be private" do
        expect { subject.default_low_output_latency = 100 }.to raise_error(NoMethodError)
      end
    end

    describe "default_high_input_latency=" do
      it "should be private" do
        expect { subject.default_high_input_latency = 100 }.to raise_error(NoMethodError)
      end
    end

    describe "default_high_output_latency=" do
      it "should be private" do
        expect { subject.default_high_output_latency = 100 }.to raise_error(NoMethodError)
      end
    end

    describe "default_sample_rate=" do
      it "should be private" do
        expect { subject.default_sample_rate = 44100 }.to raise_error(NoMethodError)
      end
    end

    describe "host_api_index=" do
      it "should be private" do
        expect { subject.host_api_id = 1 }.to raise_error(NoMethodError)
      end

      it "should set host_api to #0 when set to 0" do
        subject.send :host_api_id=, 0
        subject.host_api.should == PortAudio::Host.find_by_id(0)
      end

      it "should set host_api to #1 when set to 1" do
        subject.send :host_api_id=, 1
        subject.host_api.should == PortAudio::Host.find_by_id(1)
      end
    end

    describe "==" do
      let (:other_device) { PortAudio::Device.send :new }

      it { should == other_device }
      it { should_not == "string" }

      specify "names must be equal" do
        other_device.send(:name=, "name")
        subject.should_not == other_device
      end

      specify "max_input_channels must be equal" do
        other_device.send(:max_input_channels=, 1)
        subject.should_not == other_device
      end

      specify "max_output_channels must be equal" do
        other_device.send(:max_output_channels=, 1)
        subject.should_not == other_device
      end

      specify "default_low_input_latency must be equal" do
        other_device.send(:default_low_input_latency=, 100)
        subject.should_not == other_device
      end

      specify "default_low_output_latency must be equal" do
        other_device.send(:default_low_output_latency=, 100)
        subject.should_not == other_device
      end

      specify "default_high_input_latency must be equal" do
        other_device.send(:default_high_input_latency=, 100)
        subject.should_not == other_device
      end

      specify "default_high_output_latency must be equal" do
        other_device.send(:default_high_output_latency=, 100)
        subject.should_not == other_device
      end

      specify "default sample rate must be equal" do
        other_device.send(:default_sample_rate=, 44100)
        subject.should_not == other_device
      end

      specify "host api must be equal" do
        other_device.send(:host_api_id=, 1)
        subject.should_not == other_device
      end
    end
  end
end