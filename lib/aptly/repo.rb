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

    _, err, status = runcmd cmd
    raise AptlyError.new('Failed to create repo', err) if status != 0

    return Repo.new name
  end

  def list_repos
    out, err, status = runcmd 'aptly repo list'
    raise AptlyError.new('Failed to list repos', out, err) if status != 0
    parse_list out.lines
  end

  def repo_info name
    out, err, status = runcmd "aptly repo show #{name}"
    if status != 0
      raise AptlyError.new("Failed to fetch repo details", out, err)
    end
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
        raise AptlyError.new("Repo '#{name}' does not exist")
      end

      info = Aptly::repo_info name
      @name = info['Name']
      @comment = info['Comment']
      @dist = info['Default Distribution']
      @component = info['Default Component']
      @num_packages = info['Number of packages'].to_i
    end

    def drop
      out, err, status = Aptly::runcmd "aptly repo drop #{@name.to_safe}"
      if status != 0
        raise AptlyError.new("Failed to drop repo #{@name.to_safe}", out, err)
      end
    end

    def add path
      out, err, status = Aptly::runcmd "aptly repo add #{@name.to_safe} #{path}"
      if status != 0
        raise AptlyError.new("Failed to add to repo: #{@path.to_safe}", out, err)
      end
    end

    def save
      cmd = "aptly repo edit"
      cmd += " -distribution=#{@dist.to_safe}"
      cmd += " -comment=#{@comment.to_safe}"
      cmd += " -component=#{@component.to_safe}"
      cmd += " #{@name.to_safe}"
      out, err, status = Aptly::runcmd cmd
      if status != 0
        raise AptlyError.new("Failed to update repo #{@name}", out, err)
      end
    end
  end
end
