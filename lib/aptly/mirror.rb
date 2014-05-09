module Aptly
  extend self

  # Creates a new mirror in aptly. This simply creates the necessary records in
  # leveldb and doesn't do any heavy lifting.
  #
  # == Parameters:
  # name::
  #   The name of the new repository
  # baseurl::
  #   The URL to the repository content
  # dist::
  #   The distribution (e.g. precise, quantal)
  # components::
  #   The repository components (e.g. main, stable)
  # archlist::
  #   A list of architecture types to mirror
  # ignoresigs::
  #   Ignore package signature mismatches
  # source::
  #   Optionally mirror in source packages
  #
  # == Returns:
  # An Aptly::Mirror object
  #
  def create_mirror(
    name,
    baseurl,
    dist,
    components: [],
    archlist: [],
    ignoresigs: false,
    source: false
  )
    if list_mirrors.include? name
      raise AptlyError.new "Mirror '#{name}' already exists"
    end

    if components.length < 1
      raise AptlyError.new "1 or more components are required"
    end

    cmd = 'aptly mirror create'
    cmd += " -architectures #{archlist.join(',')}" if !archlist.empty?
    cmd += ' -ignore-signatures' if ignoresigs
    cmd += ' -with-sources' if source
    cmd += " #{name.quote} #{baseurl.quote} #{dist.quote}"
    cmd += " #{components.join(' ')}"

    runcmd cmd
    return Mirror.new name
  end

  # Returns a list of existing mirrors in aptly
  #
  # == Returns
  # An array of mirror names
  #
  def list_mirrors
    out = runcmd 'aptly mirror list'
    parse_list out.lines
  end

  # Retrieves information about a mirror
  #
  # == Parameters:
  # name::
  #   The name of the mirror to retrieve info for
  #
  # == Returns:
  # A hash of mirror information
  #
  def mirror_info name
    out = runcmd "aptly mirror show #{name.quote}"
    parse_info out.lines
  end

  # Iterates over all repositories in aptly and calls an update on each.
  def update_mirrors
    for name in list_mirrors
      mirror = Aptly::Mirror.new name
      mirror.update
    end
  end

  class Mirror
    attr_accessor :name, :baseurl, :dist, :components, :archlist

    @name = ''
    @baseurl = ''
    @dist = ''
    @components = []
    @archlist = []

    # Instantiates a new Mirror object
    #
    # == Parameters:
    # name::
    #   Then name associated with the mirror
    #
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

    # Drops an existing mirror from aptly's configuration
    def drop
      Aptly::runcmd "aptly mirror drop #{@name.quote}"
    end

    # List all packages contained in a mirror
    #
    # == Returns:
    # An array of packages
    #
    def list_packages
      res = []
      out = Aptly::runcmd "aptly mirror show -with-packages #{@name.quote}"
      Aptly::parse_indented_list out.lines
    end

    # Shortcut method to snapshot an Aptly::Mirror object
    def snapshot name
      Aptly::create_mirror_snapshot name, @name
    end

    # Updates a repository, syncing in all packages which have not already been
    # downloaded and caches them locally.
    #
    # == Parameters:
    # ignore_cksum::
    #   Ignore checksum mismatches
    # ignore_sigs::
    #   Ignore author signature mismatches
    #
    def update ignore_cksum: false, ignore_sigs: false
      cmd = 'aptly mirror update'
      cmd += ' -ignore-checksums' if ignore_cksum
      cmd += ' -ignore-signatures' if ignore_sigs
      cmd += " #{@name.quote}"
      Aptly::runcmd cmd
    end
  end
end
