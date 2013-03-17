require 'spec_helper'
require_relative '../portaudio'

describe "Host" do

  context "class" do
    subject { PortAudio::Host }
    
    describe "count" do
      specify "should raise initialization error" do
        expect { PortAudio::Host.count }.to_not raise_error(IOError, "PortAudio not initialized")
      end

      its (:count) { should == 2 }
    end

    describe "default_api" do
      subject { PortAudio::Host.default_api }

      its (:name) { should =~ /.+/ }
      its (:device_count) { should be > 0 }
      its (:type) { should == :alsa }
      its (:default_output_device) { should == PortAudio.default_output_device }
      its (:default_input_device) { should == PortAudio.default_input_device }
    end

    describe "host_api" do
      specify "should not raise initialization error" do
        expect { subject.find_by_index(1) }.to_not raise_error(IOError, "PortAudio not initialized")
      end

      it "should return default api if index is 0" do
        subject.find_by_index(0).should == PortAudio::Host.default_api
      end

      describe "host_api(1)" do
        subject { PortAudio::Host.find_by_index(1) }

        its (:name) { should == "OSS" }
        its (:type) { should == :oss }
        its (:device_count) { should == 0 }
      end

      it "should raise error if api index is out of range" do
        expect { subject.find_by_index(2) }.to raise_error(IOError, "Host API index out of range")
      end

      it "should raise error if api index is negative" do
        expect { subject.find_by_index(-1) }.to raise_error(IOError, "Host API index out of range")
      end
    end

    describe "find_by_type_id" do
      specify "should not raise initialization error" do
        expect { subject.find_by_type_id(8) }.to_not raise_error(IOError, "PortAudio not initialized")
      end

      it "returns default host if type id is 8" do
        subject.find_by_type_id(8).should == PortAudio::Host.default_api
      end

      it "returns oss host if type id is 7" do
        subject.find_by_type_id(7).should == PortAudio::Host.find_by_index(1)
      end

      it "raises error otherwise" do
        expect { subject.find_by_type_id(1) }.to raise_error(IOError, "Host API not found")
      end
    end
  end


  context "instance" do
    subject { PortAudio::Host.new }

    its(:name) { should == "" }
    its(:device_count) { should == 0 }
    its(:type) { should == :in_development }
    its(:default_output_device) { should be_nil }
    its(:default_input_device) { should be_nil }

    describe "type_id=" do
      it "should be a private method" do
        expect { subject.type_id = 1 }.to raise_error(NoMethodError)
      end

      specify "1 == Direct Sound" do
        subject.send(:type_id=, 1)
        subject.type.should == :direct_sound
      end

      specify "2 == MME" do
        subject.send(:type_id=, 2)
        subject.type.should == :mme
      end

      specify "3 == ASIO" do
        subject.send(:type_id=, 3)
        subject.type.should == :asio
      end

      specify "4 == Sound Manager" do
        subject.send(:type_id=, 4)
        subject.type.should == :sound_manager
      end

      specify "5 == Core Audio" do
        subject.send(:type_id=, 5)
        subject.type.should == :core_audio
      end

      specify "6 == in development" do
        subject.send(:type_id=, 6)
        subject.type.should == :in_development
      end

      specify "7 == OSS" do
        subject.send(:type_id=, 7)
        subject.type.should == :oss
      end

      specify "8 == ALSA" do
        subject.send(:type_id=, 8)
        subject.type.should == :alsa
      end

      specify "9 == AL" do
        subject.send(:type_id=, 9)
        subject.type.should == :al
      end

      specify "10 == BeOS" do
        subject.send(:type_id=, 10)
        subject.type.should == :be_os
      end

      specify "11 == WDMKS" do
        subject.send(:type_id=, 11)
        subject.type.should == :wdmks
      end

      specify "12 == JACK" do
        subject.send(:type_id=, 12)
        subject.type.should == :jack
      end

      specify "13 == WASAPI" do
        subject.send(:type_id=, 13)
        subject.type.should == :wasapi
      end

      specify "14 == Audio Science HPI" do
        subject.send(:type_id=, 14)
        subject.type.should == :audio_science_hpi
      end

      specify "anything else == in development" do
        subject.send(:type_id=, 1000)
        subject.type.should == :in_development
      end
    end

    describe "name=" do
      it "should be private" do
        expect { subject.name = "name" }.to raise_error(NoMethodError)
      end
    end

    describe "device_count=" do
      it "should be private" do
        expect { subject.device_count = 1 }.to raise_error(NoMethodError)
      end
    end

    describe "==" do
      it { should_not == "string" }
      it { should == PortAudio::Host.new }

      it "requires that type ids be equal" do
        other_host = PortAudio::Host.new
        other_host.send(:type_id=, 1)
        subject.should_not == other_host
      end

      it "requires that names be equal" do
        other_host = PortAudio::Host.new
        other_host.send(:name=, "name")
        subject.should_not == other_host
      end

      it "requires that device_counts be equal" do
        other_host = PortAudio::Host.new
        other_host.send(:device_count=, 5)
        subject.should_not == other_host
      end
    end
  end
end