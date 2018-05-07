From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for
 IPPROTO_TCP
Date: Mon, 7 May 2018 20:00:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1805071951590.24273@ja.home.ssi.bg>
References: <20180419212324.1542504-1-kafai@fb.com> <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg> <20180502171041.s3euld6i7hm6bw5c@kafai-mbp> <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg> <20180503070114.bcuusvzga45klccs@kafai-mbp>
 <alpine.LFD.2.20.1805051515450.1895@ja.home.ssi.bg> <20180507162229.5ndsjremhfdtbeqj@kafai-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180507162229.5ndsjremhfdtbeqj@kafai-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin KaFai Lau <kafai@fb.com>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org


	Hello,

On Mon, 7 May 2018, Martin KaFai Lau wrote:

> On Sat, May 05, 2018 at 03:58:25PM +0300, Julian Anastasov wrote:
> > 
> > 	So, except the RTF_LOCAL check in __ip6_rt_update_pmtu
> > we should have no other issues. Only one minor bit is strange to me,
> > why rt6_insert_exception warns for RTF_PCPU if rt6_cache_allowed_for_pmtu
> > allows it when returning true...
> hmm...I am not sure I follow this bits.  Where is the warn?

        if (ort->rt6i_flags & (RTF_CACHE | RTF_PCPU))
                ort = ort->from;

	Sorry, my fault, I missed above re-assignment...

        WARN_ON_ONCE(ort->rt6i_flags & (RTF_CACHE | RTF_PCPU));

> Note that "nrt6" and "from" are passed to rt6_insert_exception()
> instead of "rt6".
> 
> > 
> > 	Also, commit 0d3f6d297bfb allows rt6_do_update_pmtu() for
> > routes without RTF_CACHE, RTF_PCPU and rt6i_node. Should we
> > restrict rt6_do_update_pmtu only to RTF_CACHE routes?
> > 
> >  	if (!rt6_cache_allowed_for_pmtu(rt6)) {
> > -		rt6_do_update_pmtu(rt6, mtu);
> The existing rt6_do_update_pmtu() looks correct.
> The mtu of the dst created by icmp6_dst_alloc()
> needs to be udpated and this dst does not have
> the RTF_CACHE.

	Aha, ok. I thought, only RTF_CACHE routes can
hold PMTU.

Regards
