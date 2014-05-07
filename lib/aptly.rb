require 'open3'

require 'aptly/mutex'
require 'aptly/error'
require 'aptly/mirror'
require 'aptly/repo'
require 'aptly/string'

module Aptly

  def runcmd cmd
    Mutex.lock!
    at_exit { Mutex.unlock! }

    Open3.popen3(cmd) do |_, stdout, stderr, thread|
      res = thread.value.exitstatus
      out = stdout.read
      err = stderr.read

      # Aptly doesn't always return 1 when reporting errors, and will sometimes
      # report informational messages to stderr. This needs to be fixed in the
      # upstream code but for now we can work around it.
      res = 1 if (res != 0 && err != '')

      Mutex.unlock!

      return out, err, res
    end
  end

  def parse_list lines
    items = Array.new
    lines.each do |line|
      if line.start_with?(' * ')
        parts = line.split(/\[|\]/)
        items << parts[1] if parts.length == 3
      end
    end
    items
  end

  def parse_info lines
    items = Hash.new
    lines.reject{|l| l.empty?}.each do |line|
      parts = line.split(/:\s/)
      items[parts[0]] = parts[1].strip if parts.length == 2
    end

    def multi items, key
      items[key] = items[key].split(' ') if items.has_key? key
    end

    multi items, 'Components'
    multi items, 'Architectures'

    items
  end

  def list_snapshots
    out, err, status = runcmd 'aptly snapshot list'
    raise AptlyError.new('Failed to list snapshots', out, err) if status != 0
    parse_list out.lines
  end

end
