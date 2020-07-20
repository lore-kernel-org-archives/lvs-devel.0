From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/24] bpfilter: switch bpfilter_ip_set_sockopt to sockptr_t
Date: Mon, 20 Jul 2020 14:47:25 +0200
Message-ID: <20200720124737.118617-13-hch@lst.de>
References: <20200720124737.118617-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=+GvvL8q4oszQFmBGqA8ndhgAauPjYMp2YX20se2Rz14=; b=W/SFxvtjkpSbdCe3dGLDpwJysW
        Kf4mT9bppvn0bssZdcjZ5n0WRzHADU80XMa/3Y59SzGPudsLo+1rn4dGwK3m37MREE/JLRpPK/xr1
        UojjBq5qMtyBaoa+1AhydjHBQCM62nWZQFpfq76FY5SIXZ/oa4NZKGkB3UknnUnERbor1KGqfxaDa
        OnMIIRS/5shvCVa0wpTtP7NbwnkKSvPnPraxFDVCyejDWY23QLiHJ/unihJrffXuaOuSE+ZY/M8WP
        5Q684yLCTG6auKnTJjrd4V2q+y5dRCZjY5nTzujW1+uNfnmVlc7heVlcKQqkDHBDZEEG/Xxh2qDj6
        mbDMFwGg==;
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

This is mostly to prepare for cleaning up the callers, as bpfilter by
design can't handle kernel pointers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/bpfilter.h     | 6 +++---
 net/bpfilter/bpfilter_kern.c | 8 ++++----
 net/ipv4/bpfilter/sockopt.c  | 8 ++++----
 net/ipv4/ip_sockglue.c       | 3 ++-
 4 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/linux/bpfilter.h b/include/linux/bpfilter.h
index 9b114c718a7617..2ae3c8e1d83c43 100644
--- a/include/linux/bpfilter.h
+++ b/include/linux/bpfilter.h
@@ -4,9 +4,10 @@
 
 #include <uapi/linux/bpfilter.h>
 #include <linux/usermode_driver.h>
+#include <linux/sockptr.h>
 
 struct sock;
-int bpfilter_ip_set_sockopt(struct sock *sk, int optname, char __user *optval,
+int bpfilter_ip_set_sockopt(struct sock *sk, int optname, sockptr_t optval,
 			    unsigned int optlen);
 int bpfilter_ip_get_sockopt(struct sock *sk, int optname, char __user *optval,
 			    int __user *optlen);
@@ -16,8 +17,7 @@ struct bpfilter_umh_ops {
 	struct umd_info info;
 	/* since ip_getsockopt() can run in parallel, serialize access to umh */
 	struct mutex lock;
-	int (*sockopt)(struct sock *sk, int optname,
-		       char __user *optval,
+	int (*sockopt)(struct sock *sk, int optname, sockptr_t optval,
 		       unsigned int optlen, bool is_set);
 	int (*start)(void);
 };
diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
index 713b4b3d02005d..52f8d0bc3f6b29 100644
--- a/net/bpfilter/bpfilter_kern.c
+++ b/net/bpfilter/bpfilter_kern.c
@@ -32,7 +32,7 @@ static void __stop_umh(void)
 }
 
 static int __bpfilter_process_sockopt(struct sock *sk, int optname,
-				      char __user *optval,
+				      sockptr_t optval,
 				      unsigned int optlen, bool is_set)
 {
 	struct mbox_request req;
@@ -41,7 +41,7 @@ static int __bpfilter_process_sockopt(struct sock *sk, int optname,
 	ssize_t n;
 	int ret = -EFAULT;
 
-	if (uaccess_kernel()) {
+	if (uaccess_kernel() || sockptr_is_kernel(optval)) {
 		pr_err("kernel access not supported\n");
 		return -EFAULT;
 	}
@@ -49,7 +49,7 @@ static int __bpfilter_process_sockopt(struct sock *sk, int optname,
 	req.is_set = is_set;
 	req.pid = current->pid;
 	req.cmd = optname;
-	req.addr = (__force long)optval;
+	req.addr = (__force long)optval.user;
 	req.len = optlen;
 	if (!bpfilter_ops.info.tgid)
 		goto out;
@@ -87,7 +87,7 @@ static int start_umh(void)
 	pr_info("Loaded bpfilter_umh pid %d\n", pid_nr(bpfilter_ops.info.tgid));
 
 	/* health check that usermode process started correctly */
-	if (__bpfilter_process_sockopt(NULL, 0, NULL, 0, 0) != 0) {
+	if (__bpfilter_process_sockopt(NULL, 0, USER_SOCKPTR(NULL), 0, 0)) {
 		shutdown_umh();
 		return -EFAULT;
 	}
diff --git a/net/ipv4/bpfilter/sockopt.c b/net/ipv4/bpfilter/sockopt.c
index 9063c6767d3410..1b34cb9a7708ec 100644
--- a/net/ipv4/bpfilter/sockopt.c
+++ b/net/ipv4/bpfilter/sockopt.c
@@ -21,8 +21,7 @@ void bpfilter_umh_cleanup(struct umd_info *info)
 }
 EXPORT_SYMBOL_GPL(bpfilter_umh_cleanup);
 
-static int bpfilter_mbox_request(struct sock *sk, int optname,
-				 char __user *optval,
+static int bpfilter_mbox_request(struct sock *sk, int optname, sockptr_t optval,
 				 unsigned int optlen, bool is_set)
 {
 	int err;
@@ -52,7 +51,7 @@ static int bpfilter_mbox_request(struct sock *sk, int optname,
 	return err;
 }
 
-int bpfilter_ip_set_sockopt(struct sock *sk, int optname, char __user *optval,
+int bpfilter_ip_set_sockopt(struct sock *sk, int optname, sockptr_t optval,
 			    unsigned int optlen)
 {
 	return bpfilter_mbox_request(sk, optname, optval, optlen, true);
@@ -66,7 +65,8 @@ int bpfilter_ip_get_sockopt(struct sock *sk, int optname, char __user *optval,
 	if (get_user(len, optlen))
 		return -EFAULT;
 
-	return bpfilter_mbox_request(sk, optname, optval, len, false);
+	return bpfilter_mbox_request(sk, optname, USER_SOCKPTR(optval), len,
+				     false);
 }
 
 static int __init bpfilter_sockopt_init(void)
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 42befbf12846c0..36f746e01741f6 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1414,7 +1414,8 @@ int ip_setsockopt(struct sock *sk, int level,
 #if IS_ENABLED(CONFIG_BPFILTER_UMH)
 	if (optname >= BPFILTER_IPT_SO_SET_REPLACE &&
 	    optname < BPFILTER_IPT_SET_MAX)
-		err = bpfilter_ip_set_sockopt(sk, optname, optval, optlen);
+		err = bpfilter_ip_set_sockopt(sk, optname, USER_SOCKPTR(optval),
+					      optlen);
 #endif
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
-- 
2.27.0

