From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: SNAT packet replies only for NATed connections
Date: Mon, 1 May 2017 09:55:42 +0200
Message-ID: <20170501075542.GD18349@verge.net.au>
References: <20170429173309.16305-1-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1493625346; bh=3ns+q/eyKyR0AQNbArI0Dbwsjyk2Y6jRSwmN1NOVWXY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=R/pLxl/Luo3WKtFIl57sPgNhcpowmIjvzFxoDO6ZWyXQLiseAQBgDBkyXAKozM/Ua
         OL8VGv2h6T2NKFDpgGwu7Z4FqNTSJvEQ2kdSA46AexQnioW9VWo7cli5kyUB94gnhX
         5005/7Pv9t042D9OwCrMtTR3JR0BXGkXRAMsRC1U=
Content-Disposition: inline
In-Reply-To: <20170429173309.16305-1-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Nick Moriarty <nick.moriarty@york.ac.uk>

On Sat, Apr 29, 2017 at 08:33:09PM +0300, Julian Anastasov wrote:
> We do not check if packet from real server is for NAT
> connection before performing SNAT. This causes problems
> for setups that use DR/TUN and allow local clients to
> access the real server directly, for example:
> 
> - local client in director creates IPVS-DR/TUN connection
> CIP->VIP and the request packets are routed to RIP.
> Talks are finished but IPVS connection is not expired yet.
> 
> - second local client creates non-IPVS connection CIP->RIP
> with same reply tuple RIP->CIP and when replies are received
> on LOCAL_IN we wrongly assign them for the first client
> connection because RIP->CIP matches the reply direction.
> As result, IPVS SNATs replies for non-IPVS connections.
> 
> The problem is more visible to local UDP clients but in rare
> cases it can happen also for TCP or remote clients when the
> real server sends the reply traffic via the director.
> 
> So, better to be more precise for the reply traffic.
> As replies are not expected for DR/TUN connections, better
> to not touch them.
> 
> Reported-by: Nick Moriarty <nick.moriarty@york.ac.uk>
> Tested-by: Nick Moriarty <nick.moriarty@york.ac.uk>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> I know that 4.11 is to be released soon, I prefer this patch
> to linger in the net tree during the 4.12-rc cycle.

I have no problem with queueing this up as a fix for v4.12 as you describe
but do you also want it to be considered for -stable?

> 
>  net/netfilter/ipvs/ip_vs_core.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index db40050..ee44ed5 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -849,10 +849,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
>  {
>  	unsigned int verdict = NF_DROP;
>  
> -	if (IP_VS_FWD_METHOD(cp) != 0) {
> -		pr_err("shouldn't reach here, because the box is on the "
> -		       "half connection in the tun/dr module.\n");
> -	}
> +	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> +		goto ignore_cp;
>  
>  	/* Ensure the checksum is correct */
>  	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
> @@ -886,6 +884,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
>  		ip_vs_notrack(skb);
>  	else
>  		ip_vs_update_conntrack(skb, cp, 0);
> +
> +ignore_cp:
>  	verdict = NF_ACCEPT;
>  
>  out:
> @@ -1385,8 +1385,11 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  	 */
>  	cp = pp->conn_out_get(ipvs, af, skb, &iph);
>  
> -	if (likely(cp))
> +	if (likely(cp)) {
> +		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
> +			goto ignore_cp;
>  		return handle_response(af, skb, pd, cp, &iph, hooknum);
> +	}
>  
>  	/* Check for real-server-started requests */
>  	if (atomic_read(&ipvs->conn_out_counter)) {
> @@ -1444,9 +1447,15 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  			}
>  		}
>  	}
> +
> +out:
>  	IP_VS_DBG_PKT(12, af, pp, skb, iph.off,
>  		      "ip_vs_out: packet continues traversal as normal");
>  	return NF_ACCEPT;
> +
> +ignore_cp:
> +	__ip_vs_conn_put(cp);
> +	goto out;
>  }
>  
>  /*
> -- 
> 2.9.3
> 
