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

  describe "Loading Aptly Repos" do
    it "should successfully load existing repos" do
      repo = Aptly::Repo.new 'repo1'
      repo.kind_of?(Aptly::Repo).should eq(true)
    end

    it "should fail if the repo doesn't exist" do
      expect { Aptly::Repo.new 'nothing' }.to raise_error
    end
  end

  describe "Dropping Aptly Repos" do
    it "should successfully drop a repo" do
      repo = Aptly::Repo.new 'repo1'
      repo.drop
    end

    it "should reflect the correct repos after dropping" do
      repos = Aptly.list_repos
      repos.should eq(['repo2'])
    end
  end
end
