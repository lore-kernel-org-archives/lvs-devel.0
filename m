From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 02/25] IPVS: Change IPVS data structures to
	support IPv6 addresses
Date: Tue, 2 Sep 2008 15:53:10 +1000
Message-ID: <20080902055308.GA18985@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-3-git-send-email-juliusv@google.com> <20080902052321.GA13730@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080902052321.GA13730@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Tue, Sep 02, 2008 at 03:23:23PM +1000, Simon Horman wrote:
> On Mon, Sep 01, 2008 at 02:55:59PM +0200, Julius Volz wrote:
> > Introduce new 'af' fields into IPVS data structures for specifying an
> > entry's address family. Convert IP addresses to be of type union
> > nf_inet_addr.
> > 
> > Signed-off-by: Julius Volz <juliusv@google.com>
> > 
> >  19 files changed, 118 insertions(+), 112 deletions(-)
> > 
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index a25ad24..01cabd6 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -21,6 +21,9 @@
> >  #include <linux/timer.h>
> >  
> >  #include <net/checksum.h>
> > +#include <linux/netfilter.h>		/* for union nf_inet_addr */
> > +#include <linux/ipv6.h>			/* for struct ipv6hdr */
> > +#include <net/ipv6.h>			/* for ipv6_addr_copy */
> >  
> >  #ifdef CONFIG_IP_VS_DEBUG
> >  #include <linux/net.h>
> > @@ -259,9 +262,10 @@ struct ip_vs_conn {
> >  	struct list_head        c_list;         /* hashed list heads */
> >  
> >  	/* Protocol, addresses and port numbers */
> > -	__be32                   caddr;          /* client address */
> > -	__be32                   vaddr;          /* virtual address */
> > -	__be32                   daddr;          /* destination address */
> > +	u_int16_t               af;		/* address family */
> 
> 
> I believe that the prefered style is to use __u16 for internal
> kernel structures, u16 for structures exported to userspace
> and not u_int16_t at all.

Actually, sorry, I think I got that backwards.
I think that it should be u16 for internal structures
and __u16 for ones exported to userspace.

> > +	union nf_inet_addr       caddr;          /* client address */
> > +	union nf_inet_addr       vaddr;          /* virtual address */
> > +	union nf_inet_addr       daddr;          /* destination address */
> >  	__be16                   cport;
> >  	__be16                   vport;
> >  	__be16                   dport;
> > @@ -314,8 +318,9 @@ struct ip_vs_service {
> >  	atomic_t		refcnt;   /* reference counter */
> >  	atomic_t		usecnt;   /* use counter */
> >  
> > +	u_int16_t               af;       /* address family */
> 
> ditto (also elsewhere)
> 
> >  	__u16			protocol; /* which protocol (TCP/UDP) */
> > -	__be32			addr;	  /* IP address for virtual service */
> > +	union nf_inet_addr	addr;	  /* IP address for virtual service */
> >  	__be16			port;	  /* port number for the service */
> >  	__u32                   fwmark;   /* firewall mark of the service */
> >  	unsigned		flags;	  /* service status flags */
> > @@ -342,7 +347,8 @@ struct ip_vs_dest {
> >  	struct list_head	n_list;   /* for the dests in the service */
> >  	struct list_head	d_list;   /* for table with all the dests */
> >  
> > -	__be32			addr;		/* IP address of the server */
> > +	u_int16_t		af;		/* address family */
> > +	union nf_inet_addr	addr;		/* IP address of the server */
> >  	__be16			port;		/* port number of the server */
> >  	volatile unsigned	flags;		/* dest status flags */
> >  	atomic_t		conn_flags;	/* flags to copy to conn */
> > @@ -366,7 +372,7 @@ struct ip_vs_dest {
> >  	/* for virtual service */
> >  	struct ip_vs_service	*svc;		/* service it belongs to */
> >  	__u16			protocol;	/* which protocol (TCP/UDP) */
> > -	__be32			vaddr;		/* virtual IP address */
> > +	union nf_inet_addr	vaddr;		/* virtual IP address */
> >  	__be16			vport;		/* virtual port number */
> >  	__u32			vfwmark;	/* firewall mark of service */
> >  };
> > diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
> > index 44a6872..c7f0c2d 100644
> > --- a/net/ipv4/ipvs/ip_vs_conn.c
> > +++ b/net/ipv4/ipvs/ip_vs_conn.c
> > @@ -131,7 +131,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
> >  	int ret;
> >  
> >  	/* Hash by protocol, client address and port */
> > -	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr, cp->cport);
> > +	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.ip, cp->cport);
> >  
> >  	ct_write_lock(hash);
> >  
> > @@ -162,7 +162,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
> >  	int ret;
> >  
> >  	/* unhash it and decrease its reference counter */
> > -	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr, cp->cport);
> > +	hash = ip_vs_conn_hashkey(cp->protocol, cp->caddr.ip, cp->cport);
> >  
> >  	ct_write_lock(hash);
> >  
> > @@ -197,8 +197,8 @@ static inline struct ip_vs_conn *__ip_vs_conn_in_get
> >  	ct_read_lock(hash);
> >  
> >  	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> > -		if (s_addr==cp->caddr && s_port==cp->cport &&
> > -		    d_port==cp->vport && d_addr==cp->vaddr &&
> > +		if (s_addr==cp->caddr.ip && s_port==cp->cport &&
> > +		    d_port==cp->vport && d_addr==cp->vaddr.ip &&
> >  		    ((!s_port) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
> >  		    protocol==cp->protocol) {
> >  			/* HIT */
> > @@ -243,8 +243,8 @@ struct ip_vs_conn *ip_vs_ct_in_get
> >  	ct_read_lock(hash);
> >  
> >  	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> > -		if (s_addr==cp->caddr && s_port==cp->cport &&
> > -		    d_port==cp->vport && d_addr==cp->vaddr &&
> > +		if (s_addr==cp->caddr.ip && s_port==cp->cport &&
> > +		    d_port==cp->vport && d_addr==cp->vaddr.ip &&
> >  		    cp->flags & IP_VS_CONN_F_TEMPLATE &&
> >  		    protocol==cp->protocol) {
> >  			/* HIT */
> > @@ -286,8 +286,8 @@ struct ip_vs_conn *ip_vs_conn_out_get
> >  	ct_read_lock(hash);
> >  
> >  	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
> > -		if (d_addr == cp->caddr && d_port == cp->cport &&
> > -		    s_port == cp->dport && s_addr == cp->daddr &&
> > +		if (d_addr == cp->caddr.ip && d_port == cp->cport &&
> > +		    s_port == cp->dport && s_addr == cp->daddr.ip &&
> >  		    protocol == cp->protocol) {
> >  			/* HIT */
> >  			atomic_inc(&cp->refcnt);
> > @@ -406,9 +406,9 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
> >  		  "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
> >  		  "dest->refcnt:%d\n",
> >  		  ip_vs_proto_name(cp->protocol),
> > -		  NIPQUAD(cp->caddr), ntohs(cp->cport),
> > -		  NIPQUAD(cp->vaddr), ntohs(cp->vport),
> > -		  NIPQUAD(cp->daddr), ntohs(cp->dport),
> > +		  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
> > +		  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
> > +		  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
> >  		  ip_vs_fwd_tag(cp), cp->state,
> >  		  cp->flags, atomic_read(&cp->refcnt),
> >  		  atomic_read(&dest->refcnt));
> > @@ -444,8 +444,8 @@ struct ip_vs_dest *ip_vs_try_bind_dest(struct ip_vs_conn *cp)
> >  	struct ip_vs_dest *dest;
> >  
> >  	if ((cp) && (!cp->dest)) {
> > -		dest = ip_vs_find_dest(cp->daddr, cp->dport,
> > -				       cp->vaddr, cp->vport, cp->protocol);
> > +		dest = ip_vs_find_dest(cp->daddr.ip, cp->dport,
> > +				       cp->vaddr.ip, cp->vport, cp->protocol);
> >  		ip_vs_bind_dest(cp, dest);
> >  		return dest;
> >  	} else
> > @@ -468,9 +468,9 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
> >  		  "d:%u.%u.%u.%u:%d fwd:%c s:%u conn->flags:%X conn->refcnt:%d "
> >  		  "dest->refcnt:%d\n",
> >  		  ip_vs_proto_name(cp->protocol),
> > -		  NIPQUAD(cp->caddr), ntohs(cp->cport),
> > -		  NIPQUAD(cp->vaddr), ntohs(cp->vport),
> > -		  NIPQUAD(cp->daddr), ntohs(cp->dport),
> > +		  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
> > +		  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
> > +		  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
> >  		  ip_vs_fwd_tag(cp), cp->state,
> >  		  cp->flags, atomic_read(&cp->refcnt),
> >  		  atomic_read(&dest->refcnt));
> > @@ -530,9 +530,9 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
> >  			  "protocol %s s:%u.%u.%u.%u:%d v:%u.%u.%u.%u:%d "
> >  			  "-> d:%u.%u.%u.%u:%d\n",
> >  			  ip_vs_proto_name(ct->protocol),
> > -			  NIPQUAD(ct->caddr), ntohs(ct->cport),
> > -			  NIPQUAD(ct->vaddr), ntohs(ct->vport),
> > -			  NIPQUAD(ct->daddr), ntohs(ct->dport));
> > +			  NIPQUAD(ct->caddr.ip), ntohs(ct->cport),
> > +			  NIPQUAD(ct->vaddr.ip), ntohs(ct->vport),
> > +			  NIPQUAD(ct->daddr.ip), ntohs(ct->dport));
> >  
> >  		/*
> >  		 * Invalidate the connection template
> > @@ -641,11 +641,11 @@ ip_vs_conn_new(int proto, __be32 caddr, __be16 cport, __be32 vaddr, __be16 vport
> >  	INIT_LIST_HEAD(&cp->c_list);
> >  	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
> >  	cp->protocol	   = proto;
> > -	cp->caddr	   = caddr;
> > +	cp->caddr.ip	   = caddr;
> >  	cp->cport	   = cport;
> > -	cp->vaddr	   = vaddr;
> > +	cp->vaddr.ip	   = vaddr;
> >  	cp->vport	   = vport;
> > -	cp->daddr          = daddr;
> > +	cp->daddr.ip	   = daddr;
> >  	cp->dport          = dport;
> >  	cp->flags	   = flags;
> >  	spin_lock_init(&cp->lock);
> > @@ -763,9 +763,9 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
> >  		seq_printf(seq,
> >  			"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
> >  				ip_vs_proto_name(cp->protocol),
> > -				ntohl(cp->caddr), ntohs(cp->cport),
> > -				ntohl(cp->vaddr), ntohs(cp->vport),
> > -				ntohl(cp->daddr), ntohs(cp->dport),
> > +				ntohl(cp->caddr.ip), ntohs(cp->cport),
> > +				ntohl(cp->vaddr.ip), ntohs(cp->vport),
> > +				ntohl(cp->daddr.ip), ntohs(cp->dport),
> >  				ip_vs_state_name(cp->protocol, cp->state),
> >  				(cp->timer.expires-jiffies)/HZ);
> >  	}
> > @@ -812,9 +812,9 @@ static int ip_vs_conn_sync_seq_show(struct seq_file *seq, void *v)
> >  		seq_printf(seq,
> >  			"%-3s %08X %04X %08X %04X %08X %04X %-11s %-6s %7lu\n",
> >  				ip_vs_proto_name(cp->protocol),
> > -				ntohl(cp->caddr), ntohs(cp->cport),
> > -				ntohl(cp->vaddr), ntohs(cp->vport),
> > -				ntohl(cp->daddr), ntohs(cp->dport),
> > +				ntohl(cp->caddr.ip), ntohs(cp->cport),
> > +				ntohl(cp->vaddr.ip), ntohs(cp->vport),
> > +				ntohl(cp->daddr.ip), ntohs(cp->dport),
> >  				ip_vs_state_name(cp->protocol, cp->state),
> >  				ip_vs_origin_name(cp->flags),
> >  				(cp->timer.expires-jiffies)/HZ);
> > diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
> > index 9fbf0a6..a07e5b7 100644
> > --- a/net/ipv4/ipvs/ip_vs_core.c
> > +++ b/net/ipv4/ipvs/ip_vs_core.c
> > @@ -232,14 +232,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
> >  						    snet, 0,
> >  						    iph->daddr,
> >  						    ports[1],
> > -						    dest->addr, dest->port,
> > +						    dest->addr.ip, dest->port,
> >  						    IP_VS_CONN_F_TEMPLATE,
> >  						    dest);
> >  			else
> >  				ct = ip_vs_conn_new(iph->protocol,
> >  						    snet, 0,
> >  						    iph->daddr, 0,
> > -						    dest->addr, 0,
> > +						    dest->addr.ip, 0,
> >  						    IP_VS_CONN_F_TEMPLATE,
> >  						    dest);
> >  			if (ct == NULL)
> > @@ -286,14 +286,14 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
> >  				ct = ip_vs_conn_new(IPPROTO_IP,
> >  						    snet, 0,
> >  						    htonl(svc->fwmark), 0,
> > -						    dest->addr, 0,
> > +						    dest->addr.ip, 0,
> >  						    IP_VS_CONN_F_TEMPLATE,
> >  						    dest);
> >  			else
> >  				ct = ip_vs_conn_new(iph->protocol,
> >  						    snet, 0,
> >  						    iph->daddr, 0,
> > -						    dest->addr, 0,
> > +						    dest->addr.ip, 0,
> >  						    IP_VS_CONN_F_TEMPLATE,
> >  						    dest);
> >  			if (ct == NULL)
> > @@ -313,7 +313,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
> >  	cp = ip_vs_conn_new(iph->protocol,
> >  			    iph->saddr, ports[0],
> >  			    iph->daddr, ports[1],
> > -			    dest->addr, dport,
> > +			    dest->addr.ip, dport,
> >  			    0,
> >  			    dest);
> >  	if (cp == NULL) {
> > @@ -380,7 +380,7 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  	cp = ip_vs_conn_new(iph->protocol,
> >  			    iph->saddr, pptr[0],
> >  			    iph->daddr, pptr[1],
> > -			    dest->addr, dest->port?dest->port:pptr[1],
> > +			    dest->addr.ip, dest->port?dest->port:pptr[1],
> >  			    0,
> >  			    dest);
> >  	if (cp == NULL)
> > @@ -389,9 +389,9 @@ ip_vs_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  	IP_VS_DBG(6, "Schedule fwd:%c c:%u.%u.%u.%u:%u v:%u.%u.%u.%u:%u "
> >  		  "d:%u.%u.%u.%u:%u conn->flags:%X conn->refcnt:%d\n",
> >  		  ip_vs_fwd_tag(cp),
> > -		  NIPQUAD(cp->caddr), ntohs(cp->cport),
> > -		  NIPQUAD(cp->vaddr), ntohs(cp->vport),
> > -		  NIPQUAD(cp->daddr), ntohs(cp->dport),
> > +		  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
> > +		  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
> > +		  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
> >  		  cp->flags, atomic_read(&cp->refcnt));
> >  
> >  	ip_vs_conn_stats(cp, svc);
> > @@ -526,14 +526,14 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
> >  	struct iphdr *ciph	 = (struct iphdr *)(icmph + 1);
> >  
> >  	if (inout) {
> > -		iph->saddr = cp->vaddr;
> > +		iph->saddr = cp->vaddr.ip;
> >  		ip_send_check(iph);
> > -		ciph->daddr = cp->vaddr;
> > +		ciph->daddr = cp->vaddr.ip;
> >  		ip_send_check(ciph);
> >  	} else {
> > -		iph->daddr = cp->daddr;
> > +		iph->daddr = cp->daddr.ip;
> >  		ip_send_check(iph);
> > -		ciph->saddr = cp->daddr;
> > +		ciph->saddr = cp->daddr.ip;
> >  		ip_send_check(ciph);
> >  	}
> >  
> > @@ -762,7 +762,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
> >  	/* mangle the packet */
> >  	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
> >  		goto drop;
> > -	ip_hdr(skb)->saddr = cp->vaddr;
> > +	ip_hdr(skb)->saddr = cp->vaddr.ip;
> >  	ip_send_check(ip_hdr(skb));
> >  
> >  	/* For policy routing, packets originating from this
> > diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> > index ede101e..47644f3 100644
> > --- a/net/ipv4/ipvs/ip_vs_ctl.c
> > +++ b/net/ipv4/ipvs/ip_vs_ctl.c
> > @@ -317,7 +317,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
> >  		/*
> >  		 *  Hash it by <protocol,addr,port> in ip_vs_svc_table
> >  		 */
> > -		hash = ip_vs_svc_hashkey(svc->protocol, svc->addr, svc->port);
> > +		hash = ip_vs_svc_hashkey(svc->protocol, svc->addr.ip, svc->port);
> >  		list_add(&svc->s_list, &ip_vs_svc_table[hash]);
> >  	} else {
> >  		/*
> > @@ -373,7 +373,7 @@ __ip_vs_service_get(__u16 protocol, __be32 vaddr, __be16 vport)
> >  	hash = ip_vs_svc_hashkey(protocol, vaddr, vport);
> >  
> >  	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
> > -		if ((svc->addr == vaddr)
> > +		if ((svc->addr.ip == vaddr)
> >  		    && (svc->port == vport)
> >  		    && (svc->protocol == protocol)) {
> >  			/* HIT */
> > @@ -503,7 +503,7 @@ static int ip_vs_rs_hash(struct ip_vs_dest *dest)
> >  	 *	Hash by proto,addr,port,
> >  	 *	which are the parameters of the real service.
> >  	 */
> > -	hash = ip_vs_rs_hashkey(dest->addr, dest->port);
> > +	hash = ip_vs_rs_hashkey(dest->addr.ip, dest->port);
> >  	list_add(&dest->d_list, &ip_vs_rtable[hash]);
> >  
> >  	return 1;
> > @@ -543,7 +543,7 @@ ip_vs_lookup_real_service(__u16 protocol, __be32 daddr, __be16 dport)
> >  
> >  	read_lock(&__ip_vs_rs_lock);
> >  	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
> > -		if ((dest->addr == daddr)
> > +		if ((dest->addr.ip == daddr)
> >  		    && (dest->port == dport)
> >  		    && ((dest->protocol == protocol) ||
> >  			dest->vfwmark)) {
> > @@ -569,7 +569,7 @@ ip_vs_lookup_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
> >  	 * Find the destination for the given service
> >  	 */
> >  	list_for_each_entry(dest, &svc->destinations, n_list) {
> > -		if ((dest->addr == daddr) && (dest->port == dport)) {
> > +		if ((dest->addr.ip == daddr) && (dest->port == dport)) {
> >  			/* HIT */
> >  			return dest;
> >  		}
> > @@ -626,14 +626,14 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
> >  		IP_VS_DBG(3, "Destination %u/%u.%u.%u.%u:%u still in trash, "
> >  			  "dest->refcnt=%d\n",
> >  			  dest->vfwmark,
> > -			  NIPQUAD(dest->addr), ntohs(dest->port),
> > +			  NIPQUAD(dest->addr.ip), ntohs(dest->port),
> >  			  atomic_read(&dest->refcnt));
> > -		if (dest->addr == daddr &&
> > +		if (dest->addr.ip == daddr &&
> >  		    dest->port == dport &&
> >  		    dest->vfwmark == svc->fwmark &&
> >  		    dest->protocol == svc->protocol &&
> >  		    (svc->fwmark ||
> > -		     (dest->vaddr == svc->addr &&
> > +		     (dest->vaddr.ip == svc->addr.ip &&
> >  		      dest->vport == svc->port))) {
> >  			/* HIT */
> >  			return dest;
> > @@ -646,7 +646,7 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, __be32 daddr, __be16 dport)
> >  			IP_VS_DBG(3, "Removing destination %u/%u.%u.%u.%u:%u "
> >  				  "from trash\n",
> >  				  dest->vfwmark,
> > -				  NIPQUAD(dest->addr), ntohs(dest->port));
> > +				  NIPQUAD(dest->addr.ip), ntohs(dest->port));
> >  			list_del(&dest->n_list);
> >  			ip_vs_dst_reset(dest);
> >  			__ip_vs_unbind_svc(dest);
> > @@ -779,10 +779,10 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest,
> >  	}
> >  
> >  	dest->protocol = svc->protocol;
> > -	dest->vaddr = svc->addr;
> > +	dest->vaddr.ip = svc->addr.ip;
> >  	dest->vport = svc->port;
> >  	dest->vfwmark = svc->fwmark;
> > -	dest->addr = udest->addr;
> > +	dest->addr.ip = udest->addr;
> >  	dest->port = udest->port;
> >  
> >  	atomic_set(&dest->activeconns, 0);
> > @@ -847,7 +847,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
> >  			  NIPQUAD(daddr), ntohs(dport),
> >  			  atomic_read(&dest->refcnt),
> >  			  dest->vfwmark,
> > -			  NIPQUAD(dest->vaddr),
> > +			  NIPQUAD(dest->vaddr.ip),
> >  			  ntohs(dest->vport));
> >  		__ip_vs_update_dest(svc, dest, udest);
> >  
> > @@ -993,7 +993,7 @@ static void __ip_vs_del_dest(struct ip_vs_dest *dest)
> >  	} else {
> >  		IP_VS_DBG(3, "Moving dest %u.%u.%u.%u:%u into trash, "
> >  			  "dest->refcnt=%d\n",
> > -			  NIPQUAD(dest->addr), ntohs(dest->port),
> > +			  NIPQUAD(dest->addr.ip), ntohs(dest->port),
> >  			  atomic_read(&dest->refcnt));
> >  		list_add(&dest->n_list, &ip_vs_dest_trash);
> >  		atomic_inc(&dest->refcnt);
> > @@ -1101,7 +1101,7 @@ ip_vs_add_service(struct ip_vs_service_user *u, struct ip_vs_service **svc_p)
> >  	atomic_set(&svc->refcnt, 0);
> >  
> >  	svc->protocol = u->protocol;
> > -	svc->addr = u->addr;
> > +	svc->addr.ip = u->addr;
> >  	svc->port = u->port;
> >  	svc->fwmark = u->fwmark;
> >  	svc->flags = u->flags;
> > @@ -1751,7 +1751,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
> >  		if (iter->table == ip_vs_svc_table)
> >  			seq_printf(seq, "%s  %08X:%04X %s ",
> >  				   ip_vs_proto_name(svc->protocol),
> > -				   ntohl(svc->addr),
> > +				   ntohl(svc->addr.ip),
> >  				   ntohs(svc->port),
> >  				   svc->scheduler->name);
> >  		else
> > @@ -1768,7 +1768,7 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
> >  		list_for_each_entry(dest, &svc->destinations, n_list) {
> >  			seq_printf(seq,
> >  				   "  -> %08X:%04X      %-7s %-6d %-10d %-10d\n",
> > -				   ntohl(dest->addr), ntohs(dest->port),
> > +				   ntohl(dest->addr.ip), ntohs(dest->port),
> >  				   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
> >  				   atomic_read(&dest->weight),
> >  				   atomic_read(&dest->activeconns),
> > @@ -2040,7 +2040,7 @@ static void
> >  ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
> >  {
> >  	dst->protocol = src->protocol;
> > -	dst->addr = src->addr;
> > +	dst->addr = src->addr.ip;
> >  	dst->port = src->port;
> >  	dst->fwmark = src->fwmark;
> >  	strlcpy(dst->sched_name, src->scheduler->name, sizeof(dst->sched_name));
> > @@ -2114,7 +2114,7 @@ __ip_vs_get_dest_entries(const struct ip_vs_get_dests *get,
> >  			if (count >= get->num_dests)
> >  				break;
> >  
> > -			entry.addr = dest->addr;
> > +			entry.addr = dest->addr.ip;
> >  			entry.port = dest->port;
> >  			entry.conn_flags = atomic_read(&dest->conn_flags);
> >  			entry.weight = atomic_read(&dest->weight);
> > diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
> > index fa66824..9f9d795 100644
> > --- a/net/ipv4/ipvs/ip_vs_dh.c
> > +++ b/net/ipv4/ipvs/ip_vs_dh.c
> > @@ -218,7 +218,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  	IP_VS_DBG(6, "DH: destination IP address %u.%u.%u.%u "
> >  		  "--> server %u.%u.%u.%u:%d\n",
> >  		  NIPQUAD(iph->daddr),
> > -		  NIPQUAD(dest->addr),
> > +		  NIPQUAD(dest->addr.ip),
> >  		  ntohs(dest->port));
> >  
> >  	return dest;
> > diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
> > index c1c758e..bfe5d70 100644
> > --- a/net/ipv4/ipvs/ip_vs_ftp.c
> > +++ b/net/ipv4/ipvs/ip_vs_ftp.c
> > @@ -172,17 +172,17 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  
> >  		IP_VS_DBG(7, "PASV response (%u.%u.%u.%u:%d) -> "
> >  			  "%u.%u.%u.%u:%d detected\n",
> > -			  NIPQUAD(from), ntohs(port), NIPQUAD(cp->caddr), 0);
> > +			  NIPQUAD(from), ntohs(port), NIPQUAD(cp->caddr.ip), 0);
> >  
> >  		/*
> >  		 * Now update or create an connection entry for it
> >  		 */
> >  		n_cp = ip_vs_conn_out_get(iph->protocol, from, port,
> > -					  cp->caddr, 0);
> > +					  cp->caddr.ip, 0);
> >  		if (!n_cp) {
> >  			n_cp = ip_vs_conn_new(IPPROTO_TCP,
> > -					      cp->caddr, 0,
> > -					      cp->vaddr, port,
> > +					      cp->caddr.ip, 0,
> > +					      cp->vaddr.ip, port,
> >  					      from, port,
> >  					      IP_VS_CONN_F_NO_CPORT,
> >  					      cp->dest);
> > @@ -196,7 +196,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  		/*
> >  		 * Replace the old passive address with the new one
> >  		 */
> > -		from = n_cp->vaddr;
> > +		from = n_cp->vaddr.ip;
> >  		port = n_cp->vport;
> >  		sprintf(buf,"%d,%d,%d,%d,%d,%d", NIPQUAD(from),
> >  			(ntohs(port)>>8)&255, ntohs(port)&255);
> > @@ -306,16 +306,16 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  	 */
> >  	IP_VS_DBG(7, "protocol %s %u.%u.%u.%u:%d %u.%u.%u.%u:%d\n",
> >  		  ip_vs_proto_name(iph->protocol),
> > -		  NIPQUAD(to), ntohs(port), NIPQUAD(cp->vaddr), 0);
> > +		  NIPQUAD(to), ntohs(port), NIPQUAD(cp->vaddr.ip), 0);
> >  
> >  	n_cp = ip_vs_conn_in_get(iph->protocol,
> >  				 to, port,
> > -				 cp->vaddr, htons(ntohs(cp->vport)-1));
> > +				 cp->vaddr.ip, htons(ntohs(cp->vport)-1));
> >  	if (!n_cp) {
> >  		n_cp = ip_vs_conn_new(IPPROTO_TCP,
> >  				      to, port,
> > -				      cp->vaddr, htons(ntohs(cp->vport)-1),
> > -				      cp->daddr, htons(ntohs(cp->dport)-1),
> > +				      cp->vaddr.ip, htons(ntohs(cp->vport)-1),
> > +				      cp->daddr.ip, htons(ntohs(cp->dport)-1),
> >  				      0,
> >  				      cp->dest);
> >  		if (!n_cp)
> > diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
> > index d2a43aa..69309ed 100644
> > --- a/net/ipv4/ipvs/ip_vs_lblc.c
> > +++ b/net/ipv4/ipvs/ip_vs_lblc.c
> > @@ -422,7 +422,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
> >  
> >  	IP_VS_DBG(6, "LBLC: server %d.%d.%d.%d:%d "
> >  		  "activeconns %d refcnt %d weight %d overhead %d\n",
> > -		  NIPQUAD(least->addr), ntohs(least->port),
> > +		  NIPQUAD(least->addr.ip), ntohs(least->port),
> >  		  atomic_read(&least->activeconns),
> >  		  atomic_read(&least->refcnt),
> >  		  atomic_read(&least->weight), loh);
> > @@ -506,7 +506,7 @@ out:
> >  	IP_VS_DBG(6, "LBLC: destination IP address %u.%u.%u.%u "
> >  		  "--> server %u.%u.%u.%u:%d\n",
> >  		  NIPQUAD(iph->daddr),
> > -		  NIPQUAD(dest->addr),
> > +		  NIPQUAD(dest->addr.ip),
> >  		  ntohs(dest->port));
> >  
> >  	return dest;
> > diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
> > index 375a1ff..51c746e 100644
> > --- a/net/ipv4/ipvs/ip_vs_lblcr.c
> > +++ b/net/ipv4/ipvs/ip_vs_lblcr.c
> > @@ -204,7 +204,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
> >  
> >  	IP_VS_DBG(6, "ip_vs_dest_set_min: server %d.%d.%d.%d:%d "
> >  		  "activeconns %d refcnt %d weight %d overhead %d\n",
> > -		  NIPQUAD(least->addr), ntohs(least->port),
> > +		  NIPQUAD(least->addr.ip), ntohs(least->port),
> >  		  atomic_read(&least->activeconns),
> >  		  atomic_read(&least->refcnt),
> >  		  atomic_read(&least->weight), loh);
> > @@ -250,7 +250,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
> >  
> >  	IP_VS_DBG(6, "ip_vs_dest_set_max: server %d.%d.%d.%d:%d "
> >  		  "activeconns %d refcnt %d weight %d overhead %d\n",
> > -		  NIPQUAD(most->addr), ntohs(most->port),
> > +		  NIPQUAD(most->addr.ip), ntohs(most->port),
> >  		  atomic_read(&most->activeconns),
> >  		  atomic_read(&most->refcnt),
> >  		  atomic_read(&most->weight), moh);
> > @@ -598,7 +598,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc, struct iphdr *iph)
> >  
> >  	IP_VS_DBG(6, "LBLCR: server %d.%d.%d.%d:%d "
> >  		  "activeconns %d refcnt %d weight %d overhead %d\n",
> > -		  NIPQUAD(least->addr), ntohs(least->port),
> > +		  NIPQUAD(least->addr.ip), ntohs(least->port),
> >  		  atomic_read(&least->activeconns),
> >  		  atomic_read(&least->refcnt),
> >  		  atomic_read(&least->weight), loh);
> > @@ -706,7 +706,7 @@ out:
> >  	IP_VS_DBG(6, "LBLCR: destination IP address %u.%u.%u.%u "
> >  		  "--> server %u.%u.%u.%u:%d\n",
> >  		  NIPQUAD(iph->daddr),
> > -		  NIPQUAD(dest->addr),
> > +		  NIPQUAD(dest->addr.ip),
> >  		  ntohs(dest->port));
> >  
> >  	return dest;
> > diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
> > index 2c3de1b..551d293 100644
> > --- a/net/ipv4/ipvs/ip_vs_lc.c
> > +++ b/net/ipv4/ipvs/ip_vs_lc.c
> > @@ -68,7 +68,7 @@ ip_vs_lc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  
> >  	if (least)
> >  	IP_VS_DBG(6, "LC: server %u.%u.%u.%u:%u activeconns %d inactconns %d\n",
> > -		  NIPQUAD(least->addr), ntohs(least->port),
> > +		  NIPQUAD(least->addr.ip), ntohs(least->port),
> >  		  atomic_read(&least->activeconns),
> >  		  atomic_read(&least->inactconns));
> >  
> > diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
> > index 5330d5a..aa0e32a 100644
> > --- a/net/ipv4/ipvs/ip_vs_nq.c
> > +++ b/net/ipv4/ipvs/ip_vs_nq.c
> > @@ -101,7 +101,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >    out:
> >  	IP_VS_DBG(6, "NQ: server %u.%u.%u.%u:%u "
> >  		  "activeconns %d refcnt %d weight %d overhead %d\n",
> > -		  NIPQUAD(least->addr), ntohs(least->port),
> > +		  NIPQUAD(least->addr.ip), ntohs(least->port),
> >  		  atomic_read(&least->activeconns),
> >  		  atomic_read(&least->refcnt),
> >  		  atomic_read(&least->weight), loh);
> > diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
> > index d0ea467..15860e1 100644
> > --- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
> > +++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
> > @@ -147,7 +147,7 @@ tcp_snat_handler(struct sk_buff *skb,
> >  	/* Adjust TCP checksums */
> >  	if (!cp->app) {
> >  		/* Only port and addr are changed, do fast csum update */
> > -		tcp_fast_csum_update(tcph, cp->daddr, cp->vaddr,
> > +		tcp_fast_csum_update(tcph, cp->daddr.ip, cp->vaddr.ip,
> >  				     cp->dport, cp->vport);
> >  		if (skb->ip_summed == CHECKSUM_COMPLETE)
> >  			skb->ip_summed = CHECKSUM_NONE;
> > @@ -155,7 +155,7 @@ tcp_snat_handler(struct sk_buff *skb,
> >  		/* full checksum calculation */
> >  		tcph->check = 0;
> >  		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
> > -		tcph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
> > +		tcph->check = csum_tcpudp_magic(cp->vaddr.ip, cp->caddr.ip,
> >  						skb->len - tcphoff,
> >  						cp->protocol, skb->csum);
> >  		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
> > @@ -198,7 +198,7 @@ tcp_dnat_handler(struct sk_buff *skb,
> >  	 */
> >  	if (!cp->app) {
> >  		/* Only port and addr are changed, do fast csum update */
> > -		tcp_fast_csum_update(tcph, cp->vaddr, cp->daddr,
> > +		tcp_fast_csum_update(tcph, cp->vaddr.ip, cp->daddr.ip,
> >  				     cp->vport, cp->dport);
> >  		if (skb->ip_summed == CHECKSUM_COMPLETE)
> >  			skb->ip_summed = CHECKSUM_NONE;
> > @@ -206,7 +206,7 @@ tcp_dnat_handler(struct sk_buff *skb,
> >  		/* full checksum calculation */
> >  		tcph->check = 0;
> >  		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
> > -		tcph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
> > +		tcph->check = csum_tcpudp_magic(cp->caddr.ip, cp->daddr.ip,
> >  						skb->len - tcphoff,
> >  						cp->protocol, skb->csum);
> >  		skb->ip_summed = CHECKSUM_UNNECESSARY;
> > @@ -427,8 +427,8 @@ set_tcp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
> >  			  th->fin? 'F' : '.',
> >  			  th->ack? 'A' : '.',
> >  			  th->rst? 'R' : '.',
> > -			  NIPQUAD(cp->daddr), ntohs(cp->dport),
> > -			  NIPQUAD(cp->caddr), ntohs(cp->cport),
> > +			  NIPQUAD(cp->daddr.ip), ntohs(cp->dport),
> > +			  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
> >  			  tcp_state_name(cp->state),
> >  			  tcp_state_name(new_state),
> >  			  atomic_read(&cp->refcnt));
> > @@ -549,8 +549,8 @@ tcp_app_conn_bind(struct ip_vs_conn *cp)
> >  			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
> >  				  "%u.%u.%u.%u:%u to app %s on port %u\n",
> >  				  __func__,
> > -				  NIPQUAD(cp->caddr), ntohs(cp->cport),
> > -				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
> > +				  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
> > +				  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
> >  				  inc->name, ntohs(inc->port));
> >  			cp->app = inc;
> >  			if (inc->init_conn)
> > diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
> > index c6be5d5..8dfad5d 100644
> > --- a/net/ipv4/ipvs/ip_vs_proto_udp.c
> > +++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
> > @@ -158,7 +158,7 @@ udp_snat_handler(struct sk_buff *skb,
> >  	 */
> >  	if (!cp->app && (udph->check != 0)) {
> >  		/* Only port and addr are changed, do fast csum update */
> > -		udp_fast_csum_update(udph, cp->daddr, cp->vaddr,
> > +		udp_fast_csum_update(udph, cp->daddr.ip, cp->vaddr.ip,
> >  				     cp->dport, cp->vport);
> >  		if (skb->ip_summed == CHECKSUM_COMPLETE)
> >  			skb->ip_summed = CHECKSUM_NONE;
> > @@ -166,7 +166,7 @@ udp_snat_handler(struct sk_buff *skb,
> >  		/* full checksum calculation */
> >  		udph->check = 0;
> >  		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
> > -		udph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
> > +		udph->check = csum_tcpudp_magic(cp->vaddr.ip, cp->caddr.ip,
> >  						skb->len - udphoff,
> >  						cp->protocol, skb->csum);
> >  		if (udph->check == 0)
> > @@ -211,7 +211,7 @@ udp_dnat_handler(struct sk_buff *skb,
> >  	 */
> >  	if (!cp->app && (udph->check != 0)) {
> >  		/* Only port and addr are changed, do fast csum update */
> > -		udp_fast_csum_update(udph, cp->vaddr, cp->daddr,
> > +		udp_fast_csum_update(udph, cp->vaddr.ip, cp->daddr.ip,
> >  				     cp->vport, cp->dport);
> >  		if (skb->ip_summed == CHECKSUM_COMPLETE)
> >  			skb->ip_summed = CHECKSUM_NONE;
> > @@ -219,7 +219,7 @@ udp_dnat_handler(struct sk_buff *skb,
> >  		/* full checksum calculation */
> >  		udph->check = 0;
> >  		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
> > -		udph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
> > +		udph->check = csum_tcpudp_magic(cp->caddr.ip, cp->daddr.ip,
> >  						skb->len - udphoff,
> >  						cp->protocol, skb->csum);
> >  		if (udph->check == 0)
> > @@ -343,8 +343,8 @@ static int udp_app_conn_bind(struct ip_vs_conn *cp)
> >  			IP_VS_DBG(9, "%s: Binding conn %u.%u.%u.%u:%u->"
> >  				  "%u.%u.%u.%u:%u to app %s on port %u\n",
> >  				  __func__,
> > -				  NIPQUAD(cp->caddr), ntohs(cp->cport),
> > -				  NIPQUAD(cp->vaddr), ntohs(cp->vport),
> > +				  NIPQUAD(cp->caddr.ip), ntohs(cp->cport),
> > +				  NIPQUAD(cp->vaddr.ip), ntohs(cp->vport),
> >  				  inc->name, ntohs(inc->port));
> >  			cp->app = inc;
> >  			if (inc->init_conn)
> > diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
> > index f749291..27f0b62 100644
> > --- a/net/ipv4/ipvs/ip_vs_rr.c
> > +++ b/net/ipv4/ipvs/ip_vs_rr.c
> > @@ -76,7 +76,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  	write_unlock(&svc->sched_lock);
> >  	IP_VS_DBG(6, "RR: server %u.%u.%u.%u:%u "
> >  		  "activeconns %d refcnt %d weight %d\n",
> > -		  NIPQUAD(dest->addr), ntohs(dest->port),
> > +		  NIPQUAD(dest->addr.ip), ntohs(dest->port),
> >  		  atomic_read(&dest->activeconns),
> >  		  atomic_read(&dest->refcnt), atomic_read(&dest->weight));
> >  
> > diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
> > index 53f73be..38b574b 100644
> > --- a/net/ipv4/ipvs/ip_vs_sed.c
> > +++ b/net/ipv4/ipvs/ip_vs_sed.c
> > @@ -103,7 +103,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  
> >  	IP_VS_DBG(6, "SED: server %u.%u.%u.%u:%u "
> >  		  "activeconns %d refcnt %d weight %d overhead %d\n",
> > -		  NIPQUAD(least->addr), ntohs(least->port),
> > +		  NIPQUAD(least->addr.ip), ntohs(least->port),
> >  		  atomic_read(&least->activeconns),
> >  		  atomic_read(&least->refcnt),
> >  		  atomic_read(&least->weight), loh);
> > diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
> > index 7b979e2..c9e54e2 100644
> > --- a/net/ipv4/ipvs/ip_vs_sh.c
> > +++ b/net/ipv4/ipvs/ip_vs_sh.c
> > @@ -215,7 +215,7 @@ ip_vs_sh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  	IP_VS_DBG(6, "SH: source IP address %u.%u.%u.%u "
> >  		  "--> server %u.%u.%u.%u:%d\n",
> >  		  NIPQUAD(iph->saddr),
> > -		  NIPQUAD(dest->addr),
> > +		  NIPQUAD(dest->addr.ip),
> >  		  ntohs(dest->port));
> >  
> >  	return dest;
> > diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
> > index a652da2..2cf47b2 100644
> > --- a/net/ipv4/ipvs/ip_vs_sync.c
> > +++ b/net/ipv4/ipvs/ip_vs_sync.c
> > @@ -256,9 +256,9 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
> >  	s->cport = cp->cport;
> >  	s->vport = cp->vport;
> >  	s->dport = cp->dport;
> > -	s->caddr = cp->caddr;
> > -	s->vaddr = cp->vaddr;
> > -	s->daddr = cp->daddr;
> > +	s->caddr = cp->caddr.ip;
> > +	s->vaddr = cp->vaddr.ip;
> > +	s->daddr = cp->daddr.ip;
> >  	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
> >  	s->state = htons(cp->state);
> >  	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
> > diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
> > index df7ad8d..09fd993 100644
> > --- a/net/ipv4/ipvs/ip_vs_wlc.c
> > +++ b/net/ipv4/ipvs/ip_vs_wlc.c
> > @@ -91,7 +91,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  
> >  	IP_VS_DBG(6, "WLC: server %u.%u.%u.%u:%u "
> >  		  "activeconns %d refcnt %d weight %d overhead %d\n",
> > -		  NIPQUAD(least->addr), ntohs(least->port),
> > +		  NIPQUAD(least->addr.ip), ntohs(least->port),
> >  		  atomic_read(&least->activeconns),
> >  		  atomic_read(&least->refcnt),
> >  		  atomic_read(&least->weight), loh);
> > diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
> > index 0d86a79..19c49b2 100644
> > --- a/net/ipv4/ipvs/ip_vs_wrr.c
> > +++ b/net/ipv4/ipvs/ip_vs_wrr.c
> > @@ -197,7 +197,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb)
> >  
> >  	IP_VS_DBG(6, "WRR: server %u.%u.%u.%u:%u "
> >  		  "activeconns %d refcnt %d weight %d\n",
> > -		  NIPQUAD(dest->addr), ntohs(dest->port),
> > +		  NIPQUAD(dest->addr.ip), ntohs(dest->port),
> >  		  atomic_read(&dest->activeconns),
> >  		  atomic_read(&dest->refcnt),
> >  		  atomic_read(&dest->weight));
> > diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
> > index 9892d4a..88199c9 100644
> > --- a/net/ipv4/ipvs/ip_vs_xmit.c
> > +++ b/net/ipv4/ipvs/ip_vs_xmit.c
> > @@ -71,7 +71,7 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
> >  				.oif = 0,
> >  				.nl_u = {
> >  					.ip4_u = {
> > -						.daddr = dest->addr,
> > +						.daddr = dest->addr.ip,
> >  						.saddr = 0,
> >  						.tos = rtos, } },
> >  			};
> > @@ -80,12 +80,12 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
> >  				spin_unlock(&dest->dst_lock);
> >  				IP_VS_DBG_RL("ip_route_output error, "
> >  					     "dest: %u.%u.%u.%u\n",
> > -					     NIPQUAD(dest->addr));
> > +					     NIPQUAD(dest->addr.ip));
> >  				return NULL;
> >  			}
> >  			__ip_vs_dst_set(dest, rtos, dst_clone(&rt->u.dst));
> >  			IP_VS_DBG(10, "new dst %u.%u.%u.%u, refcnt=%d, rtos=%X\n",
> > -				  NIPQUAD(dest->addr),
> > +				  NIPQUAD(dest->addr.ip),
> >  				  atomic_read(&rt->u.dst.__refcnt), rtos);
> >  		}
> >  		spin_unlock(&dest->dst_lock);
> > @@ -94,14 +94,14 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
> >  			.oif = 0,
> >  			.nl_u = {
> >  				.ip4_u = {
> > -					.daddr = cp->daddr,
> > +					.daddr = cp->daddr.ip,
> >  					.saddr = 0,
> >  					.tos = rtos, } },
> >  		};
> >  
> >  		if (ip_route_output_key(&init_net, &rt, &fl)) {
> >  			IP_VS_DBG_RL("ip_route_output error, dest: "
> > -				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr));
> > +				     "%u.%u.%u.%u\n", NIPQUAD(cp->daddr.ip));
> >  			return NULL;
> >  		}
> >  	}
> > @@ -264,7 +264,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
> >  	/* mangle the packet */
> >  	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
> >  		goto tx_error;
> > -	ip_hdr(skb)->daddr = cp->daddr;
> > +	ip_hdr(skb)->daddr = cp->daddr.ip;
> >  	ip_send_check(ip_hdr(skb));
> >  
> >  	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
> > -- 
> > 1.5.4.5
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
