Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794589770;
	b=CLOBm8pYrmxBAZygHJ9p/9mD2ZurtwlZYitZY89egasxY6kxpfU/qVpVLiE6pn97w7dj
	 jJje2M2omCaGQvQGeYnbrCRMDbtGvGA5xwFUbiOyTx3A6M8nyQghY+N/W3wtel9SDetoS
	 0pcpxZgdOed+EZmWFUvWyS2RCdFMucuubp9mhZXLec2voC9cc2IIc1ySSzYNzNGXNzCEz
	 +/actRkPfWBNN6np+DOq5dPcwd03LHUvgnMAsOA/UDJe5jjwZYjV0lcX1pIjxpPG5RfY/
	 d3dFQdzvB+EJJyxdSk8ci1BIMRslY7ba8q8RYcD6wXR3/buHaTgpHU9VBJaJOwdYU9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794589770;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=+F0Iks+dE4n0hg1LkpvcmSNuXnlApLyi+gzeheXSIZs=;
	b=rSL+iKdAEPTok6Fk10TEX+2/rwZpMSaPL2Djfxx9JGEHcE2R6lAhYdtZM72BNp89CSEZ
	 gX60vh1RJjKvtxJgQkON4dhh2TDJ9nP0Ca66y00DI0gF6Nk7lakwax5ag41xLmzJVddRW
	 O6DZtjl3g0Dbo+BT8NEfj7nk0ySte7BxT+TNbtlUxqPNX0+Sxkwu8GjMX7/JVOORJalyy
	 rMcMiyp6+7TrQPcosOEnq3LqpvDBmJmWNXVDSxqtRV0Bkr3+Gn/4XKzmPK1AHS7kEDqCN
	 Blcjt1dvk3XtMf4CxTDDNXDwxdP9IDt03nFYWA2jEBQO2kkq6exFp2OL1vwBGcXuTOQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HPT0Paig;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5326606A323;
	Fri, 13 Nov 2026 17:09:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HPT0Paig
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 755101F000C4;
	Fri, 13 Nov 2026 17:09:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794589770;
	bh=+F0Iks+dE4n0hg1LkpvcmSNuXnlApLyi+gzeheXSIZs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=HPT0Paiglm/dpF3vAkvP2m1DeBK60ryjcJJq5eOVcYz+aNI8HRhNEUVzl3Iab+yeS
	 kJ0/ylOSqptlMKQ8aBol6kMFNJdwhJRUnFtTJjaqqQOZCAUTNcebSQUdal8X/HlUV+
	 0z1idE4x8FeUqhMiiKWD06yx4XPTPmX03PmKC6nbru70aAwUcsnmd9HfOqd/ZIWhxX
	 CvORQZDtkGkXvuUQqAbZ+dG78sO9qo2l4EUxdf14GE1Kh3HqDbqMA53SM7iMQ7vFcI
	 KmWmNJ62tm3BfXmiYpZvFgKcVk/4BAmCC52gtvTpVnw7BRJ69AXRgGAQfEWi5RNU8B
	 9V8pYZPYmRTAg==
Date: Fri, 13 Nov 2026 17:09:22 +0000
From: Simon Horman <horms@kernel.org>
To: netdev-bot+sashiko@kernel.org
Cc: jiayuan.chen@linux.dev, netdev@vger.kernel.org, dsahern@kernel.org,
	idosch@nvidia.com, davem@davemloft.net, edumazet@kernel.org,
	kuba@kernel.org, pabeni@redhat.com, pablo@netfilter.org,
	fw@strlen.de, phil@nwl.cc, razor@blackwall.org, paul@paul-moore.com,
	matttbe@kernel.org, martineau@kernel.org, geliang@kernel.org,
	ja@ssi.bg, achender@kernel.org, marcelo.leitner@gmail.com,
	lucien.xin@gmail.com, alibuda@linux.alibaba.com,
	dust.li@linux.alibaba.com, sidraya@linux.ibm.com,
	mjambigi@linux.ibm.com, tonylu@linux.alibaba.com,
	guwen@linux.alibaba.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux.dev, linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev, lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH net-next 01/14] ipv4: annotate data-races around ip_rt_*
 sysctls
