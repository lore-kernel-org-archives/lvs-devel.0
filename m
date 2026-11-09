Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=91.218.175.90
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794192998;
	b=DTDptq4cwfN4WZ/ew8pV8nqIjTGYPq3ma7c9eolT7ATKgHf3zknMssSr+Kb2x2gZn/mx
	 dqOBq5aWQGvMBT4bAOZRrixpK7hDM8D6nSDcOuiaArwI6haRmlkhSf+AkzlL6JYYsWJyz
	 X9s+jamCy0jlT17sWVujoFuBLjtCAsQjacoYd9FY2tomnPj8sgEIgnIV0Gm1YG2+9jEvY
	 1OW20U27spFNrBlc6LwqhAp4TNnM/MgNpWyUdKJ1b12u70DU8HiArXQFLZb1P4iNEaG3k
	 Mmv615Kr3H/KDQ4jKHhyYlFBFmVHjl2kX70caN/AvcOaGCulPRw2DbbFMre8rxhdYIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794192998;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=x0JDGtGCXd7TffH/+d34YMn2ktB/SOhkBO9QkKhS8XA=;
	b=Tc9rJBv8alNIldonZg6A3qByBQQQgAONALngEsJPvRYksKM49A/9BBNIK15zXY3zHWYY
	 PDfZjhBNSwomgvvoLJt/HDNk3E9upcLYLCKHbiGFsS8fRdI9+PYRAsQeVOp9GEwEbtbRJ
	 uJP3/nbF2OVyifvGUPxtaw1UjCk4kICpS5eZnIeYd3N+bxG47wnBlz0OEhQub8hvPQYxm
	 a4E1UdBd1cYQCv7bLIP+8mj12LnOkR+ASDfiUUTP6gQZlAwmY4aKZ/KwPKJA9n3cU+5Jb
	 c9YIkjMbRcAb/8PGmMVugzdex+NFXRKI12wW0JuTkfsAj9wQW9Y9PSKuCNauePXXUvg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=g1lDsqiR;
	arc=none smtp.remote-ip=91.218.175.90
Received: from mta0.migadu.com (out-90.mta0.migadu.com [91.218.175.90])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0D8D606A333
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 02:56:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A0D8D606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=g1lDsqiR
X-Envelope-To: lvs-devel@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=oYQ00QqKoEkMvDxebrBIGfEKZ3Gcw97sYPD1Al7A4CY=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794192995; v=1; x=1794797795;
 b=g1lDsqiRSINm9ZEaABG2qZP+5s1BctYSAflnusynK6Z5qrpASmJlxemvHGJdiLbPOrJM/oqh
 5SaPhl/akgvJyGDPWjhE2TSBoU16VCsh2818YLzaAa/6Qwy4bisPFL0ifMLGzfAk+HdqPuqX7xB
 nIPVjw5vYODGgnpVoPCItWVs=
X-Envelope-To: lvs-devel@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id bb9a3d38076780ee;
	Mon, 09 Nov 2026 02:56:35 +0000
X-Mizu-Trace-ID: bb9a3d38076780ee
X-Migadu-Flow: FLOW_OUT
From: Jiayuan Chen <jiayuan.chen@linux.dev>
To: netdev@vger.kernel.org
Cc: Jiayuan Chen <jiayuan.chen@linux.dev>,
	David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	bridge@lists.linux.dev,
	linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev,
	lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org,
	linux-s390@vger.kernel.org
Subject: [PATCH net-next 03/14] ipv6: annotate data-races around addrconf sysctls
Date: Mon,  9 Nov 2026 10:52:02 +0800
Message-ID: <20261109025425.328445-4-jiayuan.chen@linux.dev>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261109025425.328445-1-jiayuan.chen@linux.dev>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The forwarding setting of conf/all, the per-device autoconf, accept_ra,
accept_ra_min_lft, addr_gen_mode, ra_defrtr_metric, disable_ipv6 and mtu6
settings, and the per-netns idgen_retries and idgen_delay, can be read
concurrently with the sysctl handlers that update them with WRITE_ONCE().
Add READ_ONCE() to the readers.

