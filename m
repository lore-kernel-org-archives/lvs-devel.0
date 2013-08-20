From: Drunkard Zhang <gongfan193@gmail.com>
Subject: ipvsadm: One-packet scheduling with UDP service is unstable
Date: Tue, 20 Aug 2013 23:06:05 +0800
Message-ID: <CAJiejCQPa7V703RwOeWPpbQMJQvfswRn+pvTKFmNdeU05RU3SQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:from:date:message-id:subject:to:content-type;
        bh=75pi8vKIKz74dizE6HvQCWt7hkKQB/Ly2cSWN82bnb8=;
        b=oyFT7Y4q3IvGgTI3DjgPeSA1FkMb07v2GbmR/xs/LegE00mmH8BEAxH6IrXLEDrgDy
         kX1kHzWkJDjpZZHRdhPVjlQXYhkJtKsJSBHrlJ/Yhmq4BSoKzGkBElSekIOYp6Socjln
         pghJ3E61kQrQsUIXxG9se3Nz2FiecVInax4MCBSXcCY77sGorEZsWvrz4VOuDlzz3qlT
         tEAnRRNX1wDkxnGx/wDwy4df88xkbahF4KO/JuslJEZk8wT8Ju1p3Rcjmym3rigSDZC4
         ax+WayeIQa4KKUR0GwaI7FXkDRRCL0NUlr0m+5laSmooBshYWkzcFxWhnIy1EqVPyt/C
         JQ5Q==
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>

Need help here, thank you for replying :-)

I'm setting up a syslog cluster based on IPVS, all UDP datagrams sent
from firewall with fixed source IP and fixed source port, so
pseudo-random balancing based on client IP and port won't working. And
it seems that keepalived is not supporting One-packet scheduling
option, so I did some hacks on it after keepalived started:

1. dump LVS rules with ipvsadm -S -n > rules-vs3;
2. add --ops option;
3. restore LVS rules with ipvsadm-restore < rules-vs3;
4. dump the running LVS rules with ipvsadm -S -n

So, I got two problems here:

1. Dumped rules in step 4 above is not usable anymore, the double-dash
in --ops lost, so I can't restore rule with this dump anymore. This
must be a bug.

2. The --ops option is not working sometimes you applied the rules,
and in most of times the --ops just not working. To make it work, just
'ipvsadm-restore < rules-vs3' for plenty of times until it's working.
I haven't find the patterns make it work yet. This is lucky, I can't
get it work on second host at all.

The "not working" above means the UDP datagrams from one source IP is
sticked to one realserver, it doesn't distribute to other realservers
which --ops designed for.

So I wondering if there's some CONFIG_* options that ipvs needs, or
recent development broke the code?

Here's my hosts, both running updated Gentoo. This is the second host
that --ops doesn't work at all:
vs3 ~ # uname -r
3.10.7-gentoo
vs3 ~ # lspci |grep net
01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5716
Gigabit Ethernet (rev 20)
01:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5716
Gigabit Ethernet (rev 20)
vs3 ~ # emerge --info ipvsadm keepalived
Portage 2.1.12.2 (default/linux/amd64/13.0, gcc-4.6.3, glibc-2.15-r3,
3.10.7-gentoo x86_64)
=================================================================
                         System Settings
