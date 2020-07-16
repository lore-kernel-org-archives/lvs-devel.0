From: Andrew Sy Kim <kim.andrewsy@gmail.com>
Subject: [PATCH net-next] ipvs: ensure RCU read unlock when connection flushing and ipvs is disabled
Date: Thu, 16 Jul 2020 13:03:14 -0400
Message-ID: <20200716170314.9617-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=+cTYKrIZGIZVopU+BckUssD7pZ9lKGNH0yEl3jPyoXM=;
        b=X0m5FsJRJcZvg+C03g6IVxn4mV5SvH+bqDqn8BmS1O44A3Q89s7vwJt6iXTn06Mk9f
         BCCMsuyp/R1k8p+tCjgrloI0iJSwfXy+ButeOdWUsBSjjzIVlTpWydjbe+3/2JuObISJ
         aLrKGp+aag4KtfUiHdpIb3DlMSxb8Ci/SSkNGURI+nBIfEo9rbVJdEubjYjU/HvDUycl
         t2SNi6R4yPw66MxhjmgE0I7SE5PxteqDx0OkISzEI1BOZp/t+r0u+3ucy69Tz7EjN7dB
         z3OLo1qxmT2+lBxVV627iEQnBmJgk4ovlaDHrRI2pktc5lDhGEOU0Gwn0s+u6JNN/90U
         SiTA==
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: 
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Andrew Sy Kim <kim.andrewsy@gmail.com>

When ipvs is disabled in ip_vs_expire_nodest_conn_flush,
we should break instead of return so that rcu_read_unlock()
is run.

Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a5e9b2d55e57..a90b8eac16ac 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1422,7 +1422,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
 
 		/* netns clean up started, abort delayed work */
 		if (!ipvs->enable)
-			return;
+			break;
 	}
 	rcu_read_unlock();
 }
-- 
2.20.1

