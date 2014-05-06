#!/usr/bin/ruby

require 'aptly'

#p Aptly::list_mirrors
#p Aptly::list_snapshots
#p Aptly::create_mirror "ubuntu", "http://us.archive.ubuntu.com", ["amd64"]
#p Aptly::mirror_info "oneiric"
#mirror = Aptly::Mirror.new "oneiric"
#mirror = Aptly::create_mirror "puppetlabs-deps", "http://apt.puppetlabs.com", dist: 'precise'
#mirror = Aptly::Mirror.new "puppetlabs-deps"
#mirror.update!
#Aptly::update_mirrors
#repo = Aptly::Repo.new "test2"
#repo.drop!
repo = Aptly.create_repo "test2", comment: "Cool repo, bro"
repo.drop!
