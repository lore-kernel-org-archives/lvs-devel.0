From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 12/24] IPVS: Extend functions for getting/creating connections
Date: Wed, 20 Aug 2008 18:15:19 +0200
Message-ID: <1219248931-15064-13-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248943; bh=NudiOrrwL4BEPeDzayZO5ET2Byc=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=l5iT9wqpyr0W09v2gCtGyayKpFFu1tE9MkkYPL3T
	TQVhzwTf9rDcok4m4WWdGUgjZnRxcOMROD/usdQMWnhRIw==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Extend functions for getting/creating connections and connection
templates with IPv6 support.

Signed-off-by: Julius Volz <juliusv@google.com>

 2 files changed, 52 insertions(+), 28 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 565121e..c80eaec 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -641,11 +641,16 @@ enum {
 };
 
 extern struct ip_vs_conn *ip_vs_conn_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port);
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port);
+
 extern struct ip_vs_conn *ip_vs_ct_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port);
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port);
+
 extern struct ip_vs_conn *ip_vs_conn_out_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port);
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port);
 
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
@@ -656,9 +661,11 @@ extern void ip_vs_conn_put(struct ip_vs_conn *cp);
 extern void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
 
 extern struct ip_vs_conn *
-ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport,
-	       __be32 daddr, __be16 dport, unsigned flags,
+ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
+	       const union nf_inet_addr *vaddr, __be16 vport,
+	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
 	       struct ip_vs_dest *dest);
+
 extern void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
 
 extern const char * ip_vs_state_name(__u16 proto, int state);
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 4eae6bf..1a6b9d8 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -187,20 +187,23 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
  *	d_addr, d_port: pkt dest address (load balancer)
  */
 static inline struct ip_vs_conn *__ip_vs_conn_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(protocol, s_addr, s_port);
+	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (s_addr==cp->caddr && s_port==cp->cport &&
-		    d_port==cp->vport && d_addr==cp->vaddr &&
+		if (cp->af == af &&
+		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
+		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
+		    s_port == cp->cport && d_port == cp->vport &&
 		    ((!s_port) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
-		    protocol==cp->protocol) {
+		    protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
 			ct_read_unlock(hash);
@@ -214,13 +217,14 @@ static inline struct ip_vs_conn *__ip_vs_conn_in_get
 }
 
 struct ip_vs_conn *ip_vs_conn_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	struct ip_vs_conn *cp;
 
-	cp = __ip_vs_conn_in_get(protocol, s_addr, s_port, d_addr, d_port);
+	cp = __ip_vs_conn_in_get(af, protocol, s_addr, s_port, d_addr, d_port);
 	if (!cp && atomic_read(&ip_vs_conn_no_cport_cnt))
-		cp = __ip_vs_conn_in_get(protocol, s_addr, 0, d_addr, d_port);
+		cp = __ip_vs_conn_in_get(af, protocol, s_addr, 0, d_addr, d_port);
 
 	IP_VS_DBG_BUF(9, "lookup/in %s %s:%d->%s:%d %s\n",
 		      ip_vs_proto_name(protocol),
@@ -233,20 +237,23 @@ struct ip_vs_conn *ip_vs_conn_in_get
 
 /* Get reference to connection template */
 struct ip_vs_conn *ip_vs_ct_in_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
 
-	hash = ip_vs_conn_hashkey(protocol, s_addr, s_port);
+	hash = ip_vs_conn_hashkey(af, protocol, s_addr, s_port);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (s_addr==cp->caddr && s_port==cp->cport &&
-		    d_port==cp->vport && d_addr==cp->vaddr &&
+		if (cp->af == af &&
+		    ip_vs_addr_equal(af, s_addr, &cp->caddr) &&
+		    ip_vs_addr_equal(af, d_addr, &cp->vaddr) &&
+		    s_port == cp->cport && d_port == cp->vport &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
-		    protocol==cp->protocol) {
+		    protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
 			goto out;
@@ -273,7 +280,8 @@ struct ip_vs_conn *ip_vs_ct_in_get
  *	d_addr, d_port: pkt dest address (foreign host)
  */
 struct ip_vs_conn *ip_vs_conn_out_get
-(int protocol, __be32 s_addr, __be16 s_port, __be32 d_addr, __be16 d_port)
+(int af, int protocol, const union nf_inet_addr *s_addr, __be16 s_port,
+ const union nf_inet_addr *d_addr, __be16 d_port)
 {
 	unsigned hash;
 	struct ip_vs_conn *cp, *ret=NULL;
@@ -281,13 +289,15 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	/*
 	 *	Check for "full" addressed entries
 	 */
-	hash = ip_vs_conn_hashkey(protocol, d_addr, d_port);
+	hash = ip_vs_conn_hashkey(af, protocol, d_addr, d_port);
 
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (d_addr == cp->caddr && d_port == cp->cport &&
-		    s_port == cp->dport && s_addr == cp->daddr &&
+		if (cp->af == af &&
+		    ip_vs_addr_equal(af, d_addr, &cp->caddr) &&
+		    ip_vs_addr_equal(af, s_addr, &cp->daddr) &&
+		    d_port == cp->cport && s_port == cp->dport &&
 		    protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
@@ -655,8 +665,9 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
  *	Create a new connection entry and hash it into the ip_vs_conn_tab
  */
 struct ip_vs_conn *
-ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport,
-	       __be32 daddr, __be16 dport, unsigned flags,
+ip_vs_conn_new(int af, int proto, const union nf_inet_addr *caddr, __be16 cport,
+	       const union nf_inet_addr *vaddr, __be16 vport,
+	       const union nf_inet_addr *daddr, __be16 dport, unsigned flags,
 	       struct ip_vs_dest *dest)
 {
 	struct ip_vs_conn *cp;
@@ -670,12 +681,13 @@ ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport
 
 	INIT_LIST_HEAD(&cp->c_list);
 	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
+	cp->af		   = af;
 	cp->protocol	   = proto;
-	cp->caddr	   = caddr;
+	ip_vs_addr_copy(af, &cp->caddr, caddr);
 	cp->cport	   = cport;
-	cp->vaddr	   = vaddr;
+	ip_vs_addr_copy(af, &cp->vaddr, vaddr);
 	cp->vport	   = vport;
-	cp->daddr          = daddr;
+	ip_vs_addr_copy(af, &cp->daddr, daddr);
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	spin_lock_init(&cp->lock);
@@ -702,7 +714,12 @@ ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport
 	cp->timeout = 3*HZ;
 
 	/* Bind its packet transmitter */
-	ip_vs_bind_xmit(cp);
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6)
+		ip_vs_bind_xmit_v6(cp);
+	else
+#endif
+		ip_vs_bind_xmit(cp);
 
 	if (unlikely(pp && atomic_read(&pp->appcnt)))
 		ip_vs_bind_app(cp, pp);
-- 
1.5.4.5

