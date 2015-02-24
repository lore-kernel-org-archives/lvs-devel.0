From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next 2/4] ipvs: drop dest_p from ip_vs_new_dest
Date: Mon, 23 Feb 2015 21:07:40 -0800
Message-ID: <1424754462-3253312-3-git-send-email-agartrell@fb.com>
References: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=yPHFQY/EmL5zrIiRKUQUFwUcAqReAquwzt61q1xjlAg=;
 b=q0QybnbAjuPaL6BRYm8RejXB0YGQO2xHtCTW49oJ8Z6vmd6SHEy5Ss4yukxFItmSMpjR
 QmxB0vWoRLU2xVUq2JpantePzcmBU6XmWAFdrvVCKaP6mzNb69ofTbGzFYRMzdpyClAH
 I97us9vIqT2SxFCHjthwfJMeuuh0bZ5U7Uw= 
In-Reply-To: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

We don't actually use this in any way, so just drop it as an argument.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 11da053..6341e3f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -863,8 +863,7 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
  *	Create a destination for the given service
  */
 static int
-ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
-	       struct ip_vs_dest **dest_p)
+ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	unsigned int atype, i;
@@ -918,8 +917,6 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	spin_lock_init(&dest->stats.lock);
 	__ip_vs_update_dest(svc, dest, udest, 1);
 
-	*dest_p = dest;
