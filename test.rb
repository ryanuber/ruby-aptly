#/usr/bin/ruby

require 'aptly'

#Aptly.create_mirror(
#  "puppetlabs-deps",
#  "http://apt.puppetlabs.com",
#  "precise",
#  components: ["dependencies"],
#  archlist: ["i386"]
#)

mirror = Aptly::Mirror.new "puppetlabs-deps"
#mirror.update

#repo = Aptly.create_repo "repo1"
repo1 = Aptly::Repo.new "repo1"
#repo.import "puppetlabs-deps", "libstomp-ruby"

#repo2 = Aptly.create_repo "repo2"
#repo2.copy_from repo1.name, "libstomp-ruby"
repo2 = Aptly::Repo.new "repo2"
repo2.remove "libstomp-ruby"

snap1 = Aptly.create_snapshot_from_mirror "newsnap2", mirror.name
