require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter '/spec/'
end
require 'aptly'
ENV['PATH'] += ":#{Dir.getwd}/spec/bin"
