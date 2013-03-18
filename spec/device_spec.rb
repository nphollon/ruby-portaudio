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

      describe "find_by_id(0)" do
        subject { PortAudio::Device.find_by_id(0) }

        its (:name) { should == "HDA Intel PCH: STAC92xx Analog (hw:0,0)" }
        its (:default_sample_rate) { should be_within(1e-6).of(44100) }
        its (:max_input_channels) { should == 2 }
        its (:max_output_channels) { should == 2 }
        its (:default_low_input_latency) { should be_within(1e-6).of(0.011610) }
        its (:default_low_output_latency) { should be_within(1e-6).of(0.011610) }
        its (:default_high_input_latency) { should be_within(1e-6).of(0.046440) }
        its (:default_high_output_latency) { should be_within(1e-6).of(0.046440) }
        its (:host_api) { should == PortAudio::Host.default_api }
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