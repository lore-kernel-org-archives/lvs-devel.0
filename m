From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/3] ipvs: Fix faulty IPv6 extension header handling in
 IPVS
Date: Tue, 21 Aug 2012 17:14:49 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1208211558410.2149@ja.ssi.bg>
References: <20120820130732.1509.13080.stgit@dragon> <20120820130840.1509.75794.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120820130840.1509.75794.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org


	Hello,

On Mon, 20 Aug 2012, Jesper Dangaard Brouer wrote:

> Based on patch from: Hans Schillstrom
> 
> IPv6 headers must be processed in order of appearance,
> neither can it be assumed that Upper layer headers is first.
> If anything else than L4 is the first header IPVS will throw it.
> 
> IPVS will write SNAT & DNAT modifications at a fixed pos which
> will corrupt the message. Proper header position must be found
> before writing modifying packet.
> 
> This patch contains a lot of API changes.  This is done, to avoid
> the costly scan of finding the IPv6 headers, via ipv6_find_hdr().
> Finding the IPv6 headers is done as early as possible, and passed
> on as a pointer "struct ip_vs_iphdr *" to the affected functions.
> 
> Notice, I have choosen, not to change the API of function
> pointer "(*schedule)" (in struct ip_vs_scheduler) as it can be
> used by external schedulers, via {un,}register_ip_vs_scheduler.
> Only 4 out of 10 schedulers use info from ip_vs_iphdr*, and when
> they do, they are only interested in iph->{s,d}addr.
> 
> This patch depends on commit 84018f55a:
>  "netfilter: ip6_tables: add flags parameter to ipv6_find_hdr()"
> 
> This also adds a dependency to ip6_tables.
> 
> Hans left some questions in ip_vs_pe_sip.c, which I'm uncertain about.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

	Patch 1 looks ok, following are some small comments
for patch 2 and 3.

> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +#include <linux/netfilter_ipv6/ip6_tables.h>
> +#endif

	There is already #if IS_ENABLED(CONFIG_IPV6) that
can replace #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

	It seems we need IS_ENABLED for many places:
CONFIG_NF_CONNTRACK, CONFIG_NF_DEFRAG_IPV6

> @@ -958,34 +943,26 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
>  	}
>  
>  	/* Now find the contained IP header */
> -	offset += sizeof(_icmph);
> -	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
> -	if (cih == NULL)
> -		return NF_ACCEPT; /* The packet looks wrong, ignore */
> +	ipvsh->len += sizeof(_icmph);
> +	ip6 = skb_header_pointer(skb, ipvsh->len, sizeof(_ip6), &_ip6);

	ip6 is not checked here for NULL or we rely on
ipv6_find_hdr checks?

> @@ -1506,39 +1464,43 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
>  	}
>  
>  	/* Now find the contained IP header */
> -	offset += sizeof(_icmph);
> -	cih = skb_header_pointer(skb, offset, sizeof(_ciph), &_ciph);
> -	if (cih == NULL)
> -		return NF_ACCEPT; /* The packet looks wrong, ignore */
> +	ciph.len = iph->len + sizeof(_icmph);
> +	ciph.flags = 0;
> +	ciph.fragoffs = 0;
> +	ciph.protocol = ipv6_find_hdr(skb, &ciph.len, -1, &ciph.fragoffs,
> +				      &ciph.flags);
> +	ciph.saddr = iph->saddr;	/* con_in_get() handles reverse order */
> +	ciph.daddr = iph->daddr;

	The ciph initialization looks dangerous if one day
we add new field into the header.

	Can we use ciph = (struct ip_vs_iphdr) { .XXX = val, ... },
in such case we have to call ipv6_find_hdr out of (after)
this initialization? Of course, we will write twice to
small fields such as protocol, len, fragoffs, flags

	Also ipv6_find_hdr looks a bit noisy for missing header,
can it be a problem for the inner IPv6 header in ICMP messages?

	In patch 3 ip_vs_in_icmp_v6 initializes ciph in the
same way. It will be difficult to audit the code later
considering the large number of places where iph is used.

