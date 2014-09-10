From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH] ipvsadm: do not truncate ipv6 members of v4 services
Date: Tue, 9 Sep 2014 23:16:46 -0700
Message-ID: <1410329806-1840-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=sjSzHCw2wjPzD7fKaCrZ9+dPsmEumfFvQ7AAxWZYP60=;
 b=U5/y2cMm1iJjkn46GZMIVZ13w9PJNq9koBPD28SR8bm91uvUmnqkTmFGSp6t0a9izbvB
 6ElXqU4TjGl3x0T3kR9qozV34yBE6LxsiTcKazAftLA8jHa95yBoljUKP/6mqyVhomLQ
 /ernGe66aMzUWzPlRddMYHLHK6iSSQyb9AY= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: brouer@redhat.com
Cc: ja@ssi.bg, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, Alex Gartrell <agartrell@fb.com>

We need to compare to the entry af instead of the service af or else we'll
pop a nul byte into the middle of a v6 real server address.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 ipvsadm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index d12070e..ef19091 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1629,7 +1629,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			fprintf(stderr, "addrport_to_anyname fails\n");
 			exit(1);
 		}
-		if (!(format & FMT_RULE) && (se->af != AF_INET6))
+		if (!(format & FMT_RULE) && (e->af != AF_INET6))
 			dname[28] = '\0';
 
 		if (format & FMT_RULE) {
-- 
1.8.1