=================================================================
System uname: Linux-3.10.7-gentoo-x86_64-Intel-R-_Xeon-R-_CPU_E5620_@_2.40GHz-with-gentoo-2.2
KiB Mem:    16423692 total,  15907924 free
KiB Swap:          0 total,         0 free
Timestamp of tree: Mon, 19 Aug 2013 21:30:01 +0000
ld GNU ld (GNU Binutils) 2.23.1
app-shells/bash:          4.2_p45
dev-lang/python:          2.7.5, 3.2.5-r1
dev-util/pkgconfig:       0.28
sys-apps/baselayout:      2.2
sys-apps/openrc:          0.11.8
sys-apps/sandbox:         2.6-r1
sys-devel/autoconf:       2.69
sys-devel/automake:       1.12.6
sys-devel/binutils:       2.23.1
sys-devel/gcc:            4.6.3
sys-devel/gcc-config:     1.7.3
sys-devel/libtool:        2.4-r1
sys-devel/make:           3.82-r4
sys-kernel/linux-headers: 3.7 (virtual/os-headers)
sys-libs/glibc:           2.15-r3
Repositories: gentoo
ACCEPT_KEYWORDS="amd64"
ACCEPT_LICENSE="* -@EULA"
CBUILD="x86_64-pc-linux-gnu"
CFLAGS="-march=corei7 -O2 -pipe"
CHOST="x86_64-pc-linux-gnu"
CONFIG_PROTECT="/etc /var/bind"
CONFIG_PROTECT_MASK="/etc/ca-certificates.conf /etc/env.d /etc/gconf
/etc/gentoo-release /etc/revdep-rebuild /etc/sandbox.d /etc/terminfo"
CXXFLAGS="-march=corei7 -O2 -pipe"
DISTDIR="/usr/portage/distfiles"
FCFLAGS="-O2 -pipe"
FEATURES="assume-digests binpkg-logs config-protect-if-modified
distlocks ebuild-locks fixlafiles merge-sync news parallel-fetch
preserve-libs protect-owned sandbox sfperms strict
unknown-features-warn unmerge-logs unmerge-orphans userfetch"
FFLAGS="-O2 -pipe"
LANG="en_US.utf8"
LDFLAGS="-Wl,-O1 -Wl,--as-needed"
MAKEOPTS="-j17"
PKGDIR="/usr/portage/packages"
PORTAGE_CONFIGROOT="/"
PORTAGE_RSYNC_OPTS="--recursive --links --safe-links --perms --times
--compress --force --whole-file --delete --stats --human-readable
--timeout=180 --exclude=/distfiles --exclude=/local
--exclude=/packages"
PORTAGE_TMPDIR="/var/tmp"
PORTDIR="/usr/portage"
PORTDIR_OVERLAY=""
USE="acl acpi aio amd64 bash-completion berkdb bzip2 cli cracklib
crypt cxx dri fortran gdbm iconv ipv6 mmap mmx modules mudflap
multilib ncurses nls nptl openmp pam pcre readline session smp sse
sse2 ssl ssse3 tcpd threads unicode vim-syntax zlib" ABI_X86="64"
ALSA_CARDS="ali5451 als4000 atiixp atiixp-modem bt87x ca0106 cmipci
emu10k1x ens1370 ens1371 es1938 es1968 fm801 hda-intel intel8x0
intel8x0m maestro3 trident usb-audio via82xx via82xx-modem ymfpci"
APACHE2_MODULES="authn_core authz_core socache_shmcb unixd actions
alias auth_basic authn_alias authn_anon authn_dbm authn_default
authn_file authz_dbm authz_default authz_groupfile authz_host
authz_owner authz_user autoindex cache cgi cgid dav dav_fs dav_lock
deflate dir disk_cache env expires ext_filter file_cache filter
headers include info log_config logio mem_cache mime mime_magic
negotiation rewrite setenvif speling status unique_id userdir
usertrack vhost_alias" CALLIGRA_FEATURES="kexi words flow plan sheets
stage tables krita karbon braindump author" CAMERAS="ptp2"
COLLECTD_PLUGINS="df interface irq load memory rrdtool swap syslog"
ELIBC="glibc" GPSD_PROTOCOLS="ashtech aivdm earthmate evermore fv18
garmin garmintxt gpsclock itrax mtk3301 nmea ntrip navcom oceanserver
oldstyle oncore rtcm104v2 rtcm104v3 sirf superstar2 timing tsip
tripmate tnt ubx" INPUT_DEVICES="keyboard mouse evdev" KERNEL="linux"
LCD_DEVICES="bayrad cfontz cfontz633 glk hd44780 lb216 lcdm001 mtxorb
ncurses text" LIBREOFFICE_EXTENSIONS="presenter-console
presenter-minimizer" OFFICE_IMPLEMENTATION="libreoffice"
PHP_TARGETS="php5-4" PYTHON_SINGLE_TARGET="python2_7"
PYTHON_TARGETS="python2_7 python3_2" RUBY_TARGETS="ruby19 ruby18"
USERLAND="GNU" VIDEO_CARDS="fbdev glint intel mach64 mga nouveau nv
r128 radeon savage sis tdfx trident vesa via vmware dummy v4l"
XTABLES_ADDONS="quota2 psd pknock lscan length2 ipv4options ipset
ipp2p iface geoip fuzzy condition tee tarpit sysrq steal rawnat
logmark ipmark dhcpmac delude chaos account"
Unset:  CPPFLAGS, CTARGET, EMERGE_DEFAULT_OPTS, INSTALL_MASK, LC_ALL,
PORTAGE_BUNZIP2_COMMAND, PORTAGE_COMPRESS, PORTAGE_COMPRESS_FLAGS,
PORTAGE_RSYNC_EXTRA_OPTS, USE_PYTHON
=================================================================
                        Package Settings
