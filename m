Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590000;
	b=aTJ6cra9TAeSbA5CqzlA2d9D0w/2Ki6I7hNLlPY1qKH2pjR2U1V9SaNu8wJqZav2KKgg
	 BIG6VzqtOMEZ8y7O6CvGecY47JF26BrIR2I5kbolSOuD0d0rR6WiHfPZxwmCUMM0zaK53
	 8hkMcBQ/sqQOVKhZuVK8AHOcsB32w5YftvqjOfbU7F7B3EzXiCgZgbzHAgT7in1s3Ht3x
	 jY6KZGOHSNlwJ7BMQLag8ilx7pkrNbyO0jSrbUlnzZnibxkAmTCOl36xj0lx4yl8OqUnJ
	 AD3e0/j2tHQhnIos4J3IlaGWyNlbNMkkYLA1e05PBtU3SmhJnrYlAwVbgsXVaO2XjPA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590000;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=M9q+LvDPMwzTlHJ1z6qjfvGqi9L+uQK9zgjc9+yYEsc=;
	b=jraTOL2e+mqSjurztlxQl6tBA+djJqagQGyXXcpsDFDIwUPSR/C8r4JwKaMaWovYKBay
	 q0wsLeVPFh+deAB0XXuLkxivG9G0PQ1dH22xaymFM74e1ml5mSw1p9dyrIZvn7ZoVhVaI
	 UE252Qf8BZbmFFEpwWcE1y/WLNbFRX1kp6lwwYK7F/bI0uziWu+w7e6nnzZ6IHmacS+x9
	 GNtEhJNt/3qD0hS5DtBTjiimB79NH3rTmywVk7BVo09pdy8fzx1WRQrNiB2wKghsWDpa3
	 TvuqT3ccF76Z32fQmFjfGNspd5n1r+vIL4RsKZ935JU2csPPo3KBjudbvUF5g6QYgGg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bu3IowAC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0403606A331;
	Fri, 13 Nov 2026 17:13:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bu3IowAC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BEFAF1F000C4;
	Fri, 13 Nov 2026 17:13:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794589999;
	bh=M9q+LvDPMwzTlHJ1z6qjfvGqi9L+uQK9zgjc9+yYEsc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Bu3IowACeJIvWD+7wKM49oLy/7ngGoJ0pvvcEmtsW1b5K5SHVaEFfRBtO3oeq4vVP
	 /Qfj48crlKQv3np+MV9wj+dsD+qjItFr8H0pN4jLtQ2BSZqDdp+H0+/54GOISSD1u1
	 69j3ACS785MHsbwzqL/Zs3st0py1xcRt+0zvLBrgcpob+IlM3117ew7DlNn0bicex9
	 shmUa9N+/CQIVQm54ZguYpH+IvGpqBQtjZWwSIfxeu0c6UkKgXO6cJS33/KhAljHIa
	 c20h87uVXaDLEAuvEXMKvPaUWbschD1L3vckBWt2z0o87/DvJOXS9p7XV+z4Kzs+xn
	 4tdrjz3nzRtpw==
Date: Fri, 13 Nov 2026 17:13:11 +0000
From: Simon Horman <horms@kernel.org>
To: Jiayuan Chen <jiayuan.chen@linux.dev>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Paul Moore <paul@paul-moore.com>,
	Matthieu Baerts <matttbe@kernel.org>,
	Mat Martineau <martineau@kernel.org>,
	Geliang Tang <geliang@kernel.org>, Julian Anastasov <ja@ssi.bg>,
	Allison Henderson <achender@kernel.org>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	"D. Wythe" <alibuda@linux.alibaba.com>,
	Dust Li <dust.li@linux.alibaba.com>,
	Sidraya Jayagond <sidraya@linux.ibm.com>,
	Mahanta Jambigi <mjambigi@linux.ibm.com>,
	Tony Lu <tonylu@linux.alibaba.com>,
	Wen Gu <guwen@linux.alibaba.com>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux.dev, linux-security-module@vger.kernel.org,
	mptcp@lists.linux.dev, lvs-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
	linux-sctp@vger.kernel.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH net-next 03/14] ipv6: annotate data-races around addrconf
 sysctls
Message-ID: <20261113171311.GN18859@horms.kernel.org>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-4-jiayuan.chen@linux.dev>
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
In-Reply-To: <20261109025425.328445-4-jiayuan.chen@linux.dev>

On Mon, Nov 09, 2026 at 10:52:02AM +0800, Jiayuan Chen wrote:

...

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c

...

> @@ -2857,7 +2859,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  		return;
>  	}
>  
> -	if (valid_lft != 0 && valid_lft < in6_dev->cnf.accept_ra_min_lft)
> +	if (valid_lft != 0 && valid_lft < READ_ONCE(in6_dev->cnf.accept_ra_min_lft))

Hi Jiayuan,

This patch introduces several lines that are longer than 80 columns,
while Networking code still prefers lines 80 columns wide or less.
I'd appreciated it if this could be addressed.

In this case, I think that could look like this (completely untested):

	if (valid_lft != 0 && 
	    alid_lft < READ_ONCE(in6_dev->cnf.accept_ra_min_lft))

>  		goto put;
>  
>  	/*
> @@ -2928,7 +2930,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  	/* Try to figure out our local address for this prefix */
>  
>  	ignore_autoconf = READ_ONCE(in6_dev->cnf.ra_honor_pio_pflag) && pinfo->preferpd;
> -	if (pinfo->autoconf && in6_dev->cnf.autoconf && !ignore_autoconf) {
> +	if (pinfo->autoconf && READ_ONCE(in6_dev->cnf.autoconf) && !ignore_autoconf) {
>  		struct in6_addr addr;
>  		bool tokenized = false, dev_addr_generated = false;
>  

Similarly here.

> @@ -3434,7 +3436,7 @@ static int ipv6_generate_stable_address(struct in6_addr *address,
>  
>  	if (ipv6_reserved_interfaceid(temp)) {
>  		dad_count++;
> -		if (dad_count > dev_net(idev->dev)->ipv6.sysctl.idgen_retries)
> +		if (dad_count > READ_ONCE(dev_net(idev->dev)->ipv6.sysctl.idgen_retries))
>  			return -1;
>  		goto retry;
>  	}

And I wonder if in this case we could do something like (completely untested):

	if (ipv6_reserved_interfaceid(temp)) {
		const struct *net net = dev_net(idev->dev)

		dad_count++;
		if (dad_count > READ_ONCE(net->ipv6.sysctl.idgen_retries))
			return -1;
		goto retry;
	}

...

