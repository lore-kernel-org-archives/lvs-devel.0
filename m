Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794290002;
	b=ruFyiVAorYR8G3eUoKoV4RGY/9jnXZQzl0qopjQ/TXhvf43EKfa/PmCtdOIVWE9K2gPC
	 NXo2NpP/Hx4hmn+6F5lcSxhfqUofzM5361EGCkG+0u60Bf7e3YwGPY5E7trJsUQNkhIOV
	 B9qB8EMU2Vn3Wl+ZTXKKCiE74FOxR/u2pNEwz5woKGr/+xD0X6vyLd+yU88r+hrEcC0V4
	 jy3Gdgi4sfcDPqJ6pBIiY2xNF+LI1gRA14vYmKi4i2ZuEitmMU6pT4ZnqIrb5ou4P9qzP
	 szc1mMDi1NZEGjRrbplMZ4C+uqyNkMHpoZxMIucXu29fEyRm+b+AhzgjqE8CWRZBMKA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794290002;
	h=Received:DKIM-Signature:Subject:From:To:Cc:Date:Message-ID:
	 In-Reply-To:References:X-sashiko-severity:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=DgnkblPUAdInAdDfF7a0qcWBWPo4AF1IpWWinoSNKRs=;
	b=TIb55+KFeFLF/YWvuLUX8w0+DgvCR8HrCGoUQrRhPRNUsnJmJUmwxekC24EKKTJWZQPB
	 rjeFtaikQaXwuue/s7IASpIkfgrh4Of5fZaX3jTIRFYaiJJZAB+peFLazw1OXI0MqKSSg
	 ixgTVASba3GYp22CSqezqAI1oaairnZsMgWlRxgU1mvg7cT1LiTf750SvfDv3RWWwKvms
	 3PaIJJ04nGeP/3RQU9wvgci+wUSejOPSHCQiNTZh72J+Qgb/+QysmcCvKCs4jeff1sY4l
	 DCRa/bpjcJUZLj6yY1bGobBYAMINsccuSltPWN8XhapjdYuTz98PSCP9Jra5L1t6/Gw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=L+RlZw02;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4ABC960A2625;
	Tue, 10 Nov 2026 05:53:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=L+RlZw02
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0CCAE1F008AB;
	Tue, 10 Nov 2026 05:53:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794290001;
	bh=DgnkblPUAdInAdDfF7a0qcWBWPo4AF1IpWWinoSNKRs=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=L+RlZw02s2tHFAgXUOo1ss6RtAiJpPDuX9q8gR5V998lg0k3k5SS5iGahU2lrFJE2
	 O+cEseoTjA5Q9aWojMoej8Cg4AP9ifW5b0H6ydx/d8ePG4phkKbg7/4NPXaxM+nX6R
	 lmp+Uhk3UUh40h2YtVzxwM6olY7kLKLOgL7auqscC3Uo//AGRJvqbmqFQHgJJzqwsy
	 xHTjE1P6aqiaAzO2XFI1ER2j90PfLE/TrscxzpmtS+9VOfSR2snxctquRNg/hUhJmS
	 OiYSkcQwtdydZ/PKfv88EfzkrQvwk2QmIujH2CqXk7jS6UGE4sD/9o0i7AegLRGmOq
	 Bpr5kcQStMkJQ==
Subject:
 Re: [PATCH net-next 05/14] calipso: annotate data-races around cache sysctls
From: netdev-bot+sashiko@kernel.org
To: jiayuan.chen@linux.dev
Cc: netdev@vger.kernel.org, dsahern@kernel.org, idosch@nvidia.com,
 davem@davemloft.net, edumazet@kernel.org, kuba@kernel.org, pabeni@redhat.com,
 horms@kernel.org, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
 razor@blackwall.org, paul@paul-moore.com, matttbe@kernel.org,
 martineau@kernel.org, geliang@kernel.org, ja@ssi.bg, achender@kernel.org,
 marcelo.leitner@gmail.com, lucien.xin@gmail.com, alibuda@linux.alibaba.com,
 dust.li@linux.alibaba.com, sidraya@linux.ibm.com, mjambigi@linux.ibm.com,
 tonylu@linux.alibaba.com, guwen@linux.alibaba.com,
 linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, bridge@lists.linux.dev,
 linux-security-module@vger.kernel.org, mptcp@lists.linux.dev,
 lvs-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
 rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org,
 linux-s390@vger.kernel.org
