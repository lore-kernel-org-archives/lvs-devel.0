From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for IPPROTO_TCP
Date: Mon, 7 May 2018 09:22:31 -0700
Message-ID: <20180507162229.5ndsjremhfdtbeqj@kafai-mbp.dhcp.thefacebook.com>
References: <20180419212324.1542504-1-kafai@fb.com>
 <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg>
 <20180502171041.s3euld6i7hm6bw5c@kafai-mbp>
 <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg>
 <20180503070114.bcuusvzga45klccs@kafai-mbp>
 <alpine.LFD.2.20.1805051515450.1895@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=date : from : to : cc :
 subject : message-id : references : mime-version : content-type :
 in-reply-to; s=facebook; bh=AFMFnZoYqpWnD9c1cpDeX4d8Yo38mKTm/FdmBzOCyS0=;
 b=izclICuW079oiSJQV8KsTR/F/rsYlLuujHNySg/vASMj4BTcouxGHezAFwUuOqdu/Tsy
 gcMGu1w01bYRqYMXDU2A7b32cPFTXTNZalMai6O/yUfdmaCKJF//DyIr6wn7KRhp9v8e
 QEwwBhWdnjiPtG+AkirSr2OmykIUcmJ/NwE= 
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1805051515450.1895@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org

On Sat, May 05, 2018 at 03:58:25PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 3 May 2018, Martin KaFai Lau wrote:
> 
> > > - when exactly we start to use the new PMTU, eg. what happens
> > > in case socket caches the route, whether route is killed via
> > > dst->obsolete. Or may be while the PMTU expiration is handled
> > > per-packet, the PMTU change is noticed only on ICMP...
> > Before sk can reuse its dst cache, the sk will notice
> > its dst cache is no longer valid by calling dst_check().
> > dst_check() should return NULL which is one of the side
> > effect of the earlier update_pmtu().  This dst_check()
> > is usually only called when the sk needs to do output,
> > so the new PMTU route (i.e. the RTF_CACHE IPv6 route)
> > only have effect to the later packets.
> 
> 	I checked again the code and it looks like sockets
> are forced to use new exceptional route (RTF_CACHE/fnhe) via
> dst_check only when the PMTU update should move them away
> from old non-exceptional routes. Later, if PMTU is
> reduced/updated this is noticed for every packet via dst_mtu,
> as in the case with TCP.
> 
> 	So, except the RTF_LOCAL check in __ip6_rt_update_pmtu
> we should have no other issues. Only one minor bit is strange to me,
> why rt6_insert_exception warns for RTF_PCPU if rt6_cache_allowed_for_pmtu
> allows it when returning true...
hmm...I am not sure I follow this bits.  Where is the warn?

Note that "nrt6" and "from" are passed to rt6_insert_exception()
instead of "rt6".

> 
> 	Also, commit 0d3f6d297bfb allows rt6_do_update_pmtu() for
> routes without RTF_CACHE, RTF_PCPU and rt6i_node. Should we
> restrict rt6_do_update_pmtu only to RTF_CACHE routes?
> 
>  	if (!rt6_cache_allowed_for_pmtu(rt6)) {
> -		rt6_do_update_pmtu(rt6, mtu);
The existing rt6_do_update_pmtu() looks correct.
The mtu of the dst created by icmp6_dst_alloc()
needs to be udpated and this dst does not have
the RTF_CACHE.


> -		/* update rt6_ex->stamp for cache */
> -		if (rt6->rt6i_flags & RTF_CACHE)
> +		if (rt6->rt6i_flags & RTF_CACHE) {
> +			rt6_do_update_pmtu(rt6, mtu);
> +			/* update rt6_ex->stamp for cache */
>  			rt6_update_exception_stamp_rt(rt6);
> +		}
>  	} else if (daddr) {
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
