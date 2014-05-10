require 'spec_helper'

module Aptly
  describe "String extensions" do
    it "should safely put strings into single-quotes" do
    "this is a test".quote.should eq("'this is a test'")
    "this' is' a' test".quote.should eq("'this is a test'")
    end
  end
end
