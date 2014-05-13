require 'spec_helper'

module Aptly
  describe "Hash extensions" do
    it "should return kwargs properly when set" do
      {:arg => 'val'}.arg(:arg, '').should eq('val')
    end

    it "should return defaults when arg is not set" do
      {}.arg(:arg, 'val').should eq('val')
    end
  end
end
