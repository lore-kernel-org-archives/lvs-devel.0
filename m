From: sven.wegener@stealer.net
Subject: [PATCH 7/9] ipvs: Mark net_vs_ctl_path const
Date: Sun, 10 Aug 2008 11:07:37 +0000
Message-ID: <1218366459-23971-8-git-send-email-sven.wegener@stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: Sven Wegener <sven.wegener@stealer.net>

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 include/net/ip_vs.h       |    2 +-
 net/ipv4/ipvs/ip_vs_ctl.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e980416..c8ee9b8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -620,7 +620,7 @@ extern int sysctl_ip_vs_expire_quiescent_template;
 extern int sysctl_ip_vs_sync_threshold[2];
 extern int sysctl_ip_vs_nat_icmp_send;
 extern struct ip_vs_stats ip_vs_stats;
-extern struct ctl_path net_vs_ctl_path[];
+extern const struct ctl_path net_vs_ctl_path[];
 
 extern struct ip_vs_service *
 ip_vs_service_get(__u32 fwmark, __u16 protocol, __be32 vaddr, __be16 vport);
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index df13333..999d884 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -1589,7 +1589,7 @@ static struct ctl_table vs_vars[] = {
 	{ .ctl_name = 0 }
 };
 
-struct ctl_path net_vs_ctl_path[] = {
+const struct ctl_path net_vs_ctl_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
 	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
 	{ .procname = "vs", },
-- 
1.5.6.4

