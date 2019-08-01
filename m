From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH 2/2] In ipvsadm(8) add using nft or an eBPF
 program to set a packet mark
Date: Thu, 01 Aug 2019 11:56:55 +0100
Message-ID: <1564657015.3546.67.camel@armitage.org.uk>
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

The ipvsadm(8) man page specified that a packet mark could be set
using iptables. It is now also possible to set the packet mark using
nft, and also via an eBPF program.
 
Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 ipvsadm.8 | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/ipvsadm.8 b/ipvsadm.8
index aaee146..64a3526 100644
--- a/ipvsadm.8
+++ b/ipvsadm.8
@@ -196,9 +196,10 @@ Use SCTP service. See the -t|--tcp-service for the description of the
 .TP
 .B -f, --fwmark-service \fIinteger\fP
 Use a firewall-mark, an integer value greater than zero, to denote a
-virtual service instead of an address, port and protocol (UDP or
-TCP). The marking of packets with a firewall-mark is configured using
-the -m|--mark option to \fBiptables\fR(8). It can be used to build a
+virtual service instead of an address, port and protocol (UDP, TCP or
+SCTP). The marking of packets with a firewall-mark is configured using
+the -m|--mark option to \fBiptables\fR(8), the meta mark set \fIvalue\fR
+option to \fBnft\fR(8) or via an eBPF program. It can be used to build a
 virtual service associated with the same real servers, covering
 multiple IP address, port and protocol triplets. If IPv6 addresses
 are used, the -6 option must be used.
-- 
2.13.7

