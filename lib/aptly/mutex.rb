module Aptly
  extend self

  class Mutex
    @@mutex_path = '/tmp/aptly.lock'

    # Static attribute accessor for mutex path
    #
    # == Returns:
    # The path to the aptly mutex file
    #
    def self.mutex_path
      @@mutex_path
    end

    # Alter the mutex path. This should be set to the same path in all places
    # where ruby-aptly will be used on the same host, since the mutex is meant
    # to be system-wide.
    #
    # == Parameters:
    # path::
    #   The desired path for the mutex
    #
    def self.mutex_path= path
      @@mutex_path = path
    end

    # Attempts to acquire the aptly mutex. This method will wait if the mutex
    # is already locked elsewhere, and check back every 5 seconds to see if it
    # has been freed. On each check where the mutex is determined to be in use,
    # we check if the process which originally acquired the lock is still
    # running so we can acquire a stale mutex should we need to.
    #
    # == Returns:
    # True, once the lock is acquired.
    #
    def self.lock
      while self.locked?
        self.running? && sleep(5) || self.unlock
      end
      File.open(@@mutex_path, 'w') {|f| f.write Process.pid}
    end

    # Checks if the mutex is in use. This is done via a simple file check.
    #
    # == Returns:
    # True if locked, else false
    #
    def self.locked?
      File.exist? @@mutex_path
    end

    # Checks if the process which originally acquired the mutex is still
    # running. This is useful to determine staleness of a locked mutex.
    #
    # == Returns:
    # True if running, else false
    #
    def self.running?
      begin
        pid = File.open(@@mutex_path).read.to_i
        Process.kill(0, pid)
        return true
      rescue Errno::ESRCH, Errno::ENOENT
        return false
      end
    end

    # Unlocks the mutex so that other processes may acquire it.
    #
    # == Returns:
    # True if unlock happens, else false
    #
    def self.unlock
      File.delete @@mutex_path if self.locked?
    end
  end
end
