From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf,v2] ipvs: correctly print the memory size of
 ip_vs_conn_tab
Date: Tue, 19 Apr 2022 10:57:31 +0200
Message-ID: <Yl55e0mDsrgcCAX2@vergenet.net>
References: <1649761545-1864-1-git-send-email-yangpc@wangsu.com>
 <dd2f82a6-bf70-2b10-46e0-9d81e4dde6@ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <dd2f82a6-bf70-2b10-46e0-9d81e4dde6@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pengcheng Yang <yangpc@wangsu.com>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@netfilter.org>, netfilter-devel@vger.kernel.org

On Fri, Apr 15, 2022 at 04:22:47PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 12 Apr 2022, Pengcheng Yang wrote:
> 
> > The memory size of ip_vs_conn_tab changed after we use hlist
> > instead of list.
> > 
> > Fixes: 731109e78415 ("ipvs: use hlist instead of list")
> > Signed-off-by: Pengcheng Yang <yangpc@wangsu.com>
> > ---
> 
> 	v2 looks better to me for nf-next, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@verge.net.au>

> > v2: use pointer dereference instead of struct types
> > 
> >  net/netfilter/ipvs/ip_vs_conn.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 2c467c4..fb67f1c 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -1495,7 +1495,7 @@ int __init ip_vs_conn_init(void)
> >  	pr_info("Connection hash table configured "
> >  		"(size=%d, memory=%ldKbytes)\n",
> >  		ip_vs_conn_tab_size,
> > -		(long)(ip_vs_conn_tab_size*sizeof(struct list_head))/1024);
> > +		(long)(ip_vs_conn_tab_size*sizeof(*ip_vs_conn_tab))/1024);
> >  	IP_VS_DBG(0, "Each connection entry needs %zd bytes at least\n",
> >  		  sizeof(struct ip_vs_conn));
> >  
> > -- 
> > 1.8.3.1
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
