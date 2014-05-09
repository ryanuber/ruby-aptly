ruby-aptly
==========

Ruby wrapper for managing deb repos with [Aptly](http://aptly.info).

Introduction
============

Aptly is a great tool for managing Apt repositories. It is reliable, actively
maintained, and ridiculously fast.

Setting up Aptly is a snap - creating repositories, seeding them, taking
snapshots, and most other operations are pretty simple.

Orchestrating repository updates are a bit different. Typically this can be done
with a few simple shell scripts or similar, but where it really shines is when
you start driving it with data. Having tooling that understands Aptly's state is
nice for quickly funneling your hiera data or similar into usable repositories
with just a few lines of code. This library aims to make that process simple.

API documentation available at
[rubydoc.info](http://rubydoc.info/gems/aptly/frames)
