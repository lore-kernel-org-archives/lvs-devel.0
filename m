From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch resend nf] ipvs: fix AF assignment in ip_vs_conn_new()
Date: Wed, 29 Jan 2014 23:24:17 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401292319030.1844@ja.home.ssi.bg>
References: <20140129145437.69F56E916F@unicorn.suse.cz>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140129145437.69F56E916F@unicorn.suse.cz>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Kubecek <mkubecek@suse.cz>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>


	Hello,

On Wed, 29 Jan 2014, Michal Kubecek wrote:

> If a fwmark is passed to ip_vs_conn_new(), it is passed in
> vaddr, not daddr. Therefore we should set AF to AF_UNSPEC in
> vaddr assignment (like we do in ip_vs_ct_in_get()).
> 
> Signed-off-by: Bogdano Arendartchuk <barendartchuk@suse.com>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
> (first time it didn't reach all recipients due to a malformed header)
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 59a1a85..282b39b 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -871,11 +871,11 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p,
>  	cp->protocol	   = p->protocol;
>  	ip_vs_addr_set(p->af, &cp->caddr, p->caddr);
>  	cp->cport	   = p->cport;
> -	ip_vs_addr_set(p->af, &cp->vaddr, p->vaddr);
> -	cp->vport	   = p->vport;
> -	/* proto should only be IPPROTO_IP if d_addr is a fwmark */
> +	/* proto should only be IPPROTO_IP if p->vaddr is a fwmark */
>  	ip_vs_addr_set(p->protocol == IPPROTO_IP ? AF_UNSPEC : p->af,
> -		       &cp->daddr, daddr);
> +		       &cp->vaddr, vaddr);

	Patch does not compile due to vaddr and p->daddr
usage but you are in the right direction. Such change should
fix a problem where connection templates don't get full
IPv6 address for the real server, only the first 4 bytes
are copied and as result it works only for IPv4.

> +	cp->vport	   = p->vport;
> +	ip_vs_addr_set(p->af, &cp->daddr, p->daddr);
>  	cp->dport          = dport;
>  	cp->flags	   = flags;
>  	cp->fwmark         = fwmark;
> -- 
> 1.8.1.4

Regards

--
Julian Anastasov <ja@ssi.bg>
