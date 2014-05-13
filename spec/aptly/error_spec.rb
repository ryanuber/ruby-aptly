require 'spec_helper'

module Aptly
  describe "AptlyError" do
    it "should contain output" do
      e = AptlyError.new 'a', 'b'
      e.message.should eq('a')
      e.output.should eq('b')
    end
  end
end
