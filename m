From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [Patch resend nf] ipvs: fix AF assignment in ip_vs_conn_new()
Date: Thu, 30 Jan 2014 08:39:04 +0100
Message-ID: <20140130073904.GA25322@unicorn.suse.cz>
References: <20140129145437.69F56E916F@unicorn.suse.cz>
 <alpine.LFD.2.11.1401292319030.1844@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401292319030.1844@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>

On Wed, Jan 29, 2014 at 11:24:17PM +0200, Julian Anastasov wrote:
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 59a1a85..282b39b 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -871,11 +871,11 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
> >  	cp->protocol	   = p->protocol;
> >  	ip_vs_addr_set(p->af, &cp->caddr, p->caddr);
> >  	cp->cport	   = p->cport;
> > -	ip_vs_addr_set(p->af, &cp->vaddr, p->vaddr);
> > -	cp->vport	   = p->vport;
> > -	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
> > +	/* proto should only be IPPROTO_IP if p->vaddr is a fwmark */
> >  	ip_vs_addr_set(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
> > -		       &cp->daddr, daddr);
> > +		       &cp->vaddr, vaddr);
> 
> 	Patch does not compile due to vaddr and p->daddr
> usage but you are in the right direction. Such change should
> fix a problem where connection templates don't get full
> IPv6 address for the real server, only the first 4 bytes
> are copied and as result it works only for IPv4.

Sorry for that, looks like I ran the test build after adapting to
current code with a config which didn't actually compile this file.
I'll send a v2 after testing a fixed version and I'll also extend the
commit message to describe the outcome.

                                                      Michal Kubecek

