require 'spec_helper'

module Aptly
  describe "Creating Snapshots" do
    it "should error on invalid snapshot type" do
      expect { Aptly.create_snapshot 'x', 'y', 'z' }.to raise_error
    end

    it "should successfully create a mirror snapshot" do
      Aptly.create_mirror_snapshot 'aptly_snap', 'aptly'
    end

    it "should error on duplicate snapshot name" do
      expect {
        Aptly.create_mirror_snapshot 'aptly_snap', 'aptly'
      }.to raise_error
    end
  end
end
