From: Yejune Deng <yejune.deng@gmail.com>
Subject: [PATCH] ipvs: replace atomic_add_return()
Date: Mon, 16 Nov 2020 16:01:47 +0800
Message-ID: <1605513707-7579-1-git-send-email-yejune.deng@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=9Y1yLZPbBL2X5WIYzh0MGolabV4K2PbjAEx9PhCuf+Q=;
        b=kpM8zXJ/HI3JAXzLtyf43BKIVH0eKHa0+/czdTViRIu70kSn8YwBwt5Rin3vQ1B/V5
         7rXATO838psjNSblinn929eJATjAnVZjiR9bnBk7hZCcLju6mVRew6AJMrt7wFc1Fl7S
         Z4caCceE4pIaUUNt8DXbXosT+gL+8NBJSi+6VSoqKw3MwAzoY9hX8xE/41NgWxBDT2cz
         VytAjDZDgdc1kgxYrOIabmqd6Nab8eg0PTEn3nDiLhbeERmkgdQNx0QEg16oqQ+mrgae
         1m0uVRk2yg2jAyfXUj0VOdFRGT45FT3oSt4te7MN+DRJpItPZs1OXwD4UwfwkMWN3IGD
         R89A==
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, yejune.deng@gmail.com

atomic_inc_return() looks better

Signed-off-by: Yejune Deng <yejune.deng@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 +-
 net/netfilter/ipvs/ip_vs_sync.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index c0b8215..54e086c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2137,7 +2137,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
 		pkts = sysctl_sync_threshold(ipvs);
 	else
-		pkts = atomic_add_return(1, &cp->in_pkts);
+		pkts = atomic_inc_return(&cp->in_pkts);
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(ipvs, cp, pkts);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 16b4806..9d43277 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -615,7 +615,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
 	cp = cp->control;
 	if (cp) {
 		if (cp->flags & IP_VS_CONN_F_TEMPLATE)
-			pkts = atomic_add_return(1, &cp->in_pkts);
+			pkts = atomic_inc_return(&cp->in_pkts);
 		else
 			pkts = sysctl_sync_threshold(ipvs);
 		ip_vs_sync_conn(ipvs, cp, pkts);
@@ -776,7 +776,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
 	if (!cp)
 		return;
 	if (cp->flags & IP_VS_CONN_F_TEMPLATE)
-		pkts = atomic_add_return(1, &cp->in_pkts);
+		pkts = atomic_inc_return(&cp->in_pkts);
 	else
 		pkts = sysctl_sync_threshold(ipvs);
 	goto sloop;
-- 
1.9.1

