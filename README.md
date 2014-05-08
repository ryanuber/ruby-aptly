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
mirror = Aptly.create_mirror(
    "ubuntu",
    "http://us.archive.ubuntu.com/ubuntu",
    "precise",
    components: ["main", "universe", "multiverse"],
    archlist: ["i386", "amd64"]
)
mirror.update
snap1 = mirror.snapshot "snap1"

repo = Aptly.create_repo "my-software"
repo.add "/tmp/myapp.deb"
repo.add "/tmp/incoming-debs"
snap2 = repo.snapshot "snap2"

snap3 = Aptly.merge_snapshots snap1.name, snap2.name, latest: true
snap3.list_packages
snap3.publish

Aptly.list_published

published_snap = Aptly::PublishedResource.new "precise"
published_snap.drop

snap3.drop
snap2.drop
snap1.drop

repo.drop

mirror.drop
```
