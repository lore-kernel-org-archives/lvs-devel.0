From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 21/24] net/udp: switch udp_lib_setsockopt to sockptr_t
Date: Mon, 20 Jul 2020 14:47:34 +0200
Message-ID: <20200720124737.118617-22-hch@lst.de>
References: <20200720124737.118617-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-crypto-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=JqWr7BncnAaw1KsTe15pYPZ3Aib5oHtxDPbe0sMml/w=; b=uWZ6jCpzKP3knqB1HbYIqdAFmE
        JG/8kt3ysyB2oyx6jw5vOzeoluSO+BWwt8WMZAh30P3716tRc/lq2aNq+FR4nWuq5scmQO2/ZsF9y
        CVYkp2Iu/+kj9A4Kb4LI3X/qjbklr889G2byiZTkmSQIOWbj30FBvtgbYw5bY+zCbho9KixHprDAM
        q6OmvoWuRk884tf85LS/cT3lh+ONS4oBVU/5escrUuBJGq32mUZirYyqwG0yKxXqwnLQC1bES8v8p
        Fr5SZi1XZZOaC5Y2wZ1QlzVqibyGLKDzTbblN474UGSM/VJ3FCsD8yLKMPVyxA0znelhoXpI5VlIZ
        Fnf4QKzw==;
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
Sender: linux-crypto-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/net/udp.h | 2 +-
 net/ipv4/udp.c    | 7 ++++---
 net/ipv6/udp.c    | 3 ++-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 17a9e86a807638..295d52a7359827 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -306,7 +306,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 int udp_lib_getsockopt(struct sock *sk, int level, int optname,
 		       char __user *optval, int __user *optlen);
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
-		       char __user *optval, unsigned int optlen,
+		       sockptr_t optval, unsigned int optlen,
 		       int (*push_pending_frames)(struct sock *));
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d4be4471c424e3..641303aa17d3dd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2532,7 +2532,7 @@ void udp_destroy_sock(struct sock *sk)
  *	Socket option code for UDP
  */
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
-		       char __user *optval, unsigned int optlen,
+		       sockptr_t optval, unsigned int optlen,
 		       int (*push_pending_frames)(struct sock *))
 {
 	struct udp_sock *up = udp_sk(sk);
@@ -2543,7 +2543,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 	if (optlen < sizeof(int))
 		return -EINVAL;
 
-	if (get_user(val, (int __user *)optval))
+	if (copy_from_sockptr(&val, optval, sizeof(val)))
 		return -EFAULT;
 
 	valbool = val ? 1 : 0;
@@ -2651,7 +2651,8 @@ int udp_setsockopt(struct sock *sk, int level, int optname,
 		   char __user *optval, unsigned int optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+		return udp_lib_setsockopt(sk, level, optname,
+					  USER_SOCKPTR(optval), optlen,
 					  udp_push_pending_frames);
 	return ip_setsockopt(sk, level, optname, optval, optlen);
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5aff0856a05b44..05353b31fa07bc 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1565,7 +1565,8 @@ int udpv6_setsockopt(struct sock *sk, int level, int optname,
 		     char __user *optval, unsigned int optlen)
 {
 	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
-		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
+		return udp_lib_setsockopt(sk, level, optname,
+					  USER_SOCKPTR(optval), optlen,
 					  udp_v6_push_pending_frames);
 	return ipv6_setsockopt(sk, level, optname, optval, optlen);
 }
-- 
2.27.0

