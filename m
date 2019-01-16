From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v2 3/3] Add support for mh scheduler
Date: Wed, 16 Jan 2019 22:55:47 +0000
Message-ID: <1547679347.3577.213.camel@armitage.org.uk>
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
 SCHEDULERS      |  2 +-
 ipvsadm.8       |  9 +++++++++
 ipvsadm.c       | 17 +++++++++++++++--
 libipvs/ip_vs.h |  3 +++
 4 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/SCHEDULERS b/SCHEDULERS
index 187c07d..06d3357 100644
--- a/SCHEDULERS
+++ b/SCHEDULERS
@@ -1 +1 @@
-rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf
+rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh
diff --git a/ipvsadm.8 b/ipvsadm.8
index 79db006..1b25888 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -276,6 +276,15 @@ with the highest weight that is currently available and overflows
 to the next when active connections exceed the node's weight. Note
 that this scheduler might not be suitable for UDP because it only uses
 active connections.
+.sp
+\fBmh\fR - Maglev Hashing: assigns incoming jobs based on Google's
+Maglev hashing algorithm, providing an almost equal share of jobs to
+each real server and provides minimal disruption. When the set of real
+servers changes, a connection will likely be sent to the same real
+server as it was before.
+This scheduler has two flags: mh-fallback, which enables fallback to a
+different server if the selected server was unavailable, and mh-port,
+which adds the source port number to the hash computation.
 .TP
 .B -p, --persistent [\fItimeout\fP]
 Specify that a virtual service is persistent. If this option is
diff --git a/ipvsadm.c b/ipvsadm.c
index 7695006..0cb2b68 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1145,6 +1145,16 @@ static unsigned int parse_sched_flags(const char *sched, char *optarg)
 			if (strcmp(sched, "sh"))
 				fail(2, "incompatible scheduler flag `%s'",
 				     flag);
+		} else if (!strcmp(flag, "mh-fallback")) {
+			flags |= IP_VS_SVC_F_SCHED_MH_FALLBACK;
+			if (strcmp(sched, "mh"))
+				fail(2, "incompatible scheduler flag `%s'",
+				     flag);
+		} else if (!strcmp(flag, "mh-port")) {
+			flags |= IP_VS_SVC_F_SCHED_MH_PORT;
+			if (strcmp(sched, "mh"))
+				fail(2, "incompatible scheduler flag `%s'",
+				     flag);
 		} else {
 			fail(2, "invalid scheduler flag `%s'", flag);
 		}
@@ -1589,8 +1599,11 @@ static void print_sched_flags(ipvs_service_entry_t *se)
 			strcat(flags, "sh-fallback,");
 		if (se->flags & IP_VS_SVC_F_SCHED_SH_PORT)
 			strcat(flags, "sh-port,");
-		if (se->flags & IP_VS_SVC_F_SCHED3)
-			strcat(flags, "flag-3,");
+	} else if (!strcmp(se->sched_name, "mh")) {
+		if (se->flags & IP_VS_SVC_F_SCHED_MH_FALLBACK)
+			strcat(flags, "mh-fallback,");
+		if (se->flags & IP_VS_SVC_F_SCHED_MH_PORT)
+			strcat(flags, "mh-port,");
 	} else {
 		if (se->flags & IP_VS_SVC_F_SCHED1)
 			strcat(flags, "flag-1,");
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index e57d55a..ad0141c 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -36,6 +36,9 @@
 #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
 #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
 
+#define IP_VS_SVC_F_SCHED_MH_FALLBACK	IP_VS_SVC_F_SCHED1 /* MH fallback */
+#define IP_VS_SVC_F_SCHED_MH_PORT	IP_VS_SVC_F_SCHED2 /* MH use port */
+
 
 /*
  *      IPVS sync daemon states
