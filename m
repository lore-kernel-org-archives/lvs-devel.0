From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 19/26] net/ipv6: switch ipv6_flowlabel_opt to sockptr_t
Date: Thu, 23 Jul 2020 08:09:01 +0200
Message-ID: <20200723060908.50081-20-hch@lst.de>
References: <20200723060908.50081-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=QlF9uAsII4M+JCuvUaS+q9mzPBlfDSxuvtjJe160dNk=; b=uZpwgVyKUu+sHnxI+GopWTiL6d
        DflWs0zNQjkIouFC0PpLfgVqeceaXeebrBT5Hvgv+9HSYM4TyCMCIZGNx0+eYeBh9Tk5DjZoJE2ro
        UJGhbM7n/58Y745F6R/Sl5/zL7mwtLqnrhlHyFj6SCbQnnMskl3ihsH7pO2q9RweF/QQgtU+/UtiD
        nZj8xRqnjHonqyiSEDEzjBQjJvsw20nWfWc6j5DF0O44Txm+ejF4IsqcMx+w2BErUSkUFBMz1LlXR
        2i8tmMsDMWhw3zS9ExTIp/pb+BbFtV9/+PhOtPC2fO6cdMLW1zjwttIWVfyd6a0qDsrPXfM7heqhE
        v40/SZRw==;
In-Reply-To: <20200723060908.50081-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dccp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mptcp-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Note that the get case is pretty weird in that it actually copies data
back to userspace from setsockopt.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 include/net/ipv6.h       |  2 +-
 net/ipv6/ip6_flowlabel.c | 16 +++++++++-------
 net/ipv6/ipv6_sockglue.c |  2 +-
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 262fc88dbd7e2f..4c9d89b5d73268 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -406,7 +406,7 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions *opt_space,
 					 struct ip6_flowlabel *fl,
 					 struct ipv6_txoptions *fopt);
 void fl6_free_socklist(struct sock *sk);
-int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen);
+int ipv6_flowlabel_opt(struct sock *sk, sockptr_t optval, int optlen);
 int ipv6_flowlabel_opt_get(struct sock *sk, struct in6_flowlabel_req *freq,
 			   int flags);
 int ip6_flowlabel_init(void);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 27ee6de9beffc4..6b3c315f3d461a 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -371,7 +371,7 @@ static int fl6_renew(struct ip6_flowlabel *fl, unsigned long linger, unsigned lo
 
 static struct ip6_flowlabel *
 fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
-	  char __user *optval, int optlen, int *err_p)
+	  sockptr_t optval, int optlen, int *err_p)
 {
 	struct ip6_flowlabel *fl = NULL;
 	int olen;
@@ -401,7 +401,8 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		memset(fl->opt, 0, sizeof(*fl->opt));
 		fl->opt->tot_len = sizeof(*fl->opt) + olen;
 		err = -EFAULT;
-		if (copy_from_user(fl->opt+1, optval+CMSG_ALIGN(sizeof(*freq)), olen))
+		sockptr_advance(optval, CMSG_ALIGN(sizeof(*freq)));
+		if (copy_from_sockptr(fl->opt + 1, optval, olen))
 			goto done;
 
 		msg.msg_controllen = olen;
@@ -604,7 +605,7 @@ static int ipv6_flowlabel_renew(struct sock *sk, struct in6_flowlabel_req *freq)
 }
 
 static int ipv6_flowlabel_get(struct sock *sk, struct in6_flowlabel_req *freq,
-		void __user *optval, int optlen)
+		sockptr_t optval, int optlen)
 {
 	struct ipv6_fl_socklist *sfl, *sfl1 = NULL;
 	struct ip6_flowlabel *fl, *fl1 = NULL;
@@ -702,8 +703,9 @@ static int ipv6_flowlabel_get(struct sock *sk, struct in6_flowlabel_req *freq,
 		goto recheck;
 
 	if (!freq->flr_label) {
-		if (copy_to_user(&((struct in6_flowlabel_req __user *) optval)->flr_label,
-				 &fl->label, sizeof(fl->label))) {
+		sockptr_advance(optval,
+				offsetof(struct in6_flowlabel_req, flr_label));
+		if (copy_to_sockptr(optval, &fl->label, sizeof(fl->label))) {
 			/* Intentionally ignore fault. */
 		}
 	}
@@ -716,13 +718,13 @@ static int ipv6_flowlabel_get(struct sock *sk, struct in6_flowlabel_req *freq,
 	return err;
 }
 
-int ipv6_flowlabel_opt(struct sock *sk, char __user *optval, int optlen)
+int ipv6_flowlabel_opt(struct sock *sk, sockptr_t optval, int optlen)
 {
 	struct in6_flowlabel_req freq;
 
 	if (optlen < sizeof(freq))
 		return -EINVAL;
-	if (copy_from_user(&freq, optval, sizeof(freq)))
+	if (copy_from_sockptr(&freq, optval, sizeof(freq)))
 		return -EFAULT;
 
 	switch (freq.flr_action) {
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 119dfaf5f4bb26..3897fb55372d38 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -929,7 +929,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = 0;
 		break;
 	case IPV6_FLOWLABEL_MGR:
-		retv = ipv6_flowlabel_opt(sk, optval, optlen);
+		retv = ipv6_flowlabel_opt(sk, USER_SOCKPTR(optval), optlen);
 		break;
 	case IPV6_IPSEC_POLICY:
 	case IPV6_XFRM_POLICY:
-- 
2.27.0

