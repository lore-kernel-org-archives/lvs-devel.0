From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Sun, 5 Oct 2014 17:54:55 -0700
Message-ID: <1412556895-26891-1-git-send-email-agartrell@fb.com>
References: <20141001174526.GA16206@mwanda>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=R9u9AwdATiwI4u82F0kdr2VSYUcsDjFNAy/YdSIzTfM=;
 b=TuMG+u0OjSURXVZQjyKh4T2SUOJv9rNASIQXWNqag5EShACMvmvY5JbPVASqsrEmgr8M
 RRWM4PazegmqAbdBVx03yONoHW+rs9SqkSTYwtRSUvGXOfUbltQGvhIsrjuz6qhdTiKw
 9QzCtfk7B0wZ6e9ncRBR6xD5zUt9OMOU4QU= 
In-Reply-To: <20141001174526.GA16206@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, dan.carpenter@oracle.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Ensure that the pointer is non-NULL before dereferencing it for debugging
purposes.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..06bba9b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI4\n", &dest->addr.ip);
+			     " daddr=%pI4\n", dest ? &dest->addr.ip : NULL);
 		goto err_put;
 	}
 
@@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI6\n", &dest->addr.in6);
+			     " daddr=%pI6\n", dest ? &dest->addr.in6 : NULL);
 		goto err_put;
 	}
 
-- 
Alex Gartrell <agartrell@fb.com>
