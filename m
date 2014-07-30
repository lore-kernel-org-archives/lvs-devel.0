From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs 6/7] ipvs: prevent mixing heterogeneous pools and synchronization
Date: Tue, 29 Jul 2014 21:10:54 -0700
Message-ID: <1406693455-915-7-git-send-email-agartrell@fb.com>
References: <1406693455-915-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=zXipvFVE0QL4B94eSgl0osCTGvHjrtaBUfTwaB8d2lM=;
 b=PI/r4SjZigi/f5BYbSesGsSuBmjxsTC4UEUqwGlLnfn2B0pE8LVRtj/4KnjtG/QSqrPD
 II4uBX0NEgvc1DleOT3jg0Z6vfJ1F3cIOyrkb6flwO0W/1D7cFP93cAvv8GVNyUGUHXs
 LISwl+u8EwJ49g6C7DQVcg6u6PaHa2UfuqI= 
In-Reply-To: <1406693455-915-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

The synchronization protocol is not compatible with heterogeneous pools, so
we need to verify that we're not turning both on at the same time.

This also introduces a switch statement that we'll use to turn on
forwarding types on a case by case basis.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 1c0621b..498510b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -863,10 +863,6 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 
 	EnterFunction(2);
 
-	/* Temporary for consistency */
-	if (udest->af != svc->af)
-		return -EINVAL;
