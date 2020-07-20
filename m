From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 13/24] net/ipv4: switch ip_mroute_setsockopt to sockptr_t
Date: Mon, 20 Jul 2020 14:47:26 +0200
Message-ID: <20200720124737.118617-14-hch@lst.de>
References: <20200720124737.118617-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=3imfOAwuDTlb5YTszhgUXl+QpResNZl5INQAts7FDyw=; b=Ut0l44CFA54d4E1NP9YTRY3nZH
        rB1WsrhZdhD676gx5CTQxXzgJza4+zNMlCTFiZtYiZguvuZJeKCQH6hHSnMDfv9t3QhoJdHJizsON
        IfnubErBJ4rbUnZpM95nKJMr1slACF21eLDALHC5911LsdnVJEuMfyFNGDFPvYOvtGbJ71c4R/JJt
        xFnqPSeJyepxaPCzhDOGd8zc2RxMo5rRBW9qnSkipnrKMlngeTvvEr1QfpatbiGmfuVQzYx0JBT7J
        qCiLjQ2nguzdobsGUxVco81qotZbGQ87K7anNuwMSSbgU8r3Ek2sIKVFhad4HuGFQ5Xst2Txu6LUg
        EBZ5oaWg==;
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/mroute.h |  5 +++--
 net/ipv4/ip_sockglue.c |  3 ++-
 net/ipv4/ipmr.c        | 14 +++++++-------
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 9a36fad9e068f6..6cbbfe94348cee 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -8,6 +8,7 @@
 #include <net/fib_notifier.h>
 #include <uapi/linux/mroute.h>
 #include <linux/mroute_base.h>
+#include <linux/sockptr.h>
 
 #ifdef CONFIG_IP_MROUTE
 static inline int ip_mroute_opt(int opt)
@@ -15,7 +16,7 @@ static inline int ip_mroute_opt(int opt)
 	return opt >= MRT_BASE && opt <= MRT_MAX;
 }
 
-int ip_mroute_setsockopt(struct sock *, int, char __user *, unsigned int);
+int ip_mroute_setsockopt(struct sock *, int, sockptr_t, unsigned int);
 int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
 int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
@@ -23,7 +24,7 @@ int ip_mr_init(void);
 bool ipmr_rule_default(const struct fib_rule *rule);
 #else
 static inline int ip_mroute_setsockopt(struct sock *sock, int optname,
-				       char __user *optval, unsigned int optlen)
+				       sockptr_t optval, unsigned int optlen)
 {
 	return -ENOPROTOOPT;
 }
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 36f746e01741f6..ac495b0cff8ffb 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -925,7 +925,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	if (optname == IP_ROUTER_ALERT)
 		return ip_ra_control(sk, val ? 1 : 0, NULL);
 	if (ip_mroute_opt(optname))
-		return ip_mroute_setsockopt(sk, optname, optval, optlen);
+		return ip_mroute_setsockopt(sk, optname, USER_SOCKPTR(optval),
+					    optlen);
 
 	err = 0;
 	if (needs_rtnl)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 678639c01e4882..cdf3a40f9ff5fc 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1341,7 +1341,7 @@ static void mrtsock_destruct(struct sock *sk)
  * MOSPF/PIM router set up we can clean this up.
  */
 
-int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
+int ip_mroute_setsockopt(struct sock *sk, int optname, sockptr_t optval,
 			 unsigned int optlen)
 {
 	struct net *net = sock_net(sk);
@@ -1413,7 +1413,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (copy_from_user(&vif, optval, sizeof(vif))) {
+		if (copy_from_sockptr(&vif, optval, sizeof(vif))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1441,7 +1441,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (copy_from_user(&mfc, optval, sizeof(mfc))) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1459,7 +1459,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(val, (int __user *)optval)) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1471,7 +1471,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(val, (int __user *)optval)) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1486,7 +1486,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(val, (int __user *)optval)) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1508,7 +1508,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(uval, (u32 __user *)optval)) {
+		if (copy_from_sockptr(&uval, optval, sizeof(uval))) {
 			ret = -EFAULT;
 			break;
 		}
-- 
2.27.0

