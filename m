From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 03/26] IPVS: Use new address family fields in IPVS structs.
Date: Wed, 11 Jun 2008 19:11:46 +0200
Message-ID: <1213204329-10973-4-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204335; bh=KoGvdLOfaRztnRTFnUP1T6OBsLY=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=lQjplC6gQyI3dqfPYsWQKj9IDq0kpDPLSURVHmQt
	u9JU51N162j9kZPwi8NtCjJXUq/aKyqW/oDTSfOCveKWdQ==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com, "Julius R. Volz" <juliusv@google.com>

Adjust miscellaneous code to correctly use the new af, v4 and v6 fields in
IPVS data structures where this is not already covered by other patches.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 8 files changed, 72 insertions(+), 60 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 65f1ba1..1d81cbc 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -199,8 +199,9 @@ static inline struct ip_vs_conn *__ip_vs_conn_in_get
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (s_addr==cp->caddr && s_port==cp->cport &&
-		    d_port==cp->vport && d_addr==cp->vaddr &&
+		if (cp->af == AF_INET &&
+		    s_addr==cp->caddr.v4 && s_port==cp->cport &&
+		    d_port==cp->vport && d_addr==cp->vaddr.v4 &&
 		    ((!s_port) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
 		    protocol==cp->protocol) {
 			/* HIT */
@@ -245,8 +246,9 @@ struct ip_vs_conn *ip_vs_ct_in_get
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (s_addr==cp->caddr && s_port==cp->cport &&
-		    d_port==cp->vport && d_addr==cp->vaddr &&
+		if (cp->af == AF_INET &&
+		    s_addr==cp->caddr.v4 && s_port==cp->cport &&
+		    d_port==cp->vport && d_addr==cp->vaddr.v4 &&
 		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
 		    protocol==cp->protocol) {
 			/* HIT */
@@ -288,8 +290,9 @@ struct ip_vs_conn *ip_vs_conn_out_get
 	ct_read_lock(hash);
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
-		if (d_addr == cp->caddr && d_port == cp->cport &&
-		    s_port == cp->dport && s_addr == cp->daddr &&
+		if (cp->af == AF_INET &&
+		    d_addr == cp->caddr.v4 && d_port == cp->cport &&
+		    s_port == cp->dport && s_addr == cp->daddr.v4 &&
 		    protocol == cp->protocol) {
 			/* HIT */
 			atomic_inc(&cp->refcnt);
@@ -642,12 +645,13 @@ ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport
 
 	INIT_LIST_HEAD(&cp->c_list);
 	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
+	cp->af		   = AF_INET;
 	cp->protocol	   = proto;
-	cp->caddr	   = caddr;
+	cp->caddr.v4	   = caddr;
 	cp->cport	   = cport;
-	cp->vaddr	   = vaddr;
+	cp->vaddr.v4	   = vaddr;
 	cp->vport	   = vport;
-	cp->daddr          = daddr;
+	cp->daddr.v4	   = daddr;
 	cp->dport          = dport;
 	cp->flags	   = flags;
 	spin_lock_init(&cp->lock);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 963981a..9a3d0df 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -234,14 +234,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 						    snet, 0,
 						    iph->daddr,
 						    ports[1],
-						    dest->addr, dest->port,
+						    dest->addr.v4, dest->port,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			else
 				ct = ip_vs_conn_new(iph->protocol,
 						    snet, 0,
 						    iph->daddr, 0,
-						    dest->addr, 0,
+						    dest->addr.v4, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			if (ct == NULL)
@@ -288,14 +288,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 				ct = ip_vs_conn_new(IPPROTO_IP,
 						    snet, 0,
 						    htonl(svc->fwmark), 0,
-						    dest->addr, 0,
+						    dest->addr.v4, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			else
 				ct = ip_vs_conn_new(iph->protocol,
 						    snet, 0,
 						    iph->daddr, 0,
-						    dest->addr, 0,
+						    dest->addr.v4, 0,
 						    IP_VS_CONN_F_TEMPLATE,
 						    dest);
 			if (ct == NULL)
@@ -315,7 +315,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 	cp = ip_vs_conn_new(iph->protocol,
 			    iph->saddr, ports[0],
 			    iph->daddr, ports[1],
-			    dest->addr, dport,
+			    dest->addr.v4, dport,
 			    0,
 			    dest);
 	if (cp == NULL) {
@@ -382,7 +382,7 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	cp = ip_vs_conn_new(iph->protocol,
 			    iph->saddr, pptr[0],
 			    iph->daddr, pptr[1],
-			    dest->addr, dest->port?dest->port:pptr[1],
+			    dest->addr.v4, dest->port?dest->port:pptr[1],
 			    0,
 			    dest);
 	if (cp == NULL)
@@ -391,9 +391,9 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
 	IP_VS_DBG(6, "Schedule fwd:%c c:%u.%u.%u.%u:%u v:%u.%u.%u.%u:%u "
 		  "d:%u.%u.%u.%u:%u conn->flags:%X conn->refcnt:%d\n",
 		  ip_vs_fwd_tag(cp),
-		  NIPQUAD(cp->caddr), ntohs(cp->cport),
-		  NIPQUAD(cp->vaddr), ntohs(cp->vport),
-		  NIPQUAD(cp->daddr), ntohs(cp->dport),
+		  NIPQUAD(cp->caddr.v4), ntohs(cp->cport),
+		  NIPQUAD(cp->vaddr.v4), ntohs(cp->vport),
+		  NIPQUAD(cp->daddr.v4), ntohs(cp->dport),
 		  cp->flags, atomic_read(&cp->refcnt));
 
 	ip_vs_conn_stats(cp, svc);
@@ -528,14 +528,14 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	struct iphdr *ciph	 = (struct iphdr *)(icmph + 1);
 
 	if (inout) {
-		iph->saddr = cp->vaddr;
+		iph->saddr = cp->vaddr.v4;
 		ip_send_check(iph);
-		ciph->daddr = cp->vaddr;
+		ciph->daddr = cp->vaddr.v4;
 		ip_send_check(ciph);
 	} else {
-		iph->daddr = cp->daddr;
+		iph->daddr = cp->daddr.v4;
 		ip_send_check(iph);
-		ciph->saddr = cp->daddr;
+		ciph->saddr = cp->daddr.v4;
 		ip_send_check(ciph);
 	}
 
@@ -764,7 +764,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	/* mangle the packet */
 	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
 		goto drop;
-	ip_hdr(skb)->saddr = cp->vaddr;
+	ip_hdr(skb)->saddr = cp->vaddr.v4;
 	ip_send_check(ip_hdr(skb));
 
 	/* For policy routing, packets originating from this
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 94c5767..dd84deb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -374,7 +374,8 @@ __ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
 	hash = ip_vs_svc_hashkey(protocol, vaddr, vport);
 
 	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
-		if ((svc->addr == vaddr)
+		if ((svc->af == AF_INET)
+		    && (svc->addr.v4 == vaddr)
 		    && (svc->port == vport)
 		    && (svc->protocol == protocol)) {
 			/* HIT */
@@ -544,7 +545,8 @@ ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
 
 	read_lock(&__ip_vs_rs_lock);
 	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
-		if ((dest->addr == daddr)
+		if ((dest->af == AF_INET)
+		    && (dest->addr.v4 == daddr)
 		    && (dest->port == dport)
 		    && ((dest->protocol == protocol) ||
 			dest->vfwmark)) {
@@ -570,7 +572,8 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 	 * Find the destination for the given service
 	 */
 	list_for_each_entry(dest, &svc->destinations, n_list) {
-		if ((dest->addr == daddr) && (dest->port == dport)) {
+		if ((dest->af == AF_INET)
+		    && (dest->addr.v4 == daddr) && (dest->port == dport)) {
 			/* HIT */
 			return dest;
 		}
@@ -627,14 +630,15 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 		IP_VS_DBG(3, "Destination %u/%u.%u.%u.%u:%u still in trash, "
 			  "dest->refcnt=%d\n",
 			  dest->vfwmark,
-			  NIPQUAD(dest->addr), ntohs(dest->port),
+			  NIPQUAD(dest->addr.v4), ntohs(dest->port),
 			  atomic_read(&dest->refcnt));
-		if (dest->addr == daddr &&
+		if (dest->af == AF_INET &&
+		    dest->addr.v4 == daddr &&
 		    dest->port == dport &&
 		    dest->vfwmark == svc->fwmark &&
 		    dest->protocol == svc->protocol &&
 		    (svc->fwmark ||
-		     (dest->vaddr == svc->addr &&
+		     (dest->vaddr.v4 == svc->addr.v4 &&
 		      dest->vport == svc->port))) {
 			/* HIT */
 			return dest;
@@ -647,7 +651,7 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
 			IP_VS_DBG(3, "Removing destination %u/%u.%u.%u.%u:%u "
 				  "from trash\n",
 				  dest->vfwmark,
-				  NIPQUAD(dest->addr), ntohs(dest->port));
+				  NIPQUAD(dest->addr.v4), ntohs(dest->port));
 			list_del(&dest->n_list);
 			ip_vs_dst_reset(dest);
 			__ip_vs_unbind_svc(dest);
@@ -766,11 +770,12 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
 		return -ENOMEM;
 	}
 
+	dest->af = svc->af;
 	dest->protocol = svc->protocol;
 	dest->vaddr = svc->addr;
 	dest->vport = svc->port;
 	dest->vfwmark = svc->fwmark;
-	dest->addr = udest->addr;
+	ip_vs_copy_addr(dest->addr, udest->addr);
 	dest->port = udest->port;
 
 	atomic_set(&dest->activeconns, 0);
@@ -1085,8 +1090,9 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
 	atomic_set(&svc->usecnt, 1);
 	atomic_set(&svc->refcnt, 0);
 
+	svc->af = u->af;
 	svc->protocol = u->protocol;
-	svc->addr = u->addr;
+	ip_vs_copy_addr(svc->addr,u->addr);
 	svc->port = u->port;
 	svc->fwmark = u->fwmark;
 	svc->flags = u->flags;
@@ -2022,8 +2028,9 @@ ip_vs_copy_stats(struct ip_vs_stats_user *dst, struct ip_vs_stats *src)
 static void
 ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 {
+	dst->af = src->af;
 	dst->protocol = src->protocol;
-	dst->addr = src->addr;
+	ip_vs_copy_addr(dst->addr,src->addr);
 	dst->port = src->port;
 	dst->fwmark = src->fwmark;
 	strlcpy(dst->sched_name, src->scheduler->name, sizeof(dst->sched_name));
@@ -2097,7 +2104,8 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
 			if (count >= get->num_dests)
 				break;
 
-			entry.addr = dest->addr;
+			entry.af = dest->af;
+			ip_vs_copy_addr(entry.addr,dest->addr);
 			entry.port = dest->port;
 			entry.conn_flags = atomic_read(&dest->conn_flags);
 			entry.weight = atomic_read(&dest->weight);
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 59aa166..6542fa9 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -174,17 +174,17 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 
 		IP_VS_DBG(7, "PASV response (%u.%u.%u.%u:%d) -> "
 			  "%u.%u.%u.%u:%d detected\n",
-			  NIPQUAD(from), ntohs(port), NIPQUAD(cp->caddr), 0);
+			  NIPQUAD(from), ntohs(port), NIPQUAD(cp->caddr.v4), 0);
 
 		/*
 		 * Now update or create an connection entry for it
 		 */
 		n_cp = ip_vs_conn_out_get(iph->protocol, from, port,
-					  cp->caddr, 0);
+					  cp->caddr.v4, 0);
 		if (!n_cp) {
 			n_cp = ip_vs_conn_new(IPPROTO_TCP,
-					      cp->caddr, 0,
-					      cp->vaddr, port,
+					      cp->caddr.v4, 0,
+					      cp->vaddr.v4, port,
 					      from, port,
 					      IP_VS_CONN_F_NO_CPORT,
 					      cp->dest);
@@ -198,7 +198,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		/*
 		 * Replace the old passive address with the new one
 		 */
-		from = n_cp->vaddr;
+		from = n_cp->vaddr.v4;
 		port = n_cp->vport;
 		sprintf(buf,"%d,%d,%d,%d,%d,%d", NIPQUAD(from),
 			(ntohs(port)>>8)&255, ntohs(port)&255);
@@ -308,16 +308,16 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	 */
 	IP_VS_DBG(7, "protocol %s %u.%u.%u.%u:%d %u.%u.%u.%u:%d\n",
 		  ip_vs_proto_name(iph->protocol),
-		  NIPQUAD(to), ntohs(port), NIPQUAD(cp->vaddr), 0);
+		  NIPQUAD(to), ntohs(port), NIPQUAD(cp->vaddr.v4), 0);
 
 	n_cp = ip_vs_conn_in_get(iph->protocol,
 				 to, port,
-				 cp->vaddr, htons(ntohs(cp->vport)-1));
+				 cp->vaddr.v4, htons(ntohs(cp->vport)-1));
 	if (!n_cp) {
 		n_cp = ip_vs_conn_new(IPPROTO_TCP,
 				      to, port,
-				      cp->vaddr, htons(ntohs(cp->vport)-1),
-				      cp->daddr, htons(ntohs(cp->dport)-1),
+				      cp->vaddr.v4, htons(ntohs(cp->vport)-1),
+				      cp->daddr.v4, htons(ntohs(cp->dport)-1),
 				      0,
 				      cp->dest);
 		if (!n_cp)
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index b83dc14..6068c47 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -149,7 +149,7 @@ tcp_snat_handler(struct sk_buff *skb,
 	/* Adjust TCP checksums */
 	if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(tcph, cp->daddr, cp->vaddr,
+		tcp_fast_csum_update(tcph, cp->daddr.v4, cp->vaddr.v4,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -157,7 +157,7 @@ tcp_snat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		tcph->check = 0;
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-		tcph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
+		tcph->check = csum_tcpudp_magic(cp->vaddr.v4, cp->caddr.v4,
 						skb->len - tcphoff,
 						cp->protocol, skb->csum);
 		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
@@ -200,7 +200,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
-		tcp_fast_csum_update(tcph, cp->vaddr, cp->daddr,
+		tcp_fast_csum_update(tcph, cp->vaddr.v4, cp->daddr.v4,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -208,7 +208,7 @@ tcp_dnat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		tcph->check = 0;
 		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
-		tcph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
+		tcph->check = csum_tcpudp_magic(cp->caddr.v4, cp->daddr.v4,
 						skb->len - tcphoff,
 						cp->protocol, skb->csum);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 75771cb..0bcc17a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -160,7 +160,7 @@ udp_snat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(udph, cp->daddr, cp->vaddr,
+		udp_fast_csum_update(udph, cp->daddr.v4, cp->vaddr.v4,
 				     cp->dport, cp->vport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -168,7 +168,7 @@ udp_snat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		udph->check = 0;
 		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
-		udph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
+		udph->check = csum_tcpudp_magic(cp->vaddr.v4, cp->caddr.v4,
 						skb->len - udphoff,
 						cp->protocol, skb->csum);
 		if (udph->check == 0)
@@ -213,7 +213,7 @@ udp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
-		udp_fast_csum_update(udph, cp->vaddr, cp->daddr,
+		udp_fast_csum_update(udph, cp->vaddr.v4, cp->daddr.v4,
 				     cp->vport, cp->dport);
 		if (skb->ip_summed == CHECKSUM_COMPLETE)
 			skb->ip_summed = CHECKSUM_NONE;
@@ -221,7 +221,7 @@ udp_dnat_handler(struct sk_buff *skb,
 		/* full checksum calculation */
 		udph->check = 0;
 		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
-		udph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
+		udph->check = csum_tcpudp_magic(cp->caddr.v4, cp->daddr.v4,
 						skb->len - udphoff,
 						cp->protocol, skb->csum);
 		if (udph->check == 0)
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index eff54ef..bdd5cf0 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -245,9 +245,9 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 	s->cport = cp->cport;
 	s->vport = cp->vport;
 	s->dport = cp->dport;
-	s->caddr = cp->caddr;
-	s->vaddr = cp->vaddr;
-	s->daddr = cp->daddr;
+	s->caddr = cp->caddr.v4;
+	s->vaddr = cp->vaddr.v4;
+	s->daddr = cp->daddr.v4;
 	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
 	s->state = htons(cp->state);
 	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index f63006c..6b6ce6b 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -73,7 +73,7 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 				.oif = 0,
 				.nl_u = {
 					.ip4_u = {
-						.daddr = dest->addr,
+						.daddr = dest->addr.v4,
 						.saddr = 0,
 						.tos = rtos, } },
 			};
@@ -82,12 +82,12 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 				spin_unlock(&dest->dst_lock);
 				IP_VS_DBG_RL("ip_route_output error, "
 					     "dest: %u.%u.%u.%u\n",
-					     NIPQUAD(dest->addr));
+					     NIPQUAD(dest->addr.v4));
 				return NULL;
 			}
 			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->u.dst));
 			IP_VS_DBG(10, "new dst %u.%u.%u.%u, refcnt=%d, rtos=%X\n",
-				  NIPQUAD(dest->addr),
+				  NIPQUAD(dest->addr.v4),
 				  atomic_read(&rt->u.dst.__refcnt), rtos);
 		}
 		spin_unlock(&dest->dst_lock);
@@ -96,14 +96,14 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 			.oif = 0,
 			.nl_u = {
 				.ip4_u = {
-					.daddr = cp->daddr,
+					.daddr = cp->daddr.v4,
 					.saddr = 0,
 					.tos = rtos, } },
 		};
 
 		if (ip_route_output_key(&init_net, &rt, &fl)) {
 			IP_VS_DBG_RL("ip_route_output error, dest: "
-				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr));
+				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr.v4));
 			return NULL;
 		}
 	}
@@ -266,7 +266,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* mangle the packet */
 	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
 		goto tx_error;
-	ip_hdr(skb)->daddr = cp->daddr;
+	ip_hdr(skb)->daddr = cp->daddr.v4;
 	ip_send_check(ip_hdr(skb));
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
-- 
1.5.3.6

