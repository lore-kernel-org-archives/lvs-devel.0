From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fix problems with active FTP
Date: Thu, 2 Sep 2010 10:54:42 +0900
Message-ID: <20100902015441.GP8174@verge.net.au>
References: <Pine.LNX.4.58.1009020235160.14271@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.1009020235160.14271@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netfilter-devel <netfilter-devel@vger.kernel.org>

On Thu, Sep 02, 2010 at 02:41:35AM +0300, Julian Anastasov wrote:
> 
> 	Fix Active FTP:
> 
> - Do not create expectation when forwarding the PORT
> command to avoid blocking the connection. The problem is that
> nf_conntrack_ftp.c:help() tries to create the same expectation
> later in POST_ROUTING and drops the packet with "dropping packet"
> message after failure in nf_ct_expect_related.
> 
> - Change ip_vs_update_conntrack to alter the conntrack
> for related connections from real server. If we do not alter
> the reply in this direction the next packet from client
> sent to vport 20 comes as NEW connection. We alter it
> but may be some collision happens for both conntracks and
> the second conntrack gets destroyed immediately. The connection
> stucks too.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Thanks, this looks good to me. I have CCed the netfilter-devel
list for review there.

> 
> 	This patch is for 2.6.36
> 
> diff -urp v2.6.36-rc2/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
> --- v2.6.36-rc2/linux/include/net/ip_vs.h	2010-08-26 09:11:45.000000000 +0300
> +++ linux/include/net/ip_vs.h	2010-09-02 01:10:31.000000000 +0300
> @@ -955,6 +955,9 @@ static inline __wsum ip_vs_check_diff2(_
>  	return csum_partial(diff, sizeof(diff), oldsum);
>  }
>  
> +extern void ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp,
> +				   int outin);
> +
>  #endif /* __KERNEL__ */
>  
>  #endif	/* _NET_IP_VS_H */
> diff -urp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_core.c linux/net/netfilter/ipvs/ip_vs_core.c
> --- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_core.c	2010-08-26 09:11:47.000000000 +0300
> +++ linux/net/netfilter/ipvs/ip_vs_core.c	2010-09-02 01:08:36.000000000 +0300
> @@ -924,6 +924,7 @@ handle_response(int af, struct sk_buff *
>  
>  	ip_vs_out_stats(cp, skb);
>  	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
> +	ip_vs_update_conntrack(skb, cp, 0);
>  	ip_vs_conn_put(cp);
>  
>  	skb->ipvs_property = 1;
> diff -urp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ftp.c linux/net/netfilter/ipvs/ip_vs_ftp.c
> --- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-08-26 09:11:47.000000000 +0300
> +++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-02 00:45:54.000000000 +0300
> @@ -409,7 +409,6 @@ static int ip_vs_ftp_in(struct ip_vs_app
>  	union nf_inet_addr to;
>  	__be16 port;
>  	struct ip_vs_conn *n_cp;
> -	struct nf_conn *ct;
>  
>  #ifdef CONFIG_IP_VS_IPV6
>  	/* This application helper doesn't work with IPv6 yet,
> @@ -496,11 +495,6 @@ static int ip_vs_ftp_in(struct ip_vs_app
>  		ip_vs_control_add(n_cp, cp);
>  	}
>  
> -	ct = (struct nf_conn *)skb->nfct;
> -	if (ct && ct != &nf_conntrack_untracked)
> -		ip_vs_expect_related(skb, ct, n_cp,
> -				     IPPROTO_TCP, &n_cp->dport, 1);
> -
>  	/*
>  	 *	Move tunnel to listen state
>  	 */
> diff -urp v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
> --- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-08-26 09:11:47.000000000 +0300
> +++ linux/net/netfilter/ipvs/ip_vs_xmit.c	2010-09-02 01:04:16.000000000 +0300
> @@ -349,8 +349,8 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb
>  }
>  #endif
>  
> -static void
> -ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp)
> +void
> +ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
>  {
>  	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
>  	struct nf_conntrack_tuple new_tuple;
> @@ -365,11 +365,17 @@ ip_vs_update_conntrack(struct sk_buff *s
>  	 * real-server we will see RIP->DIP.
>  	 */
>  	new_tuple = ct->tuplehash[IP_CT_DIR_REPLY].tuple;
> -	new_tuple.src.u3 = cp->daddr;
> +	if (outin)
> +		new_tuple.src.u3 = cp->daddr;
> +	else
> +		new_tuple.dst.u3 = cp->vaddr;
>  	/*
>  	 * This will also take care of UDP and other protocols.
>  	 */
> -	new_tuple.src.u.tcp.port = cp->dport;
> +	if (outin)
> +		new_tuple.src.u.tcp.port = cp->dport;
> +	else
> +		new_tuple.dst.u.tcp.port = cp->vport;
>  	nf_conntrack_alter_reply(ct, &new_tuple);
>  }
>  
> @@ -428,7 +434,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
>  
>  	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
>  
> -	ip_vs_update_conntrack(skb, cp);
> +	ip_vs_update_conntrack(skb, cp, 1);
>  
>  	/* FIXME: when application helper enlarges the packet and the length
>  	   is larger than the MTU of outgoing device, there will be still
> @@ -506,7 +512,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
>  
>  	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
>  
> -	ip_vs_update_conntrack(skb, cp);
> +	ip_vs_update_conntrack(skb, cp, 1);
>  
>  	/* FIXME: when application helper enlarges the packet and the length
>  	   is larger than the MTU of outgoing device, there will be still
