module Aptly
  extend self

  # Publish a snapshot or repo resource.
  #
  # == Parameters:
  # type::
  #   The type of resource to publish. 'snapshot' and 'repo' supported.
  # name::
  #   The name of the resource to publish.
  # prefix::
  #   An optional prefix to publish to.
  # component::
  #   The component to publish to. If empty, aptly will attempt to guess
  #   from the source, or use 'main' as the default.
  # dist::
  #   The distribution name. If empty, aptly will try to guess.
  # gpg_key::
  #   The gpg key to sign the repository. Uses default if not specified.
  # keyring::
  #   GPG keyring to use
  # label::
  #   An optional label to give the published resource
  # origin::
  #   The value of the 'Origin' field
  # secret_keyring::
  #   GPG secret keyring to use
  # sign::
  #   When false, don't sign Release files. Defaults to true.
  #
  def publish(
    type,
    name,
    prefix: '',
    component: '',
    dist: '',
    gpg_key: '',
    keyring: '',
    label: '',
    origin: '',
    secret_keyring: '',
    sign: true
  )
    if type != 'repo' && type != 'snapshot'
      raise AptlyError "Invalid publish type: #{type}"
    end

    cmd = "aptly publish #{type}"
    cmd += ' -skip-signing' if !sign
    cmd += " -component #{component.to_safe}" if !component.empty?
    cmd += " -distribution #{dist.to_safe}" if !dist.empty?
    cmd += " -gpg-key #{gpg_key.to_safe}" if !gpg_key.empty?
    cmd += " -keyring #{keyring.to_safe}" if !keyring.empty?
    cmd += " -label #{label.to_safe}" if !label.empty?
    cmd += " -origin #{origin.to_safe}" if !origin.empty?
    cmd += " #{name.to_safe}"
    if !secret_keyring.empty?
      cmd += " -secret-keyring #{secret_keyring.to_safe}"
    end

    runcmd cmd
  end

  # List existing published resources.
  #
  # == Returns
  # A hash of published resource information. The outer hash key is the
  # published resource path, and its value is the resource metadata.
  #
  def list_published
    res = Hash.new
    out = runcmd 'aptly publish list'
    out.lines.each do |line|
      if line.start_with? '  * '
        resource = {}
        parts = line[3..-1].split(/\[|\]|\(|\)/)
        resource['path'] = parts[0].strip
        resource['component'] = parts[1].strip
        resource['archlist'] = parts[3].split(', ')
        resource['from_name'] = parts[5].strip
        if parts[6].include? 'Snapshot'
          resource['from_type'] = 'snapshot'
        elsif parts[6].include? 'Repo'
          resource['from_type'] = 'repo'
        else
          next
        end
        dist = line.split.last
        res[dist] = resource
      end
    end
    res
  end

  class PublishedResource
    attr_accessor :path, :from_name, :from_type, :component
    attr_accessor :archlist, :dist

    @path = ''
    @from_name = ''
    @from_type = ''
    @component = ''
    @archlist = []
    @dist = ''

    # Instantiates a new published resource object from an existing published
    # resource.
    #
    # == Parameters:
    # dist::
    #   The distribution name
    # prefix::
    #   An optional prefix
    #
    # == Returns:
    # An Aptly::PublishedResource object
    #
    def initialize dist, prefix=''
      idx = "#{prefix}#{prefix.empty? ? '' : '/'}#{dist}"

      published = Aptly::list_published
      if !published.include? idx
        raise AptlyError.new "Published resource #{idx} does not exist"
      end

      @dist = dist
      @prefix = prefix
      @path = published[idx]['path']
      @from_name = published[idx]['from_name']
      @from_type = published[idx]['from_type']
      @component = published[idx]['component']
      @archlist = published[idx]['archlist']
    end

    def drop
      cmd = 'aptly publish drop'
      cmd += " #{@dist.to_safe}"
      cmd += " #{@prefix.to_safe}" if !@prefix.empty?

      Aptly::runcmd cmd
    end
  end
end
