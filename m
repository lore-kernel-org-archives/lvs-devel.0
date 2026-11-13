Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590033;
	b=D9CQmWVw9Tc85M9YTal+2Xx4JKnjMVzh1XE38eJZ9fILst3BltPvyaZBXJXU1+p8qS0p
	 JqnvMubWssjzfoyDdTIpSf16Bv6MOr5JnXmxSNmKve/Bim7+SBUdbC/JCSLSYu6l3M58J
	 CWq1q2c8Vopwrm+COmCNRYNUOlp92JX2Nn9qXcA1KJQsp4qs511U8I51CWd87J8jfcHxY
	 MXEHsc/7n9qpN7fyDqgXBFzkx0jh5ipuzkQKhYLFgphpi5Bzxxw7uCDCpa/WWYNNe+yMJ
	 swN60ubw5JnYC9TmPv0r5gi7biNLbUNAAAIx9Il3J+0Hp8AzkONpu5thHC5tQLrMywQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590033;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=qcJFl9NdqvzphabZtsDLj7jWX/fBy0DU+zzdY0OOr0c=;
	b=3aU+ww2UHrpNoA4X4+6i8QDMKDkE+hps0gxGYtA6qMG/Jtrn1Vo2mG7v8+ah80khMaeI
	 5c3ULT8qByCHBQ6dNGIU1dc4f3xe9Jij4cKKBaKqhgZuUfjYjEyFgjG1zI0zQZ7KGh8sS
	 7XvKbTaOGLdlMLM0UmO2p0FFDsQ1WMYDWzq4WCT/nFdYbFYv9RoIN1gX3FUiU6CbYmNAT
	 54KchjSArpd7L+tnk01gj4u4Fu7O+i1WsZF3uwtFXC+YkBhQz3FFM6UeublmRq/w32PEM
	 UEoJrBSSbmo4lLJQ3cBBLBWP6FjrQePIGPJcItJFimgl8DTndMziEgS3cXn4NyX9EwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="PWyBk6/D";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 524FF60A6F47;
	Fri, 13 Nov 2026 17:13:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PWyBk6/D
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DFA581F000C8;
	Fri, 13 Nov 2026 17:13:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590032;
	bh=qcJFl9NdqvzphabZtsDLj7jWX/fBy0DU+zzdY0OOr0c=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=PWyBk6/DVpDsfndMVz52QbAY+pl58hD4yfZx5XLSvkS2DDdGAEaI3Aj2jg1u/4EsZ
	 ynMoxaS9cYkylWrQ+B7ztFlNkjHxnj7Y0WQqQxFPxAYOcsfC9/9hq4tRNpj9ugF+Vl
	 hr0oqrAEqLYQS+7XaCucHlEJqicIT/clAQZiPuH7ZRkTi1ctKzSN09+g6zg/AkrOZb
	 b1p1XXW7v7EkxnO7ADmQ5YLdVIBR1MVsOQicdHlxWRUZu/I7Eomi88yfECqv6RYBuA
	 X1QfkSnrWqCORwS39hsBceyqMhQ5KPHL8XVEZOzzIYZ8qXjPSbVnFqiz97VsVxT8zZ
	 moF4zRs/vYu5A==
Date: Fri, 13 Nov 2026 17:13:44 +0000
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
Subject: Re: [PATCH net-next 04/14] ipv6: annotate data-races around icmpv6
 reply sysctls
Message-ID: <20261113171344.GO18859@horms.kernel.org>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-5-jiayuan.chen@linux.dev>
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
In-Reply-To: <20261109025425.328445-5-jiayuan.chen@linux.dev>

On Mon, Nov 09, 2026 at 10:52:03AM +0800, Jiayuan Chen wrote:
> icmpv6_echo_ignore_all, icmpv6_echo_ignore_multicast,
> icmpv6_echo_ignore_anycast, anycast_src_echo_reply and fwmark_reflect are
> read without any lock while their sysctl handlers update them with
> WRITE_ONCE(). Add READ_ONCE() to the readers.
> 
> KCSAN reports it when net.ipv6.icmp.echo_ignore_all is changed while
> ICMPv6 echo requests are received:
> 
>   BUG: KCSAN: data-race in icmpv6_rcv / proc_dou8vec_minmax
> 
>   write (marked) to 0xffffffff8ee2940d of 1 bytes by task 504 on cpu 0:
>    proc_dou8vec_minmax+0x1ab/0x1f0
>    proc_sys_call_handler+0x282/0x3a0
>    proc_sys_write+0x13/0x20
>    ...
> 
>   read to 0xffffffff8ee2940d of 1 bytes by interrupt on cpu 3:
>    icmpv6_rcv+0x99d/0xd40
>    ip6_protocol_deliver_rcu+0x787/0x9a0
>    ip6_input_finish+0xb0/0x1b0
>    ip6_input+0xa8/0x250
>    ipv6_rcv+0x14b/0x1c0
>    __netif_receive_skb_one_core+0x8f/0xe0
>    ...
> 
>   value changed: 0x01 -> 0x00
> 
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>

Reviewed-by: Simon Horman <horms@kernel.org>