KCSAN reports it when net.ipv6.conf.<dev>.autoconf is changed while
Router Advertisements are received on the device:

  BUG: KCSAN: data-race in addrconf_prefix_rcv / do_proc_int_conv

  write (marked) to 0xffff8d7250116df4 of 4 bytes by task 767 on cpu 2:
   do_proc_int_conv+0xa9/0xd0
   proc_vec_conv+0x21/0x40
   proc_vec+0x21e/0x6f0
   proc_dointvec+0x16/0x30
   proc_sys_call_handler+0x282/0x3a0
   proc_sys_write+0x13/0x20
   ...

  read to 0xffff8d7250116df4 of 4 bytes by interrupt on cpu 1:
   addrconf_prefix_rcv+0x474/0xf00
   ndisc_router_discovery+0xf4f/0x1f80
   ndisc_rcv+0x2a2/0x3c0
   icmpv6_rcv+0xb46/0xd40
   ip6_protocol_deliver_rcu+0x787/0x9a0
   ip6_input_finish+0xb0/0x1b0
   ip6_input+0xa8/0x250
   ip6_mc_input+0x249/0x780
   ipv6_rcv+0x1b1/0x1c0
   __netif_receive_skb_one_core+0x8f/0xe0
   ...

  value changed: 0x00000001 -> 0x00000000

Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
---
 net/ipv6/addrconf.c | 22 ++++++++++++----------
 net/ipv6/ndisc.c    |  2 +-
 net/ipv6/route.c    |  8 ++++----
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d9d13e78bf13b..40f94124641d4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1104,7 +1104,7 @@ ipv6_add_addr(struct inet6_dev *idev, struct ifa6_config *cfg,
 		goto out;
 	}
 
