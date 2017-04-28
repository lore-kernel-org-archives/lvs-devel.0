From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] ipvs: change comparison on sync_refresh_period
Date: Fri, 28 Apr 2017 12:11:59 +0200
Message-ID: <20170428101159.9810-3-horms@verge.net.au>
References: <20170428101159.9810-1-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1493374324; bh=fnkWEX3yM5+jaVAfXMH2H5rfHnJ1X+9AHMxd3oEab3k=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=pElAIGj8SqsR7mFV5C6uy6kitWFV3tS1PqPS1aA08J9IpbtxAI9PusBWt3REd/Vre
         4v0C1q7AqMY1ALvNOfjx7gmFto+66GKMAGf3OyYGYk2AX5UltyWwR/OMq7qQYXlU7S
         8XIsDuqPS5YrxWUFDqGJvCHjbPdlhUVFxRzR14eQ=
In-Reply-To: <20170428101159.9810-1-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Aaron Conole <aconole@bytheb.org>, Simon Horman <horms@verge.net.au>

From: Aaron Conole <aconole@bytheb.org>

The sync_refresh_period variable is unsigned, so it can never be < 0.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 30d6b2cc00a0..0e5b64a75da0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -520,7 +520,7 @@ static int ip_vs_sync_conn_needed(struct netns_ipvs *ipvs,
 		if (!(cp->flags & IP_VS_CONN_F_TEMPLATE) &&
 		    pkts % sync_period != sysctl_sync_threshold(ipvs))
 			return 0;
-	} else if (sync_refresh_period <= 0 &&
+	} else if (!sync_refresh_period &&
 		   pkts != sysctl_sync_threshold(ipvs))
 		return 0;
 
-- 
2.12.2.816.g2cccc81164

