From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 3/3] ipvs: drop SCTP connections depending on state
Date: Tue, 18 Jun 2013 10:08:08 +0300
Message-ID: <1371539288-5036-4-git-send-email-ja@ssi.bg>
References: <1371539288-5036-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1371539288-5036-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

Drop SCTP connections under load (dropentry context) depending
on the protocol state, just like for TCP: INIT conns are
dropped immediately, established are dropped randomly while
connections in progress or shutdown are skipped.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_conn.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

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
1.7.3.4

