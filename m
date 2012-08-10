From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/5] ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
Date: Fri, 10 Aug 2012 10:41:30 +0900
Message-ID: <1344562895-22790-2-git-send-email-horms@verge.net.au>
References: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1344562895-22790-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

	The FTP application indirectly depends on the
nf_conntrack_ftp helper for proper NAT support. If the
module is not loaded, IPVS can resize the packets for the
command connection, eg. PASV response but the SEQ adjustment
logic in ipv4_confirm is not called without helper.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index f987138..8b2cffd 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -250,7 +250,8 @@ comment 'IPVS application helper'
 
 config	IP_VS_FTP
   	tristate "FTP protocol helper"
-        depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT
+	depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT && \
+		NF_CONNTRACK_FTP
 	select IP_VS_NFCT
 	---help---
 	  FTP is a protocol that transfers IP address and/or port number in
-- 
1.7.10.2.484.gcd07cc5

