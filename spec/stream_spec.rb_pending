require 'spec_helper'

describe "Stream" do
  before { PortAudio.init }
  after { PortAudio.terminate }

  describe "while open" do
    before { @stream = PortAudio::default_output_device.open_stream }
    after { @stream.close }

    subject { @stream }

    its(:stopped?) { should be_true }
    its(:active?) { should be_false }
    its(:time) { should be >= 0 }
    its(:cpu_load) { should be >= 0 }

    describe "after started" do
      before { subject.start }
      its(:stopped?) { should be_false }
      its(:active?) { should be_true }

      describe "after stopped" do
        before { subject.stop }
        its(:stopped?) { should be_true }
        its(:active?) { should be_false }
      end

      describe "after abort" do
        before { subject.abort }
        its(:stopped?) { should be_true }
        its(:active?) { should be_false }
      end

      specify "read not implemented" do
        expect { subject.read }.to raise_error(NotImplementedError)
      end
    end
  end
end