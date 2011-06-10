From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvs netns exit causes crash in conntrack.
Date: Sat, 11 Jun 2011 02:10:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1106102302320.1771@ja.ssi.bg>
References: <201106091457.29205.hans@schillstrom.com> <201106092146.35494.hans@schillstrom.com> <alpine.LFD.2.00.1106092325350.1472@ja.ssi.bg> <201106101102.41234.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201106101102.41234.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>


	Hello,

On Fri, 10 Jun 2011, Hans Schillstrom wrote:

> > 	In IPVS we can add checks to exit ip_vs_conn_drop_conntrack()
> > early if net cleanup is in progress because conntrack can be
> > loaded after IPVS and its cleanup called before IPVS.
> > We do not need to delete conntrack while in IPVS cleanup.
> 
> This is a quite simple patch ... 
> The enable flag is set to 0 already when an exit begins 

	Correct, this should work because we clear the
flag during device cleanup.

> So it's just to check it
> maybe it should be atomic, but for my quick test "volatile" will do.

	Yes, may be this check will need smp_rmb, not
atomic operations, sort of:

	if (cp->flags & IP_VS_CONN_F_NFCT) {
		smp_rmb():
		if (ipvs->enable)
			ip_vs_conn_drop_conntrack(cp);
	}

	And corresponding smp_wmb:

static void __net_exit __ip_vs_dev_cleanup(struct net *net)
{
	EnterFunction(2);
	net_ipvs(net)->enable = 0;	/* Disable packet reception */
--->>>	smp_wmb();
	__ip_vs_sync_cleanup(net);
	LeaveFunction(2);
}


	All other places do not need smp_rmb, it is not fatal
there.

	Also, we can put some comments that we should not access
conntracks during subsys cleanup because nf_conntrack_find_get
can not be used after conntrack cleanup for the net.

	One option to avoid such checks is the netfilter
framework to provide priority based list of netns init/exit
handlers, so that all modules are ordered by known
priority based on their dependency. For example,
nf_register_netns_subsys_hooks function can be created
in a similar way like nf_register_hooks. By this way,
IPVS should be one of the first to be called for cleanup
and such checks for enable flag will not be needed.

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index bf28ac2..ae5e9e2 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -775,8 +775,8 @@ static void ip_vs_conn_expire(unsigned long data)
>                 /* does anybody control me? */
>                 if (cp->control)
>                         ip_vs_control_del(cp);
> -
> -               if (cp->flags & IP_VS_CONN_F_NFCT)
> +               /* Do not try do drop ct when netns is dying */
> +               if (cp->flags & IP_VS_CONN_F_NFCT && ipvs->enable)
>                         ip_vs_conn_drop_conntrack(cp);
> 
>                 ip_vs_pe_put(cp->pe);

Regards

--
Julian Anastasov <ja@ssi.bg>
