From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] net/netfilter: use pr_<level> consistently
Date: Wed, 30 Sep 2009 15:37:20 -0700
Message-ID: <0fbb9ebb6d8823e71424317a177bbdcd9220c84f.1254349375.git.joe@perches.com>
References: <cover.1254349374.git.joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <cover.1254349374.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

Makefile adds a ccflags-y define pr_fmt(fmt)=KBUILD_MODNAME ": " fmt

Many fixed string prefixes are removed
Existing printks and pr_<level>s with KBUILD_MODNAMEs and PFXs are stripped
printks without KERN_ levels are converted to pr_info
Some printks with embedded function names are converted to %s...__func__

Some logging messages now have slightly different content,
but it's standardized content now.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/netfilter/Makefile                  |    2 +
 net/netfilter/nf_conntrack_acct.c       |   12 ++--
 net/netfilter/nf_conntrack_amanda.c     |    2 +-
 net/netfilter/nf_conntrack_core.c       |   35 ++++-----
 net/netfilter/nf_conntrack_ecache.c     |    5 +-
 net/netfilter/nf_conntrack_expect.c     |    3 +-
 net/netfilter/nf_conntrack_ftp.c        |   31 ++++-----
 net/netfilter/nf_conntrack_h323_main.c  |  114 +++++++++++++++---------------
 net/netfilter/nf_conntrack_irc.c        |   10 +--
 net/netfilter/nf_conntrack_netlink.c    |   12 ++--
 net/netfilter/nf_conntrack_proto_gre.c  |    4 +-
 net/netfilter/nf_conntrack_proto_sctp.c |    9 +--
 net/netfilter/nf_conntrack_proto_tcp.c  |    4 +-
 net/netfilter/nf_conntrack_sane.c       |   17 ++---
 net/netfilter/nf_conntrack_sip.c        |    5 +-
 net/netfilter/nf_conntrack_standalone.c |    2 +-
 net/netfilter/nf_conntrack_tftp.c       |    3 +-
 net/netfilter/nfnetlink.c               |    6 +-
 net/netfilter/nfnetlink_log.c           |   20 +++---
 net/netfilter/nfnetlink_queue.c         |   15 ++--
 net/netfilter/xt_CONNMARK.c             |    2 +-
 net/netfilter/xt_CONNSECMARK.c          |    8 +--
 net/netfilter/xt_DSCP.c                 |    2 +-
 net/netfilter/xt_HL.c                   |    6 +-
 net/netfilter/xt_LED.c                  |   10 +--
 net/netfilter/xt_NFQUEUE.c              |    4 +-
 net/netfilter/xt_SECMARK.c              |   14 ++--
 net/netfilter/xt_TCPMSS.c               |   18 +++---
 net/netfilter/xt_TPROXY.c               |    3 +-
 net/netfilter/xt_cluster.c              |    8 +--
 net/netfilter/xt_connbytes.c            |    2 +-
 net/netfilter/xt_connlimit.c            |    2 +-
 net/netfilter/xt_connmark.c             |    2 +-
 net/netfilter/xt_conntrack.c            |    2 +-
 net/netfilter/xt_dscp.c                 |    2 +-
 net/netfilter/xt_hashlimit.c            |   24 +++----
 net/netfilter/xt_helper.c               |    2 +-
 net/netfilter/xt_hl.c                   |    4 +-
 net/netfilter/xt_limit.c                |    4 +-
 net/netfilter/xt_osf.c                  |    4 +-
 net/netfilter/xt_physdev.c              |    2 +-
 net/netfilter/xt_policy.c               |   11 +--
 net/netfilter/xt_recent.c               |    9 +--
 net/netfilter/xt_state.c                |    2 +-
 net/netfilter/xt_statistic.c            |    2 +-
 net/netfilter/xt_time.c                 |   14 ++--
 46 files changed, 221 insertions(+), 253 deletions(-)

diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 49f62ee..57089b6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,3 +1,5 @@
+ccflags-y += -D "pr_fmt(fmt)=KBUILD_MODNAME \": \" fmt"
+
 netfilter-objs := core.o nf_log.o nf_queue.o nf_sockopt.o
 
 nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_expect.o nf_conntrack_helper.o nf_conntrack_proto.o nf_conntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_tcp.o nf_conntrack_proto_udp.o nf_conntrack_extend.o nf_conntrack_acct.o
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 4a1d94a..8ecac97 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -77,7 +77,7 @@ static int nf_conntrack_acct_init_sysctl(struct net *net)
 	net->ct.acct_sysctl_header = register_net_sysctl_table(net,
 			nf_net_netfilter_sysctl_path, table);
 	if (!net->ct.acct_sysctl_header) {
-		printk(KERN_ERR "nf_conntrack_acct: can't register to sysctl.\n");
+		pr_err("acct: can't register to sysctl.\n");
 		goto out_register;
 	}
 	return 0;
@@ -115,14 +115,16 @@ int nf_conntrack_acct_init(struct net *net)
 
 	if (net_eq(net, &init_net)) {
 #ifdef CONFIG_NF_CT_ACCT
-	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use\n");
-		printk(KERN_WARNING "nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or\n");
-		printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
+	pr_warning("CONFIG_NF_CT_ACCT is deprecated and will be removed soon.\n"
+		   "Please use one of the options below to enable it:\n"
+		   "      kernel parameter: nf_conntrack.acct=1\n"
+		   "      module option:    acct=1\n"
+		   "  or  sysctl net.netfilter.nf_conntrack_acct=1\n");
 #endif
 
 		ret = nf_ct_extend_register(&acct_extend);
 		if (ret < 0) {
-			printk(KERN_ERR "nf_conntrack_acct: Unable to register extension\n");
+			pr_err("acct: Unable to register extension\n");
 			goto out_extend_register;
 		}
 	}
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 07d9d88..81a49f0 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -107,7 +107,7 @@ static int amanda_help(struct sk_buff *skb,
 	dataoff = protoff + sizeof(struct udphdr);
 	if (dataoff >= skb->len) {
 		if (net_ratelimit())
-			printk("amanda_help: skblen = %u\n", skb->len);
+			pr_info("amanda_help: skblen = %u\n", skb->len);
 		return NF_ACCEPT;
 	}
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7c9ec3d..2eef0ae 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -554,9 +554,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
-				printk(KERN_WARNING
-				       "nf_conntrack: table full, dropping"
-				       " packet.\n");
+				pr_warning("table full, dropping packet.\n");
 			return ERR_PTR(-ENOMEM);
 		}
 	}
@@ -567,7 +565,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	 */
 	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL) {
-		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
+		pr_debug("%s(): Can't alloc conntrack.\n", __func__);
 		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
@@ -636,7 +634,7 @@ init_conntrack(struct net *net,
 
 	if (!l4proto->new(ct, skb, dataoff)) {
 		nf_conntrack_free(ct);
-		pr_debug("init conntrack: can't track with proto module\n");
+		pr_debug("Can't track with proto module\n");
 		return NULL;
 	}
 
@@ -646,7 +644,7 @@ init_conntrack(struct net *net,
 	spin_lock_bh(&nf_conntrack_lock);
 	exp = nf_ct_find_expectation(net, tuple);
 	if (exp) {
-		pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
+		pr_debug("expectation arrives ct=%p exp=%p\n",
 			 ct, exp);
 		/* Welcome, Mr. Bond.  We've been expecting you... */
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
@@ -704,7 +702,7 @@ resolve_normal_ct(struct net *net,
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb),
 			     dataoff, l3num, protonum, &tuple, l3proto,
 			     l4proto)) {
-		pr_debug("resolve_normal_ct: Can't get tuple\n");
+		pr_debug("%s(): Can't get tuple\n", __func__);
 		return NULL;
 	}
 
@@ -727,14 +725,13 @@ resolve_normal_ct(struct net *net,
 	} else {
 		/* Once we've had two way comms, always ESTABLISHED. */
 		if (test_bit(IPS_SEEN_REPLY_BIT, &ct->status)) {
-			pr_debug("nf_conntrack_in: normal packet for %p\n", ct);
+			pr_debug("in: normal packet for %p\n", ct);
 			*ctinfo = IP_CT_ESTABLISHED;
 		} else if (test_bit(IPS_EXPECTED_BIT, &ct->status)) {
-			pr_debug("nf_conntrack_in: related packet for %p\n",
-				 ct);
+			pr_debug("in: related packet for %p\n", ct);
 			*ctinfo = IP_CT_RELATED;
 		} else {
-			pr_debug("nf_conntrack_in: new packet for %p\n", ct);
+			pr_debug("in: new packet for %p\n", ct);
 			*ctinfo = IP_CT_NEW;
 		}
 		*set_reply = 0;
@@ -768,7 +765,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	ret = l3proto->get_l4proto(skb, skb_network_offset(skb),
 				   &dataoff, &protonum);
 	if (ret <= 0) {
-		pr_debug("not prepared to track yet or error occured\n");
+		pr_debug("not prepared to track yet or error occurred\n");
 		NF_CT_STAT_INC_ATOMIC(net, error);
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		return -ret;
@@ -808,7 +805,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	if (ret <= 0) {
 		/* Invalid: inverse of the return code tells
 		 * the netfilter core what to do */
-		pr_debug("nf_conntrack_in: Can't track with proto module\n");
+		pr_debug("in: Can't track with proto module\n");
 		nf_conntrack_put(skb->nfct);
 		skb->nfct = NULL;
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
@@ -1167,7 +1164,7 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int nulls)
 					get_order(sz));
 	if (!hash) {
 		*vmalloced = 1;
-		printk(KERN_WARNING "nf_conntrack: falling back to vmalloc.\n");
+		pr_warning("falling back to vmalloc.\n");
 		hash = __vmalloc(sz, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	}
 
@@ -1260,15 +1257,15 @@ static int nf_conntrack_init_init_net(void)
 	}
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
-	printk("nf_conntrack version %s (%u buckets, %d max)\n",
-	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
-	       nf_conntrack_max);
+	pr_info("version %s (%u buckets, %d max)\n",
+		NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
+		nf_conntrack_max);
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn),
 						0, SLAB_DESTROY_BY_RCU, NULL);
 	if (!nf_conntrack_cachep) {
-		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
+		pr_err("Unable to create slab cache\n");
 		ret = -ENOMEM;
 		goto err_cache;
 	}
@@ -1313,7 +1310,7 @@ static int nf_conntrack_init_net(struct net *net)
 					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
 		ret = -ENOMEM;
-		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
+		pr_err("Unable to create hash table\n");
 		goto err_hash;
 	}
 	ret = nf_conntrack_expect_init(net);
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index aee560b..a4b3a13 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -193,7 +193,7 @@ static int nf_conntrack_event_init_sysctl(struct net *net)
 		register_net_sysctl_table(net,
 					  nf_net_netfilter_sysctl_path, table);
 	if (!net->ct.event_sysctl_header) {
-		printk(KERN_ERR "nf_ct_event: can't register to sysctl.\n");
+		pr_err("event: can't register to sysctl.\n");
 		goto out_register;
 	}
 	return 0;
