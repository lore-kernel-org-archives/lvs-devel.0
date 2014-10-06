From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: Avoid null-pointer deref in debug code
Date: Mon, 6 Oct 2014 08:46:19 -0700
Message-ID: <1412610379-6295-1-git-send-email-agartrell@fb.com>
References: <20141006073232.GA10073@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=b1JM8CANwDxk2oGQUtE6Gg22EvoDTBMUxWWsFktlAss=;
 b=fAf0323MkTk87jWbNyNCXe24UeTQ/TKdUlIzca7c4/MCOjuSF2El+nGg1ka6xHrd7eQC
 miXxn34g9VGM8ojqlq79/5sJgMlhSFJjmT1h0pbxdvJ5T7OVlfMtjyy8MknTFvk3Fs/J
 RGeKeWSDzocWmB69ueP8Zlt7v6pFYWeBKYs= 
In-Reply-To: <20141006073232.GA10073@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, dan.carpenter@oracle.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

Use daddr instead of reaching into dest.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..437a366 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -316,7 +316,7 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI4\n", &dest->addr.ip);
+			     " daddr=%pI4\n", &daddr);
 		goto err_put;
 	}
 
@@ -458,7 +458,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 	if (unlikely(crosses_local_route_boundary(skb_af, skb, rt_mode,
 						  local))) {
 		IP_VS_DBG_RL("We are crossing local and non-local addresses"
-			     " daddr=%pI6\n", &dest->addr.in6);
+			     " daddr=%pI6\n", daddr);
 		goto err_put;
 	}
 
-- 
Alex Gartrell <agartrell@fb.com>

