From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv3 16/24] IPVS: Add/adjust Netfilter hook functions and helpers for v6
Date: Wed, 3 Sep 2008 11:01:10 +0200
Message-ID: <f4845fc0809030201x3961e795xdbdbe2c1060afb5@mail.gmail.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
	 <1220363755-9854-17-git-send-email-juliusv@google.com>
	 <20080903054359.GB16875@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220432472; bh=VGWLbAqTT8fS1qcy01VpED/zgFg=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=E1sptACvDdkslbW4efHBAcP6esvARjE6
	AWyuvgxL5OMZKUjTsK1k0tcQw4L9GKrnjvxvqAisYLuSmeY9vJxjSg==
In-Reply-To: <20080903054359.GB16875@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Sep 3, 2008 at 7:44 AM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Sep 02, 2008 at 03:55:47PM +0200, Julius Volz wrote:
>> Add Netfilter hook functions or modify existing ones, if possible, to
>> process IPv6 packets. Some support functions are also added/modified for
>> this. ip_vs_nat_icmp_v6() was already added in the patch that added the v6
>> xmit functions, as it is called from one of them.
>
> Hi Julius,
>
> I was looking over this code a bit more closely to rebase someone
> elses patch (which I intend to post very soon). I noticed two
> minor things.
>
> 1) ipl doesn't seem to be needed in ip_vs_out_icmp() any more.
>   But actually I'm quite ok with it staying there because the
>   patch I was working on will need it.

ihl is still used for the length of the first IP header in the skb.
The struct "ip_vs_iphdr ciph" is only used later, for the embedded IP
header in the ICMP packet. It's needed because pp->conn_out_get()
expects a pointer to this struct as a parameter. I hope that makes
sense or did I miss something?

> 2) I wonder if iph could be initialised earleir in ip_vs_out_icmp_v6()

I'll answer this below:

> [snip]
>
>> @@ -727,11 +759,117 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
>
>>       return verdict;
>>  }
>>
>> -static inline int is_tcp_reset(const struct sk_buff *skb)
>> +#ifdef CONFIG_IP_VS_IPV6
>> +static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
>> +{
>> +     struct ipv6hdr *iph;
>> +     struct icmp6hdr _icmph, *ic;
>> +     struct ipv6hdr  _ciph, *cih;    /* The ip header contained
>> +                                        within the ICMP */
>> +     struct ip_vs_iphdr ciph;
>> +     struct ip_vs_conn *cp;
>> +     struct ip_vs_protocol *pp;
>> +     unsigned int offset, verdict;
>> +
>> +     *related = 1;
>> +
>> +     /* reassemble IP fragments */
>> +     if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
>> +             if (ip_vs_gather_frags_v6(skb, IP_DEFRAG_VS_OUT))
>> +                     return NF_STOLEN;
>> +     }
>> +
>> +     iph = ipv6_hdr(skb);
>
> Would it be worthwhile rearanging things so that iph is intialised
> before "/* reassemble IP fragments */" and used instead
> of ipv6_hdr(skb)->nexthdr in the if statement?

I followed the same structure as in the v4 version of ip_vs_out_icmp()
here. I think this might be needed because ip_vs_gather_frags{_v6}
changes the location of the IP header in the skb during reassembly?

>> +     offset = sizeof(struct ipv6hdr);
>> +     ic = skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
>> +     if (ic == NULL)
>> +             return NF_DROP;
>> +
>> +     IP_VS_DBG(12, "Outgoing ICMPv6 (%d,%d) " NIP6_FMT "->" NIP6_FMT "\n",
>> +               ic->icmp6_type, ntohs(icmpv6_id(ic)),
>> +               NIP6(iph->saddr), NIP6(iph->daddr));
>
> [snip]
>
>



-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
