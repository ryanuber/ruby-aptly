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
  def create_repo(
    name,
    dist: '',
    comment: '',
    component: 'main'
  )
    if list_repos.include? name
      raise AptlyError.new("Repo '#{name}' already exists")
    end

    cmd = "aptly repo create"
    cmd += " -comment=#{comment.to_safe}" if !comment.empty?
    cmd += " -distribution=#{dist.to_safe}" if !dist.empty?
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
    out = runcmd "aptly repo show #{name.to_safe}"
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
      Aptly::runcmd "aptly repo drop #{@name.to_safe}"
    end

    # List all packages contained in a repository
    #
    # == Returns:
    # An array of packages
    #
    def list_packages
      res = []
      out = Aptly::runcmd "aptly repo show -with-packages #{@name.to_safe}"
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
    def add path, remove_files: false
      cmd = 'aptly repo add'
      cmd += ' -remove-files' if remove_files
      cmd += " #{@name.to_safe} #{path}"
      Aptly::runcmd cmd
    end

    # Imports package resources from existing mirrors
    #
    # == Parameters:
    # from_mirror::
    #   The name of the mirror to import from
    # pkg_spec::
    #   A debian pkg_spec string (e.g. "libc6 (>= 2.7-1)")
    # deps::
    #   When true, follows package dependencies and adds them
    #
    def import from_mirror, pkg_spec, deps: false
      cmd = 'aptly repo import'
      cmd += ' -with-deps' if deps
      cmd += " #{from_mirror.to_safe} #{@name.to_safe} #{pkg_spec.to_safe}"
      Aptly::runcmd cmd
    end

    # Copy package resources from one repository to another
    #
    # == Parameters:
    # from_repo::
    #   The source repository name
    # to_repo::
    #   The destination repository name
    # pkg_spec::
    #   A debian pkg_spec string
    # deps::
    #   When true, follow deps and copy them
    #
    def copy from_repo, to_repo, pkg_spec, deps: false
      cmd = 'aptly repo copy'
      cmd += ' -with-deps' if deps
      cmd += " #{from_repo.to_safe} #{to_repo.to_safe} #{pkg_spec.to_safe}"
      Aptly::runcmd cmd
    end
    private :copy

    # Shortcut method to copy resources in from another repository
    def copy_from from_repo, pkg_spec, deps: false
      copy from_repo, @name, pkg_spec, deps: deps
    end

    # Shortcut method to copy resources out to another repository
    def copy_to to_repo, pkg_spec, deps: false
      copy @name, to_repo, pkg_spec, deps: deps
    end

    # Move package resources from one repository to another
    #
    # == Parameters:
    # from_repo::
    #   The source repository name
    # to_repo::
    #   The destination repository name
    # pkg_spec::
    #   A debian pkg_spec string
    # deps::
    #   When true, follow deps and move them too
    #
    def move from_repo, to_repo, pkg_spec, deps: false
      cmd = 'aptly repo move'
      cmd += ' -with-deps' if deps
      cmd += " #{from_repo.to_safe} #{to_repo.to_safe} #{pkg_spec.to_safe}"
      Aptly::runcmd cmd
    end
    private :move

    # Shortcut method to move packages in from another repo
    def move_from from_repo, pkg_spec, deps: false
      move from_repo, @name, pkg_spec, deps: deps
    end

    # Shortcut method to move packages out to another repository
    def move_to to_repo, pkg_spec, deps: false
      move @name, to_repo, pkg_spec, deps: deps
    end

    # Remove packages selectively from a repository
    #
    # == Parameters:
    # pkg_spec::
    #   A debian pkg_spec string to select packages by
    #
    def remove pkg_spec
      Aptly::runcmd "aptly repo remove #{@name.to_safe} #{pkg_spec.to_safe}"
    end

    # save allows you to modify the repository distribution, comment, or
    # component string by using the attr_accessor's, and then calling this
    # method to persist them to aptly.
    def save
      cmd = "aptly repo edit"
      cmd += " -distribution=#{@dist.to_safe}"
      cmd += " -comment=#{@comment.to_safe}"
      cmd += " -component=#{@component.to_safe}"
      cmd += " #{@name.to_safe}"

      Aptly::runcmd cmd
    end
  end
end
