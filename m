From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/6] IPVS: buffer argument to ip_vs_process_message() should not be const
Date: Tue, 16 Nov 2010 15:34:56 +0900
Message-ID: <1289889298-17287-5-git-send-email-horms@verge.net.au>
References: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1289889298-17287-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, n
Cc: Simon Horman <horms@verge.net.au>

It is assigned to a non-const variable and its contents are modified.

Acked-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 72b3d88..3897d6b 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -303,7 +303,7 @@ ip_vs_conn_fill_param_sync(int af, int protocol,
  *      Process received multicast message and create the corresponding
  *      ip_vs_conn entries.
  */
-static void ip_vs_process_message(const char *buffer, const size_t buflen)
+static void ip_vs_process_message(char *buffer, const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
 	struct ip_vs_sync_conn *s;
-- 
1.7.2.3

