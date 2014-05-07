module Aptly
  extend self

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

  def list_repos
    out = runcmd 'aptly repo list'
    parse_list out.lines
  end

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

    def drop
      Aptly::runcmd "aptly repo drop #{@name.to_safe}"
    end

    def add path, remove_files: false
      cmd = 'aptly repo add'
      cmd += ' -remove-files' if remove_files
      cmd += " #{@name.to_safe} #{path}"
      Aptly::runcmd cmd
    end

    def import from_mirror, pkg_spec, deps: false
      cmd = 'aptly repo import'
      cmd += ' -with-deps' if deps
      cmd += " #{from_mirror.to_safe} #{@name.to_safe} #{pkg_spec.to_safe}"
      Aptly::runcmd cmd
    end

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
