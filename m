From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH ipvsadm 2/2] Fallback to libpopt on shared object
Date: Fri, 13 Jul 2012 11:48:46 +0300
Message-ID: <1342169326-1911-3-git-send-email-ja@ssi.bg>
References: <1342169326-1911-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1342169326-1911-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org

	Use shared library if no static library is installed.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 Makefile |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/Makefile b/Makefile
index e4e03cc..b411649 100644
--- a/Makefile
+++ b/Makefile
@@ -72,6 +72,21 @@ POPT_LIB = $(shell for i in $(LIB_SEARCH); do \
     fi; \
   fi; \
 done)
+ifeq (,$(POPT_LIB))
+POPT_LIB = $(shell for i in $(LIB_SEARCH); do \
+  f1=""; \
+  for so in $$i/libpopt.so*; do \
+    if [ -f $$so ]; then \
+      if objdump -T $$so | fgrep -q poptGetContext; then \
+	  echo "-lpopt"; \
+	  f1=y; \
+	  break; \
+      fi; \
+    fi; \
+  done; \
+  [ "$$f1" != "" ] && break; \
+done)
+endif
 endif
 
 ifneq (,$(POPT_LIB))
-- 
1.7.3.4

