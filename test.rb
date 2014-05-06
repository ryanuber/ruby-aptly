#!/usr/bin/ruby

require './aptly.rb'
#p Aptly::list_mirrors
#p Aptly::list_snapshots
#p Aptly::create_mirror "ubuntu", "http://us.archive.ubuntu.com", ["amd64"]
#p Aptly::mirror_info "oneiric"
#mirror = Aptly::Mirror.new "oneiric"
#mirror = Aptly::create_mirror "puppetlabs-deps", "http://apt.puppetlabs.com", dist: 'precise'
#mirror = Aptly::Mirror.new "puppetlabs-deps"
#mirror.update!
Aptly::update_mirrors
