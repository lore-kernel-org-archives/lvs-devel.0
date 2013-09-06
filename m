From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ANNOUNCE] ipvsadm release v1.27
Date: Fri, 6 Sep 2013 10:58:56 +0200
Message-ID: <20130906105856.466aa103@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/RxodrJFzld1_TaruaWOsSkE"; protocol="application/pgp-signature"
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Ryan O'Hara <rohara@redhat.com>, Daniel Borkmann <dborkman@redhat.com>, Alexander Frolkin <avf@eldamar.org.uk>

--Sig_/RxodrJFzld1_TaruaWOsSkE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


We are happy to announce the release of ipvsadm v1.27.

 ipvsadm is a utility to administer the kernels IPVS/LVS load-balancer serv=
ice

It have been quite a while since the last release of ipvsadm, as v1.26
were released on February 8, 2011.  Since then, the source code
repository have been converted into git.

This is the first released based on the kernel.org git tree:
  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/

You can download the tarballs from:
 https://kernel.org/pub/linux/utils/kernel/ipvsadm/

The older releases are also available via:
 http://www.linuxvirtualserver.org/software/ipvs.html#kernel-2.6
 http://www.linuxvirtualserver.org/software/kernel-2.6/

Maintainers:
 Simon Horman <horms@verge.net.au>
 Jesper Dangaard Brouer <brouer@redhat.com>
 Wensong Zhang <wensong@linux-vs.org>

The development have slowed down over the past years, as the tool and
kernel in this area have stabilized.  As can be seen by the shortlog
below, this release mostly contains bug fixes for existing features.

With one exception commit 3141694c (ipvsadm: support for scheduler flags)
by Alexander Frolkin, adds support for a new feature in kernel v3.11
introduced in kernel commit eba3b5a787 (ipvs: SH fallback and L4 hashing).

Shortlog:
---------
Alexander Frolkin (1):
      ipvsadm: support for scheduler flags

Alexander Holler (1):
      libipvs: Fix initialization of netlink (needed for IPv6) when the mod=
ule ip_vs wasn't loaded.

Daniel Borkmann (1):
      libipvs: libnl3: fix compilation error

Henrique Mecking (1):
      libipvs: Fix memory leak

Jesper Dangaard Brouer (6):
      ipvsadm: fix compiling tool on distros with only libnl-1
      ipvsadm: detect LIBS and CFLAGS for libnl versions
      Make README more generic and reference new kernel.org location
      Add MAINTAINERS style file
      Maintainer script for releasing tarballs
      Release: Version 1.27

Julian Anastasov (4):
      Fix the --pe option checks
      Fallback to libpopt on shared object
      ipvsadm: Fix wrong format of --pe option in FMT_RULE listing
      ipvsadm: init svc in ipvs_get_service

Krzysztof Gajdemski (2):
      ipvsadm: Fix wrong format of -o option in FMT_RULE listing
      ipvsadm: Show 'ops' flag regardless of service persistence

Ryan O'Hara (4):
      ipvsadm: fix list_daemon to handle master/backup status in either pos=
ition
      ipvsadm: Fix svc->pe_name conditional
      libipvs: Remove redundant CHECK_PE
      libipvs: CHECK_IPV4 and CHECK_PE macros should not call return

Simon Horman (1):
      Linking against libpopt is always requited

Tim Serong (1):
      ipvsadm: Fix buffer overrun in ipvs_dests_parse_cb()

wensong (1):
      exclude the .svn directory and the TAGS file while making distribution

--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--Sig_/RxodrJFzld1_TaruaWOsSkE
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iF4EAREIAAYFAlIpmV4ACgkQOlVNAzs3vO1V7gEAmY5deaZT5PCJXR9upWaDzWKR
Aqfe98PbAahW8Xj2btUBAIHz6gGTvk9+OsO7JowthYwBMMDAGyaea8X5hlnBUXPM
=xkmC
-----END PGP SIGNATURE-----

--Sig_/RxodrJFzld1_TaruaWOsSkE--
