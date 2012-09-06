From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ipvs: use list_del_init instead of list_del/INIT_LIST_HEAD
Date: Thu, 6 Sep 2012 12:21:53 +0800
Message-ID: <CAPgLHd_JMzWm-Eh48bXcq6xW2viVEQgmkxLU8KgVyD2gUk6sZQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:date:message-id:subject:from:to:cc:content-type;
        bh=1QT5PNfhDq9zyQIHd96wYxM8f1eTccVNrhiwXd/QaNY=;
        b=WZ9H277LOFs/bJvBn1K4ea4iepKSL+B9ZJrWcC4NZGHjD0HTMKCSageOvccpOTke4j
         /VUFLrSLaGVorfNXvcgxW/1mUDI8bnP/NijywjXBjiPXO1u3u/u1t8TY/OjxXzNwpSje
         TIM2rEl963g2wjGokrZxBhOtSrYuA2YMTDJCenC1R9mjcdh6vYeXnRNN569N5ZC/IKI4
         2ZJhx8edUlKvU6g8n4E/4Qzoe9y5nS7T3+OZkBc4u6X6jHN5wa5gxQQO4MhmZnDYCkSm
         YQhRf3ShpQ5+1bgqWo2KJgiVQjWhiqXDECq4lL/AjVp4YaP/s8eSCrqKW6Xug9qXXz55
         JH5w==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net
Cc: yongjun_wei@trendmicro.com.cn, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_del_init() instead of list_del() + INIT_LIST_HEAD().

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index f51013c..9d9f83e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -539,8 +539,7 @@ static int ip_vs_rs_unhash(struct ip_vs_dest *dest)
 	 * Remove it from the rs_table table.
 	 */
 	if (!list_empty(&dest->d_list)) {
-		list_del(&dest->d_list);
-		INIT_LIST_HEAD(&dest->d_list);
+		list_del_init(&dest->d_list);
 	}
 
 	return 1;


