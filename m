From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 1/2] [PATCH 1/2] Slightly simplify options conflicts logic
Date: Fri, 01 Oct 2010 23:40:42 +0900
Message-ID: <20101001144126.520973076@akiko.akashicho.tokyo.vergenet.net>
References: <20101001144041.414393254@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=0001-Slightly-simplify-options-conflicts-logic.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>

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


