From: Hannes Eder <heder@google.com>
Subject: [RFC][PATCH 4/5] IPVS: debugging output for ip_vs_update_conntrack
Date: Mon, 27 Jul 2009 15:46:31 +0200
Message-ID: <20090727134631.12897.59167.stgit@jazzy.zrh.corp.google.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1248708681; bh=3aksLeP2PbbyWbGaNh24z/VoYM8=;
	h=DomainKey-Signature:Subject:To:From:Cc:Date:Message-ID:
	 In-Reply-To:References:User-Agent:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-System-Of-Record; b=QLrlnfr3oeu4Fz6y2p
	qRr5p82qq1qW51nYUjNXEEznayltbcQH1CQOo3zfhy2GIRybZ9HEtXJB/Rp2coFMqG2
	g==
In-Reply-To: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

This patch is not ment to be merged, its mere for debugging during
development.

Signed-off-by: Hannes Eder <heder@google.com>

 net/netfilter/ipvs/ip_vs_xmit.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index f3b6810..ed6b811 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -24,6 +24,7 @@
 #include <net/ip6_route.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
+#define DEBUG
 #include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter_ipv4.h>
 
@@ -345,12 +346,31 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 }
 #endif
 
+#ifdef DEBUG
+static void
+ip_vs_dump_ct_tuple(const struct nf_conntrack_tuple *t)
+{
+	/*
+	 * We ignore the fact that this is not SMP-safe.  Otherwise we would
+	 * have to duplicate code and this code is not ment to stay here anyway.
+	 */
+	printk(KERN_DEBUG "IPVS: ");
+	nf_ct_dump_tuple(t);
+}
+#endif
+
 static void
 ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
 {
 	if (skb->nfct) {
 		struct nf_conn *ct = (struct nf_conn *)skb->nfct;
 
+#ifdef DEBUG
+		ip_vs_dump_ct_tuple(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		ip_vs_dump_ct_tuple(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+		printk("IPVS: nfct confirmed=%d\n", nf_ct_is_confirmed(ct));
+#endif
+
 		if (ct != &nf_conntrack_untracked && !nf_ct_is_confirmed(ct)) {
 			/*
 			 * The connection is not yet in the hashtable, so we
@@ -365,6 +385,12 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
 			ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u.tcp.port =
 				cp->dport;
 		}
+
+#ifdef DEBUG
+		ip_vs_dump_ct_tuple(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		ip_vs_dump_ct_tuple(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+#endif
+
 	}
 }
 

