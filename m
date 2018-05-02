From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for IPPROTO_TCP
Date: Wed, 2 May 2018 10:10:41 -0700
Message-ID: <20180502171041.s3euld6i7hm6bw5c@kafai-mbp>
References: <20180419212324.1542504-1-kafai@fb.com>
 <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=date : from : to : cc :
 subject : message-id : references : mime-version : content-type :
 in-reply-to; s=facebook; bh=UayS/TLAcoqii8GUanRdptrzthlX/JKs7r+mk7ioZv0=;
 b=rLoktGySWicN5y2ypydm2oL+9RfRToywJo/32r4iaoP38fjI7Y7i7UwcvOfSUnB2hNGZ
 byPWzpbMcbvBJJb0X8GHqgjtcgXlmeALb2EfUiRlGsbOjISQ+sUNULoQH+cFyqYIwSvJ
 OoGMokfRsxolrmDHBr6t1aidc3zJp7AaS+4= 
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org

On Wed, May 02, 2018 at 09:38:43AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 19 Apr 2018, Martin KaFai Lau wrote:
> 
> > This patch is not a proper fix and mainly serves for discussion purpose.
> > It is based on net-next which I have been using to debug the issue.
> > 
> > The change that works around the issue is in ensure_mtu_is_adequate().
> > Other changes are the rippling effect in function arg.
> > 
> > This bug was uncovered by one of our legacy service that
> > are still using ipvs for load balancing.  In that setup,
> > the ipvs encap the ipv6-tcp packet in another ipv6 hdr
> > before tx it out to eth0.
> > 
> > The problem is the kernel stack could pass a skb (which was
> > originated from a sys_write(tcp_fd)) to the driver with skb->len
> > bigger than the device MTU.  In one NIC setup (with gso and tso off)
> > that we are using, it upset the NIC/driver and caused the tx queue
> > stalled for tens of seconds which is how it got uncovered.
> > (On the NIC side, the NIC firmware and driver have been fixed
> > to avoid this tx queue stall after seeing this skb).
> 
> 	In the last week I analyzed the situation and found
> that just changes in route.c are able to solve the problems,
> at 99% :) I'm posting a separate patch for this.
> 
> 	Here is what happens, I'm testing with FTP which
> starts with connection to port 21 and then with data connection,
> from local ftp client to local Virtual IP (forwarded to remote
> real server via tunnel).
> 
> - TCP creates local route which after commit 839da4d98960
> appears to be non-cached, before this commit it is cached.
> Route is saved and reused.
> 
> - initial traffic for port 21 does not use GSO. But after
> every packet IPVS calls maybe_update_pmtu (rt->dst.ops->update_pmtu)
> to report the reduced MTU. These updates are stored in fnhe_pmtu
> but they do not go to any route, even if we try to get fresh
> output route. Why? Because the local routes are not cached, so
> they can not use the fnhe. This is what my patch for route.c
> will fix. With this fix FTP-DATA gets route with reduced PMTU.
For IPv6, the 'if (rt6->rt6i_flags & RTF_LOCAL)' gate in
__ip6_rt_update_pmtu() may need to be lifted also.

