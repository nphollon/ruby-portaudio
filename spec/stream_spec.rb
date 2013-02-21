require 'spec_helper'

describe "Stream" do
  before do
    $stderr.reopen File::NULL
    PortAudio.invoke(:init)
    $stderr.reopen STDERR
  end

  after do
    PortAudio.invoke(:terminate)
  end

  describe "check format support" do
    # TODO: Move format support from stream to device
    specify "supported format" do
      options = { device: 10, channels: 2, sample_format: :int8 }
      PortAudio::Stream.format_supported?({input: options, sample_rate: 44100}).should be_true
    end

    specify "unsupported format" do
      options = { device: 10, channels: 130, sample_format: :int8 }
      PortAudio::Stream.format_supported?({output: options, sample_rate: 44100}).should be_false
    end
  end
end