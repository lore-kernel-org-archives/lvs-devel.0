Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590406;
	b=4FwVqxc53Vbd/1XiAdVJmFWsCsf5Wg35doxOqyWQocaXFWaB9394SmwiQ2y6PJEiqb+8
	 NN8b0XL+HcwwVOSPa0h8ocYV5aDt7AlOFAFiKnKR13d8ByMzIC5hfwLKzLcmd7RtMI6Fi
	 YOJMG9sX1J2xQKnUT/bcswibu133tEMweWKIoz20RLxoafzW9sQDvOYIfr7SL+vw7eTta
	 c0USdH+96d2JNUF6E+YU/HjbrLdtxspN8m4TKj3cua/resLKiiLxZQxeLxfE/p1SkZQK4
	 U5QtPd8qqs20Dm5oehz9ouiZ0PTMnxXFosJVT9wsdxhvp7N3mg3GeOtb8E7bJeUZPFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590406;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=pLe6c2LhWdg08aU3SLTnHU4DwBkAqigblBo0XXQ9BX0=;
	b=KApGcv9qsVC0ER7M0aBItfkgSix4Z6zeKOntRu6dqsRQwDV1J46pD89xsxYU2ZkDQz8v
	 RTdSn0kFZt0WogU0v/L4DXLiqUfR+hZgrWE/vH51fqlH058bupRuPuDKqw/jzWEi0TRIC
	 sNQ+1GmgOyyEOssh53DoKGGmQzlnMhROmCKrWPo5LpOXoE5teJyEDNonH0nt3YBdrr/2y
	 KYNOvoDq9yMqBpoLvtfSlYv1wrlVax8z8k72pPLJyWzXhAx/YJzjQiMmM2G4HpyR2YMrF
	 9EXjfct49Ae6BhP6OJ2rUJ4b+6gGwQlbqaeYLvbnl3RoUkIM5fJbkUuFlWhSjyal1dg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gYBGfrXt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FB58606B462;
	Fri, 13 Nov 2026 17:20:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gYBGfrXt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E21151F000C6;
	Fri, 13 Nov 2026 17:19:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590406;
	bh=pLe6c2LhWdg08aU3SLTnHU4DwBkAqigblBo0XXQ9BX0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=gYBGfrXt2Ffp3CtT9lRu9Q4s81KSZzKqz9Lfo+PVwqO3aGrdqToyoAZeMLYx+juiA
	 KtFrHhDOvqWjuv5gegWK1CFAegTV4RmiedbGywGgJfdkE+pu8ys3/EGxWW02qZWFpy
	 HofAGIVx8fwFyNPwBLWF72gY4Vqk3SMEO1Pwq9eBSjoYvk8yZSUJKySbESzKGszr4o
	 iCc/ryB4FO6VPjWC8EgEQeu7AWL8RDX4I+OW3weY7cfxZZCq9A8Z3l+mJkz84ZgeQI
	 44bi4zPENd8IWPJH6wv4vXH4sIppBMhelgZjQY5z49TqHo3iXU4rYX3ca2x1J5HiGC
	 ZVsqI99IAXQAA==
Date: Fri, 13 Nov 2026 17:19:57 +0000
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
Subject: Re: [PATCH net-next 13/14] netfilter: conntrack: annotate data-races
 around timeout and tcp sysctls
Message-ID: <20261113171957.GV18859@horms.kernel.org>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-14-jiayuan.chen@linux.dev>
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
In-Reply-To: <20261109025425.328445-14-jiayuan.chen@linux.dev>

On Mon, Nov 09, 2026 at 10:52:12AM +0800, Jiayuan Chen wrote:
> The nf_conntrack_*_timeout* knobs, nf_flowtable_tcp_timeout,
> nf_flowtable_udp_timeout and nf_conntrack_tcp_{loose,be_liberal,
> max_retrans,ignore_invalid_rst} are read in the packet path without any
> lock while their sysctl handlers update them with WRITE_ONCE(). Add
> READ_ONCE() to the readers.
> 
> KCSAN reports it when nf_conntrack_udp_timeout is changed while UDP
> traffic goes through conntrack:
> 
>   BUG: KCSAN: data-race in nf_conntrack_udp_packet / proc_int_u2k_conv_uop
> 
>   write (marked) to 0xffffffffb0829bc4 of 4 bytes by task 436 on cpu 0:
>    proc_int_u2k_conv_uop+0x92/0xa0
>    sysctl_u2k_int_conv_hz+0x21/0x30
>    proc_int_conv+0xdf/0x130
>    do_proc_int_conv_jiffies+0x1b/0x30
>    proc_vec_conv+0x21/0x40
>    proc_vec+0x21e/0x6f0
>    proc_dointvec_conv+0x21/0x40
>    proc_dointvec_jiffies+0x15/0x30
>    proc_sys_call_handler+0x282/0x3a0
>    proc_sys_write+0x13/0x20
>    ...
> 
>   read to 0xffffffffb0829bc4 of 4 bytes by task 439 on cpu 3:
>    nf_conntrack_udp_packet+0x27b/0x550
>    nf_conntrack_in+0x767/0xb20
>    ipv4_conntrack_local+0xb0/0x120
>    nf_hook_slow+0x7e/0x180
>    nf_hook+0x1fa/0x4e0
>    __ip_local_out+0x1ac/0x3f0
>    ip_send_skb+0x31/0x120
>    udp_send_skb+0x4bf/0x640
>    udp_sendmsg+0xdec/0x18a0
>    ...
> 
>   value changed: 0x00001d4c -> 0x00001e46
> 
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>

Reviewed-by: Simon Horman <horms@kernel.org>
