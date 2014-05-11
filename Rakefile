require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default => [:prep, :spec]

task :prep do
  %x(cd spec; sh setup.sh)
end