-	if (idev->cnf.disable_ipv6) {
+	if (READ_ONCE(idev->cnf.disable_ipv6)) {
 		NL_SET_ERR_MSG_MOD(extack, "IPv6 is disabled on this device");
 		err = -EACCES;
 		goto out;
@@ -2215,7 +2215,7 @@ void addrconf_dad_failure(struct sk_buff *skb, struct inet6_ifaddr *ifp)
 			.scope = ifp->scope,
 		};
 
-		if (retries > net->ipv6.sysctl.idgen_retries) {
+		if (retries > READ_ONCE(net->ipv6.sysctl.idgen_retries)) {
 			net_info_ratelimited("%s: privacy stable address generation failed because of DAD conflicts!\n",
 					     ifp->idev->dev->name);
 			goto errdad;
@@ -2248,7 +2248,7 @@ void addrconf_dad_failure(struct sk_buff *skb, struct inet6_ifaddr *ifp)
 		spin_unlock_bh(&ifp2->lock);
 
 		if (start_dad)
-			addrconf_mod_dad_work(ifp2, net->ipv6.sysctl.idgen_delay);
+			addrconf_mod_dad_work(ifp2, READ_ONCE(net->ipv6.sysctl.idgen_delay));
 		in6_ifa_put(ifp2);
 lock_errdad:
 		spin_lock_bh(&ifp->lock);
@@ -2706,8 +2706,10 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 
 static bool is_addr_mode_generate_stable(struct inet6_dev *idev)
 {
-	return idev->cnf.addr_gen_mode == IN6_ADDR_GEN_MODE_STABLE_PRIVACY ||
-	       idev->cnf.addr_gen_mode == IN6_ADDR_GEN_MODE_RANDOM;
+	u32 mode = READ_ONCE(idev->cnf.addr_gen_mode);
+
+	return mode == IN6_ADDR_GEN_MODE_STABLE_PRIVACY ||
+	       mode == IN6_ADDR_GEN_MODE_RANDOM;
 }
 
 int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
@@ -2735,7 +2737,7 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		if ((READ_ONCE(net->ipv6.devconf_all->optimistic_dad) ||
 		     READ_ONCE(in6_dev->cnf.optimistic_dad)) &&
-		    !net->ipv6.devconf_all->forwarding && sllao)
+		    !READ_ONCE(net->ipv6.devconf_all->forwarding) && sllao)
 			cfg.ifa_flags |= IFA_F_OPTIMISTIC;
 #endif
 
@@ -2857,7 +2859,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 		return;
 	}
 
-	if (valid_lft != 0 && valid_lft < in6_dev->cnf.accept_ra_min_lft)
+	if (valid_lft != 0 && valid_lft < READ_ONCE(in6_dev->cnf.accept_ra_min_lft))
 		goto put;
 
 	/*
@@ -2928,7 +2930,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	/* Try to figure out our local address for this prefix */
 
 	ignore_autoconf = READ_ONCE(in6_dev->cnf.ra_honor_pio_pflag) && pinfo->preferpd;
-	if (pinfo->autoconf && in6_dev->cnf.autoconf && !ignore_autoconf) {
+	if (pinfo->autoconf && READ_ONCE(in6_dev->cnf.autoconf) && !ignore_autoconf) {
 		struct in6_addr addr;
 		bool tokenized = false, dev_addr_generated = false;
 
@@ -3434,7 +3436,7 @@ static int ipv6_generate_stable_address(struct in6_addr *address,
 
 	if (ipv6_reserved_interfaceid(temp)) {
 		dad_count++;
-		if (dad_count > dev_net(idev->dev)->ipv6.sysctl.idgen_retries)
+		if (dad_count > READ_ONCE(dev_net(idev->dev)->ipv6.sysctl.idgen_retries))
 			return -1;
 		goto retry;
 	}
@@ -3805,7 +3807,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			 * when the interface up, the changed MTU must be
 			 * reflected in the idev as well as routers.
 			 */
-			if (idev->cnf.mtu6 != dev->mtu &&
+			if (READ_ONCE(idev->cnf.mtu6) != dev->mtu &&
 			    dev->mtu >= IPV6_MIN_MTU) {
 				rt6_mtu_change(dev, dev->mtu);
 				WRITE_ONCE(idev->cnf.mtu6, dev->mtu);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0ed1a619372bf..b69e6d66e8b1a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1375,7 +1375,7 @@ static enum skb_drop_reason ndisc_router_discovery(struct sk_buff *skb)
 		}
 	}
 	/* Set default route metric as specified by user */
-	defrtr_usr_metric = in6_dev->cnf.ra_defrtr_metric;
+	defrtr_usr_metric = READ_ONCE(in6_dev->cnf.ra_defrtr_metric);
 	/* delete the route if lifetime is 0 or if metric needs change */
 	if (rt && (lifetime == 0 || rt->fib6_metric != defrtr_usr_metric)) {
 		ip6_del_rt_reason(net, rt,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 04098cf32eabe..91a003417697c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2065,7 +2065,7 @@ static bool rt6_mtu_change_route_allowed(struct inet6_dev *idev,
 	if (dmtu >= mtu)
 		return true;
 
-	if (dmtu == idev->cnf.mtu6)
+	if (dmtu == READ_ONCE(idev->cnf.mtu6))
 		return true;
 
 	return false;
@@ -3666,7 +3666,7 @@ int fib6_nh_init(struct net *net, struct fib6_nh *fib6_nh,
 	if (!dev)
 		goto out;
 
-	if (!idev || idev->cnf.disable_ipv6) {
+	if (!idev || READ_ONCE(idev->cnf.disable_ipv6)) {
 		NL_SET_ERR_MSG(extack, "IPv6 is disabled on nexthop device");
 		err = -EACCES;
 		goto out;
@@ -4533,7 +4533,7 @@ static void __rt6_purge_dflt_routers(struct net *net,
 		struct inet6_dev *idev = dev ? __in6_dev_get(dev) : NULL;
 
 		if (rt->fib6_flags & (RTF_DEFAULT | RTF_ADDRCONF) &&
-		    (!idev || idev->cnf.accept_ra != 2) &&
+		    (!idev || READ_ONCE(idev->cnf.accept_ra) != 2) &&
 		    fib6_info_hold_safe(rt)) {
 			rcu_read_unlock();
 			ip6_del_rt(net, rt, false);
@@ -5075,7 +5075,7 @@ static int fib6_nh_mtu_change(struct fib6_nh *nh, void *_arg)
 			return 0;
 
 		if (mtu >= arg->mtu ||
-		    (mtu < arg->mtu && mtu == idev->cnf.mtu6))
+		    (mtu < arg->mtu && mtu == READ_ONCE(idev->cnf.mtu6)))
 			fib6_metric_set(f6i, RTAX_MTU, arg->mtu);
 
 		spin_lock_bh(&rt6_exception_lock);
-- 
2.43.0

