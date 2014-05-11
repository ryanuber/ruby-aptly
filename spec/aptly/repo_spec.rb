require 'spec_helper'

module Aptly
  describe "Creating Aptly Repos" do
    it "should create repos successfully" do
      Aptly.create_repo 'repo1'
      Aptly.create_repo 'repo2'
    end

    it "should return a list of repositories" do
      Aptly.list_repos.should eq(['repo1', 'repo2'])
    end

    it "should error if repo already exists" do
      expect { Aptly.create_repo 'repo1' }.to raise_error
    end
  end
end
