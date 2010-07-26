From: Simon Horman <horms@verge.net.au>
Subject: [patch 2/5] ipvsadm: Dont include getopt.h
Date: Mon, 26 Jul 2010 17:04:50 +0900
Message-ID: <20100726080645.721715688@vergenet.net>
References: <20100726080448.476781076@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=no-getopt.h.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

getopt isn't used any more.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: trunk/ipvsadm.c
===================================================================
--- trunk.orig/ipvsadm.c	2010-07-25 15:41:19.000000000 +0900
+++ trunk/ipvsadm.c	2010-07-25 15:41:28.000000000 +0900
@@ -93,7 +93,6 @@
 #undef __KERNEL__	/* Makefile lazyness ;) */
 #include <stdio.h>
 #include <stdlib.h>
-#include <getopt.h>
 #include <netdb.h>
 #include <string.h>
 #include <unistd.h>

