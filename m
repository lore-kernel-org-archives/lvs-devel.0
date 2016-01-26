From: Yannick Brosseau <scientist@fb.com>
Subject: [PATCH] Remove noisy debug print from ip_vs_del_service
Date: Mon, 25 Jan 2016 17:12:25 -0800
Message-ID: <1453770745-12788-1-git-send-email-scientist@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=tD8ZE8EiAuanc9cSAkjUlRbAAg+6nZ3A+hNruH8U5uM=;
 b=fmVPn9Zb+4fG1+DihaNZgLfQeNv+nEgxIAYd7Q0SaVqz53E9t8chRkSQgWZxs8AaJVCE
 gdaXMkU21msvjsyksDtSmKvVOEelde5P3Y5XvZ4OBS4A97bv78IpCxc2zDOW80pi63Uj
 TUM7MkVmWDq2cdbIyG70b/taNBxNH5tV1fg= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: Yannick Brosseau <scientist@fb.com>

This have been there for a long time, but does not seem to add value

Signed-off-by: Yannick Brosseau <scientist@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e7c1b05..daf4cb7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1376,8 +1376,6 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	struct ip_vs_pe *old_pe;
 	struct netns_ipvs *ipvs = svc->ipvs;
 
-	pr_info("%s: enter\n", __func__);
