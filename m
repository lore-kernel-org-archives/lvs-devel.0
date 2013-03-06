From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 11/12] ipvs: reorder keys in connection
 structure
Date: Wed, 6 Mar 2013 23:01:50 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303062246480.1899@ja.ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>  <1362559342-18784-12-git-send-email-ja@ssi.bg> <1362563014.17102.63.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1362563014.17102.63.camel@hawk.mlab.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Wed, 6 Mar 2013, Hans Schillstrom wrote:

> Hi Julian
> Great job you have done !
> I'll test it immediate...

	Thanks, it would be good to catch the problems
in early phase...

> On Wed, 2013-03-06 at 10:42 +0200, Julian Anastasov wrote:
> > 	__ip_vs_conn_in_get and ip_vs_conn_out_get are
> > hot places. Optimize them, so that ports are matched first.
> > By moving net and fwmark below, on 32-bit arch we can fit
> > caddr in 32-byte cache line and all addresses in 64-byte
> > cache line.
> 
> Earlier I made some rearrangements like the one you have made.
> My conclusion at that time was that the best gain was to have
> fwmark and net within the first 64 bytes, and move daddr to the next
> cache line.

	But fwmark is used only for lookups in backup
server. The net field is checked first only in
ip_vs_ct_in_get (on scheduling), it can be optimized too.
Modern CPUs have 64-byte cache line and may be the
places of these fields do not play much because checking
the two ports is enough to differentiate most of the
connections. The addresses play when ports do not
differ, i.e. mostly for persistent connections. So,
on 64-byte cache line it would be more difficult to
see any difference.

> I uesd UDP at ~7Gbit/sec and 256k source address into a x86_64 machine,
> and a 50/50 mix of fwmarks and port in that tests. 
> 
> I guess that you have made similar test, and even take
> ip_vs_conn_out_get() into your calculations ?

	No, I have only virtual boxes for tests...

> Regards
> Hans
> 
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  include/net/ip_vs.h             |   12 ++++++------
> >  net/netfilter/ipvs/ip_vs_conn.c |    8 ++++----
> >  2 files changed, 10 insertions(+), 10 deletions(-)
> > 
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index 9059360..2bc30e6 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -566,20 +566,19 @@ struct ip_vs_conn_param {
> >   */
> >  struct ip_vs_conn {
> >  	struct hlist_node	c_list;         /* hashed list heads */
> > -#ifdef CONFIG_NET_NS
> > -	struct net              *net;           /* Name space */
> > -#endif
> >  	/* Protocol, addresses and port numbers */
> > -	u16                     af;             /* address family */
> >  	__be16                  cport;
> > -	__be16                  vport;
> >  	__be16                  dport;
> > -	__u32                   fwmark;         /* Fire wall mark from skb */
> > +	__be16                  vport;
> > +	u16			af;		/* address family */
> >  	union nf_inet_addr      caddr;          /* client address */
> >  	union nf_inet_addr      vaddr;          /* virtual address */
> >  	union nf_inet_addr      daddr;          /* destination address */
> >  	volatile __u32          flags;          /* status flags */
> >  	__u16                   protocol;       /* Which protocol (TCP/UDP) */
> > +#ifdef CONFIG_NET_NS
> > +	struct net              *net;           /* Name space */
> > +#endif
> >  
> >  	/* counter and timer */
> >  	atomic_t		refcnt;		/* reference count */
> > @@ -593,6 +592,7 @@ struct ip_vs_conn {
> >  						 * state transition triggerd
> >  						 * synchronization
> >  						 */
> > +	__u32			fwmark;		/* Fire wall mark from skb */
> >  	unsigned long		sync_endtime;	/* jiffies + sent_retries */
> >  
> >  	/* Control members */
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index b0cd2be..a4d8ec5 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -265,8 +265,8 @@ __ip_vs_conn_in_get(const struct ip_vs_conn_param *p)
> >  	rcu_read_lock();
> >  
> >  	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
> > -		if (cp->af == p->af &&
> > -		    p->cport == cp->cport && p->vport == cp->vport &&
> > +		if (p->cport == cp->cport && p->vport == cp->vport &&
> > +		    cp->af == p->af &&
> >  		    ip_vs_addr_equal(p->af, p->caddr, &cp->caddr) &&
> >  		    ip_vs_addr_equal(p->af, p->vaddr, &cp->vaddr) &&
> >  		    ((!p->cport) ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
> > @@ -404,8 +404,8 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
> >  	rcu_read_lock();
> >  
> >  	hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
> > -		if (cp->af == p->af &&
> > -		    p->vport == cp->cport && p->cport == cp->dport &&
> > +		if (p->vport == cp->cport && p->cport == cp->dport &&
> > +		    cp->af == p->af &&
> >  		    ip_vs_addr_equal(p->af, p->vaddr, &cp->caddr) &&
> >  		    ip_vs_addr_equal(p->af, p->caddr, &cp->daddr) &&
> >  		    p->protocol == cp->protocol &&

Regards

--
Julian Anastasov <ja@ssi.bg>
