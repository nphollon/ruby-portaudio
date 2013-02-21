require 'spec_helper'

describe "SampleBuffer" do
  it "can be initialized with no options" do
    PortAudio::SampleBuffer.new
  end
end