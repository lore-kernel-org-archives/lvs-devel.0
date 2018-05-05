From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for
 IPPROTO_TCP
Date: Sat, 5 May 2018 15:58:25 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1805051515450.1895@ja.home.ssi.bg>
References: <20180419212324.1542504-1-kafai@fb.com> <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg> <20180502171041.s3euld6i7hm6bw5c@kafai-mbp> <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg> <20180503070114.bcuusvzga45klccs@kafai-mbp>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180503070114.bcuusvzga45klccs@kafai-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin KaFai Lau <kafai@fb.com>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org


	Hello,

On Thu, 3 May 2018, Martin KaFai Lau wrote:

> > - when exactly we start to use the new PMTU, eg. what happens
> > in case socket caches the route, whether route is killed via
> > dst->obsolete. Or may be while the PMTU expiration is handled
> > per-packet, the PMTU change is noticed only on ICMP...
> Before sk can reuse its dst cache, the sk will notice
> its dst cache is no longer valid by calling dst_check().
> dst_check() should return NULL which is one of the side
> effect of the earlier update_pmtu().  This dst_check()
> is usually only called when the sk needs to do output,
> so the new PMTU route (i.e. the RTF_CACHE IPv6 route)
> only have effect to the later packets.

	I checked again the code and it looks like sockets
are forced to use new exceptional route (RTF_CACHE/fnhe) via
dst_check only when the PMTU update should move them away
from old non-exceptional routes. Later, if PMTU is
reduced/updated this is noticed for every packet via dst_mtu,
as in the case with TCP.

	So, except the RTF_LOCAL check in __ip6_rt_update_pmtu
we should have no other issues. Only one minor bit is strange to me,
why rt6_insert_exception warns for RTF_PCPU if rt6_cache_allowed_for_pmtu
allows it when returning true... 

	Also, commit 0d3f6d297bfb allows rt6_do_update_pmtu() for
routes without RTF_CACHE, RTF_PCPU and rt6i_node. Should we
restrict rt6_do_update_pmtu only to RTF_CACHE routes?

 	if (!rt6_cache_allowed_for_pmtu(rt6)) {
-		rt6_do_update_pmtu(rt6, mtu);
-		/* update rt6_ex->stamp for cache */
-		if (rt6->rt6i_flags & RTF_CACHE)
+		if (rt6->rt6i_flags & RTF_CACHE) {
+			rt6_do_update_pmtu(rt6, mtu);
+			/* update rt6_ex->stamp for cache */
 			rt6_update_exception_stamp_rt(rt6);
+		}
 	} else if (daddr) {

Regards