> 
> - later, there are large GSO packets in the FTP-DATA connection.
> Currently, IPVS does not send ICMP error for exceeded PMTU
> by GSO packets (this will be fixed, see patch below). Even
> if they reach TCP and it refreshes its route, TCP can not get
> any actual PMTU values from the routing, so continues to
> use the large gso_size without the patch for route.c
> 
> 	For the changes in IPVS that I show below as RFC:
> 
> - I synchronized the PMTU checks in __mtu_check_toobig* with
> IPv4/IPv6 forwarding
> 
> - I modified your changes, see ipvs_gso_hlen() and how I use it
> at start of ensure_mtu_is_adequate(), after skb is made writable,
> before the PMTU checks.
> 
> 	In my tests, all variants work, just with skb_decrease_gso_size
> or even if I add SKB_GSO_DODGY+gso_segs=0. But I'm not sure
> if this is safe for the different GSO configurations.
> 
> 	I'm analyzing what can be changed in route.c, so that
> dst.ops->update_pmtu changes to take effect for the provided
> route. If that is possible, it will allow the PMTU change to
> take immediate effect for the local routes.
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 4527921..7a2a0a89 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -104,9 +104,32 @@ __ip_vs_dst_check(struct ip_vs_dest *dest)
>  	return dest_dst;
>  }
>  
> -static inline bool
> -__mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
> +/* Check if packet size violates MTU */
> +static bool __mtu_check_toobig(const struct sk_buff *skb, u32 mtu)
>  {
> +	if (skb->len <= mtu)
> +		return false;
> +
> +	if (unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0))
> +		return false;
> +
> +	if (IPCB(skb)->frag_max_size) {
> +		/* frag_max_size tell us that, this packet have been
> +		 * defragmented by netfilter IPv4 conntrack module.
> +		 */
> +		if (IPCB(skb)->frag_max_size > mtu)
> +			return true; /* largest fragment violate MTU */
> +	}
> +	if (skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))
> +		return false;
> +	return true;
> +}
> +
> +/* Check if packet size violates MTU */
> +static bool __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
> +{
> +	if (skb->len <= mtu)
> +		return false;
>  	if (IP6CB(skb)->frag_max_size) {
>  		/* frag_max_size tell us that, this packet have been
>  		 * defragmented by netfilter IPv6 conntrack module.
> @@ -114,10 +137,9 @@ __mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
>  		if (IP6CB(skb)->frag_max_size > mtu)
>  			return true; /* largest fragment violate MTU */
>  	}
> -	else if (skb->len > mtu && !skb_is_gso(skb)) {
> -		return true; /* Packet size violate MTU size */
> -	}
> -	return false;
> +	if (skb_is_gso(skb) && skb_gso_validate_network_len(skb, mtu))
> +		return false;
> +	return true;
>  }
>  
>  /* Get route to daddr, update *saddr, optionally bind route to saddr */
> @@ -212,11 +234,42 @@ static inline void maybe_update_pmtu(int skb_af, struct sk_buff *skb, int mtu)
>  		ort->dst.ops->update_pmtu(&ort->dst, sk, NULL, mtu);
>  }
>  
> +/* GSO: length of network and transport headers, 0=unsupported */
> +static unsigned short ipvs_gso_hlen(struct sk_buff *skb,
> +				    struct ip_vs_iphdr *ipvsh)
> +{
> +	unsigned short hlen = ipvsh->len - ipvsh->off;
> +
> +	if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
> +		struct tcphdr _tcph, *th;
> +
> +		th = skb_header_pointer(skb, ipvsh->len, sizeof(_tcph), &_tcph);
> +		if (th)
> +			return hlen + (th->doff << 2);
> +	}
> +	return 0;
> +}
> + 
>  static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  					  int rt_mode,
>  					  struct ip_vs_iphdr *ipvsh,
>  					  struct sk_buff *skb, int mtu)
>  {
> +	/* Re-segment traffic from local clients */
> +	if (!skb->dev && skb_is_gso(skb)) {
> +		unsigned short hlen = ipvs_gso_hlen(skb, ipvsh);
> +
> +		if (hlen && mtu - hlen < skb_shinfo(skb)->gso_size &&
> +		    mtu > hlen) {
> +			u16 reduce = skb_shinfo(skb)->gso_size - (mtu - hlen);
> +
> +			IP_VS_DBG(10, "Reducing gso_size=%u with %u\n",
> +				skb_shinfo(skb)->gso_size, reduce);
> +			skb_decrease_gso_size(skb_shinfo(skb), reduce);
> +			skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
> +			skb_shinfo(skb)->gso_segs = 0;
> +		}
> +	}
>  #ifdef CONFIG_IP_VS_IPV6
>  	if (skb_af == AF_INET6) {
>  		struct net *net = ipvs->net;
> @@ -240,9 +293,7 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  		if ((rt_mode & IP_VS_RT_MODE_TUNNEL) && !sysctl_pmtu_disc(ipvs))
>  			return true;
>  
> -		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
> -			     skb->len > mtu && !skb_is_gso(skb) &&
> -			     !ip_vs_iph_icmp(ipvsh))) {
> +		if (unlikely(__mtu_check_toobig(skb, mtu))) {
>  			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
>  				  htonl(mtu));
>  			IP_VS_DBG(1, "frag needed for %pI4\n",
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
