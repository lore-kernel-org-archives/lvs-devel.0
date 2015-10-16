From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 2/2] ipvs: allow rescheduling after RST
Date: Fri, 16 Oct 2015 11:07:49 +0300
Message-ID: <1444982869-9600-3-git-send-email-ja@ssi.bg>
References: <1444982869-9600-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1444982869-9600-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Jiri Bohac <jbohac@suse.cz>

"RFC 5961, 4.2. Mitigation" describes a mechanism to request
client to confirm with RST the restart of TCP connection
before resending its SYN. As result, IPVS can see SYNs for
existing connection in CLOSE state. Add check to allow
rescheduling in this state.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 76e9736..aaf3792 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1091,6 +1091,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
 	switch (cp->protocol) {
 	case IPPROTO_TCP:
 		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
+			cp->state == IP_VS_TCP_S_CLOSE ||
 			((conn_reuse_mode & 2) &&
 			 (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
 			 (cp->flags & IP_VS_CONN_F_NOOUTPUT));
-- 
1.9.3

