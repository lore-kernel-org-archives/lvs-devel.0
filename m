From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Sun, 20 Oct 2013 09:33:08 +0200
Message-ID: <20131020073308.GE27787@order.stressinduktion.org>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au> <alpine.LFD.2.03.1310180153250.4554@ssi.bg> <20131018021008.GH18135@order.stressinduktion.org> <alpine.LFD.2.03.1310191919290.1469@ssi.bg> <20131019183433.GC31333@order.stressinduktion.org> <20131019223657.GH31333@order.stressinduktion.org> <alpine.LFD.2.03.1310200939330.1538@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310200939330.1538@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Mark Brooks <mark@loadbalancer.org>, Phil Oester <kernel@linuxace.com>

On Sun, Oct 20, 2013 at 10:11:16AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 20 Oct 2013, Hannes Frederic Sowa wrote:
> 
> > > Hm, maybe. I don't have too much insight into netfilter stack and
> > > what are the differences between OUTPUT and FORWARD path but plan to
> > > investigate. ;)
> > 
> > It seems tables are processed with bh disabled, so no preemption while
> > recursing. So I guess the use of tee_active is safe for breaking the
> > tie here.
> 
> 	May be, I'll check it again, for now I see only
> rcu_read_lock() in nf_hook_slow() which is preemptable.
> Looking at rcu_preempt_note_context_switch, many levels of
> RCU locks are preemptable too.

The caller I found was ip6t_do_table which does deactivate bottom halves.
Maybe there are others I did not see, so double checking is better.

> 	In my test I used link route to local subnet, --gateway to IP
> that is not present. I'll try other variants.

Is your kernel compiled with CONFIG_IPV6_ROUTER_PREF?

> > The more I review the patch the more I think it is ok. But we could actually
> > try to just always return rt6i_gateway, as we should always be handed a cloned
> > rt6_info where the gateway is already filled in, no?
> 
> 	Yes, this patch is ok and after spending the whole
> saturday I'm preparing a new patch that will convert
> rt6_nexthop() to return just rt6i_gateway, without daddr.
> This can happen after filling rt6i_gateway in all places.
> 
> 	For your concern for loopback, I don't see problem,
> local/anycast route will have rt6i_gateway=IP, they are
> simple DST_HOST routes. I'm preparing now the patches and
> will post them in following hours.

Ok, that's a nice simplification. I'll have a look tomorrow.

I cannot test my patch today any more, so I just leave it here. It is only
compile tested. Maybe you can make use of it:

Btw: I cannot put a reference to the rt6_info into __rt6_probe_work because we
are not supposed to use rt6_info reference counters outside of ip6_fib
because the deletion from the fib will break otherwise.

Maybe we should also create a seperate ipv6 workqueue. Will check later.

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c3130ff..6c539bc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -476,6 +476,40 @@ out:
 }
 
 #ifdef CONFIG_IPV6_ROUTER_PREF
+struct __rt6_probe_work {
+	struct work_struct work;
+	struct in6_addr target;
+	struct net_device *dev;
+};
+
+static void rt6_probe_deferred(struct work_struct *w)
+{
+	struct in6_addr mcaddr;
+	struct __rt6_probe_work *work =
+		container_of(w, struct __rt6_probe_work, work);
+
+	addrconf_addr_solict_mult(&work->target, &mcaddr);
+	ndisc_send_ns(work->dev, NULL, &work->target, &mcaddr, NULL);
+	dev_put(work->dev);
+	kfree(w);
+}
+
+static bool rt6_probe_later(struct rt6_info *rt)
+{
+	struct __rt6_probe_work *work;
+
+	work = kmalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work)
+		return false;
+
+	INIT_WORK(&work->work, rt6_probe_deferred);
+	work->target = rt->rt6i_gateway;
+	dev_hold(rt->dst.dev);
+	work->dev = rt->dst.dev;
+	schedule_work(&work->work);
+	return true;
+}
+
 static void rt6_probe(struct rt6_info *rt)
 {
 	struct neighbour *neigh;
@@ -499,17 +533,10 @@ static void rt6_probe(struct rt6_info *rt)
 
 	if (!neigh ||
 	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
-		struct in6_addr mcaddr;
-		struct in6_addr *target;
-
-		if (neigh) {
-			neigh->updated = jiffies;
+		if (neigh)
 			write_unlock(&neigh->lock);
-		}
