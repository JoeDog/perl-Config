#!/bin/sh

version=2.0.6

mkdir -p JoeDog-Config-$version
perl Makefile.PL INSTALLDIRS=vendor
make
make install DESTDIR=JoeDog-Config-$version
rm -Rf JoeDog-Config-2.0.6/usr/lib64

tar -cvf - JoeDog-Config-$version | gzip -f > JoeDog-Config-$version.tar.gz
mv JoeDog-Config-$version.tar.gz /usr/src/redhat/SOURCES
rpmbuild -ba -v config.spec
