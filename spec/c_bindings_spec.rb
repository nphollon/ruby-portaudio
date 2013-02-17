require 'portaudio'

describe "PortAudio::C" do

  describe "Attached functions" do
    subject { PortAudio::C }

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

    it "should initialize successfully" do
      $stderr.reopen(File::NULL)
      subject.initialize.should == 0
      $stderr.reopen(STDERR)
    end

    it "should terminate successfully" do
      subject.terminate.should == 0
    end
  end

end