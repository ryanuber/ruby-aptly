module Aptly
  extend self

  class Mutex
    @@mutex_path = '/tmp/aptly.lock'

    def self.lock!
      while self.locked?
        self.unlock! if !self.running?
        sleep 5
      end
      File.open(@@mutex_path, 'w') {|f| f.write Process.pid}
    end

    def self.locked?
      File.exist? @@mutex_path
    end

    def self.running?
      begin
        pid = File.open(@@mutex_path).read.to_i
        Process.kill(0, pid)
        return true
      rescue Errno::ESRCH, Errno::ENOENT
        return false
      end
    end

    def self.unlock!
      File.delete @@mutex_path if self.locked?
    end
  end
end
