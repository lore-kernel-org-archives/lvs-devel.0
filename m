From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] ipvs: remove unused function
 ip_vs_set_state_timeout
Date: Fri, 14 Apr 2017 02:13:09 +0200
Message-ID: <20170414001309.GA28870@salvia>
References: <20170410195044.19646-1-aconole@bytheb.org>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170410195044.19646-1-aconole@bytheb.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aaron Conole <aconole@bytheb.org>
Cc: netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Apr 10, 2017 at 03:50:44PM -0400, Aaron Conole wrote:
> There are no in-tree callers of this function and it isn't exported.

Simon, let me know if you want to take this, or just add your
Signed-off-by.

Thanks!

> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> ---
>  include/net/ip_vs.h              |  2 --
>  net/netfilter/ipvs/ip_vs_proto.c | 22 ----------------------
>  2 files changed, 24 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 8a4a57b8..c76fedb 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1349,8 +1349,6 @@ int ip_vs_protocol_init(void);
>  void ip_vs_protocol_cleanup(void);
>  void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags);
>  int *ip_vs_create_timeout_table(int *table, int size);
> -int ip_vs_set_state_timeout(int *table, int num, const char *const *names,
> -			    const char *name, int to);
>  void ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
>  			       const struct sk_buff *skb, int offset,
>  			       const char *msg);
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index 8ae4807..ca880a3 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -193,28 +193,6 @@ ip_vs_create_timeout_table(int *table, int size)
>  }
>  
>  
> -/*
> - *	Set timeout value for state specified by name
> - */
> -int
> -ip_vs_set_state_timeout(int *table, int num, const char *const *names,
> -			const char *name, int to)
> -{
> -	int i;
> -
> -	if (!table || !name || !to)
> -		return -EINVAL;
> -
> -	for (i = 0; i < num; i++) {
> -		if (strcmp(names[i], name))
> -			continue;
> -		table[i] = to * HZ;
> -		return 0;
> -	}
> -	return -ENOENT;
> -}
> -
> -
>  const char * ip_vs_state_name(__u16 proto, int state)
>  {
>  	struct ip_vs_protocol *pp = ip_vs_proto_get(proto);
> -- 
> 2.9.3
> 
