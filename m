From: Simon Horman <horms@verge.net.au>
Subject: [patch 3/9] IPVS: buffer argument to ip_vs_process_message() should not be const
Date: Sun, 24 Oct 2010 00:26:29 +0900
Message-ID: <20101023153019.917645726@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=sync-ip_vs_process_message-no-const-buffer.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

It is assigned to a non-const variable and its contents are modified.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 10:39:13.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 10:41:54.000000000 +0900
@@ -303,7 +303,7 @@ ip_vs_conn_fill_param_sync(int af, int p
  *      Process received multicast message and create the corresponding
  *      ip_vs_conn entries.
  */
-static void ip_vs_process_message(const char *buffer, const size_t buflen)
+static void ip_vs_process_message(char *buffer, const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
 	struct ip_vs_sync_conn *s;

