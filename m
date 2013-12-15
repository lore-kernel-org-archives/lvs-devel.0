From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: avoid oops in nf_ct_seqadj_set when called from
 ip_vs_ftp helper
Date: Sun, 15 Dec 2013 18:10:42 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1312151709260.6463@ja.home.ssi.bg>
References: <20131213214023.14478.74738.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131213214023.14478.74738.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>


	Hello,

On Fri, 13 Dec 2013, Jesper Dangaard Brouer wrote:

> The IPVS FTP helper ip_vs_ftp can trigger an OOPS in nf_ct_seqadj_set,
> after commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence
> number adjustments usuable without NAT).
> 
> We can avoid the oops in nf_ct_seqadj_set() by in ip_vs_ftp_out()
> instead of calling nf_nat_mangle_tcp_packet() we simply call
> __nf_nat_mangle_tcp_packet() with a "false" last parameter, which
> indicate not invoking the seqadj code.
> 
> After this fix, I've tested that FTP over IPVS, with module ip_vs_ftp
> loaded, works for both passive and active FTP.
> 
> Fixes: 41d73ec053d2 (netfilter: nf_conntrack: make sequence number adjustments usuable without NAT)
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> ---
> I'm uncertain if this is the correct fix.  Perhaps the ip_vs_ftp
> helper need to allocate/init the seqadj extension instead?

	I hope I'll save you some time... What do you
think about such change:

[PATCH net] ipvs: use the new seqadj interface from ip_vs_ftp

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 77c1732..9c2074d 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -34,6 +34,7 @@
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <linux/gfp.h>
@@ -260,7 +261,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		buf_len = strlen(buf);
 
 		ct = nf_ct_get(skb, &ctinfo);
-		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
+		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct) &&
+		    nfct_seqadj(ct)) {
 			/* If mangling fails this function will return 0
 			 * which will cause the packet to be dropped.
 			 * Mangling can only fail under memory pressure,
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index c8beafd..5a355a4 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -63,6 +63,7 @@
 #include <net/ip_vs.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
@@ -97,6 +98,11 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		return;
 
+	/* Applications may adjust TCP seqs */
+	if (cp->app && nf_ct_protonum(ct) == IPPROTO_TCP &&
+	    !nfct_seqadj(ct) && !nfct_seqadj_ext_add(ct))
+		return;
+
 	/*
 	 * The connection is not yet in the hashtable, so we update it.
 	 * CIP->VIP will remain the same, so leave the tuple in
-- 
1.8.4.2

Regards

--
Julian Anastasov <ja@ssi.bg>
