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
      raise AptlyError.new("Mirror '#{name}' already exists")
    end

    if components.length < 1
      raise AptlyError.new("1 or more components are required")
    end

    cmd = "aptly mirror create #{name.to_safe} #{baseurl.to_safe}"
    cmd += " #{dist.to_safe}" if !dist.empty?
    cmd += " #{components.join(' ')}"
    cmd += " -architectures #{archlist.join(',')}" if !archlist.empty?
    cmd += ' -dep-follow-all-variants' if dall
    cmd += ' -dep-follow-recommends' if drecommends
    cmd += ' -dep-follow-source' if dsource
    cmd += ' -dep-follow-suggests' if dsuggests
    cmd += ' -ignore-signatures' if ignoresigs

    _, err, status = runcmd cmd
    raise AptlyError.new('Failed to create mirror', err) if status != 0

    return Mirror.new name
  end

  def list_mirrors
    out, err, status = runcmd 'aptly mirror list'
    raise AptlyError.new('Failed to list mirrors', out, err) if status != 0
    parse_list out.lines
  end

  def mirror_info name
    out, err, status = runcmd "aptly mirror show #{name.to_safe}"
    if status != 0
      raise AptlyError.new("Failed to fetch mirror details", out, err)
    end
    parse_info out.lines
  end

  def update_mirrors
    for name in list_mirrors
      mirror = Aptly::Mirror.new name
      mirror.update!
    end
  end

  class Mirror
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
      out, err, status = Aptly::runcmd "aptly mirror drop #{@name.to_safe}"
      if status != 0
        raise AptlyError.new(
          "Failed to drop mirror '#{@name.to_safe}'", out, err
        )
      end
    end

    def update
      out, err, status = Aptly::runcmd "aptly mirror update #{@name.to_safe}"
      if status != 0
        raise AptlyError.new(
          "Failed to update mirror '#{@name.to_safe}'", out, err
        )
      end
    end
  end
end
