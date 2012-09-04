From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: ipvs: memset problem/bug in ip_vs_tunnel_xmit_v6() ?
Date: Tue, 04 Sep 2012 11:52:38 +0200
Message-ID: <1346752358.3069.594.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: LVS devel <lvs-devel@vger.kernel.org>, Julian Anastasov <ja@ssi.bg>


Hi 

While looking at the IP6CB related code in IPVS, I stumbled upon this,
memset in ip_vs_tunnel_xmit_v6() which look wrong in a IPv6 related
function...

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c
b/net/netfilter/ipvs/ip_vs_xmit.c
index 1060bd5..7efa90c 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -998,6 +998,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct
ip_vs_conn *cp,
 
        skb_push(skb, sizeof(struct ipv6hdr));
        skb_reset_network_header(skb);
+       /* jbrouer: Hmmm, memset below looks wrong in a IPv6 context */
        memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 
        /* drop old route */


The change looks like a copy-paste introduced in commit:

commit b3cdd2a73867d309dca288b8e820c09e3b7f1da1
Author: Julius Volz <juliusv@google.com>
Date:   Tue Sep 2 15:55:45 2008 +0200

    IPVS: Add and bind IPv6 xmit functions
    
    Add xmit functions for IPv6. Also add the already needed __ip_vs_get_out_rt_v6()
    to ip_vs_core.c. Bind the new xmit functions to v6 connections.
    
    Signed-off-by: Julius Volz <juliusv@google.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


