From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/2] net: ipvs: sctp: add missing verdict assignments in sctp_conn_schedule
Date: Wed, 30 Oct 2013 10:11:25 +0900
Message-ID: <1383095486-5215-2-git-send-email-horms@verge.net.au>
References: <1383095486-5215-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1383095486-5215-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Daniel Borkmann <dborkman@redhat.com>, Simon Horman <horms@verge.net.au>

From: Daniel Borkmann <dborkman@redhat.com>

If skb_header_pointer() fails, we need to assign a verdict, that is
NF_DROP in this case, otherwise, we would leave the verdict from
conn_schedule() uninitialized when returning.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 23e596e..9ca7aa0 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -20,13 +20,18 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	sctp_sctphdr_t *sh, _sctph;
 
 	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
-	if (sh == NULL)
+	if (sh == NULL) {
+		*verdict = NF_DROP;
 		return 0;
+	}
 
 	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
 				 sizeof(_schunkh), &_schunkh);
-	if (sch == NULL)
+	if (sch == NULL) {
+		*verdict = NF_DROP;
 		return 0;
+	}
+
 	net = skb_net(skb);
 	ipvs = net_ipvs(net);
 	rcu_read_lock();
-- 
1.8.4

