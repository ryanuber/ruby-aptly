require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter '/spec/'
end
require 'aptly'
Aptly::Mutex.mutex_path = "/tmp/aptly_#{Random.rand(1024)}.lock"
ENV['PATH'] += ":#{Dir.getwd}/spec/bin"
