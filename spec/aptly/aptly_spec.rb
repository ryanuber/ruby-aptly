require 'spec_helper'

module Aptly
  describe "Command Execution" do
    it "should return an error on non-zero exit codes" do
      expect { Aptly.runcmd 'exit 1' }.to raise_error
    end
  end
end
