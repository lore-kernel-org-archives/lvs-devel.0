From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH] ipvs: Kconfig cleanup
Date: Fri,  2 Jul 2010 22:32:08 +0200
Message-ID: <1278102728-20217-1-git-send-email-mmarek@suse.cz>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, linux-kernel@vger.kernel.org

IP_VS_PROTO_AH_ESP should be set iff either of IP_VS_PROTO_{AH,ESP} is
selected. Express this with standard kconfig syntax.

Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 net/netfilter/ipvs/Kconfig |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index f2d7623..91e7373 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -83,19 +83,16 @@ config	IP_VS_PROTO_UDP
 	  protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_AH_ESP
-	bool
-	depends on UNDEFINED
+	def_bool IP_VS_PROTO_ESP || IP_VS_PROTO_AH
 
 config	IP_VS_PROTO_ESP
 	bool "ESP load balancing support"
-	select IP_VS_PROTO_AH_ESP
 	---help---
 	  This option enables support for load balancing ESP (Encapsulation
 	  Security Payload) transport protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_AH
 	bool "AH load balancing support"
-	select IP_VS_PROTO_AH_ESP
 	---help---
 	  This option enables support for load balancing AH (Authentication
 	  Header) transport protocol. Say Y if unsure.
-- 
1.7.1

