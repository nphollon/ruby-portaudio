require 'spec_helper'
require_relative '../portaudio'

describe "PortAudio" do
	subject { PortAudio }

  its(:version) { should == 1899 }
  its(:version_text) { should == "PortAudio V19-devel (built Oct  8 2012 16:25:16)" }
  it { should respond_to(:sleep).with(1) }

  describe "sample_size" do
    it "returns 4 for :float32" do
      subject.sample_size(:float32).should == 4
    end

    it "returns 4 for :int32" do
      subject.sample_size(:int32).should == 4
    end

    it "returns 3 for :int24" do
      subject.sample_size(:int24).should == 3
    end

    it "returns 2 for :int16" do
      subject.sample_size(:int16).should == 2
    end

    it "returns 1 for :int8" do
      subject.sample_size(:int8).should == 1
    end

    it "returns 1 for :uint8" do
      subject.sample_size(:uint8).should == 1
    end

    it "returns nil otherwise" do
      subject.sample_size(:custom).should be_nil
    end
  end

  context "before PortAudio is initialized" do
    specify "terminate should raise error" do
      expect { PortAudio.terminate }.to raise_error(IOError, "PortAudio not initialized")
    end
  end

  context "after PortAudio is initialized" do
    before (:all) { PortAudio.init }
    after (:all) { PortAudio.terminate }

    describe "terminate" do
      it "should not raise error if init called first" do
        expect { PortAudio.terminate }.not_to raise_error
        PortAudio.init
      end
    end

  end
end