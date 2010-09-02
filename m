From: Simon Horman <horms@verge.net.au>
Subject: [patch net] ipvs: avoid oops for passive FTP
Date: Thu, 2 Sep 2010 18:07:10 +0900
Message-ID: <20100902090709.GA15401@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

From: Julian Anastasov <ja@ssi.bg>

Fix Passive FTP problem in ip_vs_ftp:

- Do not oops in nf_nat_set_seq_adjust (adjust_tcp_sequence) when
  iptable_nat module is not loaded

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

Dave, this patch fixes a regression since 2.6.35 so please consider it for net.
Julian has also found another regression, but the fix is a bit
more complex so I have posted it to the netfilter list for review.

	http://marc.info/?l=netfilter-devel&m=128339248723532&w=2

This change (and the other one) is also applicable to net-next, although
there is some diff noise. Do you want me to resolve that and post a
net-next version separately?

--- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-02 00:45:54.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-02 02:12:52.000000000 +0300
@@ -45,6 +45,7 @@
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <linux/gfp.h>
 #include <net/protocol.h>
@@ -359,7 +360,7 @@ static int ip_vs_ftp_out(struct ip_vs_ap
 		buf_len = strlen(buf);
 
 		ct = nf_ct_get(skb, &ctinfo);
-		if (ct && !nf_ct_is_untracked(ct)) {
+		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
 			/* If mangling fails this function will return 0
 			 * which will cause the packet to be dropped.
 			 * Mangling can only fail under memory pressure,
