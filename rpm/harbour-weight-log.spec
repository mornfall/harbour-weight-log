Name:          harbour-weight-log
Summary:       Weight Log
Version:       0.1
Release:       1
Group:         Qt/Qt
License:       LICENSE
URL:           http://example.org/
Source0:       %{name}-%{version}.tar.bz2
Requires:      sailfishsilica-qt5 >= 0.10.9
BuildRequires: pkgconfig(sailfishapp) >= 0.0.10
BuildRequires: pkgconfig(Qt5Core), pkgconfig(Qt5Qml), pkgconfig(Qt5Quick)
BuildRequires: desktop-file-utils

%description
A simple application to track your daily weight. Great for long-term weight
control, but you can also use it to track your progress on your diet. The
application plots your weight, shows your weekly and monthly average and shows
a trend line (a 10-day rolling average) to uncover trends (the red line in the
weight chart).

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}

%prep
%setup -q -n %{name}-%{version}

%build
%qtc_qmake5
%qtc_make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original                \
  --dir %{buildroot}%{_datadir}/applications          \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/icons/hicolor/86x86/apps
%{_datadir}share/applications
%{_datadir}/harbour-weight-log
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
%{_datadir}/applications/%{name}.desktop
%{_datadir}/%{name}/qml
%{_bindir}
