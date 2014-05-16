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

  describe "Listing Repo Content" do
    it "should find no packages in the new, empty repo" do
      repo = Aptly::Repo.new 'repo2'
      repo.list_packages.should eq([])
    end
  end

  describe "Adding Packages" do
    it "should successfully add a single file" do
      repo = Aptly::Repo.new 'repo2'
      repo.add 'spec/pkgs/pkg1_1.0.1-1_amd64.deb'
      repo.list_packages.should eq(['pkg1_1.0.1-1_amd64'])
    end

    it "should successfully add a directory of packages" do
      repo = Aptly::Repo.new 'repo2'
      repo.add 'spec/pkgs'
      repo.list_packages.should eq(['pkg1_1.0.1-1_amd64', 'pkg2_1.0.2-2_amd64'])
    end
  end

  describe "Importing Packages" do
    it "should import packages from a mirror" do
      repo = Aptly.create_repo 'repo3'
      repo.import 'aptly', :packages => ['aptly_0.5_amd64']
      repo.list_packages.should eq(['aptly_0.5_amd64'])
    end
  end

  describe "Copying Packages" do
    it "should copy a package to another repo" do
      repoA = Aptly.create_repo 'copyA'
      repoB = Aptly.create_repo 'copyB'

      # Copy to...
      repoA.add 'spec/pkgs/pkg1_1.0.1-1_amd64.deb'
      repoA.copy_to repoB.name, :packages => ['pkg1_1.0.1-1_amd64']
      repoB.list_packages.should eq(['pkg1_1.0.1-1_amd64'])

      # Copy from...
      repoB.add 'spec/pkgs/pkg2_1.0.2-2_amd64.deb'
      repoA.copy_from repoB.name, :packages => ['pkg2_1.0.2-2_amd64']
      repoA.list_packages.should eq(['pkg1_1.0.1-1_amd64', 'pkg2_1.0.2-2_amd64'])
    end
  end

  describe "Moving Packages" do
    it "should move a package from one repo to another" do
      repoA = Aptly.create_repo 'moveA'
      repoB = Aptly.create_repo 'moveB'

      # Move to...
      repoA.add 'spec/pkgs/pkg1_1.0.1-1_amd64.deb'
      repoA.move_to repoB.name, :packages => ['pkg1_1.0.1-1_amd64']
      repoA.list_packages.should eq([])
      repoB.list_packages.should eq(['pkg1_1.0.1-1_amd64'])

      # Move from...
      repoA.move_from repoB.name, :packages => ['pkg1_1.0.1-1_amd64']
      repoA.list_packages.should eq(['pkg1_1.0.1-1_amd64'])
      repoB.list_packages.should eq([])
    end
  end

  describe "Removing Packages" do
    it "should remove a package from a repo" do
      repo = Aptly.create_repo 'remove'
      repo.add 'spec/pkgs/pkg1_1.0.1-1_amd64.deb'
      repo.list_packages.should eq(['pkg1_1.0.1-1_amd64'])

      repo.remove 'pkg1_1.0.1-1_amd64'
      repo.list_packages.should eq([])
    end
  end

  describe "Snapshot Repos" do
    it "should create a new snaphot of a repo" do
      repo = Aptly.create_repo 'repo_to_snap'
      repo.add 'spec/pkgs/pkg1_1.0.1-1_amd64.deb'
      snap = repo.snapshot 'snap_from_repo'
      snap.kind_of?(Aptly::Snapshot).should eq(true)
    end
  end

  describe "Publish Repos" do
    it "should publish an existing repo" do
      repo = Aptly.create_repo 'repo_to_publish'
      repo.add 'spec/pkgs/pkg1_1.0.1-1_amd64.deb'
      repo.publish dist: 'repo_to_publish'
    end
  end

  describe "Modify Repo" do
    it "should modify the repo metadata" do
      repoA = Aptly.create_repo 'modify'
      repoA.dist = 'mydist'
      repoA.comment = 'mycomment'
      repoA.component = 'mycomponent'
      repoA.save

      repoB = Aptly::Repo.new 'modify'
      repoB.dist.should eq('mydist')
      repoB.comment.should eq('mycomment')
      repoB.component.should eq('mycomponent')
    end
  end
end