>  	net = skb_net(skb);
> -	pd = ip_vs_proto_data_get(net, cih->nexthdr);
> +	pd = ip_vs_proto_data_get(net, ciph.protocol);
>  	if (!pd)
>  		return NF_ACCEPT;
>  	pp = pd->pp;
>  
> -	/* Is the embedded protocol header present? */
> -	/* TODO: we don't support fragmentation at the moment anyways */
> -	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
> +	/* Is the embedded protocol header present?
> +	 * If it's the second or later fragment we don't know what it is
> +	 * i.e. just let it through.
> +	 */
> +	if (ciph.fragoffs)
>  		return NF_ACCEPT;
>  
> +	offset = ciph.len;
>  	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
>  		      "Checking incoming ICMPv6 for");
>  
> -	offset += sizeof(struct ipv6hdr);
> -
> -	ip_vs_fill_iphdr(AF_INET6, cih, &ciph);
>  	/* The embedded headers contain source and dest in reverse order */
> -	cp = pp->conn_in_get(AF_INET6, skb, &ciph, offset, 1);
> +	cp = pp->conn_in_get(AF_INET6, skb, &ciph, 1);
>  	if (!cp)
>  		return NF_ACCEPT;
>  
>  	/* do the statistics and put it back */
>  	ip_vs_in_stats(cp, skb);
> -	if (IPPROTO_TCP == cih->nexthdr || IPPROTO_UDP == cih->nexthdr ||
> -	    IPPROTO_SCTP == cih->nexthdr)
> -		offset += 2 * sizeof(__u16);
> -	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum);
> +	if (IPPROTO_TCP == ciph.protocol || IPPROTO_UDP == ciph.protocol ||
> +	    IPPROTO_SCTP == ciph.protocol)
> +		offset = ciph.len + (2 * sizeof(__u16));

	Still in the same func, above code is correct but
patch 3 changes it back to wrong state (offs_ciph = ciph.len).

> +
> +	verdict = ip_vs_icmp_xmit_v6(skb, cp, pp, offset, hooknum, &ciph);
>  
>  	__ip_vs_conn_put(cp);

> diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
> index 1aa5cac..bb28b4f 100644
> --- a/net/netfilter/ipvs/ip_vs_pe_sip.c
> +++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
> @@ -68,26 +68,37 @@ static int get_callid(const char *dptr, unsigned int dataoff,
>  static int
>  ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
>  {
> +	struct sk_buff *reasm = skb_nfct_reasm(skb);
>  	struct ip_vs_iphdr iph;
>  	unsigned int dataoff, datalen, matchoff, matchlen;
>  	const char *dptr;
>  	int retc;
>  
> -	ip_vs_fill_iphdr(p->af, skb_network_header(skb), &iph);
> +	ip_vs_fill_iph_skb(p->af, skb, &iph);

	May be skb_linearize is bad for IPv6? IIRC,
ip_vs_pe_sip.c needs access just to read the Call-ID.
For IPv4 it was simple to use skb_linearize, may be
the logic should be improved to read the values even
from non-linear data. May be there is already some
example code for this. For IPv6 I'm not sure what
kind are the problems here, may be it depends if
we try to call skb_linearize for reasm packet?

> -
> -	if ((retc=skb_linearize(skb)) < 0)
> +	/*
> +	 * todo: Check if this will mess-up the reasm skb !!! /HS
> +	 */
> +	retc = skb_linearize(reasm);
> +	if (retc < 0)
>  		return retc;
> -	dptr = skb->data + dataoff;
> -	datalen = skb->len - dataoff;
> +	dptr = reasm->data + dataoff;
> +	datalen = reasm->len - dataoff;
>  
>  	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
>  		return -EINVAL;

	There are recents changes for IPv6 from Patrick McHardy:

http://marc.info/?l=netfilter-devel&m=134543406303402&w=2
http://marc.info/?l=netfilter-devel&m=134543407803412&w=2

	In this context, may be soon we will modify ip_vs_ftp to
support IPv6. It is possible to work with present FTP helper
in netfilter. Does it mean that we will see only reassembled
packets when conntrack is running? No original fragments.
Are we prepared to work in both ways (originals+reasm and
just reasm) ?

- For patch 3 in Kconfig do we need 'select NF_DEFRAG_IPV6' ?

	Basicly, I'm concerned what will happen when we
start to mangle the protocol payloads (FTP). For now
we are safe by touching only addresses and ports. May be
we have to synchronize these changes with the work from
Patrick.

Regards

--
Julian Anastasov <ja@ssi.bg>
