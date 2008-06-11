From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 18/26] IPVS: Add functions for getting/creating IPv6 connections.
Date: Wed, 11 Jun 2008 19:12:01 +0200
Message-ID: <1213204329-10973-19-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204338; bh=YBC2b3LFWIxbjOD6/GuZltDPPtU=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=UO8gqjx3pRANoVwGhhOuyFu6lkCLDMWkwrEcZQEK
	NJuJEocMd6GMCYRbFVSLX15VRMsbAH61hBUp9rzo9sH2Zw==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Add functions for getting/creating IPv6 connections and connection
templates where these diverge significantly from the IPv4 versions.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 2 files changed, 211 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index d04d5c6..6a58dff 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -816,6 +816,19 @@ extern struct ip_vs_conn *ip_vs_ct_in_get
 extern struct ip_vs_conn *ip_vs_conn_out_get
 (int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port);
 
+#ifdef CONFIG_IP_VS_IPV6
+extern struct ip_vs_conn *
+ip_vs_conn_in_get_v6(int protocol, const struct in6_addr *s_addr, __be16 s_port,
+		     const struct in6_addr *d_addr, __be16 d_port);
+extern struct ip_vs_conn *
+ip_vs_ct_in_get_v6(int protocol, const struct in6_addr *s_addr, __be16 s_port,
+		   const struct in6_addr *d_addr, __be16 d_port);
+extern struct ip_vs_conn *
+ip_vs_conn_out_get_v6(int protocol, const struct in6_addr *s_addr,
+		      __be16 s_port, const struct in6_addr *d_addr,
+		      __be16 d_port);
+#endif
+
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 {
@@ -828,6 +841,15 @@ extern struct ip_vs_conn *
 ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport,
 	       __be32 daddr, __be16 dport, unsigned flags,
 	       struct ip_vs_dest *dest);
+
+#ifdef CONFIG_IP_VS_IPV6
+extern struct ip_vs_conn *
+ip_vs_conn_new_v6(int proto, const struct in6_addr *caddr, __be16 cport,
+		  const struct in6_addr *vaddr, __be16 vport,
+		  const struct in6_addr *daddr, __be16 dport, unsigned flags,
+		  struct ip_vs_dest *dest);
+#endif
+
 extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
 extern const char * ip_vs_state_name(__u16 proto, int state);
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4ee5dac..30e1ad2 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -236,6 +236,36 @@ static inline struct ip_vs_conn *__ip_vs_conn_in_get
 	return NULL;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+static inline struct ip_vs_conn *__ip_vs_conn_in_get_v6
