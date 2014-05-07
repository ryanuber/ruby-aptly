ruby-aptly
==========

Ruby bindings for [aptly](http://aptly.info)

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

Examples
========

```ruby
# Create a mirror
mirror = Aptly.create_mirror(
    "ubuntu",
    "http://us.archive.ubuntu.org/ubuntu",
    "precise",
    components: ["main", "universe", "multiverse"],
    archlist: ["i386", "amd64"]
)

# Update the mirror
mirror.update

# Create a snapshot from a mirror
snapshot1 = Aptly.create_snapshot_from_mirror "snap1", mirror.name

# Create a repository
repo = Aptly.create_repo "my-software"

# Add a package file to a repo
repo.add "/tmp/myapp.deb"

# Add all debs in a directory to a repo
repo.add "/tmp/incoming-debs"

# Create a snapshot from a repo
snapshot2 = Aptly.create_snapshot_from_repo "snap2", repo.name
```
