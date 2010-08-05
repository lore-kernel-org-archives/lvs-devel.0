From: Simon Horman <horms@verge.net.au>
Subject: [rfc 1/2] [PATCH 1/2] Slightly simplify options conflicts logic
Date: Thu, 05 Aug 2010 20:47:56 +0900
Message-ID: <20100805115605.211216460@vergenet.net>
References: <20100805115505.582164394@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=0001-Slightly-simplify-options-conflicts-logic.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 ipvsadm.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 76ec7c4..1ac6c7f 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -763,11 +763,9 @@ static int process_options(int argc, char **argv, int reading_stdin)
 
 	switch (ce.cmd) {
 	case CMD_LIST:
-		if ((options & OPT_CONNECTION ||
-		     options & OPT_TIMEOUT || options & OPT_DAEMON) &&
-		    (options & OPT_STATS ||
-		     options & OPT_PERSISTENTCONN ||
-		     options & OPT_RATE || options & OPT_THRESHOLDS))
+		if (options & (OPT_CONNECTION|OPT_TIMEOUT|OPT_DAEMON) &&
+		    options & (OPT_STATS|OPT_PERSISTENTCONN|
+			       OPT_RATE|OPT_THRESHOLDS))
 			fail(2, "options conflicts in the list command");
 
 		if (options & OPT_CONNECTION)
-- 
1.7.1


