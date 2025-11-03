Name:           tuxedo-systeminfos
Version:        20251103.1
Release:        1%{?dist}
Summary:        TUXEDO Systeminfos Script

License:        GPL-3.0-or-later
URL:            https://gitlab.com/tuxedocomputers/development/packages/fixes/tuxedo-systeminfos

BuildArch:      noarch
Requires:       curl, edid-decode, efibootmgr, jq, lm-sensors, mesa-utils, nvme-cli, zip
# Place generated rpms into the current directory
%define _rpmdir .

%description
TUXEDO Systeminfos Script

%prep
%setup -q

%build

%install
# Copy files to package build root
cp -r  %{_builddir}/files/* %{buildroot}/

%files
%license LICENSE
/opt/systeminfos.sh
/usr/local/bin/tuxedo-systeminfos
/usr/local/bin/tuxedo-systeminfo.sh
/usr/local/bin/tuxedo-systeminfo
/usr/local/bin/systeminfos.sh
/usr/local/bin/tuxedo-systeminfos.sh
/usr/local/bin/systeminfos





%changelog
* Mon Nov 03 2025 Steven Seifried <tux@tuxedocomputers.com> - 20251103.1
- Use simple-package-creator for packaging
