Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794290000;
	b=KKxBg+BwNx0M0ohQrO6dQb8xcsiPEy+WnGx1P58xzWrbS9rTpCv0IpWMiI7Xb/qtBl/O
	 aex8ySMgJBfoKRwzco4xgxNaCRhnfV7x2tVVNCOOLzpw9PPoyeI/mq5RUB4DkShpgTwqq
	 2wXIQQdWybTHl5NJA/HKnJtzMeV3EELcZHGAMTjDDM0smdG4JPaqDkS0ak7NCSZjktqAK
	 petx8+iwx5eSIyaHdvBwa3G4KUrddmtJFEXK1PR7W7JUQh6GN8Ya88XDIj87ezvpm3Fb+
	 Oz5zaFoyJTfCud03FYLS+1es11nFONjW0w+Pc2HDiic1YEi4M7nqpOyyHAkH6xMB0yg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794290000;
	h=Received:DKIM-Signature:Subject:From:To:Cc:Date:Message-ID:
	 In-Reply-To:References:X-sashiko-severity:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=Z89xSOnIYbQe/BnbwEDddihQE8DlZZ6KBDFpfIcDInE=;
	b=E7UQK56IF1CRdYnM2A0egTNzONHiwrTEYb/J6XQh6yb2v1c21FpFqQOCJDCk2+8v3r+a
	 FvKz52ZgaUti7bWWjlPDdPb+XgUGk4AK76Pb0HHzpWloyoy9O23yWSbA4IZ9FH3HoM/I9
	 ozc+JlLeSySpIdK4OcjKMFzVrpM4CK19kR5OPA6rxvmFL+7hQiB0YQfi3Sc/6McOphzv9
	 FEWjL6vDdjl66HfnMmkUE2oId1VlrDEtu7YNmgf7Gc6U2jSrUN/lWN8yr2JZk+tm5lYKB
	 GSoRvT0VMQkdZp8rVJ9dewMn4elK2VtfmH05Qp9KyysnkbpKBv+RIadgnm53ZsMd57Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lyQ9UJ+R;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C70C2606A33D;
	Tue, 10 Nov 2026 05:53:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lyQ9UJ+R
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 97FC11F008A1;
	Tue, 10 Nov 2026 05:53:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794289999;
	bh=Z89xSOnIYbQe/BnbwEDddihQE8DlZZ6KBDFpfIcDInE=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=lyQ9UJ+RnJfZYHoAs6Z6tYh7JPfwTK3ToP1JPzFXHVxRoGly7DdXrxmH8BkTgETl/
	 Obeh0mUbgS/9wHFArLQHNJbDUBgCKXQSlvTaWY79Ji4XmGotyU05XuFkzwhC4WBCzj
	 +9+UuLPufHMh9G0g5ohqhboSCWLSpUGD7a+jna9Fs/VkP+pzpv5mAlQUTLJJFd4I+q
	 e8dDiUk75aoT2UJ9hFCSJWvRtlwGTmKa8naEaX8es02v59SLHeqnzJq9+z6rhjZ5wq
	 k3Pv1LDYHv/WqQJZFk3Wj3opFF2+oCRjqFjIG4XzRUq5ucUrD7lUfqbJ+GtqEZNDS1
	 wzIkaWWQN7pGw==
Subject:
 Re: [PATCH net-next 01/14] ipv4: annotate data-races around ip_rt_* sysctls
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
Date: Tue, 10 Nov 2026 05:53:17 +0000
Message-ID: <179428999715.994134.14310277652030711794@kernel.org>
In-Reply-To: <20261109025425.328445-2-jiayuan.chen@linux.dev>
References: <20261109025425.328445-2-jiayuan.chen@linux.dev>
X-sashiko-severity: Low
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

Thank you for your contribution! Sashiko AI review found more severe
issue(s) in other patches of this series. This mail is only an FYI, in case
you want to address the nit picks below when you respin.

Low priority / nit picks for your consideration:

- [Low] In __ip_rt_update_pmtu() (net/ipv4/route.c), the patch adds two
  separate READ_ONCE() loads of net->ipv4.ip_rt_min_pmtu.

--

ipv4: annotate data-races around ip_rt_* sysctls

This adds READ_ONCE() to the lockless readers of several ip_rt_* route
sysctls in net/ipv4/route.c. Their sysctl handlers write them with
WRITE_ONCE(). The change was prompted by a KCSAN report on
net.ipv4.route.min_adv_mss in ipv4_default_advmss().

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index d0a5f6d77094c..83f49b2d4c36a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c

[ ... ]

> @@ -1063,14 +1066,14 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
>  
>  	rcu_read_lock();
>  	net = dst_dev_net_rcu(dst);
> -	if (mtu < net->ipv4.ip_rt_min_pmtu) {
> +	if (mtu < READ_ONCE(net->ipv4.ip_rt_min_pmtu)) {
>  		lock = true;
> -		mtu = min(old_mtu, net->ipv4.ip_rt_min_pmtu);
> +		mtu = min(old_mtu, READ_ONCE(net->ipv4.ip_rt_min_pmtu));

[Severity: Low]
READ_ONCE() is volatile, so __ip_rt_update_pmtu() now always does two
separate loads of ip_rt_min_pmtu. If net.ipv4.route.min_pmtu is written
between them, can the check and the clamp see different values?

For example, take old_mtu=1500 and an ICMP FRAG_NEEDED carrying mtu=300:

  first load sees min_pmtu=552   -> lock = true
  sysctl write sets min_pmtu=68  (accepted, extra1 is ip_min_valid_pmtu)
  second load sees 68            -> mtu = min(1500, 68) = 68

update_or_create_fnhe() would then store pmtu=68 with fnhe_mtu_locked set,
and it stays that way for ip_rt_mtu_expires. The old setting would give
552 locked, and the new setting would give 300 unlocked.

Before this patch, the compiler could merge the two plain loads into one.
Only a privileged writer can trigger this, because min_pmtu is not exported
to netns owned by non-init user namespaces. Later patches in the series
don't seem to change this.

Could the value be read once into a local? This patch already does that
in ip_error() with burst and cost.

A smaller case of the same pattern affects ip_rt_mtu_expires in the same
function. It is re-read for the freshness check:

	    time_before(jiffies, READ_ONCE(dst->expires) -
				 READ_ONCE(net->ipv4.ip_rt_mtu_expires) / 2))

It is read again for each nexthop in the multipath loop, and once more for
the single-path update_or_create_fnhe() call. Could nexthops updated in
one call get different expiries?

ip_rt_redirect_number is also read twice in ip_rt_send_redirect():

	if (peer->n_redirects >= READ_ONCE(ip_rt_redirect_number)) {
	...
		    peer->n_redirects == READ_ONCE(ip_rt_redirect_number))

The second read only gates the "ignores redirects" warning, so there the
only effect is on logging. Should these be loaded into locals once as
well?

>  	}
>  
>  	if (rt->rt_pmtu == mtu && !lock &&

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261109025425.328445-1-jiayuan.chen%40linux.dev
