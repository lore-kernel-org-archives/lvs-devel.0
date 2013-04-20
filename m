From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ipvs: off by one in set_sctp_state()
Date: Sat, 20 Apr 2013 14:24:55 +0300
Message-ID: <20130420112455.GA30198@elgon.mountain>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org

The sctp_events[] come from sch->type in set_sctp_state().  They are
between 0-255 so that means we need 256 elements in the array.

I believe that because of how the code is aligned there is normally a
hole after sctp_events[] so this patch doesn't actually change anything.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is static checker stuff.  I'm not very familiar with this code.

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
