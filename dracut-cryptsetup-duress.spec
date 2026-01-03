Name:           dracut-cryptsetup-duress
Version:        0.1.0
Release:        1%{?dist}
Summary:        Dracut module for duress password protection with cryptsetup

License:        GPLv3
URL:            https://github.com/melody0123/dracut-cryptsetup-duress
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       dracut
Requires:       cryptsetup

%description
A dracut module that enables a duress password for LUKS encrypted drives.
When the duress password is entered, specific actions (like header destruction) are triggered.

%prep
%setup -q

%install
mkdir -p %{buildroot}/usr/lib/dracut/modules.d/99duress
cp -r * %{buildroot}/usr/lib/dracut/modules.d/99duress/
rm -f %{buildroot}/usr/lib/dracut/modules.d/99duress/%{name}.spec

%files
/usr/lib/dracut/modules.d/99duress/*
%doc README.md

%post
echo "----------------------------------------------------------------"
echo "Installation successful."
echo "Please run 'dracut -f' to regenerate your initramfs."
echo "----------------------------------------------------------------"

%changelog
* Sat Jan 03 2026 Your Name <your.email@example.com> - 0.1.0-1
- Initial release
