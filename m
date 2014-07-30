From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [RFC] GSO: Questions for IPVS and GSO for IPv6
Date: Tue, 29 Jul 2014 20:15:37 -0700
Message-ID: <53D86359.2000604@fb.com>
References: <alpine.LFD.2.11.1407270957400.2036@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=SNy8V18gwECg68tgnD7/otPomQe5wPqIZIaniCD3+Ik=;
 b=Z5SwuPfuMFJjlY2QiVrEKY5ipP95pVp7yigfzwQCEae2tTgXMMF8l+eS6CwtEx/ON4Vq
 4Gyc77ZabWMKVPxwccLaNbTQi7tJgKyn43Bfj2KoAE+C8QfCgEJP+8BFy/oDACt32ZHN
 6ucoNWq992fujN9+MxWsfHfVGjnNKU+TWdk= 
In-Reply-To: <alpine.LFD.2.11.1407270957400.2036@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org, kernel-team <Kernel-team@fb.com>

Thanks for putting this up Julian.  As a meta-point, working with 
upstream isn't necessarily something that has come easily or obviously 
to us corporate shills at Internet companies, but it's pretty obvious at 
this point that it was foolish for us to go it alone :)

> [PATCH net] ipvs: properly declare tunnel encapsulation
>
> The tunneling method should properly use tunnel encapsulation.
> Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
> offload is supported.
>
> Thanks to Alex Gartrell for reporting the problem, providing
> solution and for all suggestions.
>
> Reported-by: Alex Gartrell <agartrell@fb.com>
> TODO: waiting for final ack from Alex before adding Signed-off-by line

nit-picky comments below, but this looks good to me.

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>   net/netfilter/ipvs/ip_vs_xmit.c | 20 ++++++++++++++++----
>   1 file changed, 16 insertions(+), 4 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 73ba1cc..8c1172c 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -38,6 +38,7 @@
>   #include <net/route.h>                  /* for ip_route_output */
>   #include <net/ipv6.h>
>   #include <net/ip6_route.h>
> +#include <net/ip_tunnels.h>
>   #include <net/addrconf.h>
>   #include <linux/icmpv6.h>
>   #include <linux/netfilter.h>
> @@ -862,14 +863,19 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>   		old_iph = ip_hdr(skb);
>   	}
>
> -	skb->transport_header = skb->network_header;
> -
>   	/* fix old IP header checksum */
>   	ip_send_check(old_iph);
>
> +	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
> +	if (IS_ERR(skb))
> +		goto tx_error;
> +
> +	skb->transport_header = skb->network_header;
> +
>   	skb_push(skb, sizeof(struct iphdr));
>   	skb_reset_network_header(skb);
>   	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> +	skb_clear_hash(skb);

We need this in ipv4 but not in ipv6?

>
>   	/*
>   	 *	Push down and install the IPIP header.
> @@ -900,7 +906,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
>   	return NF_STOLEN;
>
>     tx_error:
> -	kfree_skb(skb);
> +	if (!IS_ERR(skb))
> +		kfree_skb(skb);
>   	rcu_read_unlock();
>   	LeaveFunction(10);
>   	return NF_STOLEN;
> @@ -953,6 +960,10 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>   		old_iph = ipv6_hdr(skb);
>   	}
>
> +	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);

It sounds like this is going to take a fair amount of work.  Can we set 
gso_type_mask to 0 with a scary comment and push it as a fix and then do 
the right thing as a feature for a future release?

> +	if (IS_ERR(skb))
> +		goto tx_error;
> +
>   	skb->transport_header = skb->network_header;
>
>   	skb_push(skb, sizeof(struct ipv6hdr));
> @@ -988,7 +999,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
>   	return NF_STOLEN;
>
>   tx_error:
> -	kfree_skb(skb);
> +	if (!IS_ERR(skb))
> +		kfree_skb(skb);
>   	rcu_read_unlock();
>   	LeaveFunction(10);
>   	return NF_STOLEN;
>

