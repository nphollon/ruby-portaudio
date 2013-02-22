require 'spec_helper'

describe "Device" do
  before { PortAudio.init }
  after { PortAudio.terminate }
  
  subject { PortAudio.default_output_device }

  it "should raise exception when initialized with invalid index" do
    expect { PortAudio::Device.new(-1) }.to raise_error
  end

  it "should allow initialization with a valid index" do
    expect { PortAudio::Device.new(0) }.not_to raise_error
  end

  its(:name) { should =~ /.+/ }
  its(:max_input_channels) { should be >= 0 }
  its(:max_output_channels) { should be >= 0 }
  its(:default_sample_rate) { should be > 0 }
  its(:default_low_input_latency) { should be >= -1 }
  its(:default_low_output_latency) { should be >= -1 }
  its(:default_high_input_latency) { should be >= -1 }
  its(:default_high_output_latency) { should be >= -1 }
  
  describe "format support" do
    it "should support some audio formats" do
      subject.format_supported?(channels: 1, sample_format: :uint8, sample_rate: 44100, input: false).should be_true
    end

    it "should return false if format is not supported" do
      subject.format_supported?(channels: 1, sample_format: :uint8, sample_rate: 100, input: false).should be_false
    end

    it "should assume defaults if not all options are specified" do
      subject.format_supported?.should be_true
    end

    it "checks for input support if asked" do
      PortAudio.default_input_device.format_supported?(input: true).should be_true
    end

    specify "output-only devices do not support input formats" do
      PortAudio::Device.new(1).format_supported?(input:true).should be_false
    end
  end
end