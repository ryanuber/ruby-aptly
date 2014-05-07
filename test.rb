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

repo2 = Aptly.create_repo "repo2"
repo2.copy_from repo1.name, "libstomp-ruby"
