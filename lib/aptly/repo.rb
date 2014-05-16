module Aptly
  extend self

  # Creates a new repository in aptly
  #
  # == Parameters:
  # name::
  #   The name to use for the new repository
  # dist::
  #   The distribution used during publishing
  # comment::
  #   A comment describing the repository
  # component::
  #   The component used during publishing
  #
  # == Returns:
  # An Aptly::Repo object
  #
  def create_repo name, kwargs={}
    dist = kwargs.arg :dist, ''
    comment = kwargs.arg :comment, ''
    component = kwargs.arg :component, 'main'
    if list_repos.include? name
      raise AptlyError.new("Repo '#{name}' already exists")
    end

    cmd = "aptly repo create"
    cmd += " -comment=#{comment.quote}" if !comment.empty?
    cmd += " -distribution=#{dist.quote}" if !dist.empty?
    cmd += " #{name}"

    runcmd cmd
    return Repo.new name
  end

  # Return a list of existing repositories
  #
  # == Returns
  # An array of strings representing repository names
  #
  def list_repos
    out = runcmd 'aptly repo list'
    parse_list out.lines
  end

  # Retrieve information about a repository
  #
  # == Parameters:
  # name::
  #   The name of the repository to retrieve information for
  #
  # == Returns:
  # A hash of repository information
  #
  def repo_info name
    out = runcmd "aptly repo show #{name.quote}"
    parse_info out.lines
  end

  class Repo
    attr_accessor :name, :dist, :component
    attr_accessor :comment, :num_packages, :archlist

    @name = ''
    @dist = ''
    @component = ''
    @comment = ''
    @num_packages = 0

    # Instantiates an Aptly::Repo object
    #
    # == Parameters:
    # name::
    #   The name of the repository
    #
    # == Returns:
    # An Aptly::Repo object
    #
    def initialize name
      if !Aptly::list_repos.include? name
        raise AptlyError.new "Repo '#{name}' does not exist"
      end

      info = Aptly::repo_info name
      @name = info['Name']
      @comment = info['Comment']
      @dist = info['Default Distribution']
      @component = info['Default Component']
      @num_packages = info['Number of packages'].to_i
    end

    # Drops an existing aptly repository
    def drop
      Aptly::runcmd "aptly repo drop #{@name.quote}"
    end

    # List all packages contained in a repository
    #
    # == Returns:
    # An array of packages
    #
    def list_packages
      res = []
      out = Aptly::runcmd "aptly repo show -with-packages #{@name.quote}"
      Aptly::parse_indented_list out.lines
    end

    # Add debian packages to a repo
    #
    # == Parameters:
    # path::
    #   The path to the file or directory source
    # remove_files::
    #   When true, deletes source after import
    #
    def add path, kwargs={}
      remove_files = kwargs.arg :remove_files, false

      cmd = 'aptly repo add'
      cmd += ' -remove-files' if remove_files
      cmd += " #{@name.quote} #{path}"

      Aptly::runcmd cmd
    end

    # Imports package resources from existing mirrors
    #
    # == Parameters:
    # from_mirror::
    #   The name of the mirror to import from
    # packages::
    #   A list of debian pkg_spec strings (e.g. "libc6 (>= 2.7-1)")
    # deps::
    #   When true, follows package dependencies and adds them
    #
    def import from_mirror, kwargs={}
      deps = kwargs.arg :deps, false
      packages = kwargs.arg :packages, []

      if packages.length == 0
        raise AptlyError.new '1 or more packages are required'
      end

      cmd = 'aptly repo import'
      cmd += ' -with-deps' if deps
      cmd += " #{from_mirror.quote} #{@name.quote}"
      packages.each {|p| cmd += " #{p.quote}"}

      Aptly::runcmd cmd
    end

    # Copy package resources from one repository to another
    #
    # == Parameters:
    # from_repo::
    #   The source repository name
    # to_repo::
    #   The destination repository name
    # packages::
    #   A list of debian pkg_spec strings
    # deps::
    #   When true, follow deps and copy them
    #
    def copy from_repo, to_repo, kwargs={}
      deps = kwargs.arg :deps, false
      packages = kwargs.arg :packages, []

      if packages.length == 0
        raise AptlyError.new '1 or more packages are required'
      end

      cmd = 'aptly repo copy'
      cmd += ' -with-deps' if deps
      cmd += " #{from_repo.quote} #{to_repo.quote}"
      packages.each {|p| cmd += " #{p.quote}"}

      Aptly::runcmd cmd
    end
    private :copy

    # Shortcut method to copy resources in from another repository
    def copy_from from_repo, kwargs={}
      copy from_repo, @name, kwargs
    end

    # Shortcut method to copy resources out to another repository
    def copy_to to_repo, kwargs={}
      copy @name, to_repo, kwargs
    end

    # Move package resources from one repository to another
    #
    # == Parameters:
    # from_repo::
    #   The source repository name
    # to_repo::
    #   The destination repository name
    # packages::
    #   A list of debian pkg_spec strings
    # deps::
    #   When true, follow deps and move them too
    #
    def move from_repo, to_repo, kwargs={}
      deps = kwargs.arg :deps, false
      packages = kwargs.arg :packages, []

      if packages.length == 0
        raise AptlyError.new '1 or more packages are required'
      end

      cmd = 'aptly repo move'
      cmd += ' -with-deps' if deps
      cmd += " #{from_repo.quote} #{to_repo.quote}"
      packages.each {|p| cmd += " #{p.quote}"}

      Aptly::runcmd cmd
    end
    private :move

    # Shortcut method to move packages in from another repo
    def move_from from_repo, kwargs={}
      move from_repo, @name, kwargs
    end

    # Shortcut method to move packages out to another repository
    def move_to to_repo, kwargs={}
      move @name, to_repo, kwargs
    end

    # Remove packages selectively from a repository
    #
    # == Parameters:
    # pkg_spec::
    #   A debian pkg_spec string to select packages by
    #
    def remove pkg_spec
      Aptly::runcmd "aptly repo remove #{@name.quote} #{pkg_spec.quote}"
    end

    # Shortcut method to snapshot an Aptly::Repo object
    def snapshot name
      Aptly::create_repo_snapshot name, @name
    end

    # Shortcut method to publish a repo from an Aptly::Repo instance.
    def publish args
      Aptly::publish 'repo', @name, args
    end

    # save allows you to modify the repository distribution, comment, or
    # component string by using the attr_accessor's, and then calling this
    # method to persist them to aptly.
    def save
      cmd = "aptly repo edit"
      cmd += " -distribution=#{@dist.quote}"
      cmd += " -comment=#{@comment.quote}"
      cmd += " -component=#{@component.quote}"
      cmd += " #{@name.quote}"

      Aptly::runcmd cmd
    end
  end
end
