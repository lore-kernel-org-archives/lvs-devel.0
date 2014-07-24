From: Julian Anastasov <ja@ssi.bg>
Subject: RE: [PATCH ipvs 1/2] ipvs: Do tcp/udp checksumming prior to tunnel
 xmit
Date: Thu, 24 Jul 2014 09:22:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407240915400.1538@ja.home.ssi.bg>
References: <1406097465-8180-1-git-send-email-agartrell@fb.com>,<alpine.LFD.2.11.1407231054180.5114@ja.home.ssi.bg> <B3481EE3D901EA4983A2D2CFBA42F3AA700E2782@PRN-MBX01-3.TheFacebook.com> <alpine.LFD.2.11.1407240116400.2125@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1407240116400.2125@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, kernel-team <Kernel-team@fb.com>


	Hello,

On Thu, 24 Jul 2014, Julian Anastasov wrote:

> 	There is skb_checksum_help() call in
> dev_hard_start_xmit(), it is used when TCP/UDP offload is
> not supported. After checking the code I see only the
> CHECKSUM_PARTIAL + Enabled TCP/UDP CSum as a problem because
> the drivers use the skb->encapsulation flag to know where the
> TCP/UDP header resides. As tunnels prepend tunnel header
> they should set skb->encapsulation=1 together with
> calling skb_reset_inner_headers() before the header is
> inserted.
> 
> 	Following is a patch for the net tree that needs
> testing because I don't have setup to fully test it.
> I hope you can try it on your setup for the 3 tests.
> It should have effect only on your 2nd test. Do you
> have problems with tests 1 and 3?

	I just saw that changing skb->transport_header
before skb_reset_inner_headers() and iptunnel_handle_offloads()
can cause problems. Not sure if skb->transport_header
is used later when skb->encapsulation = 1, the strange thing
is that ip6_tnl_xmit2() changes it before skb_reset_inner_headers(),
this can lead to wrong skb->inner_transport_header.

[PATCH net] ipvs: properly declare tunnel encapsulation

The tunneling method should properly use tunnel encapsulation.
Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
offload is supported and skb->encapsulation is not set to 1.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 73ba1cc..e093580 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -38,6 +38,7 @@
 #include <net/route.h>                  /* for ip_route_output */
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/ip_tunnels.h>
 #include <net/addrconf.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
@@ -483,10 +484,8 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	skb->ipvs_property = 1;
 	if (unlikely(cp->flags & IP_VS_CONN_F_NFCT))
 		ret = ip_vs_confirm_conntrack(skb);
-	if (ret == NF_ACCEPT) {
+	if (ret == NF_ACCEPT)
 		nf_reset(skb);
-		skb_forward_csum(skb);
-	}
 	return ret;
 }
 
@@ -862,14 +861,19 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ip_hdr(skb);
 	}
 
-	skb->transport_header = skb->network_header;
-
 	/* fix old IP header checksum */
 	ip_send_check(old_iph);
 
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	if (IS_ERR(skb))
+		goto tx_error_unlock;
+
+	skb->transport_header = skb->network_header;
+
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	skb_clear_hash(skb);
 
 	/*
 	 *	Push down and install the IPIP header.
@@ -901,6 +905,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
   tx_error:
 	kfree_skb(skb);
+
+tx_error_unlock:
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -953,6 +959,12 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ipv6_hdr(skb);
 	}
 
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+	skb_forward_csum(skb);
+
 	skb->transport_header = skb->network_header;
 
 	skb_push(skb, sizeof(struct ipv6hdr));
-- 
1.9.0

Regards

--
Julian Anastasov <ja@ssi.bg>
