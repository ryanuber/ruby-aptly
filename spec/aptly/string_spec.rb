require 'spec_helper'

module Aptly
  describe "String extensions" do
    it "should enclose strings in single quotes" do
      "this is a test".quote.should eq("'this is a test'")
    end

    it "should strip the string of single quotes" do
      "this' is' a' test".quote.should eq("'this is a test'")
    end
  end
end
