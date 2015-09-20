From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 47/84] ipvs: Pass ipvs not net to ip_vs_random_drop_entry
Date: Sun, 20 Sep 2015 01:23:03 -0500
Message-ID: <1442730220-32458-47-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip_vs.h             | 2 +-
 net/netfilter/ipvs/ip_vs_conn.c | 4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c  | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2d49357b328c..c88a3bf85f98 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1258,7 +1258,7 @@ const char *ip_vs_state_name(__u16 proto, int state);
 
 void ip_vs_tcp_conn_listen(struct net *net, struct ip_vs_conn *cp);
 int ip_vs_check_template(struct ip_vs_conn *ct);
-void ip_vs_random_dropentry(struct net *net);
+void ip_vs_random_dropentry(struct netns_ipvs *ipvs);
 int ip_vs_conn_init(void);
 void ip_vs_conn_cleanup(void);
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 5d001f410fc5..3917ea1b20df 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1239,7 +1239,7 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
 }
 
 /* Called from keventd and must protect itself from softirqs */
-void ip_vs_random_dropentry(struct net *net)
+void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 {
 	int idx;
 	struct ip_vs_conn *cp, *cp_c;
@@ -1255,7 +1255,7 @@ void ip_vs_random_dropentry(struct net *net)
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
 				/* connection template */
 				continue;
-			if (!net_eq(cp->ipvs->net, net))
+			if (cp->ipvs != ipvs)
 				continue;
 			if (cp->protocol == IPPROTO_TCP) {
 				switch(cp->state) {
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 8eb5453a75f8..67278c6e41a3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -228,7 +228,7 @@ static void defense_work_handler(struct work_struct *work)
 
 	update_defense_level(ipvs);
 	if (atomic_read(&ipvs->dropentry))
-		ip_vs_random_dropentry(ipvs->net);
+		ip_vs_random_dropentry(ipvs);
 	schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
 }
 #endif
-- 
2.2.1
