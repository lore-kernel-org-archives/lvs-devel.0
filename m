From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 7/9] IPVS: buffer argument to ip_vs_process_message() should not be const
Date: Fri, 12 Nov 2010 08:34:59 +0100
Message-ID: <1289547301-28015-7-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Simon Horman <horms@verge.net.au>

It is assigned to a non-const variable and its contents are modified.

Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f21506c..be05394 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -433,7 +433,7 @@ ip_vs_conn_fill_param_sync(int af, int protocol,
  *      Process received multicast message and create the corresponding
  *      ip_vs_conn entries.
  */
-static void ip_vs_process_message(const char *buffer, const size_t buflen)
+static void ip_vs_process_message(char *buffer, const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
 	struct ip_vs_sync_conn_v0 *s;
-- 
1.7.2.3

