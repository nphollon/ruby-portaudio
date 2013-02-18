require 'spec_helper'
require 'portaudio'

describe "PortAudio" do
	subject { PortAudio }

	it "delegates version to C module" do
		subject.version.should == subject::C.version
	end

	it "delegates version_text to C module" do
		subject.version_text.should == subject::C.version_text
	end

	it "delegates error_text to C module" do
		subject.error_text(0).should == subject::C.error_text(0)
	end

	it "delegates initialize to C module" do
		subject::C.should_receive(:initialize)
		subject.initialize
	end

	it "delegates terminate to C module" do
		subject::C.should_receive(:terminate)
		subject.terminate
	end

	it "delegates sleep to C module" do
		subject::C.should_receive(:sleep).with(5)
		subject.sleep(5)
	end
end