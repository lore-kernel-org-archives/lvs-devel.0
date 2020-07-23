From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 22/26] net/udp: switch udp_lib_setsockopt to sockptr_t
Date: Thu, 23 Jul 2020 08:09:04 +0200
Message-ID: <20200723060908.50081-23-hch@lst.de>
References: <20200723060908.50081-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-can-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=B8ko5pqj9E5RJoiDMAT4LWCptgAPGsTT9yGUOg+zWgY=; b=MjJqnKULSWCVH3PByQuNM/qNXX
        HtMB9dNpDBTWgJugcO7sE/5ko9tHLFvQQR2XB+seIcDgNTq0BIUT+jAS9YnxntKaMacKvA3QzLDz+
        zGlGK28S4DDyYfe4AW2lZ7egTVp764ymWynHmgHFOMbVH5dRl56eBZKRzkiXR6tj4nh5pm3fHpJ0C
        D7KIViHus2vbs8lwyCCqFoTyuA7CUg8gUDjDutcOgepeoe8H4V4VclrD+KVF5iFtHs5JYWGRp57sI
        ctRlfcOu0L+2rfrA9FFOOVRguL7CObocmaxk45GM10m0ZW5jysNmi0VmrX1q8LwS7ICnZPKjKkGuJ
        piwC5ebg==;
In-Reply-To: <20200723060908.50081-1-hch@lst.de>
Sender: linux-can-owner@vger.kernel.org
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
index bb95cddcb040a6..c6cb2d09dbc75e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2588,7 +2588,7 @@ void udp_destroy_sock(struct sock *sk)
  *	Socket option code for UDP
  */
 int udp_lib_setsockopt(struct sock *sk, int level, int optname,
-		       char __user *optval, unsigned int optlen,
+		       sockptr_t optval, unsigned int optlen,
 		       int (*push_pending_frames)(struct sock *))
 {
 	struct udp_sock *up = udp_sk(sk);
@@ -2599,7 +2599,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 	if (optlen < sizeof(int))
 		return -EINVAL;
 
-	if (get_user(val, (int __user *)optval))
+	if (copy_from_sockptr(&val, optval, sizeof(val)))
 		return -EFAULT;
 
 	valbool = val ? 1 : 0;
@@ -2707,7 +2707,8 @@ int udp_setsockopt(struct sock *sk, int level, int optname,
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
index 7c1143feb2bf7e..2df1e6c9d7cbf6 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1622,7 +1622,8 @@ int udpv6_setsockopt(struct sock *sk, int level, int optname,
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

