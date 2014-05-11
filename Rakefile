require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default => [:test]
task :test => [:clean, :prep, :spec]
task :prep do
  %x(cd spec; sh setup.sh)
end
task :clean do
  FileUtils.rm_rf "#{File.dirname(__FILE__)}/.aptly"
end