@@ -233,8 +233,7 @@ int nf_conntrack_ecache_init(struct net *net)
 	if (net_eq(net, &init_net)) {
 		ret = nf_ct_extend_register(&event_extend);
 		if (ret < 0) {
-			printk(KERN_ERR "nf_ct_event: Unable to register "
-					"event extension.\n");
+			pr_err("event: Unable to register event extension.\n");
 			goto out_extend_register;
 		}
 	}
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 2032dfe..1b3c02b 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -404,8 +404,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 
 	if (net->ct.expect_count >= nf_ct_expect_max) {
 		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "nf_conntrack: expectation table full\n");
+			pr_warning("expectation table full\n");
 		ret = -EMFILE;
 	}
 out:
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 5509dd1..64d3c6f 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -201,7 +201,7 @@ static int try_eprt(const char *data, size_t dlen, struct nf_conntrack_man *cmd,
 	}
 	delim = data[0];
 	if (isdigit(delim) || delim < 33 || delim > 126 || data[2] != delim) {
-		pr_debug("try_eprt: invalid delimitter.\n");
+		pr_debug("try_eprt: invalid delimiter.\n");
 		return 0;
 	}
 
@@ -277,9 +277,9 @@ static int find_pattern(const char *data, size_t dlen,
 #if 0
 		size_t i;
 
-		pr_debug("ftp: string mismatch\n");
+		pr_debug("string mismatch\n");
 		for (i = 0; i < plen; i++) {
-			pr_debug("ftp:char %u `%c'(%u) vs `%c'(%u)\n",
+			pr_debug("char %u `%c'(%u) vs `%c'(%u)\n",
 				 i, data[i], data[i],
 				 pattern[i], pattern[i]);
 		}
@@ -368,7 +368,7 @@ static int help(struct sk_buff *skb,
 	/* Until there's been traffic both ways, don't look in packets. */
 	if (ctinfo != IP_CT_ESTABLISHED
 	    && ctinfo != IP_CT_ESTABLISHED+IP_CT_IS_REPLY) {
-		pr_debug("ftp: Conntrackinfo = %u\n", ctinfo);
+		pr_debug("Conntrackinfo = %u\n", ctinfo);
 		return NF_ACCEPT;
 	}
 
@@ -379,7 +379,7 @@ static int help(struct sk_buff *skb,
 	dataoff = protoff + th->doff * 4;
 	/* No data? */
 	if (dataoff >= skb->len) {
-		pr_debug("ftp: dataoff(%u) >= skblen(%u)\n", dataoff,
+		pr_debug("dataoff(%u) >= skblen(%u)\n", dataoff,
 			 skb->len);
 		return NF_ACCEPT;
 	}
@@ -395,7 +395,7 @@ static int help(struct sk_buff *skb,
 	/* Look up to see if we're just after a \n. */
 	if (!find_nl_seq(ntohl(th->seq), ct_ftp_info, dir)) {
 		/* Now if this ends in \n, update ftp info. */
-		pr_debug("nf_conntrack_ftp: wrong seq pos %s(%u) or %s(%u)\n",
+		pr_debug("wrong seq pos %s(%u) or %s(%u)\n",
 			 ct_ftp_info->seq_aft_nl_num[dir] > 0 ? "" : "(UNSET)",
 			 ct_ftp_info->seq_aft_nl[dir][0],
 			 ct_ftp_info->seq_aft_nl_num[dir] > 1 ? "" : "(UNSET)",
@@ -426,7 +426,7 @@ static int help(struct sk_buff *skb,
 		   connection tracking, not packet filtering.
 		   However, it is necessary for accurate tracking in
 		   this case. */
-		pr_debug("conntrack_ftp: partial %s %u+%u\n",
+		pr_debug("partial %s %u+%u\n",
 			 search[dir][i].pattern,  ntohl(th->seq), datalen);
 		ret = NF_DROP;
 		goto out;
@@ -435,7 +435,7 @@ static int help(struct sk_buff *skb,
 		goto out_update_nl;
 	}
 
-	pr_debug("conntrack_ftp: match `%.*s' (%u bytes at %u)\n",
+	pr_debug("match `%.*s' (%u bytes at %u)\n",
 		 matchlen, fb_ptr + matchoff,
 		 matchlen, ntohl(th->seq) + matchoff);
 
@@ -459,11 +459,11 @@ static int help(struct sk_buff *skb,
 		   different IP address.  Simply don't record it for
 		   NAT. */
 		if (cmd.l3num == PF_INET) {
-			pr_debug("conntrack_ftp: NOT RECORDING: %pI4 != %pI4\n",
+			pr_debug("NOT RECORDING: %pI4 != %pI4\n",
 				 &cmd.u3.ip,
 				 &ct->tuplehash[dir].tuple.src.u3.ip);
 		} else {
-			pr_debug("conntrack_ftp: NOT RECORDING: %pI6 != %pI6\n",
+			pr_debug("NOT RECORDING: %pI6 != %pI6\n",
 				 cmd.u3.ip6,
 				 ct->tuplehash[dir].tuple.src.u3.ip6);
 		}
@@ -527,8 +527,7 @@ static void nf_conntrack_ftp_fini(void)
 			if (ftp[i][j].me == NULL)
 				continue;
 
-			pr_debug("nf_ct_ftp: unregistering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("unregistering helper for pf: %d port: %d\n",
 				 ftp[i][j].tuple.src.l3num, ports[i]);
 			nf_conntrack_helper_unregister(&ftp[i][j]);
 		}
@@ -567,14 +566,12 @@ static int __init nf_conntrack_ftp_init(void)
 				sprintf(tmpname, "ftp-%d", ports[i]);
 			ftp[i][j].name = tmpname;
 
-			pr_debug("nf_ct_ftp: registering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("registering helper for pf: %d port: %d\n",
 				 ftp[i][j].tuple.src.l3num, ports[i]);
 			ret = nf_conntrack_helper_register(&ftp[i][j]);
 			if (ret) {
-				printk("nf_ct_ftp: failed to register helper "
-				       " for pf: %d port: %d\n",
-					ftp[i][j].tuple.src.l3num, ports[i]);
+				pr_err("failed to register helper for pf: %d port: %d\n",
+				       ftp[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_ftp_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 6636949..e7895d0 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -145,7 +145,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 		if (tcpdatalen < 4 || tpkt[0] != 0x03 || tpkt[1] != 0) {
 			/* Netmeeting sends TPKT header and data separately */
 			if (info->tpkt_len[dir] > 0) {
-				pr_debug("nf_ct_h323: previous packet "
+				pr_debug("h323: previous packet "
 					 "indicated separate TPKT data of %hu "
 					 "bytes\n", info->tpkt_len[dir]);
 				if (info->tpkt_len[dir] <= tcpdatalen) {
@@ -158,7 +158,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 				}
 
 				/* Fragmented TPKT */
-				pr_debug("nf_ct_h323: fragmented TPKT\n");
+				pr_debug("h323: fragmented TPKT\n");
 				goto clear_out;
 			}
 
@@ -185,7 +185,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 	if (tpktlen > tcpdatalen) {
 		if (tcpdatalen == 4) {	/* Separate TPKT header */
 			/* Netmeeting sends TPKT header and data separately */
-			pr_debug("nf_ct_h323: separate TPKT header indicates "
+			pr_debug("h323: separate TPKT header indicates "
 				 "there will be TPKT data of %hu bytes\n",
 				 tpktlen - 4);
 			info->tpkt_len[dir] = tpktlen - 4;
@@ -193,7 +193,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 		}
 
 		if (net_ratelimit())
-			printk("nf_ct_h323: incomplete TPKT (fragmented?)\n");
+			pr_info("h323: incomplete TPKT (fragmented?)\n");
 		goto clear_out;
 	}
 
@@ -302,9 +302,9 @@ static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(rtp_exp) == 0) {
 			if (nf_ct_expect_related(rtcp_exp) == 0) {
-				pr_debug("nf_ct_h323: expect RTP ");
+				pr_debug("h323: expect RTP ");
 				nf_ct_dump_tuple(&rtp_exp->tuple);
-				pr_debug("nf_ct_h323: expect RTCP ");
+				pr_debug("h323: expect RTCP ");
 				nf_ct_dump_tuple(&rtcp_exp->tuple);
 			} else {
 				nf_ct_unexpect_related(rtp_exp);
@@ -359,7 +359,7 @@ static int expect_t120(struct sk_buff *skb,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_h323: expect T.120 ");
+			pr_debug("h323: expect T.120 ");
 			nf_ct_dump_tuple(&exp->tuple);
 		} else
 			ret = -1;
@@ -407,7 +407,7 @@ static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 {
 	int ret;
 
-	pr_debug("nf_ct_h323: OpenLogicalChannel\n");
+	pr_debug("h323: OpenLogicalChannel\n");
 
 	if (olc->forwardLogicalChannelParameters.multiplexParameters.choice ==
 	    eOpenLogicalChannel_forwardLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters)
@@ -467,7 +467,7 @@ static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 	H2250LogicalChannelAckParameters *ack;
 	int ret;
 
-	pr_debug("nf_ct_h323: OpenLogicalChannelAck\n");
+	pr_debug("h323: OpenLogicalChannelAck\n");
 
 	if ((olca->options &
 	     eOpenLogicalChannelAck_reverseLogicalChannelParameters) &&
@@ -538,7 +538,7 @@ static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 			return process_olc(skb, ct, ctinfo, data, dataoff,
 					   &mscm->request.openLogicalChannel);
 		}
-		pr_debug("nf_ct_h323: H.245 Request %d\n",
+		pr_debug("h323: H.245 Request %d\n",
 			 mscm->request.choice);
 		break;
 	case eMultimediaSystemControlMessage_response:
@@ -548,11 +548,11 @@ static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 					    &mscm->response.
 					    openLogicalChannelAck);
 		}
-		pr_debug("nf_ct_h323: H.245 Response %d\n",
+		pr_debug("h323: H.245 Response %d\n",
 			 mscm->response.choice);
 		break;
 	default:
-		pr_debug("nf_ct_h323: H.245 signal %d\n", mscm->choice);
+		pr_debug("h323: H.245 signal %d\n", mscm->choice);
 		break;
 	}
 
@@ -574,21 +574,21 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
 	    ctinfo != IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
 		return NF_ACCEPT;
 	}
-	pr_debug("nf_ct_h245: skblen = %u\n", skb->len);
+	pr_debug("h245: skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
 	while (get_tpkt_data(skb, protoff, ct, ctinfo,
 			     &data, &datalen, &dataoff)) {
-		pr_debug("nf_ct_h245: TPKT len=%d ", datalen);
+		pr_debug("h245: TPKT len=%d ", datalen);
 		nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
 		/* Decode H.245 signal */
 		ret = DecodeMultimediaSystemControlMessage(data, datalen,
 							   &mscm);
 		if (ret < 0) {
-			pr_debug("nf_ct_h245: decoding error: %s\n",
+			pr_debug("h245: decoding error: %s\n",
 				 ret == H323_ERROR_BOUND ?
 				 "out of bound" : "out of range");
 			/* We don't drop when decoding error */
@@ -606,7 +606,7 @@ static int h245_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_h245: packet dropped\n");
+		pr_info("h245: packet dropped\n");
 	return NF_DROP;
 }
 
@@ -695,7 +695,7 @@ static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_q931: expect H.245 ");
+			pr_debug("q931: expect H.245 ");
 			nf_ct_dump_tuple(&exp->tuple);
 		} else
 			ret = -1;
@@ -789,7 +789,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 	if (callforward_filter &&
 	    callforward_do_filter(&addr, &ct->tuplehash[!dir].tuple.src.u3,
 				  nf_ct_l3num(ct))) {
-		pr_debug("nf_ct_q931: Call Forwarding not tracked\n");
+		pr_debug("q931: Call Forwarding not tracked\n");
 		return 0;
 	}
 
@@ -811,7 +811,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 					 taddr, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_q931: expect Call Forwarding ");
+			pr_debug("q931: expect Call Forwarding ");
 			nf_ct_dump_tuple(&exp->tuple);
 		} else
 			ret = -1;
@@ -835,7 +835,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	typeof(set_h225_addr_hook) set_h225_addr;
 
-	pr_debug("nf_ct_q931: Setup\n");
+	pr_debug("q931: Setup\n");
 
 	if (setup->options & eSetup_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -850,7 +850,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->destCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.src.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set destCallSignalAddress %pI6:%hu->%pI6:%hu\n",
+		pr_debug("q931: set destCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.src.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.src.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
@@ -866,7 +866,7 @@ static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 	    get_h225_addr(ct, *data, &setup->sourceCallSignalAddress,
 			  &addr, &port) &&
 	    memcmp(&addr, &ct->tuplehash[!dir].tuple.dst.u3, sizeof(addr))) {
-		pr_debug("nf_ct_q931: set sourceCallSignalAddress %pI6:%hu->%pI6:%hu\n",
+		pr_debug("q931: set sourceCallSignalAddress %pI6:%hu->%pI6:%hu\n",
 			 &addr, ntohs(port), &ct->tuplehash[!dir].tuple.dst.u3,
 			 ntohs(ct->tuplehash[!dir].tuple.dst.u.tcp.port));
 		ret = set_h225_addr(skb, data, dataoff,
@@ -899,7 +899,7 @@ static int process_callproceeding(struct sk_buff *skb,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: CallProceeding\n");
+	pr_debug("q931: CallProceeding\n");
 
 	if (callproc->options & eCallProceeding_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -929,7 +929,7 @@ static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Connect\n");
+	pr_debug("q931: Connect\n");
 
 	if (connect->options & eConnect_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -959,7 +959,7 @@ static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Alerting\n");
+	pr_debug("q931: Alerting\n");
 
 	if (alert->options & eAlerting_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -989,7 +989,7 @@ static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Facility\n");
+	pr_debug("q931: Facility\n");
 
 	if (facility->reason.choice == eFacilityReason_callForwarded) {
 		if (facility->options & eFacility_UUIE_alternativeAddress)
@@ -1028,7 +1028,7 @@ static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	int i;
 
-	pr_debug("nf_ct_q931: Progress\n");
+	pr_debug("q931: Progress\n");
 
 	if (progress->options & eProgress_UUIE_h245Address) {
 		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
@@ -1085,7 +1085,7 @@ static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 				       &pdu->h323_message_body.progress);
 		break;
 	default:
-		pr_debug("nf_ct_q931: Q.931 signal %d\n",
+		pr_debug("q931: Q.931 signal %d\n",
 			 pdu->h323_message_body.choice);
 		break;
 	}
@@ -1120,20 +1120,20 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
 	    ctinfo != IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
 		return NF_ACCEPT;
 	}
-	pr_debug("nf_ct_q931: skblen = %u\n", skb->len);
+	pr_debug("q931: skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
 	while (get_tpkt_data(skb, protoff, ct, ctinfo,
 			     &data, &datalen, &dataoff)) {
-		pr_debug("nf_ct_q931: TPKT len=%d ", datalen);
+		pr_debug("q931: TPKT len=%d ", datalen);
 		nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
 		/* Decode Q.931 signal */
 		ret = DecodeQ931(data, datalen, &q931);
 		if (ret < 0) {
-			pr_debug("nf_ct_q931: decoding error: %s\n",
+			pr_debug("q931: decoding error: %s\n",
 				 ret == H323_ERROR_BOUND ?
 				 "out of bound" : "out of range");
 			/* We don't drop when decoding error */
@@ -1151,7 +1151,7 @@ static int q931_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_q931: packet dropped\n");
+		pr_info("q931: packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1277,7 +1277,7 @@ static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 		ret = nat_q931(skb, ct, ctinfo, data, taddr, i, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
-			pr_debug("nf_ct_ras: expect Q.931 ");
+			pr_debug("ras: expect Q.931 ");
 			nf_ct_dump_tuple(&exp->tuple);
 
 			/* Save port for looking up expect in processing RCF */
@@ -1298,7 +1298,7 @@ static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
 
-	pr_debug("nf_ct_ras: GRQ\n");
+	pr_debug("ras: GRQ\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK)	/* NATed */
@@ -1318,7 +1318,7 @@ static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	struct nf_conntrack_expect *exp;
 
-	pr_debug("nf_ct_ras: GCF\n");
+	pr_debug("ras: GCF\n");
 
 	if (!get_h225_addr(ct, *data, &gcf->rasAddress, &addr, &port))
 		return 0;
@@ -1341,7 +1341,7 @@ static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 	exp->helper = nf_conntrack_helper_ras;
 
 	if (nf_ct_expect_related(exp) == 0) {
-		pr_debug("nf_ct_ras: expect RAS ");
+		pr_debug("ras: expect RAS ");
 		nf_ct_dump_tuple(&exp->tuple);
 	} else
 		ret = -1;
@@ -1360,7 +1360,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	typeof(set_ras_addr_hook) set_ras_addr;
 
-	pr_debug("nf_ct_ras: RRQ\n");
+	pr_debug("ras: RRQ\n");
 
 	ret = expect_q931(skb, ct, ctinfo, data,
 			  rrq->callSignalAddress.item,
@@ -1378,7 +1378,7 @@ static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (rrq->options & eRegistrationRequest_timeToLive) {
-		pr_debug("nf_ct_ras: RRQ TTL = %u seconds\n", rrq->timeToLive);
+		pr_debug("ras: RRQ TTL = %u seconds\n", rrq->timeToLive);
 		info->timeout = rrq->timeToLive;
 	} else
 		info->timeout = default_rrq_ttl;
@@ -1397,7 +1397,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 	struct nf_conntrack_expect *exp;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: RCF\n");
+	pr_debug("ras: RCF\n");
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
@@ -1409,12 +1409,12 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 	}
 
 	if (rcf->options & eRegistrationConfirm_timeToLive) {
-		pr_debug("nf_ct_ras: RCF TTL = %u seconds\n", rcf->timeToLive);
+		pr_debug("ras: RCF TTL = %u seconds\n", rcf->timeToLive);
 		info->timeout = rcf->timeToLive;
 	}
 
 	if (info->timeout > 0) {
-		pr_debug("nf_ct_ras: set RAS connection timeout to "
+		pr_debug("ras: set RAS connection timeout to "
 			 "%u seconds\n", info->timeout);
 		nf_ct_refresh(ct, skb, info->timeout * HZ);
 
@@ -1423,7 +1423,7 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		exp = find_expect(ct, &ct->tuplehash[dir].tuple.dst.u3,
 				  info->sig_port[!dir]);
 		if (exp) {
-			pr_debug("nf_ct_ras: set Q.931 expect "
+			pr_debug("ras: set Q.931 expect "
 				 "timeout to %u seconds for",
 				 info->timeout);
 			nf_ct_dump_tuple(&exp->tuple);
@@ -1445,7 +1445,7 @@ static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 	int ret;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: URQ\n");
+	pr_debug("ras: URQ\n");
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
@@ -1478,7 +1478,7 @@ static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	typeof(set_h225_addr_hook) set_h225_addr;
 
-	pr_debug("nf_ct_ras: ARQ\n");
+	pr_debug("ras: ARQ\n");
 
 	set_h225_addr = rcu_dereference(set_h225_addr_hook);
 	if ((arq->options & eAdmissionRequest_destCallSignalAddress) &&
@@ -1521,7 +1521,7 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 	struct nf_conntrack_expect *exp;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: ACF\n");
+	pr_debug("ras: ACF\n");
 
 	if (!get_h225_addr(ct, *data, &acf->destCallSignalAddress,
 			   &addr, &port))
@@ -1546,7 +1546,7 @@ static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 	exp->helper = nf_conntrack_helper_q931;
 
 	if (nf_ct_expect_related(exp) == 0) {
-		pr_debug("nf_ct_ras: expect Q.931 ");
+		pr_debug("ras: expect Q.931 ");
 		nf_ct_dump_tuple(&exp->tuple);
 	} else
 		ret = -1;
@@ -1563,7 +1563,7 @@ static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 {
 	typeof(set_ras_addr_hook) set_ras_addr;
 
-	pr_debug("nf_ct_ras: LRQ\n");
+	pr_debug("ras: LRQ\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK)
@@ -1583,7 +1583,7 @@ static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 	union nf_inet_addr addr;
 	struct nf_conntrack_expect *exp;
 
-	pr_debug("nf_ct_ras: LCF\n");
+	pr_debug("ras: LCF\n");
 
 	if (!get_h225_addr(ct, *data, &lcf->callSignalAddress,
 			   &addr, &port))
@@ -1599,7 +1599,7 @@ static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 	exp->helper = nf_conntrack_helper_q931;
 
 	if (nf_ct_expect_related(exp) == 0) {
-		pr_debug("nf_ct_ras: expect Q.931 ");
+		pr_debug("ras: expect Q.931 ");
 		nf_ct_dump_tuple(&exp->tuple);
 	} else
 		ret = -1;
@@ -1620,7 +1620,7 @@ static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 	typeof(set_ras_addr_hook) set_ras_addr;
 	typeof(set_sig_addr_hook) set_sig_addr;
 
-	pr_debug("nf_ct_ras: IRR\n");
+	pr_debug("ras: IRR\n");
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK) {
@@ -1679,7 +1679,7 @@ static int process_ras(struct sk_buff *skb, struct nf_conn *ct,
 		return process_irr(skb, ct, ctinfo, data,
 				   &ras->infoRequestResponse);
 	default:
-		pr_debug("nf_ct_ras: RAS message %d\n", ras->choice);
+		pr_debug("ras: RAS message %d\n", ras->choice);
 		break;
 	}
 
@@ -1695,7 +1695,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	int datalen = 0;
 	int ret;
 
-	pr_debug("nf_ct_ras: skblen = %u\n", skb->len);
+	pr_debug("ras: skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
@@ -1703,13 +1703,13 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
 	data = get_udp_data(skb, protoff, &datalen);
 	if (data == NULL)
 		goto accept;
-	pr_debug("nf_ct_ras: RAS message len=%d ", datalen);
+	pr_debug("ras: RAS message len=%d ", datalen);
 	nf_ct_dump_tuple(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
 
 	/* Decode RAS message */
 	ret = DecodeRasMessage(data, datalen, &ras);
 	if (ret < 0) {
-		pr_debug("nf_ct_ras: decoding error: %s\n",
+		pr_debug("ras: decoding error: %s\n",
 			 ret == H323_ERROR_BOUND ?
 			 "out of bound" : "out of range");
 		goto accept;
@@ -1726,7 +1726,7 @@ static int ras_help(struct sk_buff *skb, unsigned int protoff,
       drop:
 	spin_unlock_bh(&nf_h323_lock);
 	if (net_ratelimit())
-		printk("nf_ct_ras: packet dropped\n");
+		pr_info("ras: packet dropped\n");
 	return NF_DROP;
 }
 
@@ -1766,7 +1766,7 @@ static void __exit nf_conntrack_h323_fini(void)
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[0]);
 	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
 	kfree(h323_buffer);
-	pr_debug("nf_ct_h323: fini\n");
+	pr_debug("h323: fini\n");
 }
 
 /****************************************************************************/
@@ -1792,7 +1792,7 @@ static int __init nf_conntrack_h323_init(void)
 	ret = nf_conntrack_helper_register(&nf_conntrack_helper_ras[1]);
 	if (ret < 0)
 		goto err5;
-	pr_debug("nf_ct_h323: init success\n");
+	pr_debug("h323: init success\n");
 	return 0;
 
 err5:
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 8bd98c8..f9ac790 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -186,8 +186,7 @@ static int help(struct sk_buff *skb, unsigned int protoff,
 			if (tuple->src.u3.ip != dcc_ip &&
 			    tuple->dst.u3.ip != dcc_ip) {
 				if (net_ratelimit())
-					printk(KERN_WARNING
-						"Forged DCC command from %pI4: %pI4:%u\n",
+					pr_warning("Forged DCC command from %pI4: %pI4:%u\n",
 						&tuple->src.u3.ip,
 						&dcc_ip, dcc_port);
 				continue;
@@ -234,7 +233,7 @@ static int __init nf_conntrack_irc_init(void)
 	char *tmpname;
 
 	if (max_dcc_channels < 1) {
-		printk("nf_ct_irc: max_dcc_channels must not be zero\n");
+		pr_info("max_dcc_channels must not be zero\n");
 		return -EINVAL;
 	}
 
@@ -266,9 +265,8 @@ static int __init nf_conntrack_irc_init(void)
 
 		ret = nf_conntrack_helper_register(&irc[i]);
 		if (ret) {
-			printk("nf_ct_irc: failed to register helper "
-			       "for pf: %u port: %u\n",
-			       irc[i].tuple.src.l3num, ports[i]);
+			pr_info("failed to register helper for pf: %u port: %u\n",
+				irc[i].tuple.src.l3num, ports[i]);
 			nf_conntrack_irc_fini();
 			return ret;
 		}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 59d8064..334f9eb 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1942,29 +1942,29 @@ static int __init ctnetlink_init(void)
 {
 	int ret;
 
-	printk("ctnetlink v%s: registering with nfnetlink.\n", version);
+	pr_info("version %s: registering with nfnetlink.\n", version);
 	ret = nfnetlink_subsys_register(&ctnl_subsys);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register with nfnetlink.\n");
+		pr_err("%s(): cannot register with nfnetlink.\n", __func__);
 		goto err_out;
 	}
 
 	ret = nfnetlink_subsys_register(&ctnl_exp_subsys);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register exp with nfnetlink.\n");
+		pr_err("%s(): cannot register exp with nfnetlink.\n", __func__);
 		goto err_unreg_subsys;
 	}
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	ret = nf_conntrack_register_notifier(&ctnl_notifier);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot register notifier.\n");
+		pr_err("%s(): cannot register notifier.\n", __func__);
 		goto err_unreg_exp_subsys;
 	}
 
 	ret = nf_ct_expect_register_notifier(&ctnl_notifier_exp);
 	if (ret < 0) {
-		printk("ctnetlink_init: cannot expect register notifier.\n");
+		pr_err("%s(): cannot expect register notifier.\n", __func__);
 		goto err_unreg_notifier;
 	}
 #endif
@@ -1985,7 +1985,7 @@ err_out:
 
 static void __exit ctnetlink_exit(void)
 {
-	printk("ctnetlink: unregistering from nfnetlink.\n");
+	pr_info("%s(): unregistering from nfnetlink.\n", __func__);
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	nf_ct_expect_unregister_notifier(&ctnl_notifier_exp);
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index a54a0af..7314c89 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -253,7 +253,7 @@ static int gre_packet(struct nf_conn *ct,
 static bool gre_new(struct nf_conn *ct, const struct sk_buff *skb,
 		    unsigned int dataoff)
 {
-	pr_debug(": ");
+	pr_debug("new: ");
 	nf_ct_dump_tuple(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
 
 	/* initialize to sane value.  Ideally a conntrack helper
@@ -269,7 +269,7 @@ static bool gre_new(struct nf_conn *ct, const struct sk_buff *skb,
 static void gre_destroy(struct nf_conn *ct)
 {
 	struct nf_conn *master = ct->master;
-	pr_debug(" entering\n");
+	pr_debug("entering\n");
 
 	if (!master)
 		pr_debug("no master !?!\n");
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index c10e6f3..2b6cc42 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -344,8 +344,7 @@ static int sctp_packet(struct nf_conn *ct,
 
 		/* Invalid */
 		if (new_state == SCTP_CONNTRACK_MAX) {
-			pr_debug("nf_conntrack_sctp: Invalid dir=%i ctype=%u "
-				 "conntrack=%u\n",
+			pr_debug("Invalid dir=%i ctype=%u conntrack=%u\n",
 				 dir, sch->type, old_state);
 			goto out_unlock;
 		}
@@ -422,7 +421,7 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		/* Invalid: delete conntrack */
 		if (new_state == SCTP_CONNTRACK_NONE ||
 		    new_state == SCTP_CONNTRACK_MAX) {
-			pr_debug("nf_conntrack_sctp: invalid new deleting.\n");
+			pr_debug("invalid new deleting.\n");
 			return false;
 		}
 
@@ -721,12 +720,12 @@ static int __init nf_conntrack_proto_sctp_init(void)
 
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp4);
 	if (ret) {
-		printk("nf_conntrack_l4proto_sctp4: protocol register failed\n");
+		pr_info("nf_conntrack_l4proto_sctp4: protocol register failed\n");
 		goto out;
 	}
 	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp6);
 	if (ret) {
-		printk("nf_conntrack_l4proto_sctp6: protocol register failed\n");
+		pr_info("nf_conntrack_l4proto_sctp6: protocol register failed\n");
 		goto cleanup_sctp4;
 	}
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 97a82ba..9eb5e85 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -932,7 +932,7 @@ static int tcp_packet(struct nf_conn *ct,
 		return NF_ACCEPT;
 	case TCP_CONNTRACK_MAX:
 		/* Invalid packet */
-		pr_debug("nf_ct_tcp: Invalid dir=%i index=%u ostate=%u\n",
+		pr_debug("tcp: Invalid dir=%i index=%u ostate=%u\n",
 			 dir, get_conntrack_index(th), old_state);
 		spin_unlock_bh(&ct->lock);
 		if (LOG_INVALID(net, IPPROTO_TCP))
@@ -1053,7 +1053,7 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 	/* Invalid: delete conntrack */
 	if (new_state >= TCP_CONNTRACK_MAX) {
-		pr_debug("nf_ct_tcp: invalid new deleting.\n");
+		pr_debug("tcp: invalid new deleting.\n");
 		return false;
 	}
 
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index dcfecbb..28d90d5 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -120,14 +120,14 @@ static int help(struct sk_buff *skb,
 	ct_sane_info->state = SANE_STATE_NORMAL;
 
 	if (datalen < sizeof(struct sane_reply_net_start)) {
-		pr_debug("nf_ct_sane: NET_START reply too short\n");
+		pr_debug("NET_START reply too short\n");
 		goto out;
 	}
 
 	reply = sb_ptr;
 	if (reply->status != htonl(SANE_STATUS_SUCCESS)) {
 		/* saned refused the command */
-		pr_debug("nf_ct_sane: unsuccessful SANE_STATUS = %u\n",
+		pr_debug("unsuccessful SANE_STATUS = %u\n",
 			 ntohl(reply->status));
 		goto out;
 	}
@@ -147,7 +147,7 @@ static int help(struct sk_buff *skb,
 			  &tuple->src.u3, &tuple->dst.u3,
 			  IPPROTO_TCP, NULL, &reply->port);
 
-	pr_debug("nf_ct_sane: expect: ");
+	pr_debug("expect: ");
 	nf_ct_dump_tuple(&exp->tuple);
 
 	/* Can't expect this?  Best to drop packet now. */
@@ -176,8 +176,7 @@ static void nf_conntrack_sane_fini(void)
 
 	for (i = 0; i < ports_c; i++) {
 		for (j = 0; j < 2; j++) {
-			pr_debug("nf_ct_sane: unregistering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("unregistering helper for pf: %d port: %d\n",
 				 sane[i][j].tuple.src.l3num, ports[i]);
 			nf_conntrack_helper_unregister(&sane[i][j]);
 		}
@@ -216,14 +215,12 @@ static int __init nf_conntrack_sane_init(void)
 				sprintf(tmpname, "sane-%d", ports[i]);
 			sane[i][j].name = tmpname;
 
-			pr_debug("nf_ct_sane: registering helper for pf: %d "
-				 "port: %d\n",
+			pr_debug("registering helper for pf: %d port: %d\n",
 				 sane[i][j].tuple.src.l3num, ports[i]);
 			ret = nf_conntrack_helper_register(&sane[i][j]);
 			if (ret) {
-				printk(KERN_ERR "nf_ct_sane: failed to "
-				       "register helper for pf: %d port: %d\n",
-					sane[i][j].tuple.src.l3num, ports[i]);
+				pr_err("failed to register helper for pf: %d port: %d\n",
+				       sane[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_sane_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4b57216..0cd79c7 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1363,9 +1363,8 @@ static int __init nf_conntrack_sip_init(void)
 
 			ret = nf_conntrack_helper_register(&sip[i][j]);
 			if (ret) {
-				printk("nf_ct_sip: failed to register helper "
-				       "for pf: %u port: %u\n",
-				       sip[i][j].tuple.src.l3num, ports[i]);
+				pr_info("failed to register helper for pf: %u port: %u\n",
+					sip[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_sip_fini();
 				return ret;
 			}
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 1935153..2dad630 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -445,7 +445,7 @@ out_kmemdup:
 	if (net_eq(net, &init_net))
 		unregister_sysctl_table(nf_ct_netfilter_header);
 out:
-	printk("nf_conntrack: can't register to sysctl.\n");
+	pr_info("can't register to sysctl.\n");
 	return -ENOMEM;
 }
 
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 46e646b..0dcd4de 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -138,8 +138,7 @@ static int __init nf_conntrack_tftp_init(void)
 
 			ret = nf_conntrack_helper_register(&tftp[i][j]);
 			if (ret) {
-				printk("nf_ct_tftp: failed to register helper "
-				       "for pf: %u port: %u\n",
+				pr_info("failed to register helper for pf: %u port: %u\n",
 					tftp[i][j].tuple.src.l3num, ports[i]);
 				nf_conntrack_tftp_fini();
 				return ret;
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index eedc0c1..51d2920 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -186,19 +186,19 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 
 static void __exit nfnetlink_exit(void)
 {
-	printk("Removing netfilter NETLINK layer.\n");
+	pr_info("Removing netfilter NETLINK layer.\n");
 	netlink_kernel_release(nfnl);
 	return;
 }
 
 static int __init nfnetlink_init(void)
 {
-	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
+	pr_info("Netfilter messages via NETLINK v%s.\n", nfversion);
 
 	nfnl = netlink_kernel_create(&init_net, NETLINK_NETFILTER, NFNLGRP_MAX,
 				     nfnetlink_rcv, NULL, THIS_MODULE);
 	if (!nfnl) {
-		printk(KERN_ERR "cannot initialize nfnetlink!\n");
+		pr_err("cannot initialize nfnetlink!\n");
 		return -ENOMEM;
 	}
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index f900dc3..32dd241 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -43,8 +43,8 @@
 #define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */
 #define NFULNL_COPY_RANGE_MAX	0xFFFF	/* max packet size is limited by 16-bit struct nfattr nfa_len field */
 
-#define PRINTR(x, args...)	do { if (net_ratelimit()) \
-				     printk(x, ## args); } while (0);
+#define PRINTR(level, fmt, args...)					\
+	do { if (net_ratelimit()) printk(level pr_fmt(fmt), ## args); } while (0)
 
 struct nfulnl_instance {
 	struct hlist_node hlist;	/* global list of instances */
@@ -296,8 +296,8 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 	n = max(inst_size, pkt_size);
 	skb = alloc_skb(n, GFP_ATOMIC);
 	if (!skb) {
-		PRINTR("nfnetlink_log: can't alloc whole buffer (%u bytes)\n",
-			inst_size);
+		PRINTR(KERN_ERR, "can't alloc whole buffer (%u bytes)\n",
+		       inst_size);
 
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
@@ -305,8 +305,8 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 
 			skb = alloc_skb(pkt_size, GFP_ATOMIC);
 			if (!skb)
-				PRINTR("nfnetlink_log: can't even alloc %u "
-				       "bytes\n", pkt_size);
+				PRINTR(KERN_ERR, "can't even alloc %u bytes\n",
+				       pkt_size);
 		}
 	}
 
@@ -500,7 +500,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 		int size = nla_attr_size(data_len);
 
 		if (skb_tailroom(inst->skb) < nla_total_size(data_len)) {
-			printk(KERN_WARNING "nfnetlink_log: no tailroom!\n");
+			pr_warning("no tailroom!\n");
 			goto nlmsg_failure;
 		}
 
@@ -517,7 +517,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 
 nlmsg_failure:
 nla_put_failure:
-	PRINTR(KERN_ERR "nfnetlink_log: error creating log nlmsg\n");
+	PRINTR(KERN_ERR, "error creating log nlmsg\n");
 	return -1;
 }
 
@@ -956,13 +956,13 @@ static int __init nfnetlink_log_init(void)
 	netlink_register_notifier(&nfulnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfulnl_subsys);
 	if (status < 0) {
-		printk(KERN_ERR "log: failed to create netlink socket\n");
+		pr_err("failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
 	}
 
 	status = nf_log_register(NFPROTO_UNSPEC, &nfulnl_logger);
 	if (status < 0) {
-		printk(KERN_ERR "log: failed to register logger\n");
+		pr_err("failed to register logger\n");
 		goto cleanup_subsys;
 	}
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7a9dec9..d965292 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -362,7 +362,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		int sz = nla_attr_size(data_len);
 
 		if (skb_tailroom(skb) < nla_total_size(data_len)) {
-			printk(KERN_WARNING "nf_queue: no tailroom!\n");
+			pr_warning("no tailroom!\n");
 			goto nlmsg_failure;
 		}
 
@@ -382,7 +382,7 @@ nla_put_failure:
 	if (skb)
 		kfree_skb(skb);
 	if (net_ratelimit())
-		printk(KERN_ERR "nf_queue: error creating packet message\n");
+		pr_err("error creating packet message\n");
 	return NULL;
 }
 
@@ -413,9 +413,9 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	if (queue->queue_total >= queue->queue_maxlen) {
 		queue->queue_dropped++;
 		if (net_ratelimit())
-			  printk(KERN_WARNING "nf_queue: full at %d entries, "
-				 "dropping packets(s). Dropped: %d\n",
-				 queue->queue_total, queue->queue_dropped);
+			  pr_warning("full at %d entries, dropping packets(s). "
+				     "Dropped: %d\n",
+				     queue->queue_total, queue->queue_dropped);
 		goto err_out_free_nskb;
 	}
 
@@ -456,8 +456,7 @@ nfqnl_mangle(void *data, int data_len, struct nf_queue_entry *e)
 			nskb = skb_copy_expand(e->skb, skb_headroom(e->skb),
 					       diff, GFP_ATOMIC);
 			if (!nskb) {
-				printk(KERN_WARNING "nf_queue: OOM "
-				      "in mangle, dropping packet\n");
+				pr_warning("OOM in mangle, dropping packet\n");
 				return -ENOMEM;
 			}
 			kfree_skb(e->skb);
@@ -904,7 +903,7 @@ static int __init nfnetlink_queue_init(void)
 	netlink_register_notifier(&nfqnl_rtnl_notifier);
 	status = nfnetlink_subsys_register(&nfqnl_subsys);
 	if (status < 0) {
-		printk(KERN_ERR "nf_queue: failed to create netlink socket\n");
+		pr_err("failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
 	}
 
diff --git a/net/netfilter/xt_CONNMARK.c b/net/netfilter/xt_CONNMARK.c
index 5934570..daf27c6 100644
--- a/net/netfilter/xt_CONNMARK.c
+++ b/net/netfilter/xt_CONNMARK.c
@@ -76,7 +76,7 @@ connmark_tg(struct sk_buff *skb, const struct xt_target_param *par)
 static bool connmark_tg_check(const struct xt_tgchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
+		pr_warning("cannot load conntrack support for "
 		       "proto=%u\n", par->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index b54c375..c21148c 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -22,8 +22,6 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 
-#define PFX "CONNSECMARK: "
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Morris <jmorris@redhat.com>");
 MODULE_DESCRIPTION("Xtables: target for copying between connection and security mark");
@@ -91,7 +89,7 @@ static bool connsecmark_tg_check(const struct xt_tgchk_param *par)
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
-		printk(KERN_INFO PFX "target only valid in the \'mangle\' "
+		pr_info("target only valid in the \'mangle\' "
 		       "or \'security\' tables, not \'%s\'.\n", par->table);
 		return false;
 	}
@@ -102,12 +100,12 @@ static bool connsecmark_tg_check(const struct xt_tgchk_param *par)
 		break;
 
 	default:
-		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		pr_info("invalid mode: %hu\n", info->mode);
 		return false;
 	}
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
+		pr_warning("can't load conntrack support for "
 				    "proto=%u\n", par->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 74ce892..adffc77 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -65,7 +65,7 @@ static bool dscp_tg_check(const struct xt_tgchk_param *par)
 	const struct xt_DSCP_info *info = par->targinfo;
 
 	if (info->dscp > XT_DSCP_MAX) {
-		printk(KERN_WARNING "DSCP: dscp %x out of range\n", info->dscp);
+		pr_warning("dscp %x out of range\n", info->dscp);
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 10e789e..e4153f7 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -106,7 +106,7 @@ static bool ttl_tg_check(const struct xt_tgchk_param *par)
 	const struct ipt_TTL_info *info = par->targinfo;
 
 	if (info->mode > IPT_TTL_MAXMODE) {
-		printk(KERN_WARNING "ipt_TTL: invalid or unknown Mode %u\n",
+		pr_warning("ipt_TTL: invalid or unknown Mode %u\n",
 			info->mode);
 		return false;
 	}
@@ -120,12 +120,12 @@ static bool hl_tg6_check(const struct xt_tgchk_param *par)
 	const struct ip6t_HL_info *info = par->targinfo;
 
 	if (info->mode > IP6T_HL_MAXMODE) {
-		printk(KERN_WARNING "ip6t_HL: invalid or unknown Mode %u\n",
+		pr_warning("ip6t_HL: invalid or unknown Mode %u\n",
 			info->mode);
 		return false;
 	}
 	if (info->mode != IP6T_HL_SET && info->hop_limit == 0) {
-		printk(KERN_WARNING "ip6t_HL: increment/decrement doesn't "
+		pr_warning("ip6t_HL: increment/decrement doesn't "
 			"make sense with value 0\n");
 		return false;
 	}
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index 8ff7843..8de6bf9 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -87,13 +87,13 @@ static bool led_tg_check(const struct xt_tgchk_param *par)
 	int err;
 
 	if (ledinfo->id[0] == '\0') {
-		printk(KERN_ERR KBUILD_MODNAME ": No 'id' parameter given.\n");
+		pr_err("No 'id' parameter given.\n");
 		return false;
 	}
 
 	ledinternal = kzalloc(sizeof(struct xt_led_info_internal), GFP_KERNEL);
 	if (!ledinternal) {
-		printk(KERN_CRIT KBUILD_MODNAME ": out of memory\n");
+		pr_crit("out of memory\n");
 		return false;
 	}
 
@@ -101,11 +101,9 @@ static bool led_tg_check(const struct xt_tgchk_param *par)
 
 	err = led_trigger_register(&ledinternal->netfilter_led_trigger);
 	if (err) {
-		printk(KERN_CRIT KBUILD_MODNAME
-			": led_trigger_register() failed\n");
+		pr_crit("led_trigger_register() failed\n");
 		if (err == -EEXIST)
-			printk(KERN_ERR KBUILD_MODNAME
-				": Trigger name is already in use.\n");
+			pr_err("Trigger name is already in use.\n");
 		goto exit_alloc;
 	}
 
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index f28f6a5..0006566 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -91,12 +91,12 @@ static bool nfqueue_tg_v1_check(const struct xt_tgchk_param *par)
 	u32 maxid;
 
 	if (info->queues_total == 0) {
-		pr_err("NFQUEUE: number of total queues is 0\n");
+		pr_err("number of total queues is 0\n");
 		return false;
 	}
 	maxid = info->queues_total - 1 + info->queuenum;
 	if (maxid > 0xffff) {
-		pr_err("NFQUEUE: number of queues (%u) out of range (got %u)\n",
+		pr_err("number of queues (%u) out of range (got %u)\n",
 		       info->queues_total, maxid);
 		return false;
 	}
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 7a6f9e6..166f015 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -24,8 +24,6 @@ MODULE_DESCRIPTION("Xtables: packet security mark modification");
 MODULE_ALIAS("ipt_SECMARK");
 MODULE_ALIAS("ip6t_SECMARK");
 
-#define PFX "SECMARK: "
-
 static u8 mode;
 
 static unsigned int
@@ -59,20 +57,20 @@ static bool checkentry_selinux(struct xt_secmark_target_info *info)
 	err = selinux_string_to_sid(sel->selctx, &sel->selsid);
 	if (err) {
 		if (err == -EINVAL)
-			printk(KERN_INFO PFX "invalid SELinux context \'%s\'\n",
+			pr_info("invalid SELinux context \'%s\'\n",
 			       sel->selctx);
 		return false;
 	}
 
 	if (!sel->selsid) {
-		printk(KERN_INFO PFX "unable to map SELinux context \'%s\'\n",
+		pr_info("unable to map SELinux context \'%s\'\n",
 		       sel->selctx);
 		return false;
 	}
 
 	err = selinux_secmark_relabel_packet_permission(sel->selsid);
 	if (err) {
-		printk(KERN_INFO PFX "unable to obtain relabeling permission\n");
+		pr_info("unable to obtain relabeling permission\n");
 		return false;
 	}
 
@@ -86,13 +84,13 @@ static bool secmark_tg_check(const struct xt_tgchk_param *par)
 
 	if (strcmp(par->table, "mangle") != 0 &&
 	    strcmp(par->table, "security") != 0) {
-		printk(KERN_INFO PFX "target only valid in the \'mangle\' "
+		pr_info("target only valid in the \'mangle\' "
 		       "or \'security\' tables, not \'%s\'.\n", par->table);
 		return false;
 	}
 
 	if (mode && mode != info->mode) {
-		printk(KERN_INFO PFX "mode already set to %hu cannot mix with "
+		pr_info("mode already set to %hu cannot mix with "
 		       "rules for mode %hu\n", mode, info->mode);
 		return false;
 	}
@@ -104,7 +102,7 @@ static bool secmark_tg_check(const struct xt_tgchk_param *par)
 		break;
 
 	default:
-		printk(KERN_INFO PFX "invalid mode: %hu\n", info->mode);
+		pr_info("invalid mode: %hu\n", info->mode);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index eda64c1..dbf0896 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -67,7 +67,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	   badly. --RR */
 	if (tcplen != tcph->doff*4) {
 		if (net_ratelimit())
-			printk(KERN_ERR "xt_TCPMSS: bad length (%u bytes)\n",
+			pr_err("bad length (%u bytes)\n",
 			       skb->len);
 		return -1;
 	}
@@ -75,14 +75,14 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		if (dst_mtu(skb_dst(skb)) <= minlen) {
 			if (net_ratelimit())
-				printk(KERN_ERR "xt_TCPMSS: "
+				pr_err(""
 				       "unknown or invalid path-MTU (%u)\n",
 				       dst_mtu(skb_dst(skb)));
 			return -1;
 		}
 		if (in_mtu <= minlen) {
 			if (net_ratelimit())
-				printk(KERN_ERR "xt_TCPMSS: unknown or "
+				pr_err("unknown or "
 				       "invalid path-MTU (%u)\n", in_mtu);
 			return -1;
 		}
@@ -246,13 +246,13 @@ static bool tcpmss_tg4_check(const struct xt_tgchk_param *par)
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
 			   (1 << NF_INET_LOCAL_OUT) |
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		printk("xt_TCPMSS: path-MTU clamping only supported in "
-		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
+		pr_info("path-MTU clamping only supported in "
+			"FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
 	if (IPT_MATCH_ITERATE(e, find_syn_match))
 		return true;
-	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
+	pr_info("Only works on TCP SYN packets\n");
 	return false;
 }
 
@@ -266,13 +266,13 @@ static bool tcpmss_tg6_check(const struct xt_tgchk_param *par)
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
 			   (1 << NF_INET_LOCAL_OUT) |
 			   (1 << NF_INET_POST_ROUTING))) != 0) {
-		printk("xt_TCPMSS: path-MTU clamping only supported in "
-		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
+		pr_info("path-MTU clamping only supported in "
+			"FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
 	if (IP6T_MATCH_ITERATE(e, find_syn_match))
 		return true;
-	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
+	pr_info("Only works on TCP SYN packets\n");
 	return false;
 }
 #endif
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 1340c2f..c95db23 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -67,8 +67,7 @@ static bool tproxy_tg_check(const struct xt_tgchk_param *par)
 	    && !(i->invflags & IPT_INV_PROTO))
 		return true;
 
-	pr_info("xt_TPROXY: Can be used only in combination with "
-		"either -p tcp or -p udp\n");
+	pr_info("Can be used only in combination with either -p tcp or -p udp\n");
 	return false;
 }
 
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 225ee3e..25daae7 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -136,14 +136,12 @@ static bool xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
 	struct xt_cluster_match_info *info = par->matchinfo;
 
 	if (info->total_nodes > XT_CLUSTER_NODES_MAX) {
-		printk(KERN_ERR "xt_cluster: you have exceeded the maximum "
-				"number of cluster nodes (%u > %u)\n",
-				info->total_nodes, XT_CLUSTER_NODES_MAX);
+		pr_err("you have exceeded the maximum number of cluster nodes (%u > %u)\n",
+		       info->total_nodes, XT_CLUSTER_NODES_MAX);
 		return false;
 	}
 	if (info->node_mask >= (1ULL << info->total_nodes)) {
-		printk(KERN_ERR "xt_cluster: this node mask cannot be "
-				"higher than the total number of nodes\n");
+		pr_err("this node mask cannot be higher than the total number of nodes\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 955e659..c38ccd8 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -107,7 +107,7 @@ static bool connbytes_mt_check(const struct xt_mtchk_param *par)
 		return false;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
+		pr_warning("can't load conntrack support for "
 				    "proto=%u\n", par->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 6809809..1f87665 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -229,7 +229,7 @@ static bool connlimit_mt_check(const struct xt_mtchk_param *par)
 	unsigned int i;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
+		pr_warning("cannot load conntrack support for "
 		       "address family %u\n", par->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 122aa8b..186f85b 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -50,7 +50,7 @@ connmark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool connmark_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "cannot load conntrack support for "
+		pr_warning("cannot load conntrack support for "
 		       "proto=%u\n", par->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 6dc4652..f7f93b0 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -202,7 +202,7 @@ conntrack_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
+		pr_warning("can't load conntrack support for "
 				    "proto=%u\n", par->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index 0280d3a..bb41523 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -47,7 +47,7 @@ static bool dscp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_dscp_info *info = par->matchinfo;
 
 	if (info->dscp > XT_DSCP_MAX) {
-		printk(KERN_ERR "xt_dscp: dscp %x out of range\n", info->dscp);
+		pr_err("dscp %x out of range\n", info->dscp);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index dd16e40..20bb220 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -156,17 +156,15 @@ dsthash_alloc_init(struct xt_hashlimit_htable *ht,
 	if (ht->cfg.max && ht->count >= ht->cfg.max) {
 		/* FIXME: do something. question is what.. */
 		if (net_ratelimit())
-			printk(KERN_WARNING
-				"xt_hashlimit: max count of %u reached\n",
-				ht->cfg.max);
+			pr_warning("max count of %u reached\n",
+				   ht->cfg.max);
 		return NULL;
 	}
 
 	ent = kmem_cache_alloc(hashlimit_cachep, GFP_ATOMIC);
 	if (!ent) {
 		if (net_ratelimit())
-			printk(KERN_ERR
-				"xt_hashlimit: can't allocate dsthash_ent\n");
+			pr_err("can't allocate dsthash_ent\n");
 		return NULL;
 	}
 	memcpy(&ent->dst, dst, sizeof(ent->dst));
@@ -205,7 +203,7 @@ static int htable_create_v0(struct xt_hashlimit_info *minfo, u_int8_t family)
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 			sizeof(struct list_head) * size);
 	if (!hinfo) {
-		printk(KERN_ERR "xt_hashlimit: unable to create hashtable\n");
+		pr_err("unable to create hashtable\n");
 		return -1;
 	}
 	minfo->hinfo = hinfo;
@@ -277,7 +275,7 @@ static int htable_create(struct xt_hashlimit_mtinfo1 *minfo, u_int8_t family)
 	hinfo = vmalloc(sizeof(struct xt_hashlimit_htable) +
 	                sizeof(struct list_head) * size);
 	if (hinfo == NULL) {
-		printk(KERN_ERR "xt_hashlimit: unable to create hashtable\n");
+		pr_err("unable to create hashtable\n");
 		return -1;
 	}
 	minfo->hinfo = hinfo;
@@ -670,7 +668,7 @@ static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 	/* Check for overflow. */
 	if (r->cfg.burst == 0 ||
 	    user2credits(r->cfg.avg * r->cfg.burst) < user2credits(r->cfg.avg)) {
-		printk(KERN_ERR "xt_hashlimit: overflow, try lower: %u/%u\n",
+		pr_err("overflow, try lower: %u/%u\n",
 		       r->cfg.avg, r->cfg.burst);
 		return false;
 	}
@@ -712,7 +710,7 @@ static bool hashlimit_mt_check(const struct xt_mtchk_param *par)
 	if (info->cfg.burst == 0 ||
 	    user2credits(info->cfg.avg * info->cfg.burst) <
 	    user2credits(info->cfg.avg)) {
-		printk(KERN_ERR "xt_hashlimit: overflow, try lower: %u/%u\n",
+		pr_err("overflow, try lower: %u/%u\n",
 		       info->cfg.avg, info->cfg.burst);
 		return false;
 	}
@@ -971,21 +969,19 @@ static int __init hashlimit_mt_init(void)
 					    sizeof(struct dsthash_ent), 0, 0,
 					    NULL);
 	if (!hashlimit_cachep) {
-		printk(KERN_ERR "xt_hashlimit: unable to create slab cache\n");
+		pr_err("unable to create slab cache\n");
 		goto err2;
 	}
 	hashlimit_procdir4 = proc_mkdir("ipt_hashlimit", init_net.proc_net);
 	if (!hashlimit_procdir4) {
-		printk(KERN_ERR "xt_hashlimit: unable to create proc dir "
-				"entry\n");
+		pr_err("unable to create proc dir entry\n");
 		goto err3;
 	}
 	err = 0;
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 	hashlimit_procdir6 = proc_mkdir("ip6t_hashlimit", init_net.proc_net);
 	if (!hashlimit_procdir6) {
-		printk(KERN_ERR "xt_hashlimit: unable to create proc dir "
-				"entry\n");
+		pr_err("unable to create proc dir entry\n");
 		err = -ENOMEM;
 	}
 #endif
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 64fc7f2..4e683f6 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -59,7 +59,7 @@ static bool helper_mt_check(const struct xt_mtchk_param *par)
 	struct xt_helper_info *info = par->matchinfo;
 
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
+		pr_warning("can't load conntrack support for "
 				    "proto=%u\n", par->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_hl.c b/net/netfilter/xt_hl.c
index 7726154..62345e9 100644
--- a/net/netfilter/xt_hl.c
+++ b/net/netfilter/xt_hl.c
@@ -40,7 +40,7 @@ static bool ttl_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		case IPT_TTL_GT:
 			return ttl > info->ttl;
 		default:
-			printk(KERN_WARNING "ipt_ttl: unknown mode %d\n",
+			pr_warning("ipt_ttl: unknown mode %d\n",
 				info->mode);
 			return false;
 	}
@@ -67,7 +67,7 @@ static bool hl_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 			return ip6h->hop_limit > info->hop_limit;
 			break;
 		default:
-			printk(KERN_WARNING "ip6t_hl: unknown mode %d\n",
+			pr_warning("ip6t_hl: unknown mode %d\n",
 				info->mode);
 			return false;
 	}
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 2e8089e..ad51844 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -105,8 +105,8 @@ static bool limit_mt_check(const struct xt_mtchk_param *par)
 	/* Check for overflow. */
 	if (r->burst == 0
 	    || user2credits(r->avg * r->burst) < user2credits(r->avg)) {
-		printk("Overflow in xt_limit, try lower: %u/%u\n",
-		       r->avg, r->burst);
+		pr_info("Overflow in xt_limit, try lower: %u/%u\n",
+			r->avg, r->burst);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 63e1905..f50158b 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -382,13 +382,13 @@ static int __init xt_osf_init(void)
 
 	err = nfnetlink_subsys_register(&xt_osf_nfnetlink);
 	if (err < 0) {
-		printk(KERN_ERR "Failed (%d) to register OSF nsfnetlink helper.\n", err);
+		pr_err("Failed (%d) to register OSF nsfnetlink helper.\n", err);
 		goto err_out_exit;
 	}
 
 	err = xt_register_match(&xt_osf_match);
 	if (err) {
-		printk(KERN_ERR "Failed (%d) to register OS fingerprint "
+		pr_err("Failed (%d) to register OS fingerprint "
 				"matching module.\n", err);
 		goto err_out_remove;
 	}
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 8d28ca5..64186c7 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -95,7 +95,7 @@ static bool physdev_mt_check(const struct xt_mtchk_param *par)
 	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
 	    par->hook_mask & ((1 << NF_INET_LOCAL_OUT) |
 	    (1 << NF_INET_FORWARD) | (1 << NF_INET_POST_ROUTING))) {
-		printk(KERN_WARNING "physdev match: using --physdev-out in the "
+		pr_warning("physdev match: using --physdev-out in the "
 		       "OUTPUT, FORWARD and POSTROUTING chains for non-bridged "
 		       "traffic is not supported anymore.\n");
 		if (par->hook_mask & (1 << NF_INET_LOCAL_OUT))
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 4cbfebd..8cf4d0f 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -133,24 +133,21 @@ static bool policy_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_policy_info *info = par->matchinfo;
 
 	if (!(info->flags & (XT_POLICY_MATCH_IN|XT_POLICY_MATCH_OUT))) {
-		printk(KERN_ERR "xt_policy: neither incoming nor "
-				"outgoing policy selected\n");
+		pr_err("neither incoming nor outgoing policy selected\n");
 		return false;
 	}
 	if (par->hook_mask & ((1 << NF_INET_PRE_ROUTING) |
 	    (1 << NF_INET_LOCAL_IN)) && info->flags & XT_POLICY_MATCH_OUT) {
-		printk(KERN_ERR "xt_policy: output policy not valid in "
-				"PRE_ROUTING and INPUT\n");
+		pr_err("output policy not valid in PRE_ROUTING and INPUT\n");
 		return false;
 	}
 	if (par->hook_mask & ((1 << NF_INET_POST_ROUTING) |
 	    (1 << NF_INET_LOCAL_OUT)) && info->flags & XT_POLICY_MATCH_IN) {
-		printk(KERN_ERR "xt_policy: input policy not valid in "
-				"POST_ROUTING and OUTPUT\n");
+		pr_err("input policy not valid in POST_ROUTING and OUTPUT\n");
 		return false;
 	}
 	if (info->len > XT_POLICY_MAX_ELEM) {
-		printk(KERN_ERR "xt_policy: too many policy elements\n");
+		pr_err("too many policy elements\n");
 		return false;
 	}
 	return true;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index eb0ceb8..c6635af 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -459,8 +459,8 @@ static int recent_old_seq_open(struct inode *inode, struct file *filp)
 	static bool warned_of_old;
 
 	if (unlikely(!warned_of_old)) {
-		printk(KERN_INFO KBUILD_MODNAME ": Use of /proc/net/ipt_recent"
-		       " is deprecated; use /proc/net/xt_recent.\n");
+		pr_info("Use of /proc/net/ipt_recent is deprecated; "
+			"use /proc/net/xt_recent.\n");
 		warned_of_old = true;
 	}
 	return recent_seq_open(inode, filp);
@@ -568,7 +568,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 		add = true;
 		break;
 	default:
-		printk(KERN_INFO KBUILD_MODNAME ": Need +ip, -ip or /\n");
+		pr_info("Need +ip, -ip or /\n");
 		return -EINVAL;
 	}
 
@@ -583,8 +583,7 @@ recent_mt_proc_write(struct file *file, const char __user *input,
 	}
 
 	if (!succ) {
-		printk(KERN_INFO KBUILD_MODNAME ": illegal address written "
-		       "to procfs\n");
+		pr_info("illegal address written to procfs\n");
 		return -EINVAL;
 	}
 
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 4c946cb..3e6c3c0 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -40,7 +40,7 @@ state_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool state_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->match->family) < 0) {
-		printk(KERN_WARNING "can't load conntrack support for "
+		pr_warning("can't load conntrack support for "
 				    "proto=%u\n", par->match->family);
 		return false;
 	}
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index d8c0f8f..3cda5d8 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -62,7 +62,7 @@ static bool statistic_mt_check(const struct xt_mtchk_param *par)
 
 	info->master = kzalloc(sizeof(*info->master), GFP_KERNEL);
 	if (info->master == NULL) {
-		printk(KERN_ERR KBUILD_MODNAME ": Out of memory\n");
+		pr_err("Out of memory\n");
 		return false;
 	}
 	info->master->count = info->u.nth.count;
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 93acaa5..e900b5e 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -224,8 +224,8 @@ static bool time_mt_check(const struct xt_mtchk_param *par)
 
 	if (info->daytime_start > XT_TIME_MAX_DAYTIME ||
 	    info->daytime_stop > XT_TIME_MAX_DAYTIME) {
-		printk(KERN_WARNING "xt_time: invalid argument - start or "
-		       "stop time greater than 23:59:59\n");
+		pr_warning("invalid argument - start or "
+			   "stop time greater than 23:59:59\n");
 		return false;
 	}
 
@@ -246,13 +246,11 @@ static int __init time_mt_init(void)
 	int minutes = sys_tz.tz_minuteswest;
 
 	if (minutes < 0) /* east of Greenwich */
-		printk(KERN_INFO KBUILD_MODNAME
-		       ": kernel timezone is +%02d%02d\n",
-		       -minutes / 60, -minutes % 60);
+		pr_info("kernel timezone is +%02d%02d\n",
+			-minutes / 60, -minutes % 60);
 	else /* west of Greenwich */
-		printk(KERN_INFO KBUILD_MODNAME
-		       ": kernel timezone is -%02d%02d\n",
-		       minutes / 60, minutes % 60);
+		pr_info("kernel timezone is -%02d%02d\n",
+			minutes / 60, minutes % 60);
 
 	return xt_register_match(&xt_time_mt_reg);
 }
-- 
1.6.3.1.10.g659a0.dirty

