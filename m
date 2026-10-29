Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=117.135.210.8
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793258046;
	b=nFsA5ltz/ujF5K33JXZbep8odIK3G0oSpbnrvogmOrxJA407K5uAR5Z1Apa6EBJ07gax
	 aDcF61E0Rl10+a1UHAMQtbUmVyCKrFmhhJThGI2mZCODncwYxD0tW8ETHtsJa14o3gqzV
	 lI4ciL9UOZPmD+SEz/2/QLXGMFEdG8GRaLLR2DMz5fUBKEZ6jsA01ngVz9FXMK1jvbpFX
	 B2ZyenoA323vooeBn9rve+5fG0xFKbTqAyhbTwdkUMAjk5xGAEE5RwqGG5PxiOQMtuAMh
	 QxjOMJmIWNcGInsiwR/R/hN9P5VG+40NfF7VxOazsedfKRM7aTCz0LSLk6hX1sU4QwA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793258046;
	h=DMARC-Filter:DKIM-Signature:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:Content-Language:From:In-Reply-To:
	 Content-Type:Content-Transfer-Encoding:X-CM-TRANSID:
	 X-Coremail-Antispam:X-CM-SenderInfo;
	bh=RbnMv4NDWsSfm6NxZli87tg/xVFmW0yI0I8tPFPNz/g=;
	b=YcuWo4ZX1UlAdrenJp97+8sjz8FF68vfCYoJHBm94WbAVd+AAzArdzEmQ7Gn5ZjNbia4
	 PfdZd5Ty87FOwTkqxppyZi5hh472mApf4PwYwJ7Q505etdYTQpl6nbKiNxkjFcsDFAFWR
	 XbS7o6ls7vF3srW9nr+kWuM5JTVxhSFMPbCxQ/jcYJqmFFKib/DN6bLSc1NDQhAFF28rb
	 B7uJy7N7S2n3Q/U6Yjeli+RgqNuk6YcsRNQKIne/ZwW0OZ1eEw7W2GqzSqIb3odMqxGjx
	 l4r7cSjspwJVwzbkuANW5pKM5/DD4dsYY6VUrHYJXtj3jHQv6M8XsbTph+UP84WH2Tg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=126.com;
	spf=pass smtp.mailfrom=126.com;
	dkim=pass header.d=126.com header.i=@126.com header.a=rsa-sha256 header.s=s110527 header.b=n1ugxA1Y;
	arc=none smtp.remote-ip=117.135.210.8
Received: from m16.mail.126.com (m16.mail.126.com [117.135.210.8])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74C9A606A31A;
	Thu, 29 Oct 2026 07:14:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 74C9A606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=126.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=126.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=126.com header.i=@126.com header.a=rsa-sha256 header.s=s110527 header.b=n1ugxA1Y
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=126.com;
	s=s110527; h=Message-ID:Date:MIME-Version:Subject:To:From:
	Content-Type; bh=RbnMv4NDWsSfm6NxZli87tg/xVFmW0yI0I8tPFPNz/g=;
	b=n1ugxA1Y4FY/D66ZAf6vU6Da+o8xXcBIJ/SYYtkXRqDK9dQU8zKVH5SdC5rCOP
	GZhonQzO9F+jboy+PzqS+s0aFtbOPy4vAh8KbVzqnHK0Lr3Paxd14rE8oIbnAXDR
	oF1NpCctM8/muSuNfE0jYdyhL7CHRa24gYL8xZMdCkD/0=
Message-ID: <ede3104a-7e14-40ac-b16c-9750d5b2a8a7@126.com>
Date: Thu, 29 Oct 2026 15:12:24 +0800
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net-next] ipvs: annotate the lockless read of
 sysctl_sync_threshold[0]
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, dsahern@kernel.org, idosch@nvidia.com,
 davem@davemloft.net, edumazet@kernel.org, kuba@kernel.org,
 pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
 linux-kernel@vger.kernel.org, Linkui Xiao <xiaolinkui@kylinos.cn>
References: <20261026083708.617278-1-xiaolinkui@126.com>
 <45d598e6-3625-0879-59b0-51f649ebe509@ssi.bg>
Content-Language: en-US
From: Linkui Xiao <xiaolinkui@126.com>
In-Reply-To: <45d598e6-3625-0879-59b0-51f649ebe509@ssi.bg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-CM-TRANSID:_____wD339LY8eJqcEnFBw--.42381S2
X-Coremail-Antispam: 1Uf129KBjvJXoW7KFyrXr43JFWDKr1xXr43Jrb_yoW8Ar1kpa
	9FkF4qyrWkJw4fZFZ7Cw47ZFZaqws7A3s0kwn8ArWDAa13Xrn2yrWSyay5GFyqkFn3u3ZY
	vayUX3s5Aw4kZaDanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDUYxBIdaVFxhVjvjDU0xZFpf9x07UZZ2-UUUUU=
X-CM-SenderInfo: p0ld0z5lqn3xa6rslhhfrp/xtbBlRsG3Gri8dvnSQAA3Y

Hi Julian, Simon,

Thanks for the reviews.

On Wed, Oct 28, 2026 at 07:15:34PM +0300, Julian Anastasov wrote:
 > Yes, ACCESS_ONCE was used to solve possible division-by-zero problem,
 > not to solve the data race. Even if memcpy is converted to 2 int copies
 > on some archs (eg. x86) may be it is time to use 2 WRITE_ONCE instead of
 > the last memcpy. Can you include this change in v2. Post it when net-next
 > opens again by using nf-next tag.

Agreed. v2 replaces the last memcpy() in proc_do_sync_threshold() with
two WRITE_ONCE() stores, one per element. The if/else branches gained
braces to keep checkpatch --strict happy about the now multi-statement
else.

net-next is currently closed and is scheduled to reopen on November 9th
(https://netdev.bots.linux.dev/net-next.html). I will post it as
[PATCH nf-next v2] then.

On Tue, Oct 28, 2026 at 12:49:35PM +0000, Simon Horman wrote:
 > I wonder if it would also be appropriate to call
 > sysctl_sync_threshold() only once (per-packet) in
 > ip_vs_sync_conn_needed(). Stashing the value in a local variable if
 > appropriate.

Agreed, and thank you. v2 reads the value once into a local variable,
sync_threshold, before the branch and uses it in either branch.

One precision while re-checking the code: the two call sites are on
mutually exclusive branches of the same if/else, so a single packet
never reads the value twice at runtime. My v1 commit message overstated
this ("the two comparisons ... can observe different values for one and
the same packet"); v2 rewords that paragraph and notes the rewording in
Changes in v2. Stashing a single snapshot is still the cleaner shape, so
the change is worthwhile regardless.

Thanks,
Linkui Xiao

