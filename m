From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH ipvs 1/2] net: ipvs: sctp: add missing verdict assignments in sctp_conn_schedule
Date: Fri, 25 Oct 2013 11:05:04 +0200
Message-ID: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com>
References: <cover.1382689350.git.dborkman@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1382689350.git.dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

If skb_header_pointer() fails, we need to assign a verdict, that is
NF_DROP in this case, otherwise, we would leave the verdict from
conn_schedule() uninitialized when returning.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
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
1.7.11.7

