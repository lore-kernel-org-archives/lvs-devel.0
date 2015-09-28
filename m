From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Don't protect ip_vs_addr_is_unicast with
 CONFIG_SYSCTL
Date: Mon, 28 Sep 2015 21:45:28 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509282144410.6497@ja.home.ssi.bg>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au> <20150925000102.GA5634@salvia> <87612ueff4.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87612ueff4.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Mon, 28 Sep 2015, Eric W. Biederman wrote:

> I arranged the code so that the compiler can remove the unecessary bits
> in ip_vs_leave when CONFIG_SYSCTL is unset, and removed an explicit
> CONFIG_SYSCTL.
> 
> Unfortunately when rebasing my work on top of that of Alex Gartrell I
> missed the fact that the newly added function ip_vs_addr_is_unicast was
> surrounded by CONFIG_SYSCTL.
> 
> So remove the now unnecessary CONFIG_SYSCTL guards around
> ip_vs_addr_is_unicast.  It is causing build failures today when
> CONFIG_SYSCTL is not selected and any self respecting compiler will
> notice that sysctl_cache_bypass is always false without CONFIG_SYSCTL
> and not include the logic from the function ip_vs_addr_is_unicast in
> the compiled code.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, please apply to ipvs-next

> ---
> 
> This is a build fix for ipvs-next and nf-next.
> 
>  net/netfilter/ipvs/ip_vs_core.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 07a791ecdfba..fba73db81d2f 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -547,7 +547,6 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
>  	return cp;
>  }
>  
> -#ifdef CONFIG_SYSCTL
>  static inline int ip_vs_addr_is_unicast(struct net *net, int af,
>  					union nf_inet_addr *addr)
>  {
> @@ -557,7 +556,6 @@ static inline int ip_vs_addr_is_unicast(struct net *net, int af,
>  #endif
>  	return (inet_addr_type(net, addr->ip) == RTN_UNICAST);
>  }
> -#endif
>  
>  /*
>   *  Pass or drop the packet.
> -- 
> 2.2.1

Regards

--
Julian Anastasov <ja@ssi.bg>
