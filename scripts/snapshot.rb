#!/usr/bin/env ruby

require 'syslog'
require 'aptly'

# Get a short id and make sure it hasn't been used
existing = Aptly.list_snapshots
while id = Time.now.to_i.to_s
  break if !existing.include? id
  sleep 1
end

begin
  to_snapshot = Array.new
  snapshots = Array.new

  # First, update the mirrors
  Aptly.list_mirrors.each do |mirror_name|
    puts "==> Updating mirror: #{mirror_name}"
    mirror = Aptly::Mirror.new mirror_name
    mirror.update
    to_snapshot << mirror
  end

  # Add repos to the snapshot work
  Aptly.list_repos.each do |repo_name|
    to_snapshot << Aptly::Repo.new(repo_name)
  end

  # Loop over collected resources and snapshot them
  to_snapshot.each do |r|
    snapshot_name = "#{r.name}.#{id}"

    # Create a new snapshot of the resource
    puts "==> Creating snapshot: #{snapshot_name}"
    r.snapshot snapshot_name

    # Add it to our list of snapshots.
    snapshots << snapshot_name
  end

  # Merge all of the snapshots taken into a single snapshot.
  puts "==> Creating merged snapshot: #{id}"
  Aptly.merge_snapshots id, sources: snapshots, latest: true

  puts "Done!"
  exit 0
rescue AptlyError => e
  Syslog.open("aptly") {|log| log.err e.message}
  exit 1
end
