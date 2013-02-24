require 'spec_helper'

describe "SampleBuffer" do
  before { PortAudio.init }
  after { PortAudio.terminate }
  
  describe "format support" do
    it "should allow uint8" do
      buffer = PortAudio::SampleBuffer.new(format: :uint8, frames: 1)
      buffer.fill do |f,c|
        5
      end
      buffer[0,0] += 1
      buffer[0,0].should == 6
    end

    it "should allow int8" do
      buffer = PortAudio::SampleBuffer.new(format: :int8, frames: 1)
      buffer.fill do |f,c|
        5
      end
      buffer[0,0] += 1
      buffer[0,0].should == 6
    end

    it "should allow int16" do
      buffer = PortAudio::SampleBuffer.new(format: :int16, frames: 1)
      buffer.fill do |f,c|
        5
      end
      buffer[0,0] += 1
      buffer[0,0].should == 6
    end

    it "should not allow int24" do
      buffer = PortAudio::SampleBuffer.new(format: :int24, frames: 1)
      expect { buffer[0,0] = 1 }.to raise_error
    end

    it "should allow int32" do
      buffer = PortAudio::SampleBuffer.new(format: :int32, frames: 1)
      buffer.fill do |f,c|
        5
      end
      buffer[0,0] += 1
      buffer[0,0].should == 6
    end
  end
end