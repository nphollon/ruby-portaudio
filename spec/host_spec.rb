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

      it "should have default output" do
        subject.default_output.class.should == PortAudio::Device
      end

      specify "default output is included in devices" do
        subject.devices.should include(subject.default_output)
      end

      it "should have default input" do
        subject.default_input.class.should == PortAudio::Device
      end

      specify "default input is included in devices" do
        subject.devices.should include(subject.default_input)
      end
    end
  end
end