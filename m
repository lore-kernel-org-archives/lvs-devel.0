Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3C55340A4D;
	Wed, 26 Nov 2025 19:40:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764186007; cv=none; b=hA4Y7pJfBDsnaEwCv6XfBPxbL4yGqwlSC3o+50oxg5cvxaFEXaKuGmL6nkvRRaufJmSoL9qjYnmWn4263/ej3nY5leUVCi4/diNycBnv/Xba9bnLyGKfB8T7pDjqXDpLO2SFs5NASZYpDTjvKh7p+ZBk/a7SwDmwr5CJMblnRuw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764186007; c=relaxed/simple;
	bh=YX4q/wcpA5y1fCOLi2L2c3p9kDasf1tI1rL12depJOQ=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=WCNiudeIDE5nnev0eA3LRp0LJ8oicMe/odgW2nJPHgUi5L9CJc4ZUh+y67P1YNOmv+rjX5j52ukdLIflYC1TjHWP9a1x7E99McLyTziSmcKu6JWvX1wfANMY3LoxYJI+7FQDO0KdwdoSaUpmLh2owDLVzH8BWT1zThuxJoKW1zY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=7oSd+9U7; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="7oSd+9U7"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id ED8472119C;
	Wed, 26 Nov 2025 21:39:52 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=AJ19/uiGm0nWORtRyjBPrH/LQasoFUjJbG+DeVntpCQ=; b=7oSd+9U7uGUV
	wyLI9WZVTjwB3EEaQGHJ3k9lrNWE1CsUlOcZjoglmhMGrCnBqvhi+h2SDUb84Wrt
	yDrc6Vv2TTQ+q7Z8uSBp30q11QZVcTb0M7gV1TdKmz/foJ5l2w8aiyiLyp8ftnwK
	QMx+iyeoefEhTjqIyTQQ1gwZ3gAjVSq94hNDhqb6jhY+6tAXBd/dheaFgkPY4zwQ
	p55qd4PR6+eSrJAukOG8q1AFlZCGduSpuRsPIp6OwzsFhKP8poWGUFmutTCT3ywW
	6RJki4HCVjSO99CRNVgw+7Jxet2/kT5T2vybYJ7VI1vMNJdkV4xIV323el3sSefb
	XeiiEUQU2Zscq18CMOUMsZ+PRHbiafv75L1hGSpRuPVThV9pI7WJsnXKHlDZCgEr
	BJVxHb1uu3TgYGgB+PHBtpsg+z6e1ZYkM6qv+wK3ZC7Lz56+8jvxPvEMU+NulkGs
	mxAyV8dTTuIwR+milUn0W3bjGuqGIvcEhHbs3C2E/6QP7w6j86pUg3br2txKEkIA
	ZnNy1oWK2iatkgWuyYMyqHHLt/pjztlpZRu7sj/b2lwyBKw5f4qa4QNQxaY6gDlo
	dVCiImsuJYYVryuRfAgADE33UvA9guM//rgcZL9N8+Nt+YENPVpqfGHHsdh9bRYO
	HMSgiOMZsECZ9n0u3T4QO2tmCmrpm6s=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 26 Nov 2025 21:39:51 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4FBA76580E;
	Wed, 26 Nov 2025 21:39:49 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 5AQJdaAn040800;
	Wed, 26 Nov 2025 21:39:36 +0200
Date: Wed, 26 Nov 2025 21:39:36 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 03/14] ipvs: some service readers can use
 RCU
In-Reply-To: <aSTHJAR5aXml2ms0@calendula>
Message-ID: <a1339ab7-7363-bc56-7b30-5bdbd43e3bd0@ssi.bg>
References: <20251019155711.67609-1-ja@ssi.bg> <20251019155711.67609-4-ja@ssi.bg> <aSTHJAR5aXml2ms0@calendula>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 24 Nov 2025, Pablo Neira Ayuso wrote:

