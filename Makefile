clean:
	rm -f aptly-*.gem
	rm -f rubygem-aptly_*.deb

gem:
	gem build aptly.gemspec

deb: gem
	fpm -s gem -t deb --license 'Apache-2.0' \
	--url http://github.com/ryanuber/ruby-aptly ./aptly-*.gem
