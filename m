From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2] ipvs: uninitialized data with IP_VS_IPV6
Date: Tue, 9 Dec 2014 09:52:15 +0900
Message-ID: <20141209005215.GH8897@verge.net.au>
References: <20141206134924.GA17278@mwanda>
 <alpine.LFD.2.11.1412072032420.1885@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1412072032420.1885@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

On Sun, Dec 07, 2014 at 08:39:35PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 6 Dec 2014, Dan Carpenter wrote:
> 
> > The app_tcp_pkt_out() function expects "*diff" to be set and ends up
> > using uninitialized data if CONFIG_IP_VS_IPV6 is turned on.
> > 
> > The same issue is there in app_tcp_pkt_in().  Thanks to Julian Anastasov
> > for noticing that.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > v2: fix app_tcp_pkt_in() as well.  This is an old bug.
> 
> 	Thanks! It will not break seqs for IPv6 control
> connection, only that we do not support FTP yet :( I have
> the doubt whether this should be classified as bugfix :)
> I guess, it is a net-next material, right?

Agreed, I have queued it up in ipvs-next.
I'll send a pull request to Pablo if Dan doesn't object
to it going there.

> 	Simon, please apply.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> > index 1d5341f..5d3daae 100644
> > --- a/net/netfilter/ipvs/ip_vs_ftp.c
> > +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> > @@ -183,6 +183,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  	struct nf_conn *ct;
> >  	struct net *net;
> >  
> > +	*diff = 0;
> > +
> >  #ifdef CONFIG_IP_VS_IPV6
> >  	/* This application helper doesn't work with IPv6 yet,
> >  	 * so turn this into a no-op for IPv6 packets
> > @@ -191,8 +193,6 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  		return 1;
> >  #endif
> >  
> > -	*diff = 0;
> > -
> >  	/* Only useful for established sessions */
> >  	if (cp->state != IP_VS_TCP_S_ESTABLISHED)
> >  		return 1;
> > @@ -322,6 +322,9 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  	struct ip_vs_conn *n_cp;
> >  	struct net *net;
> >  
> > +	/* no diff required for incoming packets */
> > +	*diff = 0;
> > +
> >  #ifdef CONFIG_IP_VS_IPV6
> >  	/* This application helper doesn't work with IPv6 yet,
> >  	 * so turn this into a no-op for IPv6 packets
> > @@ -330,9 +333,6 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
> >  		return 1;
> >  #endif
> >  
> > -	/* no diff required for incoming packets */
> > -	*diff = 0;
> > -
> >  	/* Only useful for established sessions */
> >  	if (cp->state != IP_VS_TCP_S_ESTABLISHED)
> >  		return 1;
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
