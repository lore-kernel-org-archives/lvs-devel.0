From: Tinggong Wang <wangtinggong@gmail.com>
Subject: [PATCH 2/3] ipvs: check data validation before local_bh_disable
Date: Sun, 12 Dec 2010 19:42:29 +0800
Message-ID: <3236859ec32d32324ce6e1f8a4456d2d1a84ed7b.1292153764.git.wangtinggong@gmail.com>
References: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:date:from:to:subject
         :message-id:references:mime-version:content-type:content-disposition
         :in-reply-to;
        bh=MzM9Bs3URX80L9VztsOvVu+JShNesdwsTPwSAXqgHQo=;
        b=cKvu1R+Q9DJAtg5MOgjD9RdVS0W0kPfBLBlZh3dW451GZZwSZB09TF6UbGWDVbEtvA
         1ts+9sdi0F764+Gu4t93m0igujBsG/cbRZ386bKuP5IM4Xr2Ucq60XYGKgswuitzHLtR
         ky+WeREHdUxqDtNB0yESt+Jbnvty/LFHxdBaQ=
Content-Disposition: inline
In-Reply-To: <adb973b711975ac5a24c69818fd0439d88f4c68c.1292153764.git.wangtinggong@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 7632a17..2b6b0cb 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -315,11 +315,6 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 	char *p;
 	int i;
 
-	if (buflen < SYNC_MESG_HEADER_LEN) {
-		IP_VS_ERR_RL("sync message header too short\n");
-		return;
-	}
