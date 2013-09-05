From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ipvsadm PATCH 1/3] Make README more generic and reference new
 kernel.org location
Date: Thu, 05 Sep 2013 13:23:09 +0200
Message-ID: <20130905112308.5071.6480.stgit@localhost>
References: <20130905112303.5071.14612.stgit@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130905112303.5071.14612.stgit@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Ryan O'Hara <rohara@redhat.com>

The old README were written for Version 1.20 - 18th September 2001.
Change this to be more generic for future releases.

Make it clear that SCM/git repository have been moved to kernel.org:
 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git

And release tarball also have moved to kernel.org:
 https://kernel.org/pub/linux/utils/kernel/ipvsadm/

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 README |   26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/README b/README
index 54474e5..2e62008 100644
--- a/README
+++ b/README
@@ -1,21 +1,31 @@
 --------------------------------------------------------------------------
 
-ipvsadm - Version 1.20 - 18th September 2001
+ipvsadm
 
 This is free software.  See below for details.
 
-ipvsadm is a utility to administer the IP virtual server services
-offered by the Linux kernel with IP virtual server support.
+ipvsadm is a utility to administer the IP Virtual Server (IPVS)
+services offered by the Linux kernel with IPVS support to create a
+wide range of load-balancer setups.
 
-This version of ipvsadm requires IPVS module v0.9.7 for kernel 2.4 or
-later.  Check out the Linux Virtual Server Project home page on the
+Check out the Linux Virtual Server Project home page on the
 World Wide Web:
 	http://www.LinuxVirtualServer.org/
 	or
 	http://www.Linux-VS.org/
-for the most recent information and original sources about ipvsadm.
+for the most recent information about ipvsadm.
 
-To make, make sure your Linux kernel is already patched with IPVS and 
+Releases can be downloaded from:
+ https://kernel.org/pub/linux/utils/kernel/ipvsadm/
+
+The source code is available via git from kernel.org:
+ https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git
+ git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git
+
+A wikipage is available at:
+ http://kb.linuxvirtualserver.org/wiki/Main_Page
+
+To make, make sure your Linux kernel is compiled with IPVS, e.g. by invoking
 "make menuconfig" or "make xconfig" to setup the right compiling options, 
 see the README of the virtual server patch for detail, then simply type
 	make
@@ -35,7 +45,7 @@ in the source directory.
 
 
 Wensong Zhang <wensong@linuxvirtualserver.org>
