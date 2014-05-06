module Aptly
  extend self

  def create_repo(
    name,
    dist: '',
    archlist: [],
    comment: '',
    component: 'main',
    dall: false,
    drecommends: false,
    dsource: false,
    dsuggests: false
  )
    if list_repos.include? name
      raise AptlyError.new("Repo '#{name}' already exists")
    end

    cmd = "aptly repo create"
    cmd += " -comment '#{comment.gsub("'", '')}'" if !comment.empty?
    cmd += " -distribution #{dist}" if !dist.empty?
    cmd += " -architectures #{archlist.join(',')}" if !archlist.empty?
    cmd += ' -dep-follow-all-variants' if dall
    cmd += ' -dep-follow-recommends' if drecommends
    cmd += ' -dep-follow-source' if dsource
    cmd += ' -dep-follow-suggests' if dsuggests
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
    @name = nil
    @dist = nil
    @component = nil
    @comment = nil
    @num_packages = 0
    @archlist = []

    def initialize name
      if !Aptly::list_repos.include? name
        raise AptlyError.new("Repo '#{name}' does not exist")
      end

      info = Aptly::repo_info name
      @name = info['Name']
      @comment = info['Comment']
      @dist = info['Default Distribution']
      @component = info['Default Component']
      @num_packages = info['Number of packages']
    end

    def drop!
      out, err, status = Aptly::runcmd "aptly repo drop #{@name}"
      if status != 0
        raise AptlyError.new("Failed to drop repo '#{@name}'", out, err)
      end
    end
  end
end
