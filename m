From: Anders Henke <anders.henke@1und1.de>
Subject: [PATCH] libipvs: Fix initialization of netlink (needed for IPv6)
Date: Thu, 9 Feb 2012 15:00:01 +0100
Message-ID: <20120209140001.GB22237@1und1.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

we've been investigating a few minor issues with LVS and keepalived; a=20
freelance developer at my team also prepared a couple of smaller patches=20
to resolve those issues we'd like to contribute to the general LVS public.

=3D=3D=3D Fix Netlink Init

When the kernel module for ip_vs hasn't been loaded yet and an
application (say, keepalived) tries to call ipvs, IPVS assumes
netlink not to be present and triggers another load attempt
of the kernel module, but without re-testing for netlink.
In the end, netlink isn't being used. However, netlink is essential
for running IPVS with IPv6.

Attached is a oneline-patch for libipvs to adress this issue; it is
based upon commit 91c61a85dccffd00dd6e887d24302443e412433d from
http://master.formilux.org/git/people/alex/keepalived.git,
but is simple enough to be applied to almost any other
release of libipvs as well.

As it's directly related to keepalived and they do seem to keep their own
copy of libipvs, I'll post this patch to keepalived-devel as well
(among a few other patches).


Best,

Anders
--=20
1&1 Internet AG              Expert Systems Architect (IT Operations)
Brauerstrasse 48             v://49.721.91374.0
D-76135 Karlsruhe            f://49.721.91374.225

Amtsgericht Montabaur HRB 6484
Vorst=E4nde: Henning Ahlert, Ralph Dommermuth, Matthias Ehrlich, Robert Hof=
fmann,
Markus Huhn, Hans-Henning Kettler, Dr. Oliver Mauss, Jan Oetjen

Aufsichtsratsvorsitzender: Michael Scheeren


--fUYQa+Pmc3FrFX/N
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-libipvs-Fix-initialization-of-netlink-needed-for-IPv.patch"

From cf8ff745812b7fe00d509fb50592348b6f60b433 Mon Sep 17 00:00:00 2001
From: Alexander Holler <alexander.holler@1und1.de>
Date: Mon, 9 Jan 2012 12:58:12 +0100
Subject: [PATCH] libipvs: Fix initialization of netlink (needed for IPv6)
 when the module ip_vs wasn't loaded.

The following happened when keepalived was started before the module for IPVS was loaded:

ipvs_init() failed => netlink got disabled.
modprobe_ipvs()
ipvs_init() => netlink was not tested again => no netlink => no IPv6

Fixed through testing netlink always in ipvs_init().
---
 keepalived/libipvs-2.6/libipvs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/keepalived/libipvs-2.6/libipvs.c b/keepalived/libipvs-2.6/libipvs.c
index 2c75118..ea5e851 100644
--- a/keepalived/libipvs-2.6/libipvs.c
+++ b/keepalived/libipvs-2.6/libipvs.c
@@ -114,6 +114,8 @@ int ipvs_init(void)
 	ipvs_func = ipvs_init;
 
 #ifdef LIBIPVS_USE_NL
+	try_nl = 1;
+
 	if (ipvs_nl_send_message(NULL, NULL, NULL) == 0) {
 		return ipvs_getinfo();
 	}
-- 
1.7.6.5


--fUYQa+Pmc3FrFX/N--
