require 'open3'

require 'aptly/version'
require 'aptly/mutex'
require 'aptly/error'
require 'aptly/mirror'
require 'aptly/repo'
require 'aptly/snapshot'
require 'aptly/publish'
require 'aptly/string'

module Aptly

  # runcmd handles running arbitrary commands. It is intended to run aptly-
  # specific commands, and as such, it uses a mutex to take gurantee
  # consistency and avoid multiple processes modifying aptly simultaneously.
  #
  # == Parameters:
  # cmd::
  #   A string holding the command to run
  #
  # == Returns:
  # The content of stdout
  #
  def runcmd cmd
    Mutex.lock
    at_exit { Mutex.unlock }

    Open3.popen3(cmd) do |_, stdout, stderr, thread|
      res = thread.value.exitstatus
      out = stdout.read
      err = stderr.read

      # Aptly doesn't always return 1 when reporting errors, and will sometimes
      # report informational messages to stderr. This needs to be fixed in the
      # upstream code but for now we can work around it.
      res = 1 if (res == 0 && err != '')

      Mutex.unlock

      if res != 0
        raise AptlyError.new "aptly: command failed: #{cmd}", out, err
      end

      return out
    end
  end

  # Parses the output lines of aptly listing commands
  #
  # == Parameters:
  # lines::
  #   An array of lines of string output from aptly list commands
  #
  # == Returns:
  # An array of items
  #
  def parse_list lines
    items = Array.new
    lines.each do |line|
      if line.start_with?(' * ')
        parts = line.split(/\[|\]/, 3)
        items << parts[1] if parts.length == 3
      end
    end
    items
  end

  # Parses the output of aptly show commands.
  #
  # == Parameters:
  # lines::
  #   An array of strings of aptly output
  #
  # == Returns:
  # A hash of information
  #
  def parse_info lines
    items = Hash.new
    lines.reject{|l| l.empty?}.each do |line|
      parts = line.split(/:\s/, 2)
      items[parts[0]] = parts[1].strip if parts.length == 2
    end

    def multi items, key
      items[key] = items[key].split(' ') if items.has_key? key
    end

    multi items, 'Components'
    multi items, 'Architectures'

    items
  end

  # Parses aptly output of double-space indented lists
  #
  # == Parameters:
  # lines::
  #   Output lines from an aptly list command
  #
  # == Result:
  # An array of items
  #
  def parse_indented_list lines
    items = Array.new
    lines.each do |line|
      items << line.strip if line.start_with? '  '
    end
    items
  end
end
