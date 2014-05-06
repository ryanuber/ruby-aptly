#!/usr/bin/ruby

require './aptly.rb'
p Aptly::list_mirrors
p Aptly::list_snapshots
