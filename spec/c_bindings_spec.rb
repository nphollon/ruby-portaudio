require 'portaudio'

describe "PortAudio::C" do

  describe "Attached functions" do
    let (:c_module) { PortAudio::C }
    subject { c_module }

    its(:version) { should be > 0 }
    its(:version_text) { should =~ /\APortAudio V\d+/ }

    describe "Error Codes" do
      it "has error code 0 if no error is raised" do
        subject.error_text(0).should == "Success"
      end

      it "has error code -10000 if environment not initialized" do
        subject.error_text(-10000).should == "PortAudio not initialized"
      end
    end

    its(:terminate) { should == -10000 }
    it { should respond_to(:host_api_info) }
    it { should respond_to(:host_api_type_id_to_host_api_index) }
    it { should respond_to(:host_api_device_index_to_device_index) }
    it { should respond_to(:last_host_error_info) }
    it { should respond_to(:device_count) }
    it { should respond_to(:default_input_device) }
    it { should respond_to(:default_output_device) }
    it { should respond_to(:device_info) }
    it { should respond_to(:is_format_supported) }
    it { should respond_to(:sleep) }

    describe "Streaming" do
      # Add more tests once I figure out how the Stream object works
    end

    it "returns sample size" do
      subject.sample_size(subject::PA_SAMPLE_FORMAT_MAP[:int32]).should == 4
    end

    describe "Initialized PortAudio" do
      before do
        $stderr.reopen(File::NULL)
        @error = c_module.initialize
      end

      after do
        $stderr.reopen(STDERR)
        c_module.terminate
      end

      it "should initialize successfully" do
        @error.should == 0
      end

      its(:host_api_count) { should be >= 0 }
      its(:default_host_api) { should be >= 0 }
    end
  end
end