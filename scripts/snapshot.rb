#!/usr/bin/env ruby

# This script will create a new snapshot for each repo and each mirror,
# named by the current UNIX timestamp. Once all snapshots are created, it
# will then create a merged snapshot of all of the newly-created snapshots.

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

  # Add mirrors to the snapshot queue
  Aptly.list_mirrors.each do |mirror_name|
    to_snapshot << Aptly::Mirror.new(mirror_name)
  end

  # Add repos to the snapshot queue
  Aptly.list_repos.each do |repo_name|
    to_snapshot << Aptly::Repo.new(repo_name)
  end

  # Loop over queue and create snapshots
  to_snapshot.each do |r|
    snapshot_name = "#{r.name}.#{id}"
    puts "==> Creating snapshot: #{snapshot_name}"
    r.snapshot snapshot_name

    # Add it to our list of snapshots.
    snapshots << snapshot_name
  end

  # Merge all of the snapshots taken into a single snapshot.
  puts "==> Creating merged snapshot: #{id}"
  Aptly.merge_snapshots id, sources: snapshots, latest: true

  puts 'Done!'
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
