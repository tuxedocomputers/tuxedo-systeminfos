# Don't ship debug info (of Rust packages for example)
%define debug_package %{nil}

Name:           tuxedo-systeminfos
Version:        20260216.1.0
Release:        1%{?dist}
Summary:        TUXEDO Systeminfos Script

License:        GPL-2.0-only
Group:          Development
Packager:       TUXEDO Computers GmbH <tux@tuxedocomputers.com>
URL:            https://gitlab.com/tuxedocomputers/development/systeminfos-script

source0:        https://gitlab.com/tuxedocomputers/development/systeminfos-script/releases/%{name}-%{version}.tar.gz

BuildArch:      noarch

Requires:       curl, edid-decode, efibootmgr, jq, lm-sensors, mesa-utils, nvme-cli, zip

%description
TUXEDO Systeminfos Script

Script from TUXEDO Computers to get necessary information of the system for
technical support purposes.

%prep
%setup -q

%build

%install
# Copy files to package build root
cp -r files/* %{buildroot}/

%files
%license LICENSE
/usr/bin/tuxedo-systeminfo
/usr/bin/tuxedo-systeminfo.sh
/usr/bin/tuxedo-systeminfos.sh
/usr/bin/systeminfos.sh
/usr/bin/systeminfos
/usr/bin/tuxedo-systeminfos
/usr/share/applications/tuxedo-systeminfos.desktop
/usr/share/icons/hicolor/64x64/apps/tuxedo-systeminfos.png
/usr/share/metainfo/tuxedo-systeminfos.metainfo.xml






%changelog
* Mon Feb 16 2026 Steven Seifried <tux@tuxedocomputers.com> - 20260216.1.0-1
- Add NB02 battery information (introduced with tuxedo-drivers 4.20.0)
* Mon Nov 17 2025 Steven Seifried <tux@tuxedocomputers.com> - 20251117.2.0-1
- Remove not working '$(basename $0)' and change '$1' to '$0'
* Mon Nov 17 2025 Steven Seifried <tux@tuxedocomputers.com> - 20251117.1.0-1
- Remove 'SYSINFOS_DEBUG' due to bugs and less usage
* Mon Nov 03 2025 Steven Seifried <tux@tuxedocomputers.com> - 20251103.1.0-1
- Use simple-package-creator for packaging
