clean:
	rm -f aptly-*.gem
	rm -f rubygem-aptly_*.deb

gem:
	gem build aptly.gemspec

deb: clean gem
	fpm -s gem -t deb ./aptly-*.gem