=================================================================
sys-cluster/ipvsadm-1.26-r2 was built with the following:
USE="(multilib) -static-libs" ABI_X86="64"
sys-cluster/keepalived-1.2.2-r4 was built with the following:
USE="ipv6 (multilib) -debug" ABI_X86="64"


And this is the host that --ops works occasionally:
vs4 ~ # uname -r
3.10.7-gentoo
vs4 ~ # lspci |grep net
05:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
Ethernet Controller (Copper) (rev 01)
05:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
Ethernet Controller (Copper) (rev 01)
vs4 ~ # emerge --info ipvsadm keepalived
Portage 2.1.12.2 (default/linux/amd64/13.0, gcc-4.6.3, glibc-2.15-r3,
3.10.7-gentoo x86_64)
=================================================================
                         System Settings
=================================================================
System uname: Linux-3.10.7-gentoo-x86_64-Intel-R-_Xeon-R-_CPU_E5405_@_2.00GHz-with-gentoo-2.2
KiB Mem:     4046544 total,   3192820 free
KiB Swap:          0 total,         0 free
Timestamp of tree: Fri, 16 Aug 2013 21:30:01 +0000
ld GNU ld (GNU Binutils) 2.23.1
app-shells/bash:          4.2_p45
dev-lang/python:          2.7.5, 3.2.5-r1
dev-util/pkgconfig:       0.28
sys-apps/baselayout:      2.2
sys-apps/openrc:          0.11.8
sys-apps/sandbox:         2.6-r1
sys-devel/autoconf:       2.69
sys-devel/automake:       1.12.6
sys-devel/binutils:       2.23.1
sys-devel/gcc:            4.6.3
sys-devel/gcc-config:     1.7.3
sys-devel/libtool:        2.4-r1
sys-devel/make:           3.82-r4
sys-kernel/linux-headers: 3.7 (virtual/os-headers)
sys-libs/glibc:           2.15-r3
Repositories: gentoo
ACCEPT_KEYWORDS="amd64"
ACCEPT_LICENSE="* -@EULA"
CBUILD="x86_64-pc-linux-gnu"
CFLAGS="-march=core2 -O2 -pipe"
CHOST="x86_64-pc-linux-gnu"
CONFIG_PROTECT="/etc /var/bind"
CONFIG_PROTECT_MASK="/etc/ca-certificates.conf /etc/env.d /etc/gconf
/etc/gentoo-release /etc/revdep-rebuild /etc/sandbox.d /etc/terminfo"
CXXFLAGS="-march=core2 -O2 -pipe"
DISTDIR="/usr/portage/distfiles"
FCFLAGS="-O2 -pipe"
FEATURES="assume-digests binpkg-logs config-protect-if-modified
distlocks ebuild-locks fixlafiles merge-sync news parallel-fetch
preserve-libs protect-owned sandbox sfperms strict
unknown-features-warn unmerge-logs unmerge-orphans userfetch"
FFLAGS="-O2 -pipe"
LANG="en_US.utf8"
LDFLAGS="-Wl,-O1 -Wl,--as-needed"
MAKEOPTS="-j5"
PKGDIR="/usr/portage/packages"
PORTAGE_CONFIGROOT="/"
PORTAGE_RSYNC_OPTS="--recursive --links --safe-links --perms --times
--compress --force --whole-file --delete --stats --human-readable
--timeout=180 --exclude=/distfiles --exclude=/local
--exclude=/packages"
PORTAGE_TMPDIR="/var/tmp"
PORTDIR="/usr/portage"
PORTDIR_OVERLAY=""
USE="acl acpi aio amd64 bash-completion berkdb bzip2 cli cracklib
crypt cxx dri fortran gdbm iconv ipv6 mmap mmx modules mudflap
multilib ncurses nls nptl openmp pam pcre readline session smp sse
sse2 ssl ssse3 threads unicode vim-syntax zlib" ABI_X86="64"
ALSA_CARDS="ali5451 als4000 atiixp atiixp-modem bt87x ca0106 cmipci
emu10k1x ens1370 ens1371 es1938 es1968 fm801 hda-intel intel8x0
intel8x0m maestro3 trident usb-audio via82xx via82xx-modem ymfpci"
APACHE2_MODULES="authn_core authz_core socache_shmcb unixd actions
alias auth_basic authn_alias authn_anon authn_dbm authn_default
authn_file authz_dbm authz_default authz_groupfile authz_host
authz_owner authz_user autoindex cache cgi cgid dav dav_fs dav_lock
deflate dir disk_cache env expires ext_filter file_cache filter
headers include info log_config logio mem_cache mime mime_magic
negotiation rewrite setenvif speling status unique_id userdir
usertrack vhost_alias" CALLIGRA_FEATURES="kexi words flow plan sheets
stage tables krita karbon braindump author" CAMERAS="ptp2"
COLLECTD_PLUGINS="df interface irq load memory rrdtool swap syslog"
ELIBC="glibc" GPSD_PROTOCOLS="ashtech aivdm earthmate evermore fv18
garmin garmintxt gpsclock itrax mtk3301 nmea ntrip navcom oceanserver
oldstyle oncore rtcm104v2 rtcm104v3 sirf superstar2 timing tsip
tripmate tnt ubx" INPUT_DEVICES="keyboard mouse evdev" KERNEL="linux"
LCD_DEVICES="bayrad cfontz cfontz633 glk hd44780 lb216 lcdm001 mtxorb
ncurses text" LIBREOFFICE_EXTENSIONS="presenter-console
presenter-minimizer" OFFICE_IMPLEMENTATION="libreoffice"
PHP_TARGETS="php5-4" PYTHON_SINGLE_TARGET="python2_7"
PYTHON_TARGETS="python2_7 python3_2" RUBY_TARGETS="ruby19 ruby18"
USERLAND="GNU" VIDEO_CARDS="fbdev glint intel mach64 mga nouveau nv
r128 radeon savage sis tdfx trident vesa via vmware dummy v4l"
XTABLES_ADDONS="quota2 psd pknock lscan length2 ipv4options ipset
ipp2p iface geoip fuzzy condition tee tarpit sysrq steal rawnat
logmark ipmark dhcpmac delude chaos account"
Unset:  CPPFLAGS, CTARGET, EMERGE_DEFAULT_OPTS, INSTALL_MASK, LC_ALL,
PORTAGE_BUNZIP2_COMMAND, PORTAGE_COMPRESS, PORTAGE_COMPRESS_FLAGS,
PORTAGE_RSYNC_EXTRA_OPTS, USE_PYTHON
=================================================================
                        Package Settings
=================================================================
sys-cluster/ipvsadm-1.26-r2 was built with the following:
USE="(multilib) -static-libs" ABI_X86="64"
sys-cluster/keepalived-1.2.2-r4 was built with the following:
USE="ipv6 (multilib) -debug" ABI_X86="64"

Do I need to attach kernel config file?
