From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 01/84] ipvs: Hoist computation of ipvs earlier in sctp_conn_schedule
Date: Sun, 20 Sep 2015 01:22:17 -0500
Message-ID: <1442730220-32458-1-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

The addition of sysctl_sloppy_sctp in sctp_conn_schedule resulted
in a use of ipvs before it was computed.  Hoist the computation of
ipvs earlier to avoid this problem.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 2026fca7e1c3..ac628a9afdb5 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -20,6 +20,9 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	sctp_sctphdr_t *sh, _sctph;
 	__be16 _ports[2], *ports = NULL;
 
+	net = skb_net(skb);
+	ipvs = net_ipvs(net);
+
 	if (likely(!ip_vs_iph_icmp(iph))) {
 		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
 		if (sh) {
@@ -40,8 +43,6 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		return 0;
 	}
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
 	rcu_read_lock();
 	if (likely(!ip_vs_iph_inverse(iph)))
 		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-- 
2.2.1

