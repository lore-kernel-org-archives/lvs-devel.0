Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794310098;
	b=K22t4274AhAO3XoN28g7i4MbbWIerbTWu9Jr4/C7s43Cvl5ZADWnIRZ27S/Mf4JyVZZ0
	 fxxVRir7WO+HL5Ua/1d3WxbTCrwXlCaJrgkdsNrogLHUQGzH8EaSIQVWLcNfjWuMtiuJY
	 F2vyh+wk6XvxHhHW54GNrVPnB2aCZrtRnjBaKC/L1hdJ5GbZN7ukkn7Y+y5Pk+Ru1UJ3r
	 BFO3LsPjT5ZxhvMdK5JWyccRGmxMogTA/9wA7gohnEkiiQ0aBBwsQ2nCvIZk+nNyEaY1h
	 7pVHYjnmh5rob+W6NhLVLIiRistuWEVljzuqvkdwSHgH4ELSKEV4B6d149rqrinUj6A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794310098;
	h=Received:DKIM-Signature:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:Content-Language:To:Cc:References:From:Autocrypt:Organization:
	 In-Reply-To:Content-Type:Content-Transfer-Encoding;
	bh=Bow83wIczwiYl+mYNYisPcBsNVqLXF/ekH8fXtAJVuI=;
	b=h0SevbFsdJemG+3oXqjiA8a2+gtxr2gBleTipfwHqX22JlqfJSiqu18Vy1PouNlchpB6
	 MWuYZun5GLHdZAIMsaeK9RmdPp7r553zpE5RHDIY44500WN7xwEGsF4lOmNa+ZpJJTNye
	 ViFYhAljQoXF+WTTk+OXNKqEzCeomKK4f784i/7Oy2MVGkals/sHkXJM0zzqwjObU92WE
	 HSGA3o2VJGsVCS4Ufh9qPu0M0uNvMxffCQj4kbpg8hT83VjIgUpvaeGV0hmjJ9mfNmLCH
	 8du29KiwWEN89e/rjjFVt7FuCIfanhm9edw/rDXWZWqY86IR7TDMQPkcJdZt800JMIg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dDeiScvo;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F74F606A32E;
	Tue, 10 Nov 2026 11:28:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dDeiScvo
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2808E1F008A1;
	Tue, 10 Nov 2026 11:28:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794310097;
	bh=Bow83wIczwiYl+mYNYisPcBsNVqLXF/ekH8fXtAJVuI=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To;
	b=dDeiScvozPtJL2n8qM+O8IYSe4tDr75pEKgeDQV/2HtafsTURojPSPpvFqmo1cN2s
	 GNA4CAxFdnwnUocGJO/qkY33Wkvh0iDQp0ti8/bl7tM6+cAE9Im6fH1wkgORmxv7pT
	 /S4BrOAaIH0J1PG7YF+XMYDaCFdQvToy8iw0IssbHfxidsoHXgcOXQuRjh46ndqltW
	 NaTufVAhNVRcEw9a/2txcKtAOUtXBDjh0dxAReVTdLVenPqGQhEHuFaY+JL6er0vAm
	 UJjsI7NNM6mTUthKYkQvyQBwAByiK1w3j6G37bIPZu/ksTBjjoa7b8kHtqbcmrHbrs
	 EEaMiN0YqAZ8Q==
Message-ID: <35051734-9f07-47f3-88c6-f603b8263df6@kernel.org>
Date: Tue, 10 Nov 2026 12:28:01 +0100
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird Beta
Subject: Re: [PATCH net-next 07/14] mptcp: annotate data-races around pernet
 sysctls
Content-Language: fr
To: Jiayuan Chen <jiayuan.chen@linux.dev>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@kernel.org>,
 Ido Schimmel <idosch@nvidia.com>, "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@kernel.org>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
 Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
 Phil Sutter <phil@nwl.cc>, Nikolay Aleksandrov <razor@blackwall.org>,
 Paul Moore <paul@paul-moore.com>, Mat Martineau <martineau@kernel.org>,
 Geliang Tang <geliang@kernel.org>, Julian Anastasov <ja@ssi.bg>,
 Allison Henderson <achender@kernel.org>,
 Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
 Xin Long <lucien.xin@gmail.com>, "D. Wythe" <alibuda@linux.alibaba.com>,
 Dust Li <dust.li@linux.alibaba.com>, Sidraya Jayagond
 <sidraya@linux.ibm.com>, Mahanta Jambigi <mjambigi@linux.ibm.com>,
 Tony Lu <tonylu@linux.alibaba.com>, Wen Gu <guwen@linux.alibaba.com>,
 linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, bridge@lists.linux.dev,
 linux-security-module@vger.kernel.org, mptcp@lists.linux.dev,
 lvs-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
 rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org,
 linux-s390@vger.kernel.org
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-8-jiayuan.chen@linux.dev>
From: Matthieu Baerts <matttbe@kernel.org>
Autocrypt: addr=matttbe@kernel.org; keydata=
 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
 lzVbFe7fduHbABmYz9cefQpO7wDE/Q==
Organization: NGI0 Core
In-Reply-To: <20261109025425.328445-8-jiayuan.chen@linux.dev>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi Jiayuan,

Thank you for the patch!

On 09/11/2026 03:52, Jiayuan Chen wrote:
> enabled, add_addr_timeout, checksum_enabled, allow_join_initial_addr_port,
> stale_loss_cnt, close_timeout, pm_type and syn_retrans_before_tcp_fallback
> are read by their ctrl.c helpers without any lock while the sysctl
> handlers update them with WRITE_ONCE(), and the path_manager handler
> stores pm_type with a plain write. Add READ_ONCE() to the readers and
> WRITE_ONCE() to that handler.
I have the same patch on the MPTCP ML (the WRITE_ONCE() is split in
another one):


https://lore.kernel.org/e8335e14eff144774aec63393f5cce13e69dddc0.1790147728.git.yangang@kylinos.cn

So that's good to me:

Reviewed-by: Matthieu Baerts (NGI0) <matttbe@kernel.org>

Note that my patch was still in review because Sashiko kept complaining
that this was not fixing all issues, e.g. the new WRITE_ONCE() you
introduced is not enough. Gang has a fix for that [1], and that's not
blocking your patch.

[1]
https://lore.kernel.org/c9f533ea507e6a88d3401768785153a63790c3d8.1790147728.git.yangang@kylinos.cn

Cheers,
Matt
-- 
Sponsored by the NGI0 Core fund.