Date: Tue, 10 Nov 2026 05:53:19 +0000
Message-ID: <179428999963.994134.16904544500890053668@kernel.org>
In-Reply-To: <20261109025425.328445-6-jiayuan.chen@linux.dev>
References: <20261109025425.328445-6-jiayuan.chen@linux.dev>
X-sashiko-severity: High
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 1 potential
issue(s) to consider.

Critical: 0 · High: 1 · Medium: 0 · Low: 0

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [High] calipso_cache_add() in net/ipv6/calipso.c still reads
  calipso_cache_bucketsize twice, and the two reads can disagree.

--

calipso: annotate data-races around cache sysctls

This commit adds READ_ONCE() to the lockless readers of
calipso_cache_enabled and calipso_cache_bucketsize in net/ipv6/calipso.c.
The sysctl handlers update these variables with WRITE_ONCE().

> diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
> index e399a42e30839..5e63212b60163 100644
> --- a/net/ipv6/calipso.c
> +++ b/net/ipv6/calipso.c

[ ... ]

> @@ -269,7 +269,7 @@ static int calipso_cache_add(const unsigned char *calipso_ptr,
>  	struct calipso_map_cache_entry *old_entry = NULL;
>  	u32 calipso_ptr_len;
>  
> -	if (!calipso_cache_enabled || calipso_cache_bucketsize <= 0)
> +	if (!READ_ONCE(calipso_cache_enabled) || READ_ONCE(calipso_cache_bucketsize) <= 0)
>  		return 0;
>  
>  	calipso_ptr_len = calipso_ptr[1];
> @@ -289,7 +289,7 @@ static int calipso_cache_add(const unsigned char *calipso_ptr,
>  
>  	bkt = entry->hash & (CALIPSO_CACHE_BUCKETS - 1);
>  	spin_lock_bh(&calipso_cache[bkt].lock);
> -	if (calipso_cache[bkt].size < calipso_cache_bucketsize) {
> +	if (calipso_cache[bkt].size < READ_ONCE(calipso_cache_bucketsize)) {
>  		list_add(&entry->list, &calipso_cache[bkt].list);
>  		calipso_cache[bkt].size += 1;
>  	} else {

[Severity: High]
Can these two separate READ_ONCE() loads of calipso_cache_bucketsize in
calipso_cache_add() return different values?

The first load is unlocked and only guards the early return. The second
load comes later, under the bucket spinlock, after the GFP_ATOMIC
allocations, jhash() and refcount_inc().

The bucket lock does not cover the sysctl. Also, calipso_cache_bucket_size
in net/ipv6/sysctl_net_ipv6.c uses plain proc_dointvec with no
extra1/extra2 bounds, so 0 or a negative value can be written during that
window.

Suppose three things happen together:

  - the first load sees a positive value
  - a concurrent write of 0 lands before the second load
  - the hashed bucket is empty (size == 0)

Then the size check is false, and the eviction branch runs on an empty
list:

    old_entry = list_entry(calipso_cache[bkt].list.prev,
                           struct calipso_map_cache_entry, list);
    list_del(&old_entry->list);
    list_add(&entry->list, &calipso_cache[bkt].list);
    calipso_cache_entry_free(old_entry);

Here old_entry is container_of() applied to the bucket's own list head.
list_del() poisons the head, and list_add() then dereferences
LIST_POISON1.

Wouldn't that oops in softirq context with the bucket lock held?

If execution got past that point, calipso_cache_entry_free() would free
whatever sits at the key and lsm_data offsets of the fake entry. Those
offsets overlap neighbouring buckets. It would then kfree() a pointer into
the middle of the calipso_cache array.

Separately, if only the second load sees a negative value, it is
converted to a huge u32 limit and the bucket size cap is skipped.

This window existed before this patch, since spin_lock_bh() already forced
a reload. However, this commit is meant to fix the racy reads of this
exact variable. Could it take a single snapshot instead? That is what
cipso_v4_cache_add() has done since commit dd44f04b9214ad ("cipso: Fix
data-races around sysctl."):

net/ipv4/cipso_ipv4.c:cipso_v4_cache_add() {
	int bkt_size = READ_ONCE(cipso_v4_cache_bucketsize);
	...
	if (!READ_ONCE(cipso_v4_cache_enabled) || bkt_size <= 0)
		return 0;
	...
	if (cipso_v4_cache[bkt].size < bkt_size) {
	...
}

No later patch in the series changes net/ipv6/calipso.c.

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261109025425.328445-1-jiayuan.chen%40linux.dev