Message-ID: <20261113170922.GL18859@horms.kernel.org>
References: <20261109025425.328445-2-jiayuan.chen@linux.dev>
 <179428999715.994134.14310277652030711794@kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <179428999715.994134.14310277652030711794@kernel.org>

On Tue, Nov 10, 2026 at 05:53:17AM +0000, netdev-bot+sashiko@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found more severe
> issue(s) in other patches of this series. This mail is only an FYI, in case
> you want to address the nit picks below when you respin.
> 
> Low priority / nit picks for your consideration:
> 
> - [Low] In __ip_rt_update_pmtu() (net/ipv4/route.c), the patch adds two
>   separate READ_ONCE() loads of net->ipv4.ip_rt_min_pmtu.
> 
> --
> 
> ipv4: annotate data-races around ip_rt_* sysctls
> 
> This adds READ_ONCE() to the lockless readers of several ip_rt_* route
> sysctls in net/ipv4/route.c. Their sysctl handlers write them with
> WRITE_ONCE(). The change was prompted by a KCSAN report on
> net.ipv4.route.min_adv_mss in ipv4_default_advmss().
> 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index d0a5f6d77094c..83f49b2d4c36a 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> 
> [ ... ]
> 
> > @@ -1063,14 +1066,14 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
> >  
> >  	rcu_read_lock();
> >  	net = dst_dev_net_rcu(dst);
> > -	if (mtu < net->ipv4.ip_rt_min_pmtu) {
> > +	if (mtu < READ_ONCE(net->ipv4.ip_rt_min_pmtu)) {
> >  		lock = true;
> > -		mtu = min(old_mtu, net->ipv4.ip_rt_min_pmtu);
> > +		mtu = min(old_mtu, READ_ONCE(net->ipv4.ip_rt_min_pmtu));
> 
> [Severity: Low]
> READ_ONCE() is volatile, so __ip_rt_update_pmtu() now always does two
> separate loads of ip_rt_min_pmtu. If net.ipv4.route.min_pmtu is written
> between them, can the check and the clamp see different values?
> 
> For example, take old_mtu=1500 and an ICMP FRAG_NEEDED carrying mtu=300:
> 
>   first load sees min_pmtu=552   -> lock = true
>   sysctl write sets min_pmtu=68  (accepted, extra1 is ip_min_valid_pmtu)
>   second load sees 68            -> mtu = min(1500, 68) = 68
> 
> update_or_create_fnhe() would then store pmtu=68 with fnhe_mtu_locked set,
> and it stays that way for ip_rt_mtu_expires. The old setting would give
> 552 locked, and the new setting would give 300 unlocked.
> 
> Before this patch, the compiler could merge the two plain loads into one.
> Only a privileged writer can trigger this, because min_pmtu is not exported
> to netns owned by non-init user namespaces. Later patches in the series
> don't seem to change this.
> 
> Could the value be read once into a local? This patch already does that
> in ip_error() with burst and cost.
> 
> A smaller case of the same pattern affects ip_rt_mtu_expires in the same
> function. It is re-read for the freshness check:
> 
> 	    time_before(jiffies, READ_ONCE(dst->expires) -
> 				 READ_ONCE(net->ipv4.ip_rt_mtu_expires) / 2))
> 
> It is read again for each nexthop in the multipath loop, and once more for
> the single-path update_or_create_fnhe() call. Could nexthops updated in
> one call get different expiries?
> 
> ip_rt_redirect_number is also read twice in ip_rt_send_redirect():
> 
> 	if (peer->n_redirects >= READ_ONCE(ip_rt_redirect_number)) {
> 	...
> 		    peer->n_redirects == READ_ONCE(ip_rt_redirect_number))
> 
> The second read only gates the "ignores redirects" warning, so there the
> only effect is on logging. Should these be loaded into locals once as
> well?
> 
> >  	}
> >  
> >  	if (rt->rt_pmtu == mtu && !lock &&

I think it would be best to address this issue.
