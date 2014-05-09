clean:
	rm -f aptly-*.gem
	rm -f rubygem-aptly_*.deb

deb: clean
	gem build aptly.gemspec
	fpm -s gem -t deb ./aptly-*.gem
