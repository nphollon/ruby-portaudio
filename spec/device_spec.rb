require 'spec_helper'
require 'device'

describe "Device" do
  before do
    $stderr.reopen File::NULL
    PortAudio.invoke(:init)
    $stderr.reopen STDERR
  end

  subject { PortAudio::Device.new(0) }

  after do
    PortAudio.invoke(:terminate)
  end

  it "should raise exception when initialized with invalid index" do
    expect { PortAudio::Device.new(-1) }.to raise_error
  end

  its(:name) { should =~ /.+/ }
  its(:max_input_channels) { should be >= 0}
  its(:max_output_channels) { should be >= 0 }
  its(:default_low_input_latency) { should be >= 0 }
  its(:default_low_output_latency) { should be >= 0 }
  its(:default_high_input_latency) { should be >= 0 }
  its(:default_high_output_latency) { should be >= 0 }
  its(:default_sample_rate) { should be >= 0 }
end