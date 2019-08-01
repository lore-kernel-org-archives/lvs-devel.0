From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH 1/2] Add --pe sip option in ipvsadm(8) man page
Date: Thu, 01 Aug 2019 11:55:48 +0100
Message-ID: <1564656948.3546.66.camel@armitage.org.uk>
References: <1564656793.3546.64.camel@armitage.org.uk>
Reply-To: quentin@armitage.org.uk, "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <1564656793.3546.64.camel@armitage.org.uk>
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
To: Jesper Dangaard Brouer <brouer@redhat.com>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Inju Song <inju.song@navercorp.com>

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 ipvsadm.8 | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)
 
diff --git a/ipvsadm.8 b/ipvsadm.8 
index 256718e..aaee146 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -94,11 +94,11 @@ The command has two basic formats for execution:
 The first format manipulates a virtual service and the algorithm for
 assigning service requests to real servers. Optionally, a persistent
 timeout and network mask for the granularity of a persistent service
-may be specified. The second format manipulates a real server that is
-associated with an existing virtual service. When specifying a real
-server, the packet-forwarding method and the weight of the real
-server, relative to other real servers for the virtual service, may be
-specified, otherwise defaults will be used.
+and a persistence engine may be specified. The second format manipulates
+a real server that is associated with an existing virtual service.
+When specifying a real server, the packet-forwarding method and the
+weight of the real server, relative to other real servers for the
+virtual service, may be specified, otherwise defaults will be used.
 .SS COMMANDS
 \fBipvsadm\fR(8) recognises the commands described below. Upper-case
 commands maintain virtual services. Lower-case commands maintain real
@@ -313,6 +313,10 @@ resolve problems with non-persistent cache clusters on the client side.
 IPv6 netmasks should be specified as a prefix length between 1 and 128.
 The default prefix length is 128.
 .TP
+.B --pe \fIpersistence-engine\fP
+Specify an alternative persistence engine to be used. Currently the
+only alternative persistence engine available is sip.
+.TP
 .B -b, --sched-flags \fIsched-flags\fP
 Set scheduler flags for this virtual server.  \fIsched-flags\fP is a
 comma-separated list of flags.  See the scheduler descriptions for
-- 
2.13.7

