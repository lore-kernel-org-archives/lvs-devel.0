From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH RFC net-next] net: ipvs: Adjust gso_size for IPPROTO_TCP
Date: Thu, 3 May 2018 00:01:25 -0700
Message-ID: <20180503070114.bcuusvzga45klccs@kafai-mbp>
References: <20180419212324.1542504-1-kafai@fb.com>
 <alpine.LFD.2.20.1805020932270.1964@ja.home.ssi.bg>
 <20180502171041.s3euld6i7hm6bw5c@kafai-mbp>
 <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=date : from : to : cc :
 subject : message-id : references : mime-version : content-type :
 in-reply-to; s=facebook; bh=9fvBUEjUC6w3KUtcsRTllkDs7b2fTa96lJ09YVh5vvw=;
 b=CoGy5XaPE1tMIBzdzmk5iRUPwAsfdVOPRUMrzPhTvspu6CVPMfb+MU/PyZAUJsDfk4CT
 hgEO5yquIcFUYM4ooNscMZBN5FaRJqIkWY1lECo3GSIG9q/2GcvRuiKE+F6ibc0/DzoG
 uiJKnX6dgFsztMJkO0HJ7rTwYzRgl4a/2MY= 
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1805022143360.3301@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@gmail.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>, Nikita Shirokov <tehnerd@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org

On Wed, May 02, 2018 at 10:30:32PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 2 May 2018, Martin KaFai Lau wrote:
> 
> > On Wed, May 02, 2018 at 09:38:43AM +0300, Julian Anastasov wrote:
> > > 
> > > - initial traffic for port 21 does not use GSO. But after
> > > every packet IPVS calls maybe_update_pmtu (rt->dst.ops->update_pmtu)
> > > to report the reduced MTU. These updates are stored in fnhe_pmtu
> > > but they do not go to any route, even if we try to get fresh
> > > output route. Why? Because the local routes are not cached, so
> > > they can not use the fnhe. This is what my patch for route.c
> > > will fix. With this fix FTP-DATA gets route with reduced PMTU.
> > For IPv6, the 'if (rt6->rt6i_flags & RTF_LOCAL)' gate in
> > __ip6_rt_update_pmtu() may need to be lifted also.
> 
> 	Probably. I completely forgot the IPv6 part
> but as I don't know the IPv6 code enough, it may take
> some time to understand what can be the problem there...
> I'm not sure whether everything started with commit 0a6b2a1dc2a2,
> so that in some configurations before that commit things
> worked and problem was not noticed.
> 
> 	I think, we should focus on such direction for IPv6:
> 
> - do we remember per-VIP PMTU for the local routes
IPv6 used not to create cache route for DST_HOST route which
is a /128 route (that includes local /128 route).

Because of this, it had a bug such that a PMTU for the DST_HOST
route will trigger dst.ops->update_pmtu() which then set
an expire on the permanent /128 route instead of a cache
route.  The permanent route got unexpectedly expired/removed
later.

The fix was to allow creating /128 cache route as long as
it is not RTF_LOCAL in 653437d02f1f and 7035870d1219.  The
first post spelled out the problem better:
https://patchwork.ozlabs.org/patch/456050/

Later, when we only create cache route after seeing PMTU
in 45e4fd26683c, this RTF_LOCAL checking was carried over
to __ip6_rt_update_pmtu().

Out of my head, I don't see issue removing the
RTF_LOCAL check from __ip6_rt_update_pmtu().
DavidA, what do you think?

> 
> - when exactly we start to use the new PMTU, eg. what happens
> in case socket caches the route, whether route is killed via
> dst->obsolete. Or may be while the PMTU expiration is handled
> per-packet, the PMTU change is noticed only on ICMP...
Before sk can reuse its dst cache, the sk will notice
its dst cache is no longer valid by calling dst_check().
dst_check() should return NULL which is one of the side
effect of the earlier update_pmtu().  This dst_check()
is usually only called when the sk needs to do output,
so the new PMTU route (i.e. the RTF_CACHE IPv6 route)
only have effect to the later packets.

> 
> - as IPVS reports the PMTU via dst.ops->update_pmtu() long
> before any large packets are sent, do we propagate the
> PMTU. Also, for IPv4 __ip_rt_update_pmtu() has some protection
> from such per-packet updates that do not change the PMTU.
> 
> - if IPVS starts to send ICMP when gso_size exceeds PMTU,
> like in my draft patch, whether the PMTU is propagated
> to route and then to socket. As for the gso_size decrease,
> playing in IPVS is not very safe, at least, we need help
> from GSO experts to know how we should use it.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
