require 'spec_helper'

module Aptly
  describe "Aptly Repos" do
    it "should return a list of repositories" do
      Aptly.list_repos.should eq(['repo1', 'repo2'])
    end
  end
end
