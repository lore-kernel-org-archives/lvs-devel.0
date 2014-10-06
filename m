From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ipvs: remove unnecessary assignment in __ip_vs_get_out_rt
Date: Mon, 6 Oct 2014 13:30:08 -0700
Message-ID: <1412627408-13766-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=XWVD8JF71seFYY9ONOFfArjLF/HexCHjCn7wqUGsltc=;
 b=XjTBDlztsfatuaEViDOhTn9s/amaIezmQ++sLEIoxis3Sia+IdTSu/R2PH8ASTPIoZnq
 KfoYBTmN90qADGp9Zvj65N+GHpaPNtrydOXuQVAJlUqAIkVQpc6WC9DLb+I8BBLTKFvB
 oywkqJm+cD8YPB+IaVWoFNZFlqQKD2ZODro= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

It is a precondition of the function that daddr be equal to dest->addr.ip
if dest is non-NULL, so this additional assignment is just confusing for
stupid engineers like me.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 91f17c1..5efa597 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -293,7 +293,6 @@ __ip_vs_get_out_rt(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 				  &dest->addr.ip, &dest_dst->dst_saddr.ip,
 				  atomic_read(&rt->dst.__refcnt));
 		}
-		daddr = dest->addr.ip;
 		if (ret_saddr)
 			*ret_saddr = dest_dst->dst_saddr.ip;
 	} else {
-- 
Alex Gartrell <agartrell@fb.com>

