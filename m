From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 8/9] ipvs: off by one in set_sctp_state()
Date: Tue, 23 Apr 2013 12:03:59 +0900
Message-ID: <1366686240-23493-9-git-send-email-horms@verge.net.au>
References: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, Simon Horman <horms@verge.net.au>

From: Dan Carpenter <dan.carpenter@oracle.com>

The sctp_events[] come from sch->type in set_sctp_state().  They are
between 0-255 so that means we need 256 elements in the array.

I believe that because of how the code is aligned there is normally a
hole after sctp_events[] so this patch doesn't actually change anything.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 6e14a7b..8646488 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -208,7 +208,7 @@ enum ipvs_sctp_event_t {
 	IP_VS_SCTP_EVE_LAST
 };
 
-static enum ipvs_sctp_event_t sctp_events[255] = {
+static enum ipvs_sctp_event_t sctp_events[256] = {
 	IP_VS_SCTP_EVE_DATA_CLI,
 	IP_VS_SCTP_EVE_INIT_CLI,
 	IP_VS_SCTP_EVE_INIT_ACK_CLI,
-- 
1.8.2.1
