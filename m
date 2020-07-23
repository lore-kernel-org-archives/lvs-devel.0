From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/26] net: switch sock_set_timeout to sockptr_t
Date: Thu, 23 Jul 2020 08:08:49 +0200
Message-ID: <20200723060908.50081-8-hch@lst.de>
References: <20200723060908.50081-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=xqGJvoPJ0+pH4qYG06e/7bN83cyQPL98EGqqjHTTiVQ=; b=tp0Qjqxv0RF9S9VMvHxOQakmQ+
        NHHCC0pZ4D54ej/cePwKmpeQERvhgixf2rr+yFCMAku4YwZ7qHeZ23zUko4Runxz4X2FA51oNK9RB
        G71rtpRMLN+TsNxoueQ+MRUu2h3xtmBHPMKP/izudC5N1oy/s4c0lP2BwaH2EI/Tr0TB9gDhdqJ6a
        rycFr/S96lGHvxszuLGeDv20/dHJLbjMO/W0HRsKz2fbUItwUz/GhoTeBU/3lzVe84kUEMznjTO9R
        ZoRl8WaL9OyZSPxjaiWAD5kw4pVGMaXBipOjPZoChto8wAEpQi6Fg9FEFIqXI5trxbLidsCIfPpe2
        WB6TV97Q==;
In-Reply-To: <20200723060908.50081-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/core/sock.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5b55bc9397f282..8b9eddaff868a5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -361,7 +361,8 @@ static int sock_get_timeout(long timeo, void *optval, bool old_timeval)
 	return sizeof(tv);
 }
 
-static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen, bool old_timeval)
+static int sock_set_timeout(long *timeo_p, sockptr_t optval, int optlen,
+			    bool old_timeval)
 {
 	struct __kernel_sock_timeval tv;
 
@@ -371,7 +372,7 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen, bool
 		if (optlen < sizeof(tv32))
 			return -EINVAL;
 
-		if (copy_from_user(&tv32, optval, sizeof(tv32)))
+		if (copy_from_sockptr(&tv32, optval, sizeof(tv32)))
 			return -EFAULT;
 		tv.tv_sec = tv32.tv_sec;
 		tv.tv_usec = tv32.tv_usec;
@@ -380,14 +381,14 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen, bool
 
 		if (optlen < sizeof(old_tv))
 			return -EINVAL;
-		if (copy_from_user(&old_tv, optval, sizeof(old_tv)))
+		if (copy_from_sockptr(&old_tv, optval, sizeof(old_tv)))
 			return -EFAULT;
 		tv.tv_sec = old_tv.tv_sec;
 		tv.tv_usec = old_tv.tv_usec;
 	} else {
 		if (optlen < sizeof(tv))
 			return -EINVAL;
-		if (copy_from_user(&tv, optval, sizeof(tv)))
+		if (copy_from_sockptr(&tv, optval, sizeof(tv)))
 			return -EFAULT;
 	}
 	if (tv.tv_usec < 0 || tv.tv_usec >= USEC_PER_SEC)
@@ -1051,12 +1052,14 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 
 	case SO_RCVTIMEO_OLD:
 	case SO_RCVTIMEO_NEW:
-		ret = sock_set_timeout(&sk->sk_rcvtimeo, optval, optlen, optname == SO_RCVTIMEO_OLD);
+		ret = sock_set_timeout(&sk->sk_rcvtimeo, USER_SOCKPTR(optval),
+				       optlen, optname == SO_RCVTIMEO_OLD);
 		break;
 
 	case SO_SNDTIMEO_OLD:
 	case SO_SNDTIMEO_NEW:
-		ret = sock_set_timeout(&sk->sk_sndtimeo, optval, optlen, optname == SO_SNDTIMEO_OLD);
+		ret = sock_set_timeout(&sk->sk_sndtimeo, USER_SOCKPTR(optval),
+				       optlen, optname == SO_SNDTIMEO_OLD);
 		break;
 
 	case SO_ATTACH_FILTER: {
-- 
2.27.0

