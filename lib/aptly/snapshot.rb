module Aptly
  extend self

  # Create a new snapshot of a repo or mirror
  #
  # == Parameters:
  # name::
  #   The name for the new snapshot
  # type::
  #   The type of snapshot. "mirror" and "repo" are supported.
  # resource_name::
  #   The name of the mirror or repo
  #
  # == Returns:
  # An Aptly::Snapshot object
  #
  def create_snapshot name, type, resource_name
    if type != 'mirror' && type != 'repo'
      raise AptlyError.new "Invalid snapshot type: #{type}"
    end

    if list_snapshots.include? name
      raise AptlyError.new "Snapshot '#{name}' already exists"
    end

    cmd = 'aptly snapshot create '
    cmd += " #{name.to_safe} from #{type} #{resource_name.to_safe}"

    runcmd cmd
    return Snapshot.new name
  end
  private :create_snapshot

  # Shortcut method to create a snapshot from a mirror
  def create_snapshot_from_mirror name, mirror_name
    create_snapshot name, 'mirror', mirror_name
  end

  # Shortcut method to create a snapshot from a repo
  def create_snapshot_from_repo name, repo_name
    create_snapshot name, 'repo', repo_name
  end

  # List existing snapshots
  #
  # == Returns:
  # A list of snapshot names
  #
  def list_snapshots
    out = runcmd 'aptly snapshot list'
    parse_list out.lines
  end

  # Retrieves information about a snapshot
  #
  # == Parameters:
  # name::
  #   The name of the snapshot to gather information about
  #
  # == Returns:
  # A hash of snapshot information
  #
  def snapshot_info name
    out = runcmd "aptly snapshot show #{name.to_safe}"
    parse_info out.lines
  end

  class Snapshot
    @name = ''
    @created_at = ''
    @description = ''
    @num_packages = 0

    # Instantiates a new Aptly::Snapshot instance
    #
    # == Parameters:
    # name::
    #   The name of the snapshot
    #
    # == Returns:
    # An Aptly::Snapshot instance
    #
    def initialize name
      if !Aptly::list_snapshots.include? name
        raise AptlyError.new("Snapshot '#{name}' does not exist")
      end

      info = Aptly::snapshot_info name
      @name = info['Name']
      @created_at = info['Created At']
      @description = info['Description']
      @num_packages = info['Number of packages'].to_i
    end

    # Drops an existing snapshot
    def drop
      Aptly::runcmd "aptly snapshot drop #{@name.to_safe}"
    end

    # Verifies an existing snapshot is able to resolve dependencies. This method
    # currently only returns true/false status.
    #
    # == Parameters:
    # sources::
    #   Additional snapshot sources to be considered during verification
    # follow_source::
    #   When true, verify all source packages as well
    #
    # == Returns:
    # True if verified, false if any deps are missing
    #
    def verify sources: [], follow_source: false
      cmd = 'aptly snapshot verify'
      cmd += ' -dep-follow-source' if follow_source
      cmd += " #{@name.to_safe}"
      cmd += " #{@sources.join(' ')}" if !sources.empty?
      out = Aptly::runcmd cmd
      return out.lines.length == 0
    end
  end
end
