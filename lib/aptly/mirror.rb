module Aptly
  extend self

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
    cmd += " #{name.to_safe} #{baseurl.to_safe} #{dist.to_safe}"
    cmd += " #{components.join(' ')}"

    runcmd cmd
    return Mirror.new name
  end

  def list_mirrors
    out = runcmd 'aptly mirror list'
    parse_list out.lines
  end

  def mirror_info name
    out = runcmd "aptly mirror show #{name.to_safe}"
    parse_info out.lines
  end

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

    def drop
      Aptly::runcmd "aptly mirror drop #{@name.to_safe}"
    end

    def update ignore_cksum: false, ignore_sigs: false
      cmd = 'aptly mirror update'
      cmd += ' -ignore-checksums' if ignore_cksums
      cmd += ' -ignore-signatures' if ignore_sigs
      cmd += " #{@name.to_safe}"
      Aptly::runcmd cmd
    end
  end
end
