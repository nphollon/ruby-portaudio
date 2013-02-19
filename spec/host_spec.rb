require 'spec_helper'
require 'host'

describe "Host" do
  subject { PortAudio::Host }

  it "should not be initializable" do
    expect { subject.new(1) }.to raise_error(NoMethodError)
  end

  describe "without initialized environment" do
    specify { expect { subject.count }.to raise_error(RuntimeError) }
    specify { expect { subject.default }.to raise_error(RuntimeError) }
  end

  describe "in initialized environment" do
    before do
      $stderr.reopen File::NULL
      PortAudio.invoke(:init)
      $stderr.reopen STDERR
    end

    after do
      PortAudio.invoke(:terminate)
    end

    its(:count) { should be >= 0 }

    describe "default API" do
      subject { PortAudio::Host.default }

      its(:name) { should =~ /.+/ }

      specify "number of devices should match C function call" do
        subject.devices.length.should == PortAudio::C.device_count
      end

      it "should have default output" do
        subject.default_output.class.should == PortAudio::Device
      end

      specify "default output index matches C function call" do
        subject.default_output.index.should == PortAudio::C.default_output_device
      end

      it "should have default input" do
        subject.default_input.class.should == PortAudio::Device
      end

      specify "default input index matches C function call" do
        subject.default_input.index.should == PortAudio::C.default_input_device
      end
    end
  end
end