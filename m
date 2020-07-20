From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 22/24] net/tcp: switch ->md5_parse to sockptr_t
Date: Mon, 20 Jul 2020 14:47:35 +0200
Message-ID: <20200720124737.118617-23-hch@lst.de>
References: <20200720124737.118617-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=XFgdEhn2vLmThLShP1o7gYGDYV3zgNoNH4PA05fsJS8=; b=Wkzy9EJDG4l7lgluY2A4k1gkzk
        dHXnUTdC/Nhh1WIcSPASdHtlIMwcRj8ffKYWkm/ND2HeOF9pwAr6W0kFtq++kQkmsFbDKkGph29TG
        mLxMkHP/KhFXpyNQnHvKtgkdUiKmemflpUt39osjFaqvvF/EFGdVXCXHfwu5HIh/q2IOaC35QPVM6
        DUvpfkRYCdoLNG0Zz72Bb7JVAWpDKbATSgbOwnqvggK4gHxNhJVnpZGhEV0mRP+mMAL7ub9tuTAvU
        xQHw+/y8tgti6Qyzdrzl2hUUfwrzU7JnbzMGgsdbBO4RfqCvdlUEEmDH0RkjxN+ICaczwlL2GumfX
        JoHLgVXw==;
In-Reply-To: <20200720124737.118617-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dccp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mptcp-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 include/net/tcp.h   | 2 +-
 net/ipv4/tcp.c      | 3 ++-
 net/ipv4/tcp_ipv4.c | 4 ++--
 net/ipv6/tcp_ipv6.c | 4 ++--
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9f7f7c0c110451..e3c8e1d820214c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -2002,7 +2002,7 @@ struct tcp_sock_af_ops {
 					 const struct sk_buff *skb);
 	int		(*md5_parse)(struct sock *sk,
 				     int optname,
-				     char __user *optval,
+				     sockptr_t optval,
 				     int optlen);
 #endif
 };
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 58ede3d62b2e2c..49bf15c27deac7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3249,7 +3249,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 #ifdef CONFIG_TCP_MD5SIG
 	case TCP_MD5SIG:
 	case TCP_MD5SIG_EXT:
-		err = tp->af_specific->md5_parse(sk, optname, optval, optlen);
+		err = tp->af_specific->md5_parse(sk, optname,
+						 USER_SOCKPTR(optval), optlen);
 		break;
 #endif
 	case TCP_USER_TIMEOUT:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd81b6e04efbfa..a03e70b3af2e6c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1194,7 +1194,7 @@ static void tcp_clear_md5_list(struct sock *sk)
 }
 
 static int tcp_v4_parse_md5_keys(struct sock *sk, int optname,
-				 char __user *optval, int optlen)
+				 sockptr_t optval, int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
@@ -1205,7 +1205,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, int optname,
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
 
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+	if (copy_from_sockptr(&cmd, optval, sizeof(cmd)))
 		return -EFAULT;
 
 	if (sin->sin_family != AF_INET)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c34b7834fd84a8..305870a72352d6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -567,7 +567,7 @@ static struct tcp_md5sig_key *tcp_v6_md5_lookup(const struct sock *sk,
 }
 
 static int tcp_v6_parse_md5_keys(struct sock *sk, int optname,
-				 char __user *optval, int optlen)
+				 sockptr_t optval, int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
@@ -577,7 +577,7 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, int optname,
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
 
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+	if (copy_from_sockptr(&cmd, optval, sizeof(cmd)))
 		return -EFAULT;
 
 	if (sin6->sin6_family != AF_INET6)
-- 
2.27.0

