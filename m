From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ipvsadm PATCH 2/3] Add MAINTAINERS style file
Date: Thu, 05 Sep 2013 13:23:14 +0200
Message-ID: <20130905112314.5071.85778.stgit@localhost>
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

Adding a MAINTAINERS file, to make it more clear who is maintaining
the different parts of the IPVS project.

Borrowing the kernel style MAINTAINERS listing.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 MAINTAINERS |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)
 create mode 100644 MAINTAINERS

diff --git a/MAINTAINERS b/MAINTAINERS
new file mode 100644
index 0000000..bd14d45
--- /dev/null
+++ b/MAINTAINERS
@@ -0,0 +1,33 @@
+
+List of maintainers for the different parts of the IPVS project.
+(using kernel style MAINTAINERS listing)
+
+Userspace ipvsadm tool (this tool)
+M:	Jesper Dangaard Brouer <brouer@redhat.com>
+M:	Simon Horman <horms@verge.net.au>
+T:	git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git
+W:	https://kernel.org/pub/linux/utils/kernel/ipvsadm/ (tarballs)
+L:	lvs-devel@vger.kernel.org
+L:	lvs-users@linuxvirtualserver.org
+
+Kernel IPVS
+M:	Simon Horman <horms@verge.net.au>
+M:	Julian Anastasov <ja@ssi.bg>
+M:	Wensong Zhang <wensong@linux-vs.org>
+L:	netdev@vger.kernel.org
+L:	lvs-devel@vger.kernel.org
+S:	Maintained
+F:	Documentation/networking/ipvs-sysctl.txt
+F:	include/net/ip_vs.h
+F:	include/uapi/linux/ip_vs.h
+F:	net/netfilter/ipvs/
+
+Homepage: http://www.linuxvirtualserver.org/
+M:	Wensong Zhang <wensong@linux-vs.org>
+W:	http://www.linuxvirtualserver.org/
+W:	http://www.Linux-vs.org/
+
+Wikipage: http://kb.linuxvirtualserver.org/
+M:	Wensong Zhang <wensong@linux-vs.org>
+M:	Jesper Dangaard Brouer <brouer@redhat.com>
+W:	http://kb.linuxvirtualserver.org/wiki/Main_Page

