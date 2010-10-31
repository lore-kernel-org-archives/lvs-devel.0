From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 4/4] IPVS: Backup, Change sending to Version 1 format
Date: Sun, 31 Oct 2010 10:09:02 +0900
Message-ID: <20101031010900.GA4525@verge.net.au>
References: <1288354599-10919-4-git-send-email-hans.schillstrom@ericsson.com>
 <20101030065031.GK26727@verge.net.au>
 <201010301353.17889.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010301353.17889.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

On Sat, Oct 30, 2010 at 01:53:17PM +0200, Hans Schillstrom wrote:
> 
> On Saturday, October 30, 2010 08:50:31 Simon Horman wrote:
> > On Fri, Oct 29, 2010 at 02:16:39PM +0200, Hans Schillstrom wrote:
> > > Enable sending and removal of version 0 sending
> > > Affected functions,
> > > 
> > > ip_vs_sync_buff_create()
> > > ip_vs_sync_conn()
> > > 
> > > ip_vs_core.c removal of IPv4 check.
> > > 
> > > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> > 
> > [ snip ]
> > 
> > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > > index 5aa8e04..00f0fd3 100644
> > > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > 
> > [ snip ]
> > 
> > > @@ -376,36 +420,63 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
> > >  		}
> > >  	}
> > >  
> > > -	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
> > > -		SIMPLE_CONN_SIZE;
> > > +
> > >  	m = curr_sb->mesg;
> > > -	s = (struct ip_vs_sync_conn_v0 *)curr_sb->head;
> > > +	s = (union ip_vs_sync_conn *)curr_sb->head;
> > > +	p = (char *)s;
> > >  
> > > +	/* Set message type */
> > > +	s->v4.type = (cp->af == AF_INET6 ? STYPE_INET6 : 0 );
> > >  	/* copy members */
> > > -	s->protocol = cp->protocol;
> > > -	s->cport = cp->cport;
> > > -	s->vport = cp->vport;
> > > -	s->dport = cp->dport;
> > > -	s->caddr = cp->caddr.ip;
> > > -	s->vaddr = cp->vaddr.ip;
> > > -	s->daddr = cp->daddr.ip;
> > > -	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
> > > -	s->state = htons(cp->state);
> > > -	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
> > > -		struct ip_vs_sync_conn_options *opt =
> > > -			(struct ip_vs_sync_conn_options *)&s[1];
> > > -		memcpy(opt, &cp->in_seq, sizeof(*opt));
> > > -	}
> > > -
> > > +	s->v4.ver_size = htons(len & SVER_MASK);	/* Version=0 */
> > > +	s->v4.flags = htonl(cp->flags & ~IP_VS_CONN_F_HASHED);
> > > +	s->v4.state = htons(cp->state);
> > > +	s->v4.protocol = cp->protocol;
> > > +	s->v4.cport = cp->cport;
> > > +	s->v4.vport = cp->vport;
> > > +	s->v4.dport = cp->dport;
> > > +	s->v4.fwmark = htonl(cp->fwmark);
> > > +	s->v4.timeout = htonl(cp->timeout / HZ);
> > >  	m->nr_conns++;
> > > -	m->size += len;
> > > -	curr_sb->head += len;
> > >  
> > > -	/* check if there is a space for next one */
> > > -	if (curr_sb->head+FULL_CONN_SIZE > curr_sb->end) {
> > > -		sb_queue_tail(curr_sb);
> > > -		curr_sb = NULL;
> > > +#ifdef CONFIG_IP_VS_IPV6
> > > +	if (cp->af == AF_INET6 ) {
> > > +		p += sizeof(struct ip_vs_sync_v6);
> > > +		ipv6_addr_copy(&s->v6.caddr, &cp->caddr.in6);
> > > +		ipv6_addr_copy(&s->v6.vaddr, &cp->vaddr.in6);
> > > +		ipv6_addr_copy(&s->v6.daddr, &cp->daddr.in6);
> > > +	} else
> > > +#endif
> > > +	{
> > > +		p += sizeof(struct ip_vs_sync_v4);	/* options ptr */
> > > +		s->v4.caddr = cp->caddr.ip;
> > > +		s->v4.vaddr = cp->vaddr.ip;
> > > +		s->v4.daddr = cp->daddr.ip;
> > > +	}
> > > +	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
> > > +		*(p++) = IPVS_OPT_SEQ_DATA;
> > > +		*(p++) = sizeof(struct ip_vs_sync_conn_options);
> > > +		memcpy(p, &cp->in_seq,
> > > +			       sizeof(struct ip_vs_sync_conn_options));
> > > +			p += sizeof(struct ip_vs_sync_conn_options);
> > >  	}
> > > +	/* Handle pe data */
> > > +	if (cp->pe_data_len && cp->pe_data) {
> > 
> > I don't think that its possible for pe_data_len to be non-zero
> > and pe_data be NULL and vice-versa.
> 
> I prefer to avoid a NULL pointer exception :-) 
> but if you are 100% sure that that I can remove the  "&& cp->pe_data", I do that

I am 99.9% sure. You call :-)
