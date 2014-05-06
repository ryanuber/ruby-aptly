#!/usr/bin/ruby

require 'open3'

class AptlyError < RuntimeError
  attr_accessor :aptly_error, :aptly_output
  @aptly_output = nil
  @aptly_error = nil

  def initialize msg=nil, output=nil, error=nil
    @aptly_output = output
    @aptly_error = error
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

      # Aptly doesn't always return 1 when reporting errors, and will sometimes
      # report informational messages to stderr. This needs to be fixed in the
      # upstream code but for now we can work around it.
      res = 1 if (res != 0 && err != '')

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
    raise AptlyError.new('Failed to list mirrors', out, err) if status != 0
    parse_list out.lines
  end

  def list_snapshots
    out, err, status = runcmd 'aptly snapshot list'
    raise AptlyError.new('Failed to list snapshots', out, err) if status != 0
    parse_list out.lines
  end

  def list_repos
    out, err, status = runcmd 'aptly repo list'
    raise AptlyError.new('Failed to list repos', out, err) if status != 0
    parse_list out.lines
  end

  def mirror_info name
    out, err, status = runcmd "aptly mirror show #{name}"
    if status != 0
      raise AptlyError.new("Failed to fetch mirror details", out, err)
    end
    parse_info out.lines
  end

  def create_mirror(
    name,
    baseurl,
    dist: '',
    repos: [],
    archlist: [],
    keyrings: [],
    dall: false,
    drecommends: false,
    dsource: false,
    dsuggests: false,
    ignoresigs: false,
    source: false
  )
    if list_mirrors.include? name
      raise AptlyError.new("Mirror '#{name}' already exists")
    end

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

    return Mirror.new name
  end

  class Mirror
    @name = nil
    @baseurl = nil
    @dist = nil
    @components = []
    @archlist = []

    def initialize name
      if !Aptly::list_mirrors.include? name
        raise AptlyError.new("Mirror '#{name}' does not exist")
      end

      info = Aptly::mirror_info name
      @name = info['Name']
      @baseurl = info['Archive Root URL']
      @dist = info['Distribution']
      @components = info['Components']
      @archlist = info['Architectures']
    end

    def drop!
      out, err, status = Aptly::runcmd "aptly mirror drop #{@name}"
      if status != 0
        raise AptlyError.new("Failed to drop mirror '#{@name}'", out, err)
      end
      return true
    end
  end
end
