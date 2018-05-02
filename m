From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for
 IPPROTO_TCP
Date: Wed, 2 May 2018 22:30:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg>
References: <20180419212324.1542504-1-kafai@fb.com> <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg> <20180502171041.s3euld6i7hm6bw5c@kafai-mbp>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180502171041.s3euld6i7hm6bw5c@kafai-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin KaFai Lau <kafai@fb.com>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org


	Hello,

On Wed, 2 May 2018, Martin KaFai Lau wrote:

> On Wed, May 02, 2018 at 09:38:43AM +0300, Julian Anastasov wrote:
> > 
> > - initial traffic for port 21 does not use GSO. But after
> > every packet IPVS calls maybe_update_pmtu (rt->dst.ops->update_pmtu)
> > to report the reduced MTU. These updates are stored in fnhe_pmtu
> > but they do not go to any route, even if we try to get fresh
> > output route. Why? Because the local routes are not cached, so
> > they can not use the fnhe. This is what my patch for route.c
> > will fix. With this fix FTP-DATA gets route with reduced PMTU.
> For IPv6, the 'if (rt6->rt6i_flags & RTF_LOCAL)' gate in
> __ip6_rt_update_pmtu() may need to be lifted also.

	Probably. I completely forgot the IPv6 part
but as I don't know the IPv6 code enough, it may take
some time to understand what can be the problem there...
I'm not sure whether everything started with commit 0a6b2a1dc2a2,
so that in some configurations before that commit things
worked and problem was not noticed.

	I think, we should focus on such direction for IPv6:

- do we remember per-VIP PMTU for the local routes

- when exactly we start to use the new PMTU, eg. what happens
in case socket caches the route, whether route is killed via
dst->obsolete. Or may be while the PMTU expiration is handled
per-packet, the PMTU change is noticed only on ICMP...

- as IPVS reports the PMTU via dst.ops->update_pmtu() long
before any large packets are sent, do we propagate the
PMTU. Also, for IPv4 __ip_rt_update_pmtu() has some protection
from such per-packet updates that do not change the PMTU.

- if IPVS starts to send ICMP when gso_size exceeds PMTU,
like in my draft patch, whether the PMTU is propagated
to route and then to socket. As for the gso_size decrease,
playing in IPVS is not very safe, at least, we need help
from GSO experts to know how we should use it.

Regards
