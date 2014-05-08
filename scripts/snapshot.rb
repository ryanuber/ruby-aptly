#!/usr/bin/env ruby

require 'syslog'
require 'aptly'

# Get a short id and make sure it hasn't been used
existing = Aptly.list_snapshots
while id = Time.now.to_i.to_s
  break if !existing.include? id
end

begin
  # Create an array for tracking snapshots we create
  snapshots = Array.new

  # Loop over mirrors
  Aptly.list_mirrors.each do |mirror_name|
    snapshot_name = "#{mirror_name}.#{id}"

    # Get mirror object and call a mirror update
    puts "==> Updating mirror: #{mirror_name}"
    mirror = Aptly::Mirror.new mirror_name
    mirror.update

    # Create a new snapshot of the mirror after the update.
    puts "==> Creating mirror snapshot: #{snapshot_name}"
    Aptly.create_mirror_snapshot snapshot_name, mirror_name

    # Add it to our list of snapshots.
    snapshots << snapshot_name
  end

  # Merge all of the snapshots taken into a single snapshot.
  puts "==> Creating merged snapshot: #{id}"
  Aptly.merge_snapshots id, sources: snapshots, latest: true

  puts "Done!"
  exit 0
rescue AptlyError => e
  Syslog.open("aptly_daily_snapshot") {|log| log.err e.message}
  exit 1
end
