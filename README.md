ruby-aptly
==========

Ruby wrapper for managing deb repos with [Aptly](http://aptly.info).

This is currently a **work in progress**! `ruby-aptly` does not wrap 100% of the
aptly feature set yet, but most major things are working at this point.

### Compatibility

ruby-aptly is currently tested against Aptly 0.5. It is possible that it will
also work fine on older or newer versions, but this is untested.

ruby-aptly should work on any Ruby >= 1.8.7.

---

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
