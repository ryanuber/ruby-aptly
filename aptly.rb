#!/usr/bin/ruby

module Aptly
  extend self

  class AptlyException < Exception
  end

  def runcmd cmd
    out = %x(#{cmd})
    return out, $?.exitstatus
  end

  def parse_list lines
    items = Array.new
    lines.each do |line|
      if line.start_with?(" * ")
        parts = line.split(/\[|\]/)
        items << parts[1] if parts.length == 3
      end
    end
    items
  end

  def list_mirrors
    out, status = runcmd "aptly mirror list"
    raise AptlyException.new "Failed to list mirrors" if status != 0
    parse_list out.lines
  end

  def list_snapshots
    out, status = runcmd "aptly snapshot list"
    raise AptlyException.new "Failed to list snapshots" if status != 0
    parse_list out.lines
  end

  def list_repos
    out, status = runcmd "aptly repo list"
    raise AptlyException.new "Failed to list repos" if status != 0
    parse_list out.lines
  end

end
