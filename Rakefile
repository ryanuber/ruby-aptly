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

task :deb do
  %x(gem build ./aptly.gemspec)
  %x(fpm -s gem -t deb --license 'Apache-2.0' \
     --prefix /var/lib/gems/1.8 \
	   --url http://github.com/ryanuber/ruby-aptly ./aptly-*.gem)
end
