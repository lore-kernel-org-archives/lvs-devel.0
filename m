From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: fix matching of fwmark templates during scheduling
Date: Fri, 27 Jan 2012 10:45:27 +0900
Message-ID: <1327628727-22482-2-git-send-email-horms@verge.net.au>
References: <1327628727-22482-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1327628727-22482-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	Commit f11017ec2d1859c661f4e2b12c4a8d250e1f47cf (2.6.37)
moved the fwmark variable in subcontext that is invalidated before
reaching the ip_vs_ct_in_get call. As vaddr is provided as pointer
in the param structure make sure the fwmark variable is in
same context. As the fwmark templates can not be matched,
more and more template connections are created and the
controlled connections can not go to single real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Cc: stable@vger.kernel.org
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 093cc32..6dc7d7d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -232,6 +232,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	__be16 dport = 0;		/* destination port to forward */
 	unsigned int flags;
 	struct ip_vs_conn_param param;
+	const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
 	union nf_inet_addr snet;	/* source network of the client,
 					   after masking */
 
@@ -267,7 +268,6 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	{
 		int protocol = iph.protocol;
 		const union nf_inet_addr *vaddr = &iph.daddr;
-		const union nf_inet_addr fwmark = { .ip = htonl(svc->fwmark) };
 		__be16 vport = 0;
 
 		if (dst_port == svc->port) {
-- 
1.7.6.3

