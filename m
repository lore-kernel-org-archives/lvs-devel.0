From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 1/2] ipvsadm: restrict different address family
Date: Sat, 30 Aug 2014 14:35:48 +0300
Message-ID: <1409398549-5386-2-git-send-email-ja@ssi.bg>
References: <1409398549-5386-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1409398549-5386-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Alex Gartrell <agartrell@fb.com>, kernel-team@fb.com

Now real server can have different address family only
for tunneling. For other modes it must match the service.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 ipvsadm.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ipvsadm.c b/ipvsadm.c
index d12070e..3000117 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -788,6 +788,12 @@ static int process_options(int argc, char **argv, int reading_stdin)
 		    (ce.dest.conn_flags == IP_VS_CONN_F_TUNNEL
 		     || ce.dest.conn_flags == IP_VS_CONN_F_DROUTE))
 			ce.dest.port = ce.svc.port;
+
+		/* Tunneling allows different address family */
+		if (ce.dest.af != ce.svc.af &&
+		    ce.dest.conn_flags != IP_VS_CONN_F_TUNNEL)
+			fail(2, "Different address family is allowed only "
+			     "for tunneling servers");
 	}
 
 	switch (ce.cmd) {
-- 
1.9.0

