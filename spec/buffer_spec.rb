require 'spec_helper'

describe "SampleBuffer" do
  before { PortAudio.init }
  after { PortAudio.terminate }
  subject { PortAudio::SampleBuffer.new }
end