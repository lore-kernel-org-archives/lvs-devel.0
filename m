From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/8] ipvs: drop SCTP connections depending on state
Date: Wed, 26 Jun 2013 18:11:26 +0900
Message-ID: <1372237890-28211-5-git-send-email-horms@verge.net.au>
References: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1372237890-28211-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Drop SCTP connections under load (dropentry context) depending
on the protocol state, just like for TCP: INIT conns are
dropped immediately, established are dropped randomly while
connections in progress or shutdown are skipped.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index c8c52a9..4c8e5c0 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1231,6 +1231,18 @@ void ip_vs_random_dropentry(struct net *net)
 				default:
 					continue;
 				}
+			} else if (cp->protocol == IPPROTO_SCTP) {
+				switch (cp->state) {
+				case IP_VS_SCTP_S_INIT1:
+				case IP_VS_SCTP_S_INIT:
+					break;
+				case IP_VS_SCTP_S_ESTABLISHED:
+					if (todrop_entry(cp))
+						break;
+					continue;
+				default:
+					continue;
+				}
 			} else {
 				if (!todrop_entry(cp))
 					continue;
-- 
1.8.2.1

