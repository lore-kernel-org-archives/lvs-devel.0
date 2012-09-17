From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] Linking against libpopt is always requited
Date: Mon, 17 Sep 2012 10:24:43 +0900
Message-ID: <1347845083-32449-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>

It used to be the case that ipvsadm could be compiled to use
getopt_long rather than libpopt. However, this is no longer the case
and linking against libpopt is always requited.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Makefile |   33 +--------------------------------
 1 file changed, 1 insertion(+), 32 deletions(-)

diff --git a/Makefile b/Makefile
index 930b29f..6e36d79 100644
--- a/Makefile
+++ b/Makefile
@@ -62,39 +62,8 @@ RPMBUILD = $(shell				\
 		echo "/bin/rpm";		\
 	fi )
 
-ifeq (,$(FORCE_GETOPT))
-LIB_SEARCH = /lib64 /usr/lib64 /usr/local/lib64 /lib /usr/lib /usr/local/lib
-POPT_LIB = $(shell for i in $(LIB_SEARCH); do \
-  if [ -f $$i/libpopt.a ]; then \
-    if nm $$i/libpopt.a | fgrep -q poptGetContext; then \
-	echo "-lpopt"; \
-	break; \
-    fi; \
-  fi; \
-done)
-ifeq (,$(POPT_LIB))
-POPT_LIB = $(shell for i in $(LIB_SEARCH); do \
-  f1=""; \
-  for so in $$i/libpopt.so*; do \
-    if [ -f $$so ]; then \
-      if objdump -T $$so | fgrep -q poptGetContext; then \
-	  echo "-lpopt"; \
-	  f1=y; \
-	  break; \
-      fi; \
-    fi; \
-  done; \
-  [ "$$f1" != "" ] && break; \
-done)
-endif
-endif
-
-ifneq (,$(POPT_LIB))
-POPT_DEFINE = -DHAVE_POPT
-endif
