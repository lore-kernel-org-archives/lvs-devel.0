Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794590140;
	b=izZbuT9zYqPezTOJm4flINwAHqiY3r2tHAFMVoGf6sqfgTCgVfmoqKVP4reQDYiVI4HH
	 cowFlobwBYdGg/orHa1+d564Ntddriw7yNJr3PjvipGM+UuktO1YrLW39Y9DjaeEEH1g1
	 Hqw5Bb/315okVEJB4romuOYAgkWnVt4aHWBGBJs5gzDDm4mn0M7VXH3vc0WcZ4E1WwDkC
	 M0sLDiqh5d3otYfJWmE1jbLVNFgsx58ygCmf+iCgyDJKvq96UJdq7Wi7pzlYwIYymDyte
	 G3ZAw2oAOu1zbuUiBsrizUIUmMa9FqpyXf07hxvLN0tlg5cEujUuWkNGPkCQvU3wNzQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794590140;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=1vMesprYhFeENWisDIzJhcy04vIcu8PwjlxWvClS8Hs=;
	b=Vk6X/9KiWoJ0ZUfA2TBPjZWXhq985VnfNsuSPvzWuXllhubmv8daOmW4uS5HcZy17/g0
	 i1la+ohJZRrvYhxyH44ft8M8SvSv97tg9hM1OKn1uVhWUZpWpj+89uZKYSICjkkd7GTC0
	 MwT/FiUkoOBuvMHWx+VxntJ5B8+Os7ppZhZs+yXrqPQdyQH1WvWnR6msCF+55sF7bB6sg
	 eSLozKoQJJz05WkrA9UYizJ3KQtyLk2kyDnRL8CwDl76a5S5Lqb0ATtP5H0cRJihI6ZQY
	 yiOu95ldI4OATU9hB5k0keGmZhs3U19n8ZARu+eQ6DVRjHthV+FUDJKeLDwIYMgun9g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="EyVRa/9f";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED688606E20D;
	Fri, 13 Nov 2026 17:15:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EyVRa/9f
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BEB021F000C4;
	Fri, 13 Nov 2026 17:15:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794590139;
	bh=1vMesprYhFeENWisDIzJhcy04vIcu8PwjlxWvClS8Hs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=EyVRa/9fVvx9+Qbm0nTockS2FVMvizEhoCsvvuFlwnODla6jIfcftkyAaI4hWexcL
	 pUSC3y3CyEo3ZLC4Njyo7cK13k1/EWsLdIFajb3d+ckXZG5Vu+0JFU09dKEenWwrvD
	 ogQeZhOCJCpIw8TLahIIifIrGlbU5C9wR5wM3kjyZIhPlMBc4Zyz+9khmFDS/6Dw4B
	 0WMkPMTrRxZhEMnLsL1DVMXbrsAfV1h6Ow81B9z8COrDULGtlrD6hMy9kT/iuqWRNe
	 uUZ1zefj5znLTMOE/lpnyaGwMN4kxrLFr3QihAO3Lpvc6z9jzl1W7Ck74qEAI7MvJb
	 lFvhNdGfk4Mgg==
Date: Fri, 13 Nov 2026 17:15:31 +0000
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
Subject: Re: [PATCH net-next 08/14] rds: annotate data-races around core rds
 sysctls
Message-ID: <20261113171531.GR18859@horms.kernel.org>
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
 <20261109025425.328445-9-jiayuan.chen@linux.dev>
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
In-Reply-To: <20261109025425.328445-9-jiayuan.chen@linux.dev>

On Mon, Nov 09, 2026 at 10:52:07AM +0800, Jiayuan Chen wrote:
> reconnect_min_delay_ms, reconnect_max_delay_ms, max_unacked_packets,
> max_unacked_bytes and ping_enable are read without any lock while their
> sysctl handlers update them with WRITE_ONCE(). Add READ_ONCE() to the
> readers.
> 
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>

As per my remarks on another patch. Networking does prefer lines
80 columns wide or less. But I am inclined to turn a blind eye
to the in the case of longer lines introduced by this patch because
they are not that much longer and addressing them seems rather tedious.
That said, I would not object to them being fixed.

Reviewed-by: Simon Horman <horms@kernel.org>

...