+(int protocol, const struct in6_addr *s_addr, __be16 s_port, const struct in6_addr *d_addr, __be16 d_port)
+{
+	unsigned hash;
+	struct ip_vs_conn *cp;
+
+	hash = ip_vs_conn_hashkey_v6(protocol, s_addr, s_port);
+
+	ct_read_lock(hash);
+
+	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		if (cp->af == AF_INET6 &&
+		    ipv6_addr_equal(s_addr, &cp->caddr.v6) && s_port==cp->cport &&
+		    ipv6_addr_equal(d_addr, &cp->vaddr.v6) && d_port==cp->vport &&
+		    ((!s_port) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
+		    protocol==cp->protocol) {
+			/* HIT */
+			atomic_inc(&cp->refcnt);
+			ct_read_unlock(hash);
+			return cp;
+		}
+	}
+
+	ct_read_unlock(hash);
+
+	return NULL;
+}
+#endif
+
 struct ip_vs_conn *ip_vs_conn_in_get
 (int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
 {
@@ -254,6 +284,26 @@ struct ip_vs_conn *ip_vs_conn_in_get
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+struct ip_vs_conn *ip_vs_conn_in_get_v6
+(int protocol, const struct in6_addr *s_addr, __be16 s_port, const struct in6_addr *d_addr, __be16 d_port)
+{
+	struct ip_vs_conn *cp;
+
+	cp = __ip_vs_conn_in_get_v6(protocol, s_addr, s_port, d_addr, d_port);
+	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt))
+		cp = __ip_vs_conn_in_get_v6(protocol, s_addr, 0, d_addr, d_port);
+
+	IP_VS_DBG(9, "lookup/in %s " NIP6_FMT ":%d->" NIP6_FMT ":%d %s\n",
+		  ip_vs_proto_name(protocol),
+		  NIP6(*s_addr), ntohs(s_port),
+		  NIP6(*d_addr), ntohs(d_port),
+		  cp?"hit":"not hit");
+
+	return cp;
+}
+#endif
+
 /* Get reference to connection template */
 struct ip_vs_conn *ip_vs_ct_in_get
 (int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
@@ -290,6 +340,44 @@ struct ip_vs_conn *ip_vs_ct_in_get
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+/* Get reference to connection template */
+struct ip_vs_conn *ip_vs_ct_in_get_v6
+(int protocol, const struct in6_addr *s_addr, __be16 s_port, const struct in6_addr *d_addr, __be16 d_port)
+{
+	unsigned hash;
+	struct ip_vs_conn *cp;
+
+	hash = ip_vs_conn_hashkey_v6(protocol, s_addr, s_port);
+
+	ct_read_lock(hash);
+
+	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		if (cp->af == AF_INET6 &&
+		    ipv6_addr_equal(s_addr, &cp->caddr.v6) && s_port==cp->cport &&
+		    ipv6_addr_equal(d_addr, &cp->vaddr.v6) && d_port==cp->vport &&
+		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
+		    protocol==cp->protocol) {
+			/* HIT */
+			atomic_inc(&cp->refcnt);
+			goto out;
+		}
+	}
+	cp = NULL;
+
+  out:
+	ct_read_unlock(hash);
+
+	IP_VS_DBG(9, "template lookup/in %s " NIP6_FMT ":%d->" NIP6_FMT ":%d %s\n",
+		  ip_vs_proto_name(protocol),
+		  NIP6(*s_addr), ntohs(s_port),
+		  NIP6(*d_addr), ntohs(d_port),
+		  cp?"hit":"not hit");
+
+	return cp;
+}
+#endif
+
 /*
  *  Gets ip_vs_conn associated with supplied parameters in the ip_vs_conn_tab.
  *  Called for pkts coming from inside-to-OUTside.
@@ -332,6 +420,44 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	return ret;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+struct ip_vs_conn *ip_vs_conn_out_get_v6
+(int protocol, const struct in6_addr *s_addr, __be16 s_port, const struct in6_addr *d_addr, __be16 d_port)
+{
+	unsigned hash;
+	struct ip_vs_conn *cp, *ret=NULL;
+
+	/*
+	 *	Check for "full" addressed entries
+	 */
+	hash = ip_vs_conn_hashkey_v6(protocol, d_addr, d_port);
+
+	ct_read_lock(hash);
+
+	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
+		if (cp->af == AF_INET6 &&
+		    ipv6_addr_equal(d_addr, &cp->caddr.v6) && d_port==cp->cport &&
+		    ipv6_addr_equal(s_addr, &cp->daddr.v6) && s_port==cp->dport &&
+		    protocol == cp->protocol) {
+			/* HIT */
+			atomic_inc(&cp->refcnt);
+			ret = cp;
+			break;
+		}
+	}
+
+	ct_read_unlock(hash);
+
+	IP_VS_DBG(9, "lookup/out %s " NIP6_FMT ":%d->" NIP6_FMT ":%d %s\n",
+		  ip_vs_proto_name(protocol),
+		  NIP6(*s_addr), ntohs(s_port),
+		  NIP6(*d_addr), ntohs(d_port),
+		  ret?"hit":"not hit");
+
+	return ret;
+}
+#endif
+
 
 /*
  *      Put back the conn and restart its timer with its timeout
@@ -766,6 +892,69 @@ ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport
 	return cp;
 }
 
+#ifdef CONFIG_IP_VS_IPV6
+struct ip_vs_conn *
+ip_vs_conn_new_v6(int proto, const struct in6_addr *caddr, __be16 cport,
+	          const struct in6_addr *vaddr, __be16 vport,
+	          const struct in6_addr *daddr, __be16 dport, unsigned flags,
+	          struct ip_vs_dest *dest)
+{
+	struct ip_vs_conn *cp;
+	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
+
+	cp = kmem_cache_zalloc(ip_vs_conn_cachep, GFP_ATOMIC);
+	if (cp == NULL) {
+		IP_VS_ERR_RL("ip_vs_conn_new_v6: no memory available.\n");
+		return NULL;
+	}
+
+	INIT_LIST_HEAD(&cp->c_list);
+	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
+	cp->af		   = AF_INET6;
+	cp->protocol	   = proto;
+	cp->caddr.v6	   = *caddr;
+	cp->cport	   = cport;
+	cp->vaddr.v6	   = *vaddr;
+	cp->vport	   = vport;
+	cp->daddr.v6	   = *daddr;
+	cp->dport          = dport;
+	cp->flags	   = flags;
+	spin_lock_init(&cp->lock);
+
+	/*
+	 * Set the entry is referenced by the current thread before hashing
+	 * it in the table, so that other thread run ip_vs_random_dropentry
+	 * but cannot drop this entry.
+	 */
+	atomic_set(&cp->refcnt, 1);
+
+	atomic_set(&cp->n_control, 0);
+	atomic_set(&cp->in_pkts, 0);
+
+	atomic_inc(&ip_vs_conn_count);
+	if (flags & IP_VS_CONN_F_NO_CPORT)
+		atomic_inc(&ip_vs_conn_no_cport_cnt);
+
+	/* Bind the connection with a destination server */
+	ip_vs_bind_dest(cp, dest);
+
+	/* Set its state and timeout */
+	cp->state = 0;
+	cp->timeout = 3*HZ;
+
+	/* Bind its packet transmitter */
+	ip_vs_bind_xmit_v6(cp);
+
+	if (unlikely(pp && atomic_read(&pp->appcnt)))
+		ip_vs_bind_app(cp, pp);
+
+	/* Hash it in the ip_vs_conn_tab finally */
+	ip_vs_conn_hash(cp);
+
+	return cp;
+}
+#endif
+
 
 /*
  *	/proc/net/ip_vs_conn entries
-- 
1.5.3.6

