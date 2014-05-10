require 'spec_helper'

module Aptly
  describe "AptlyError" do
    it "should contain stdout and stderr" do
      e = AptlyError.new 'a', 'b', 'c'
      e.message.should eq('a')
      e.stdout.should eq('b')
      e.stderr.should eq('c')
    end
  end
end
