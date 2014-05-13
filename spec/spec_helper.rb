require 'simplecov'
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter '/spec/'
end
require 'aptly'
Aptly::Mutex.mutex_path = "/tmp/aptly_#{Random.rand(1024)}.lock"
ENV['PATH'] = "#{Dir.getwd}/spec/bin:#{ENV['PATH']}"

# Create a mirror of the aptly repo for testing purposes
puts "==> Mirroring aptly..."
begin
  mirror = Aptly.create_mirror(
    'aptly', 'http://repo.aptly.info/', 'squeeze',
    components: ['main']
  )
  mirror.update
rescue AptlyError => e
  puts "Failed: #{e.message}"
  puts "==> output:\n#{e.output}\n"
end
puts "Done!"
