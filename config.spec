%define    _topdir /usr/src/redhat
%define    _unpackaged_files_terminate_build 0
Name:      JoeDog-Config
Summary:   A perl config file parser
Version:   2.0.6
Release:   8
BuildArch: noarch
Group:     Programming
License:   GPL
Source:    ftp://ftp.joedog.org/pub/JoeDog/%{name}-%{version}.tar.gz
BuildRoot: /var/tmp/%{name}-buildroot
AutoReq:   0

%description
A perl config file parser

%prep 
%setup -q 

%install
cp --verbose -a ./ $RPM_BUILD_ROOT/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)

%dir /usr/share/perl5/vendor_perl/JoeDog
%dir /usr/share/perl5/vendor_perl/JoeDog/Config
/usr/share/man/man3/JoeDog::Config.3pm.gz
/usr/share/man/man3/JoeDog::Iterator.3pm.gz
/usr/share/perl5/vendor_perl/JoeDog/Config/Iterator.pm
/usr/share/perl5/vendor_perl/JoeDog/Config.pm

%changelog