> On Sun, Oct 19, 2025 at 06:57:00PM +0300, Julian Anastasov wrote:
> > Some places walk the services under mutex but they can just use RCU:
> > 
> > * ip_vs_dst_event() uses ip_vs_forget_dev() which uses its own lock
> >   to modify dest
> > * ip_vs_genl_dump_services(): ip_vs_genl_fill_service() just fills skb
> > * ip_vs_genl_parse_service(): move RCU lock to callers
> >   ip_vs_genl_set_cmd(), ip_vs_genl_dump_dests() and ip_vs_genl_get_cmd()
> > * ip_vs_genl_dump_dests(): just fill skb
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c | 47 +++++++++++++++++-----------------
> >  1 file changed, 23 insertions(+), 24 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index 2fb9034b4f53..b18d08d79bcb 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -1759,23 +1759,21 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
> >  	if (event != NETDEV_DOWN || !ipvs)
> >  		return NOTIFY_DONE;
> >  	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
> > -	mutex_lock(&ipvs->service_mutex);
> > +	rcu_read_lock();
> 

	First, thanks for the review!

> Control plane can still add destinations to svc->destinations that can
> be skipped by the rcu walk. I think it should be possible to trigger
> leaks with a sufficiently large list, given concurrent updates can
> happen. ip_vs_forget_dev() has its own lock, but this is a per-dest
> lock which is taken during the list walk.

	Even if dest is added, its dest_dst will be allocated on
next packet. And this is not the real problem.

	The race is different: the first flow
clears __LINK_STATE_START, IFF_UP and then notifies for
NETDEV_DOWN ip_vs_dst_event() and then FIB. During
ip_vs_dst_event() device is down but the routes are
not dead yet. The second flow can call do_output_route4() and
create again dest->dest_dst because the routes still
work, see fib_lookup_good_nhc(). Even adding new dest can
trigger this. It can happen even immediately after a
mutex unlock in ip_vs_dst_event(). And the problem is that
during the notification phase there is a gap where we can
attach new routes while the device is marked down
but it is not yet propagated to FIB.

	As we hold implicit reference to dev via
dst, if due to race we miss to drop a route, the dev
will be replaced with blackhole_netdev on
NETDEV_UNREGISTER. So, the leak is until UNREGISTER
or until next packet that will catch the dead route
in __ip_vs_dst_check(). And if dest is deleted we
always drop this route in __ip_vs_dst_cache_reset(),
the leak is gone.

	One way to make this rt caching more robust
is to add a netif_running() check together with the
IP_VS_DEST_F_AVAILABLE check that is under dst_lock after
the do_output_route4() call. By this way we synchronize
with both dest deletion and device closing. I'll
probably extend the patch with such change in the next
days, including the same for IPv6:

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index d57af95f1ebd..7b356ab8f439 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -295,6 +295,12 @@ static inline bool decrement_ttl(struct netns_ipvs *ipvs,
 	return true;
 }
 
+/* rt has device that is down */
+static bool rt_dev_is_down(const struct net_device *dev)
+{
+	return dev && !netif_running(dev);
+}
+
 /* Get route to destination or remote server */
 static int
 __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
@@ -335,7 +341,8 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			 * for very short period and it must be checked under
 			 * dst_lock.
 			 */
-			if (dest->flags & IP_VS_DEST_F_AVAILABLE)
+			if (dest->flags & IP_VS_DEST_F_AVAILABLE &&
+			    !rt_dev_is_down(rt->dst.dev))
 				__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
 			else
 				noref = 0;

> > @@ -3915,9 +3911,12 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
> >  	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
> >  		need_full_svc = true;
> >  
> > +	/* We use function that requires RCU lock */
> > +	rcu_read_lock();
> 
> This is ip_vs_genl_set_cmd path and the new per-netns mutex is held.
> 
> I think __ip_vs_service_find() can now just access this mutex to check
> if it is held, using fourth parameter:
> 
>         list_for_each_entry_rcu(..., lockdep_is_held(&ipvs->service_mutex))
> 
> Then this rcu_read_lock() after mutex_lock(&ipvs->service_mutex) can
> be removed. I suspect you added it to quiet a rcu debugging splat.

	Yep, that is why the above comment. I'll check this...

Regards

--
Julian Anastasov <ja@ssi.bg>

