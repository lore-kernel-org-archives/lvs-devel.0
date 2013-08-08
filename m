From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] Allow override of CFLAGS
Date: Thu,  8 Aug 2013 13:59:59 +0900
Message-ID: <1375937999-11660-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jesper Dangaard Brouer <jbrouer@redhat.com>, Simon Horman <horms@verge.net.au>

When building ipvsadm this allows make to add to CFLAGS supplied
on the command line.

This seems to make sense as Makefile and libipvs/Makefile
add different CFLAGS but it may be desirable to supply supplementary
flags when building ipvsadm.

In particular the following may be useful when building ipvsadm
on Debian Jessie.

make CFLAGS='-I/usr/include/libnl3' LIBS='-lnl-3 -lnl-genl-3 -lnl-3 -lpopt'

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Makefile b/Makefile
index 6e36d79..c8c1eec 100644
--- a/Makefile
+++ b/Makefile
@@ -48,7 +48,7 @@ STATIC_LIBS	= libipvs/libipvs.a
 ifeq "${ARCH}" "sparc64"
     CFLAGS = -Wall -Wunused -Wstrict-prototypes -g -m64 -pipe -mcpu=ultrasparc -mcmodel=medlow
 else
-    CFLAGS = -Wall -Wunused -Wstrict-prototypes -g
+    CFLAGS = -I/usr/include/libnl3 -Wall -Wunused -Wstrict-prototypes -g
 endif
 
 
-- 
1.8.3.2

