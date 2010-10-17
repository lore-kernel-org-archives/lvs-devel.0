From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 11/12] ipvs: inherit forwarding method in backup
Date: Sun, 17 Oct 2010 16:43:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010171640520.20665@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


 	Connections in backup server should inherit the
forwarding method from real server. It is a way to fix a
problem where the forwarding method in backup connection
is damaged by logical OR operation with the real server's
connection flags. And the change is needed for setups
where the backup server uses different forwarding method
for the same real servers.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_conn.c linux/net/netfilter/ipvs/ip_vs_conn.c
--- nf-next-2.6-a91fd26/linux/net/netfilter/ipvs/ip_vs_conn.c	2010-10-13 22:22:35.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_conn.c	2010-10-16 21:00:44.819355693 +0300
@@ -563,6 +563,8 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, s
  		 */
  		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE))
  			conn_flags &= ~IP_VS_CONN_F_INACTIVE;
+		/* connections inherit forwarding method from dest */
+		cp->flags &= ~IP_VS_CONN_F_FWD_MASK;
  	}
  	cp->flags |= conn_flags;
  	cp->dest = dest;
