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

  describe "each" do
    subject { PortAudio::SampleBuffer.new(format: :float32, frames: 10, channels: 2) }

    before do
      subject.fill do |f, c|
        f*10 + c
      end
    end

    it "should accept a block" do
      STDOUT.should_receive(:puts).with(0).exactly(20).times
      subject.each do
        puts 0
      end
    end

    it "should pass frame number, channel number, and sample to block" do
      subject.each do |f,c,s|
        s.should == f*10 + c
      end
    end
  end
end