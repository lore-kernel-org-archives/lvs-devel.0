Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590171;
	b=q2leGlBpeY/gnRAQqhU70txR6byFWMMDVClmst07pVDAHfH1sT3WZbSNKUBhRtj+NJxF
	 jUv921k6Eb+10mqTir4qhMBeMewDkP2ncgE4VGLCKKJvHsj0QSNr/JNd612WxEjwa4hab
	 xG+YJKX2Ko71NKkFofAWGl1V0TaBcVOUflNUMXNo7x5a1deUwXpa2fmLXlX9JXPLiqBZP
	 ww/5LV7myg1zfWdsA+q7qE/FRxx6FBe+86igDi3tFXwxgx+Mon5SmkdVqEk0uZ3mvgxHw
	 7SdlqAvUhpJ8VCJgrPjJVXcbbR75N2MNpErNtWWPoPvi/EtY5bWjaQqQNAi6KNgh99w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590171;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=jJlSj4ByLlh4nc3J/r005UKpkIbKb0lLpM2tMKOuUHE=;
	b=Q0Pwhbv1Zrl1JY/7q7LbDg8RJBxnfOD9S3DnK5paFbX3EocZy+QxYm7GRwDLLG0rLq6V
	 tLMZNlpqLxVsvg3n9VEQlCzwUa420HRjE+tPx0DsHE07BDidQJtwTjjKWqcAeN2rmFRNb
	 qJME57vxMM/QsvPhTtDbv2r3CG3HtL3qeLKzRIdwyFMsLXYVaaK/ZSX25IamgoMWz8+Ss
	 0Gx8PDN6kWIPFGSHxSgV+6Vx2tQkJRz+UumA2wnhb0G650wCivGPbRpUU4I3CjGTMpzMu
	 s6JTv2gGvtXMt5HvN7oClkTxFceNpbiKj0fAM+WMnEmzVaMMAXgRAVeuIj2e9Y8GBNg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="WlIaPU/n";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D068606E657;
	Fri, 13 Nov 2026 17:16:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WlIaPU/n
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 51BF51F000C6;
	Fri, 13 Nov 2026 17:16:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590171;
	bh=jJlSj4ByLlh4nc3J/r005UKpkIbKb0lLpM2tMKOuUHE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=WlIaPU/n4qfg0E5msNHiYPLwCppsHz7ULNqKiGhsdyQMwiWXK/+Anu0FDPYYlDUtP
	 kMxWx46JEa0jQTVfzenY9pZdHS/nyi0B5UVmUjrKtTYkmh4O4OLLQVLiDdQAg2TjbW
	 Wo4CxE5WbCcJNDMsVx1tITDuLzhLrPqi4cjDFVa3aqsi5PxrKDJajN/pZyzNCa9PLa
	 2IOf3uePihX9+YbGXCl5kjzPel5oksZyNSRttGHtqjI4Ew5RaN4w8W1EjdDuyYArrW
	 1WPz+2hpTlM9RnJ8tHMeoINU0a3B3EPoa2SQzBS9MRCJNBUAbyPJb3um+HLvQvRlIW
	 Y5TbanvDRWPiw==
Date: Fri, 13 Nov 2026 17:16:03 +0000
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
Subject: Re: [PATCH net-next 09/14] netfilter: conntrack: annotate data-races
 around conntrack sysctls
Message-ID: <20261113171603.GS18859@horms.kernel.org>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-10-jiayuan.chen@linux.dev>
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
In-Reply-To: <20261109025425.328445-10-jiayuan.chen@linux.dev>

On Mon, Nov 09, 2026 at 10:52:08AM +0800, Jiayuan Chen wrote:
> nf_conntrack_acct, nf_conntrack_events, nf_conntrack_timestamp,
> nf_conntrack_checksum, nf_conntrack_log_invalid, nf_conntrack_max and
> nf_conntrack_expect_max are read without any lock while their sysctl
> handlers update them with WRITE_ONCE(), and nf_ct_set_acct() stores
> sysctl_acct with a plain write. Add READ_ONCE() to the readers and
> WRITE_ONCE() to nf_ct_set_acct().
> 
> KCSAN reports it when nf_conntrack_checksum is changed while packets go
> through conntrack:
> 
>   BUG: KCSAN: data-race in nf_conntrack_icmpv4_error / proc_dou8vec_minmax
> 
>   write (marked) to 0xffffffff8ee29b6d of 1 bytes by task 568 on cpu 0:
>    proc_dou8vec_minmax+0x1ab/0x1f0
>    proc_sys_call_handler+0x282/0x3a0
>    proc_sys_write+0x13/0x20
>    ...
> 
>   read to 0xffffffff8ee29b6d of 1 bytes by interrupt on cpu 2:
>    nf_conntrack_icmpv4_error+0xb3/0x240
>    nf_conntrack_in+0xa85/0xb20
>    ipv4_conntrack_local+0xb0/0x120
>    nf_hook_slow+0x7e/0x180
>    nf_hook+0x1fa/0x4e0
>    __ip_local_out+0x1ac/0x3f0
>    ip_push_pending_frames+0x65/0x160
>    icmp_push_reply+0x17a/0x200
>    __icmp_send+0xb7d/0x1a10
>    udp_rcv+0x95c/0x14e0
>    ...
> 
>   value changed: 0x00 -> 0x01
> 
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>

It might be worth splitting off this and other netfilter (and IPVS) patches
into a separate patch-set for nf-next rather than net-next. As that is the
usual path for such patches.

But at any rate these change look good to me.

Reviewed-by: Simon Horman <horms@kernel.org>

...
