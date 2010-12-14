From: Tinggong Wang <wangtinggong@gmail.com>
Subject: Re: [PATCH 3/3] ipvs: fix get_curr_sync_buff
Date: Tue, 14 Dec 2010 11:00:26 +0800
Message-ID: <20101214030026.GA3399@wangtg>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
 <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
 <f190cc57967c7435bc405fd4a192d15605652461.1292153764.git.wangtinggong@gmail.com>
 <alpine.LFD.2.00.1012140113140.2634@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:cc:subject
         :message-id:references:mime-version:content-type:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=GRvLJvz+eb/GEm/GCbH743dJlcydgM7n3B0ivBT/B8A=;
        b=uUspE2EFdKoB7oIE7NgKr9Vzl3Ppyja4HQNWZnlHRUiXZ0vAtQDiA88ZarrZQGTjUq
         O+eU/rGIZNTLQ1b7kmrzRNq/1XM28Vem9JSB6K5ZN/pC8UG4gYC5Hgzfe1hrdf+0AGhi
         JSWKWjGdvjjzYdjYoK0i/pfInWSIY2SpPDdAQ=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1012140113140.2634@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

on Tue, 14 Dec 2010 01:32:36AM +0200 Julian Anastasov (ja@ssi.bg) wrote:
> 
> 	Hello,
> 
> On Sun, 12 Dec 2010, Tinggong Wang wrote:
> 
> >use time_after get the current buffer created more than the specified time.
> >
> >time_before in get_curr_sync_buff(2 * HZ) will get the buffer created newly.
> >if curr_sb has been created more than 2*HZ then it will still sit in master.
> >so use time_after instead.
> >
> >Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> >---
> >net/netfilter/ipvs/ip_vs_sync.c |    3 +--
> >1 files changed, 1 insertions(+), 2 deletions(-)
> >
> >diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> >index 2b6b0cb..555b0dd 100644
> >--- a/net/netfilter/ipvs/ip_vs_sync.c
> >+++ b/net/netfilter/ipvs/ip_vs_sync.c
> >@@ -221,8 +221,7 @@ get_curr_sync_buff(unsigned long time)
> >	struct ip_vs_sync_buff *sb;
> >
> >	spin_lock_bh(&curr_sb_lock);
> >-	if (curr_sb && (time == 0 ||
> >-			time_before(jiffies - curr_sb->firstuse, time))) {
> >+	if (curr_sb && time_after(jiffies - curr_sb->firstuse, time)) {
> 
> 	This breaks the time=0 case when jiffies matches firstuse.
> 
> 	May be the fix should be as follows?:
> 
> 	if (curr_sb && time_after_eq(jiffies - curr_sb->firstuse, time)) {
> 
> 	i.e. passed >= limit (2 or 0).
> 

Thanks!

here is the improved patch:

From 68f30a4e8759dae7de4fb846db8ad264301c0bc6 Mon Sep 17 00:00:00 2001
From: Tinggong Wang <wangtinggong@gmail.com>
Date: Tue, 14 Dec 2010 10:53:24 +0800
Subject: [PATCH] ipvs: fix get_curr_sync_buff

use time_after_eq get the current buffer created more than the specified time,
or equals it.

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index c1c167a..e9d2196 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -395,8 +395,7 @@ get_curr_sync_buff(unsigned long time)
 	struct ip_vs_sync_buff *sb;
 
 	spin_lock_bh(&curr_sb_lock);
-	if (curr_sb && (time == 0 ||
-			time_before(jiffies - curr_sb->firstuse, time))) {
+	if (curr_sb && time_after_eq(jiffies - curr_sb->firstuse, time)) {
 		sb = curr_sb;
 		curr_sb = NULL;
 	} else
-- 
1.7.2.3

> >		sb = curr_sb;
> >		curr_sb = NULL;
> >	} else
> >-- 
> >1.7.2.3
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
