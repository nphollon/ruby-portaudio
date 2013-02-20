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

	describe "sample size" do
		it "returns sample size for valid arguments" do
			subject.sample_size(:int32).should == 4
		end

		it "raises exception for invalid arguments" do
			expect { subject.sample_size(-1) }.to raise_error(TypeError)
		end
	end
	
	describe "Device" do
	  before do
	    $stderr.reopen File::NULL
	    PortAudio.invoke(:init)
	    $stderr.reopen STDERR
	  end

	  subject { PortAudio.device(0) }

	  after do
	    PortAudio.invoke(:terminate)
	  end

	  it "should raise exception when initialized with invalid index" do
	    expect { PortAudio.device(-1) }.to raise_error
	  end

	  it { should have_key(:name) }
	  it { should have_key(:max_input_channels) }
	  it { should have_key(:max_output_channels) }
	  it { should have_key(:default_sample_rate) }
	  it { should have_key(:default_low_input_latency) }
	  it { should have_key(:default_low_output_latency) }
	  it { should have_key(:default_high_input_latency) }
	  it { should have_key(:default_high_output_latency) }

	end

	describe "Host" do

	  describe "without initialized environment" do
	    specify { expect { PortAudio.host_count }.to raise_error(RuntimeError) }
	    specify { expect { PortAudio.default_host }.to raise_error(RuntimeError) }
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

	    specify { PortAudio.host_count.should be >= 0 }

	    describe "default API" do
	      subject { PortAudio.default_host }

	      it "Should have a name" do
	        subject[:name].should =~ /.+/
	      end

	      specify "number of devices should match C function call" do
	        subject[:devices].length.should == PortAudio::C.device_count
	      end

	      specify "default output index matches C function call" do
	        PortAudio.default_output_device[:index].should == PortAudio::C.default_output_device
	      end

	      specify "default input index matches C function call" do
	        PortAudio.default_input_device[:index].should == PortAudio::C.default_input_device
	      end
	    end
	  end
	end
end