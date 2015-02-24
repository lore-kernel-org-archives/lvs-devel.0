From: Alex Gartrell <agartrell@fb.com>
Subject: [RFC PATCH net-next 4/4] ipvs: check return value of del_dest
Date: Mon, 23 Feb 2015 21:07:42 -0800
Message-ID: <1424754462-3253312-5-git-send-email-agartrell@fb.com>
References: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=g/GBMAfG8ncpZylj0a6gAQs+nScu6lwPYSxd4gKzuvo=;
 b=RUo1j9uFCPjyyfoi4cFYwpwgBeE0iD6ixOYtE7YBFPKSfOoXtGu3SBHttlab0lOIhVx4
 buzZ7sSLzwP5f0TS24AQsAIsDlFKOQcoLDA8Kt9axOIqP2MtpE8EP9y2+SMQ3/HmFYhj
 DBr3BSZP8R7wNvOlfsbqmXfMjBhlZU37S3c= 
In-Reply-To: <1424754462-3253312-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

If del_dest returns non-zero, restore flags and the counts in services and
ipvs and leave things as they were.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 42 +++++++++++++++++++++++++-----------------
 1 file changed, 25 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d384b7f..2e9deb4 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1068,10 +1068,13 @@ static void __ip_vs_del_dest(struct net *net, struct ip_vs_dest *dest,
 /*
  *	Unlink a destination from the given service
  */
-static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
-				struct ip_vs_dest *dest,
-				int svcupd)
+static int __ip_vs_unlink_dest(struct ip_vs_service *svc,
+			       struct ip_vs_dest *dest,
+			       int svcupd)
 {
+	int ret = 0;
+	int old_flags = dest->flags;
+
 	dest->flags &= ~IP_VS_DEST_F_AVAILABLE;
 
 	/*
@@ -1080,16 +1083,25 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
 	list_del_rcu(&dest->n_list);
 	svc->num_dests--;
 
-	if (dest->af != svc->af)
-		net_ipvs(svc->net)->mixed_address_family_dests--;
 
 	if (svcupd) {
 		struct ip_vs_scheduler *sched;
 
 		sched = rcu_dereference_protected(svc->scheduler, 1);
-		if (sched->del_dest)
-			sched->del_dest(svc, dest);
+		if (sched->del_dest) {
+			ret = sched->del_dest(svc, dest);
+			if (ret) {
+				list_add_rcu(&dest->n_list, &svc->destinations);
+				dest->flags = old_flags;
+				svc->num_dests++;
+			}
+		}
 	}
+
+	if (!ret && dest->af != svc->af)
+		net_ipvs(svc->net)->mixed_address_family_dests--;
+
+	return ret;
 }
 
 
@@ -1101,6 +1113,7 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 {
 	struct ip_vs_dest *dest;
 	__be16 dport = udest->port;
+	int ret;
 
 	EnterFunction(2);
 
@@ -1114,19 +1127,14 @@ ip_vs_del_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		return -ENOENT;
 	}
 
-	/*
-	 *	Unlink dest from the service
-	 */
-	__ip_vs_unlink_dest(svc, dest, 1);
