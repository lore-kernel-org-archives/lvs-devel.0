From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next] ipvs: remove unused function ip_vs_set_state_timeout
Date: Mon, 10 Apr 2017 15:50:44 -0400
Message-ID: <20170410195044.19646-1-aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bytheb-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id;
        bh=djdE1hmCIJCbqoqGKbQLzLjuSxMMtTQZNGGEjqzTKYs=;
        b=PBdLv4F0BGBPNxSI9gUelUcUbHO94d6mhDx6AZNV0HQrELZqwN1gVbUfFh39S3e2zH
         oGgPf8YnsWApc2+qenH4vvhRbkX8jiu8BTILNUyZRuROHDlhsqhoZB0G4fOHjGoAcQqt
         MqLoNH3QnH7o9iYM3nh3+Uol6ObDAfX9Mdujf/oy5uHZOXzxG2Ctk1cTlUuzIPhcGrBe
         /jrx4nGh8bCcwb2zt60upYC9cfZ1qq+GPOzcs5ZzCAoTvpYOf6fC69KJ09ubAQYU0pEh
         KFZoQDgoY3sRTFjkTeIeCLOICKbssFUJagrgBVzPgiRBt6frl8NvvRtfzkts/cemJOYa
         SVfw==
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

There are no in-tree callers of this function and it isn't exported.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 include/net/ip_vs.h              |  2 --
 net/netfilter/ipvs/ip_vs_proto.c | 22 ----------------------
 2 files changed, 24 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 8a4a57b8..c76fedb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1349,8 +1349,6 @@ int ip_vs_protocol_init(void);
 void ip_vs_protocol_cleanup(void);
 void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
 int *ip_vs_create_timeout_table(int *table, int size);
-int ip_vs_set_state_timeout(int *table, int num, const char *const *names,
-			    const char *name, int to);
 void ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 			       const struct sk_buff *skb, int offset,
 			       const char *msg);
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 8ae4807..ca880a3 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -193,28 +193,6 @@ ip_vs_create_timeout_table(int *table, int size)
 }
 
 
-/*
- *	Set timeout value for state specified by name
- */
-int
-ip_vs_set_state_timeout(int *table, int num, const char *const *names,
-			const char *name, int to)
-{
-	int i;
-
-	if (!table || !name || !to)
-		return -EINVAL;
-
-	for (i = 0; i < num; i++) {
-		if (strcmp(names[i], name))
-			continue;
-		table[i] = to * HZ;
-		return 0;
-	}
-	return -ENOENT;
-}
-
-
 const char * ip_vs_state_name(__u16 proto, int state)
 {
 	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
-- 
2.9.3

