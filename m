From: Tinggong Wang <wangtinggong@gmail.com>
Subject: [PATCH 3/3] ipvs: fix get_curr_sync_buff
Date: Sun, 12 Dec 2010 19:43:04 +0800
Message-ID: <f190cc57967c7435bc405fd4a192d15605652461.1292153764.git.wangtinggong@gmail.com>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
 <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:subject
         :message-id:references:mime-version:content-type:content-disposition
         :in-reply-to;
        bh=kYS9s5BNHgzrON38epTETHXfx0Og6/nOuCdnn2Sd4Hw=;
        b=rOIngB5dgdC1QQQFJhW8TyuzaB5rQO9Fvpgkq9STVXK0b9xAuUbomG9V5qgSvLTcJO
         knnjowV/lu62e/OuwI8CAaBhhUQIKztvz07Q/dyblUUzaEB1hXlPrznc2+SJeffKa5/g
         2AevPWYejHQJdakYmx9pXaxpcz6U55mb/1F3w=
Content-Disposition: inline
In-Reply-To: <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

use time_after get the current buffer created more than the specified time.

time_before in get_curr_sync_buff(2 * HZ) will get the buffer created newly.
if curr_sb has been created more than 2*HZ then it will still sit in master.
so use time_after instead.

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2b6b0cb..555b0dd 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -221,8 +221,7 @@ get_curr_sync_buff(unsigned long time)
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&curr_sb_lock);
-	if (curr_sb && (time == 0 ||
-			time_before(jiffies - curr_sb->firstuse, time))) {
+	if (curr_sb && time_after(jiffies - curr_sb->firstuse, time)) {
 		sb = curr_sb;
 		curr_sb = NULL;
 	} else
-- 
1.7.2.3
