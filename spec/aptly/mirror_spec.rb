require 'spec_helper'

module Aptly
  describe "Creating mirrors" do
    # This mirror is created in spec_helper so that we only do it once for the
    # entire test suite run.
    it "should fail to create a mirror with a duplicate name" do
      expect { Aptly.create_mirror(
        'aptly', 'http://repo.aptly.info', 'squeeze',
        components: ['main']
      )}.to raise_error
    end

    it "should error if no component is provided" do
      expect { Aptly.create_mirror(
        'no_component', 'http://repo.aptly.info', 'squeeze'
      )}.to raise_error
    end
  end

  describe "Updating Mirrors" do
    it "should successfully update an existing mirror" do
      mirror = Aptly::Mirror.new 'aptly'
      mirror.update
    end
  end

  describe "Loading Mirrors" do
    it "should error trying to load a mirror that doesn't exist" do
      expect { Aptly::Mirror.new('nothing') }.to raise_error
    end
  end

  describe "Updating Mirrors" do
    it "should successfully update a mirror" do
      mirror = Aptly::Mirror.new 'aptly'
      mirror.update
      # Need to check here for updated content
    end
  end

  describe "List Packages" do
    it "should return a list of packages in the mirror" do
      mirror = Aptly::Mirror.new 'aptly'
      mirror.list_packages.should include('aptly_0.5.1_amd64')
    end
  end

  describe "Snapshot Mirrors" do
    it "should create a new snaphot of a mirror" do
      mirror = Aptly::Mirror.new 'aptly'
      snap = mirror.snapshot 'snap_from_mirror'
      snap.kind_of?(Aptly::Snapshot).should eq(true)
    end
  end
end
