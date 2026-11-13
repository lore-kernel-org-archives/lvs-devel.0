Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590056;
	b=Cv4TA9CRo4b4ciW6maPsblm/Z1CqA8LStOYWvVTyF4yKOPxzJOxAyxLdsw/XDhP9XYEh
	 CjcxLlVYMIw+wRM04w3ACxf1AOO3dM5lnHsiqsw+okbKBAwqHtxJZbk2h1QX0h1YUwCe5
	 rlBFeyP3rBNsCeGuqYdB1OiFWP5cmQI1udKMt4G3xo10JsX2OZUBBeL8H5XCDhHEspiae
	 xMpkDfVdSQKTmwxVPkOwK93bQMlDjZ93mlxbdLnXqxu1yOr9F3d4RJLPoIxaxkzCrSYAk
	 LG2FLo0j1Mboo5PDRF5QY6mxA1qFQpGK1VgxjJT+d4A8yfiZoiKX556UKAo5AEhIiCQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590056;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To;
	bh=8zEUtU3NrH0Vnr3AaC6OVuCQcGRPjf9GkR7fU3Z6j3U=;
	b=oGYtv2cDfLOjIvJrBSWOTF3/WzWGwWcjLU3gm78VuJmPmqtgXebWyvgswfRrwGqQWh2T
	 yfirwiRyg2f2iUMsgcBTsK4QIuc+pC7hNzBuonXGSfzOqm2dfVs+D8oQa8sglDqH7D5jQ
	 kiqUS1E/scfyId0Drk0KHx/sQy7hP3ytTkDIknaQD0lTDR944KREesEiCuwUf0tP6Nfdq
	 U5lbSpYui9S+VdvuTQxfNfd8sNEPCcOEqUGbkGKkR+bwVNotAc0bllUywLr5/uAWJQ4dY
	 yExUZFhXTYMiR0AeS8jWtnkXbMblrQ9fstRQqtHQiF6G+JKOnUGEhHWNa/fMz/iQPhQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eep61KBl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1B75606A8AA;
	Fri, 13 Nov 2026 17:14:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eep61KBl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B6F2C1F000CB;
	Fri, 13 Nov 2026 17:14:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590055;
	bh=8zEUtU3NrH0Vnr3AaC6OVuCQcGRPjf9GkR7fU3Z6j3U=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=eep61KBlNlzGeP7TAbKMPEuELQlAOysuYgrRzX86Qe+/Y19mr8r5tPwAWLse6HbHm
	 xJ8JTv/bhiumuex+hbpaD9n2mcoMZwq+nRF2tDycVp5H+fjYfU3NXkuQtl2UsawvgM
	 Lse1leWTEHrBXWcGGSd+RuFPfrBvCsvm/CxnBa0jEZ6v/FwrD3cOUv1w7AtYefJYlE
	 Kx43vbwulzFuq9bkPxHhBrgwuk5WCPFjr2mMtKQ9G1sCjJsnuh3zAKU4FPqTe3t7HA
	 aWB30rpvhu7Vm9QOo1DCVs/ZvW3FwAosjq8eEfg44qICk0P8wk5psns5mH6AQLBbot
	 mh2iwq1NwfZ5A==
Date: Fri, 13 Nov 2026 17:14:07 +0000
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
Subject: Re: [PATCH net-next 05/14] calipso: annotate data-races around cache
 sysctls
Message-ID: <20261113171407.GP18859@horms.kernel.org>
References: <20261109025425.328445-6-jiayuan.chen@linux.dev>
 <179428999963.994134.16904544500890053668@kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <179428999963.994134.16904544500890053668@kernel.org>

