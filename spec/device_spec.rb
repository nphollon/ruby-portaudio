require 'spec_helper'
require 'device'

describe "Device" do
  before do
    $stderr.reopen File::NULL
    PortAudio.invoke(:init)
    $stderr.reopen STDERR
  end

  after do
    PortAudio.invoke(:terminate)
  end
end