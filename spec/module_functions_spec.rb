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

	it "delegates sleep to C module" do
		subject::C.should_receive(:sleep).with(5)
		subject.sleep(5)
	end
	
	describe "invoke" do
		it "should return normally if nothing is wrong" do
			$stderr.reopen(File::NULL)
			expect { subject.invoke(:init) }.to_not raise_error(RuntimeError)
			subject.invoke(:terminate)
			$stderr.reopen(STDERR)
		end

		it "should raise_exception if something exceptional happens" do
			expect { subject.invoke(:terminate) }.to raise_error(RuntimeError)
		end
	end
end