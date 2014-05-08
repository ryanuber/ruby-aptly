#!/usr/bin/env ruby

# This script will update all mirrors known to aptly.

require 'syslog'
require 'aptly'

begin
  Aptly.list_mirrors.each do |mirror_name|
    puts "==> Updating mirror: #{mirror_name}"
    mirror = Aptly::Mirror.new mirror_name
    mirror.update
  end

  puts "Done!"
  exit 0
rescue AptlyError => e
  Syslog.open('aptly') {|log| log.err e.message}
  File.open('aptly.log', 'a+').write <<-EOF
=== #{Time.now} ===
--- error: #{e.message}
--- stdout:
#{e.aptly_output}
--- stderr:
#{e.aptly_error}

EOF
  exit 1
end
