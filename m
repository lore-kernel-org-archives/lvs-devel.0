From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
Date: Sat,  7 Jul 2012 20:32:12 +0300
Message-ID: <1341682332-4809-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

	The FTP application indirectly depends on the
nf_conntrack_ftp helper for proper NAT support. If the
module is not loaded, IPVS can resize the packets for the
command connection, eg. PASV response but the SEQ adjustment
logic in ipv4_confirm is not called without helper.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

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
1.7.3.4

