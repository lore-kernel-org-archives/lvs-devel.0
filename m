From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipvs: use skb_to_full_sk() helper
Date: Thu, 12 Nov 2015 09:14:12 -0800
Message-ID: <1447348452.22599.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <06dc952f98f54da2c4d85b31e5fa9826@eikelenboom.it>
	 <1447337353.22599.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :content-type:mime-version:content-transfer-encoding;
        bh=5ibT462C1ZBMA6bftTQ3cmQp+bi9qQlboMM9foTQLNU=;
        b=OpsEv3Dwt3GpsdA+xRKn4f6hix0uOgedLpcJZmIIJlZTFCvxBXT767TsoO9Nw+rG+h
         22YHyEe1EhBqoTvKUZ1MOWj9mnUBW92NdENRsUfc561MPL1YjT1BMKZSxtkKHx2bkCyA
         ie8/sJvPXSVpQSEa4kd6LqIlICUPjQiFmqgLg35EN2bn8A7DLno+gC6sY/eg9Db/Vh/r
         yXiURelFypFSSNE1jB0xDH5vRR5OskogyvC+kJiFK8sXP+q4q9LgtWsR0XGK7egP2Cfl
         7J7eBPE7TM0T/MdlHIHoFquHxVGJQWNVdKVtIx3mtuw6xAI6DwS0soR3J4zdbGwcbzWb
         Nskw==
In-Reply-To: <b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Sander Eikelenboom <linux@eikelenboom.it>, David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

SYNACK packets might be attached to request sockets.

Use skb_to_full_sk() helper to avoid illegal accesses to
inet_sk(skb->sk)

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
---
 net/netfilter/ipvs/ip_vs_core.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 1e24fff53e4b..f57b4dcdb233 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1176,6 +1176,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
 	struct ip_vs_conn *cp;
+	struct sock *sk;
 
 	EnterFunction(11);
 
@@ -1183,13 +1184,12 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	if (skb->ipvs_property)
 		return NF_ACCEPT;
 
+	sk = skb_to_full_sk(skb);
 	/* Bad... Do not break raw sockets */
-	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
+	if (unlikely(sk && hooknum == NF_INET_LOCAL_OUT &&
 		     af == AF_INET)) {
-		struct sock *sk = skb->sk;
-		struct inet_sock *inet = inet_sk(skb->sk);
 
-		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+		if (sk->sk_family == PF_INET && inet_sk(sk)->nodefrag)
 			return NF_ACCEPT;
 	}
 
@@ -1681,6 +1681,7 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	struct ip_vs_conn *cp;
 	int ret, pkts;
 	int conn_reuse_mode;
+	struct sock *sk;
 
 	/* Already marked as IPVS request or reply? */
 	if (skb->ipvs_property)
@@ -1708,12 +1709,11 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	ip_vs_fill_iph_skb(af, skb, false, &iph);
 
 	/* Bad... Do not break raw sockets */
-	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
+	sk = skb_to_full_sk(skb);
+	if (unlikely(sk && hooknum == NF_INET_LOCAL_OUT &&
 		     af == AF_INET)) {
-		struct sock *sk = skb->sk;
-		struct inet_sock *inet = inet_sk(skb->sk);
 
-		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
+		if (sk->sk_family == PF_INET && inet_sk(sk)->nodefrag)
 			return NF_ACCEPT;
 	}
 


