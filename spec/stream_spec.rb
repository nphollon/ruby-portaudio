require 'spec_helper'

describe "Stream" do
  before do
    $stderr.reopen File::NULL
    PortAudio.invoke(:init)
    $stderr.reopen STDERR
  end

  after do
    PortAudio.invoke(:terminate)
  end

  describe "check format support" do
    # TODO: Move format support from stream to device
    specify "supported format" do
      options = { device: 10, channels: 2, sample_format: :int8 }
      PortAudio::Stream.format_supported?({input: options, sample_rate: 44100}).should be_true
    end

    specify "unsupported format" do
      options = { device: 10, channels: 130, sample_format: :int8 }
      PortAudio::Stream.format_supported?({output: options, sample_rate: 44100}).should be_false
    end
  end

  describe "while open" do
    before do
      options = {
        output: { device: 10, channels: 2, sample_format: :int8 },
        sample_rate: 44100
      }
      @stream = PortAudio::Stream.open(options)
    end

    after do
      @stream.close
    end

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