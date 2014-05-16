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

# Example

```ruby
require 'rubygems'
require 'aptly'

# Creates a new mirror
mirror = Aptly.create_mirror(
    'precise',
    'http://us.archive.ubuntu.com/ubuntu',
    'precise',
    :components => ['main', 'universe', 'multiverse']
)

# Performs a mirror update
mirror.update

# List packages in the mirror
mirror.list_packages

# Create a snapshot of a mirror
snap1 = mirror.snapshot 'snap1'

# Creates a new repo
repo = Aptly.create_repo 'test_repo'

# Import packages from a mirror into the repo
repo.import mirror.name, :packages => ['linux-image', 'bash']

# Create a snapshot from a repo
snap2 = repo.snap 'snap2'

# Merge two snapshots together, pulling in only latest packages
merged = Aptly.merge_snapshots snap1, snap2, :latest => true

# List packages in a merged snapshot
merged.list_packages

# Publish a snapshot
merged.publish
```
