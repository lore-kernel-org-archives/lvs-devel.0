From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH 1/3] ipvsadm: Document support of fo scheduler
Date: Fri, 04 Jan 2019 20:26:38 +0000
Message-ID: <1546633598.3577.12.camel@armitage.org.uk>
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
To: Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org


Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 SCHEDULERS | 2 +-
 ipvsadm.8  | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/SCHEDULERS b/SCHEDULERS
index 84ba299..a782bea 100644
--- a/SCHEDULERS
+++ b/SCHEDULERS
@@ -1 +1 @@
-rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq
+rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo
diff --git a/ipvsadm.8 b/ipvsadm.8
index dad1712..c05e577 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -267,6 +267,10 @@ fixed service rate (weight) of the ith server.
 \fBnq\fR - Never Queue: assigns an incoming job to an idle server if
 there is, instead of waiting for a fast one; if all the servers are
 busy, it adopts the Shortest Expected Delay policy to assign the job.
+.sp
+\fBfo\fR - Weighted Failover: assigns an incoming job to the highest
+weighted available server and overflows to the next when the number
+of connections exceeds its weight.
 .TP
 .B -p, --persistent [\fItimeout\fP]
 Specify that a virtual service is persistent. If this option is
-- 
2.13.7
