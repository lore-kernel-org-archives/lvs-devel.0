From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/2] netfilter: ipvs: do not create conn for ABORT packet in sctp_conn_schedule
Date: Sun, 20 Aug 2017 13:38:08 +0800
Message-ID: <3f97d61377667c421b40f865f85d99541f693ae9.1503207076.git.lucien.xin@gmail.com>
References: <cover.1503207076.git.lucien.xin@gmail.com>
 <9475ae3e6d80f0c6547371f5a910edfbbd4a9b2a.1503207076.git.lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=cIg5Jfp7jsa4uwoW8j4yBhTy58aXE4WGtLV2pFJWPvQ=;
        b=vQ43orPywfBea+PAV6VjiLbRc2vOZf2I4yo8VLrSv5gK/stRb6IuL6usnDcCFRFJJJ
         V7MYNdBBbwHLcyrebLWmWSPUrhn7IjDxJwCX1mruEeWyv61R1LpHf3rWX7IM1clZ3hHA
         uWae58dKJ4reiumGPjwvG6yV5O1a0TA3tnMUKhlPRxt4+VrXH+QMeDuYonjiNd3GCQQg
         S631Pie2MizrLENqCB3HW3TbXWrr2VuuPcFh3Xc5zJ2C5g/tUwprYlY5elkU8Y3HvhMT
         9nushTvb4+lTHKg8niCjueyYdhCfZ3nzGh4ssg3vxEtxxuOpPvV7luyAlaMDOzZpDCmG
         eHmg==
In-Reply-To: <9475ae3e6d80f0c6547371f5a910edfbbd4a9b2a.1503207076.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1503207076.git.lucien.xin@gmail.com>
References: <cover.1503207076.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org
Cc: pablo@netfilter.org, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org

There's no reason for ipvs to create a conn for an ABORT packet
even if sysctl_sloppy_sctp is set.

This patch is to accept it without creating a conn, just as ipvs
does for tcp's RST packet.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index e9b18ac..d86773a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -25,7 +25,8 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 			sch = skb_header_pointer(skb, iph->len + sizeof(_sctph),
 						 sizeof(_schunkh), &_schunkh);
 			if (sch) {
-				if (!(sysctl_sloppy_sctp(ipvs) ||
+				if (sch->type == SCTP_CID_ABORT ||
+				    !(sysctl_sloppy_sctp(ipvs) ||
 				      sch->type == SCTP_CID_INIT))
 					return 1;
 				ports = &sh->source;
-- 
2.1.0

