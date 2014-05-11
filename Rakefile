require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default => [:test]
task :test => [:prep, :spec, :clean]
task :prep do
  %x(cd spec; sh setup.sh)
end
task :clean do
  FileUtils.rm_rf "#{File.dirname(__FILE__)}/.aptly"
  FileUtils.rm_rf "#{File.dirname(__FILE__)}/spec/bin/real_aptly"
end
