require 'spec_helper'

module Aptly
  describe "Aptly mutex" do
    it "should recognize when the mutex is locked" do
      Mutex.lock
      Mutex.locked?.should eq(true)
      Mutex.unlock
      Mutex.locked?.should eq(false)
    end

    it "should acquire a stale mutex" do
      # Create a lock with a mangled PID
      File.open(Mutex.mutex_path, 'w') {|f| f.write('99999')}
      Mutex.locked?.should eq(true)
      Mutex.running?.should eq(false)

      # Attempt to acquire a lock
      Mutex.lock
      Mutex.locked?.should eq(true)
      Mutex.running?.should eq(true)
      Mutex.unlock
    end
  end
end
