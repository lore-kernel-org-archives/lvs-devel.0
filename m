From: Julian Anastasov <ja@ssi.bg>
Subject: Re: activeconns * weight overflowing 32-bit int
Date: Sat, 13 Apr 2013 18:10:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304131736430.1662@ja.ssi.bg>
References: <20130413064355.GB24319@hostway.ca>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130413064355.GB24319@hostway.ca>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Kirby <sim@hostway.ca>
Cc: lvs-devel@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>


	Hello,

On Fri, 12 Apr 2013, Simon Kirby wrote:

> Hello!
> 
> We use lblc in some environments to try to maintain some cache locality.
> 
> We recently had some problems upgrading beyond 2.6.38 in one environment.
> The cluster kept overloading real servers and showed flapping that didn't
> occur on 2.6.38 and older. I was never able to figure this out, but I
> think now I see the reason.
> 
> We need to use fairly high weights, since lblc requires this in order to
> do rescheduling in the event of overload. In the event that we have 3000
> activeconns to a real server and a weight of 3000, the next connection
> will check to see if any other real server has 2*activeconns less than
> its weight, and if so, reschedule by wlc.
> 
> With b552f7e3a9524abcbcdf86f0a99b2be58e55a9c6, which "git tag --contains"
> says appeared in 2.6.39-rc, the open-coded activeconns * 50 + inactconns
> was changed to ip_vs_dest_conn_overhead() that matches the implementation
> in ip_vs_wlc.c and others. The problem for us is that ip_vs_lblc.c uses
> "int" (and wlc uses "unsigned int") for "loh" and "doh" variables that
> the ip_vs_dest_conn_overhead() result is stored in, and then these are
> multiplied by the weight.
> 
> ip_vs_dest_conn_overhead() uses (activeconns << 8) + inactconns (* 256
> instead of * 50), so before where 3000 * 3000 * 50 would fit in an int,
> 3000 * 3000 * 256 does not.

	There is no big difference between 50 and 256.

> We really don't care about inactconns, so removing the "<< 8" and just
> using activeconns would work for us, but I suspect it must be there for a
> raeason. "unsigned long" would fix the problem only for 64-bit arches.
> Using __u64 would work everywhere, but perhaps be slow on 32-bit arches.
> Thoughts?

	May be we can avoid 64-bit multiply with a
32*32=>64 optimization, for example:

-               if (loh * atomic_read(&dest->weight) >
-                   doh * atomic_read(&least->weight)) {
+               if ((__u64) loh * atomic_read(&dest->weight) >
+                   (__u64) doh * atomic_read(&least->weight)) {

	May be __s64/__u64 does not matter here. Can you
create and test such patch for lblc and lblcr against
ipvs-next or net-next tree? Such change should be also
applied to other schedulers but it does not look so critical.

Regards

--
Julian Anastasov <ja@ssi.bg>
