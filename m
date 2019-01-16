From: Quentin Armitage <quentin@armitage.org.uk>
Subject: Subject: [PATCH v2 2/3] Document support of ovf
	scheduler
Date: Wed, 16 Jan 2019 22:55:35 +0000
Message-ID: <1547679335.3577.212.camel@armitage.org.uk>
Reply-To: quentin@armitage.org.uk, "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: Julian Anastasov <ja@ssi.bg>, Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Inju Song <inju.song@navercorp.com>


Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 SCHEDULERS | 2 +-
 ipvsadm.8  | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/SCHEDULERS b/SCHEDULERS
index a782bea..187c07d 100644
--- a/SCHEDULERS
+++ b/SCHEDULERS
@@ -1 +1 @@
-rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo
+rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf
diff --git a/ipvsadm.8 b/ipvsadm.8
index f9e953e..79db006 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -270,6 +270,12 @@ busy, it adopts the Shortest Expected Delay policy to assign the job.
 .sp
 \fBfo\fR - Weighted Failover: assigns an incoming job to the server
 with the highest weight that is currently available.
+.sp
+\fBovf\fR - Weighted Overflow: assigns an incoming job to the server
+with the highest weight that is currently available and overflows
+to the next when active connections exceed the node's weight. Note
+that this scheduler might not be suitable for UDP because it only uses
+active connections.
 .TP
 .B -p, --persistent [\fItimeout\fP]
 Specify that a virtual service is persistent. If this option is
