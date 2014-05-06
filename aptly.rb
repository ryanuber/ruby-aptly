#!/usr/bin/ruby

require 'open3'

class AptlyError < RuntimeError
  attr_accessor :aptly_error
  @aptly_error = nil

  def initialize msg=nil, errortext=nil
    @aptly_error = errortext
    super msg
  end
end

module Aptly
  extend self

  def runcmd cmd
    Open3.popen3(cmd) do |_, stdout, stderr, thread|
      res = thread.value.exitstatus
      out = stdout.read
      err = stderr.read

      # Aptly doesn't always return 1 when reporting usage errors
      res = 1 unless res != 0 || err == ""

      return out, err, res
    end
  end

  def parse_list lines
    items = Array.new
    lines.each do |line|
      if line.start_with?(' * ')
        parts = line.split(/\[|\]/)
        items << parts[1] if parts.length == 3
      end
    end
    items
  end

  def parse_info lines
    items = Hash.new
    lines.reject{|l| l.empty?}.each do |line|
      parts = line.split(/:\s/)
      items[parts[0]] = parts[1].strip if parts.length == 2
    end

    def multi items, key
      items[key] = items[key].split(' ') if items.has_key? key
    end

    multi items, 'Components'
    multi items, 'Architectures'

    items
  end

  def list_mirrors
    out, err, status = runcmd 'aptly mirror list'
    raise AptlyError.new('Failed to list mirrors', err) if status != 0
    parse_list out.lines
  end

  def list_snapshots
    out, err, status = runcmd 'aptly snapshot list'
    raise AptlyError.new('Failed to list snapshots', err) if status != 0
    parse_list out.lines
  end

  def list_repos
    out, err, status = runcmd 'aptly repo list'
    raise AptlyError.new('Failed to list repos', err) if status != 0
    parse_list out.lines
  end

  def mirror_info name
    out, err, status = runcmd "aptly mirror show #{name}"
    raise AptlyError.new("Failed to fetch mirror details", err) if status != 0
    parse_info out.lines
  end

  class Mirror
    @name = nil
    @baseurl = nil
    @dist = nil
    @components = []
    @archlist = []

    def initialize name
      if Aptly::list_mirrors.include? name
        info = Aptly::mirror_info name
        @name = info['Name']
        @baseurl = info['Archive Root URL']
        @dist = info['Distribution']
        @components = info['Components']
        @archlist = info['Architectures']
      end
    end

    def create(
      name,
      baseurl,
      dist='',
      repos=[],
      archlist=[],
      keyrings=[],
      dall=false,
      drecommends=false,
      dsource=false,
      dsuggests=false,
      ignoresigs=false,
      source=false)

      cmd = "aptly mirror create #{name} #{baseurl}"
      cmd += " #{dist}" if !dist.empty?
      cmd += " #{repos.join(',')}" if !repos.empty?
      cmd += " -architectures #{archlist.join(',')}" if !archlist.empty?
      cmd += ' -dep-follow-all-variants' if dall
      cmd += ' -dep-follow-recommends' if drecommends
      cmd += ' -dep-follow-source' if dsource
      cmd += ' -dep-follow-suggests' if dsuggests
      cmd += ' -ignore-signatures' if ignoresigs

      if !keyrings.empty?
        keyrings.each {|keyring| cmd += " -keyring #{keyring}"}
      end

      _, err, status = runcmd cmd
      raise AptlyError.new('Failed to create mirror', err) if status != 0
    end

    private :create
  end

end
