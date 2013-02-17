require 'portaudio'

describe "PortAudio::C" do

  describe "Attached functions" do
    subject { PortAudio::C }

    its(:version) { should be > 0 }
    its(:version_text) { should =~ /\APortAudio V\d+/ }
    
    it "Returns text for error codes" do
      subject.error_text(0).should == "Success"
    end
  end

end