From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Remove unused net variable from ip_vs_out
Date: Tue, 6 Oct 2015 09:35:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1510060934320.2233@ja.home.ssi.bg>
References: <1443746619-3503-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443746619-3503-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, "Eric W. Biederman" <ebiederm@xmission.com>


	Hello,

On Fri, 2 Oct 2015, Simon Horman wrote:

> Since 6f2bcea9917d ("ipvs: Pass ipvs into ip_vs_in_icmp and ip_vs_in_icmp_v6")
> the net net variable in ip_vs_out() appears to be unused so remove it.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index d08df435c2aa..72b6a44ea9de 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1172,7 +1172,6 @@ drop:
>  static unsigned int
>  ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int af)
>  {
> -	struct net *net = ipvs->net;

	So, this line should be moved into the block
where the var is used?

Regards

--
Julian Anastasov <ja@ssi.bg>