On Tue, Nov 10, 2026 at 05:53:19AM +0000, netdev-bot+sashiko@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found 1 potential
> issue(s) to consider.
> 
> Critical: 0 · High: 1 · Medium: 0 · Low: 0
> 
> If you believe none of the issues are legitimate, please reply to each
> issue of Medium severity or higher and explain why the AI is wrong.
> If any of them are legitimate and you plan to respin, please let patchwork
> know by including "pw-bot: cr" as a separate line at the end of your reply
> (one such reply per series is enough).
> 
> - [High] calipso_cache_add() in net/ipv6/calipso.c still reads
>   calipso_cache_bucketsize twice, and the two reads can disagree.
> 
> --
> 
> calipso: annotate data-races around cache sysctls
> 
> This commit adds READ_ONCE() to the lockless readers of
> calipso_cache_enabled and calipso_cache_bucketsize in net/ipv6/calipso.c.
> The sysctl handlers update these variables with WRITE_ONCE().
> 
> > diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
> > index e399a42e30839..5e63212b60163 100644
> > --- a/net/ipv6/calipso.c
> > +++ b/net/ipv6/calipso.c
> 
> [ ... ]
> 
> > @@ -269,7 +269,7 @@ static int calipso_cache_add(const unsigned char *calipso_ptr,
> >  	struct calipso_map_cache_entry *old_entry = NULL;
> >  	u32 calipso_ptr_len;
> >  
> > -	if (!calipso_cache_enabled || calipso_cache_bucketsize <= 0)
> > +	if (!READ_ONCE(calipso_cache_enabled) || READ_ONCE(calipso_cache_bucketsize) <= 0)
> >  		return 0;
> >  
> >  	calipso_ptr_len = calipso_ptr[1];
> > @@ -289,7 +289,7 @@ static int calipso_cache_add(const unsigned char *calipso_ptr,
> >  
> >  	bkt = entry->hash & (CALIPSO_CACHE_BUCKETS - 1);
> >  	spin_lock_bh(&calipso_cache[bkt].lock);
> > -	if (calipso_cache[bkt].size < calipso_cache_bucketsize) {
> > +	if (calipso_cache[bkt].size < READ_ONCE(calipso_cache_bucketsize)) {
> >  		list_add(&entry->list, &calipso_cache[bkt].list);
> >  		calipso_cache[bkt].size += 1;
> >  	} else {
> 
> [Severity: High]
> Can these two separate READ_ONCE() loads of calipso_cache_bucketsize in
> calipso_cache_add() return different values?
> 
> The first load is unlocked and only guards the early return. The second
> load comes later, under the bucket spinlock, after the GFP_ATOMIC
> allocations, jhash() and refcount_inc().
> 
> The bucket lock does not cover the sysctl. Also, calipso_cache_bucket_size
> in net/ipv6/sysctl_net_ipv6.c uses plain proc_dointvec with no
> extra1/extra2 bounds, so 0 or a negative value can be written during that
> window.
> 
> Suppose three things happen together:
> 
>   - the first load sees a positive value
>   - a concurrent write of 0 lands before the second load
>   - the hashed bucket is empty (size == 0)
> 
> Then the size check is false, and the eviction branch runs on an empty
> list:
> 
>     old_entry = list_entry(calipso_cache[bkt].list.prev,
>                            struct calipso_map_cache_entry, list);
>     list_del(&old_entry->list);
>     list_add(&entry->list, &calipso_cache[bkt].list);
>     calipso_cache_entry_free(old_entry);
> 
> Here old_entry is container_of() applied to the bucket's own list head.
> list_del() poisons the head, and list_add() then dereferences
> LIST_POISON1.
> 
> Wouldn't that oops in softirq context with the bucket lock held?
> 
> If execution got past that point, calipso_cache_entry_free() would free
> whatever sits at the key and lsm_data offsets of the fake entry. Those
> offsets overlap neighbouring buckets. It would then kfree() a pointer into
> the middle of the calipso_cache array.
> 
> Separately, if only the second load sees a negative value, it is
> converted to a huge u32 limit and the bucket size cap is skipped.
> 
> This window existed before this patch, since spin_lock_bh() already forced
> a reload. However, this commit is meant to fix the racy reads of this
> exact variable. Could it take a single snapshot instead? That is what
> cipso_v4_cache_add() has done since commit dd44f04b9214ad ("cipso: Fix
> data-races around sysctl."):
> 
> net/ipv4/cipso_ipv4.c:cipso_v4_cache_add() {
> 	int bkt_size = READ_ONCE(cipso_v4_cache_bucketsize);
> 	...
> 	if (!READ_ONCE(cipso_v4_cache_enabled) || bkt_size <= 0)
> 		return 0;
> 	...
> 	if (cipso_v4_cache[bkt].size < bkt_size) {
> 	...
> }
> 
> No later patch in the series changes net/ipv6/calipso.c.

This problem looks legit to me.

-- 
pw-bot: changes-requested
