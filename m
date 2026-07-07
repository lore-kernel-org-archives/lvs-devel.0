Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B41EA3F4DDB;
	Tue,  7 Jul 2026 13:51:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783432288; cv=none; b=OiUpJUylyNescsB/hSEFycLseRte5esbQbqIm3VaxknLjjvVu9McJ2YGcyLaoJWHJ4cjMIz+ynnMUNcHWjBeisHj1XkhRXQ2ZB5CIP2jDtINWqRyV95eIZ5A9/byFIMRW27mIhzcK2kZjDzxal6DBuMWT1ShyPEUWVSAvuCDrIo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783432288; c=relaxed/simple;
	bh=vxInMY00Jzl3/lr3lH3zr+U2RqbRBBU8wA4aSfKJKHc=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=IlWXGN6bPQ4J5R/jw3IwBOLtJTV85HlLkrFOf30kX6wXhA+ju4ao0/Lnh4ZKldKsyCdEYXc0XSzyUccYgsXsRjBNTMLpjf/IaWASYTG+0IEMJcwHc1dIiNMIznR+2meDWWi+wqcuzKuIhw71OOFGvVt5DTnLCRr1C0/yd+2GRVs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=aRVnyjvY; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="aRVnyjvY"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9030521302;
	Tue, 07 Jul 2026 16:51:19 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=VI3pBgOZzhP1av4QcJZuHCeEiA9AJwOZl1ZTj3J6s6I=; b=aRVnyjvYKndf
	Wn5j9k9AMp/tVUoNhE0mjfPQdiw1gGY3BM1wK5BvC0yQmaBuE8idfDBR7bx/nZnr
	2R9p8a+sl2oGo/mzHg0w98fb67ZPeDH5AfebmnFodr037ReG1kcxFg6hVz2cSkzk
	chUbHWNl8k1pxOR/6WBw0fa6tQIy5y4sHkHPu9Mtz0S7V9oZrQlzhesv2JNKGGvq
	iEysO2/mkZME2ba/E+NqhvV+bET8WgePSQ2vk2mC4PvHBcxTkFiVRa2THE/zeaUz
	JdKQqdUenqpZuTQY9CKRgsNcyVbHzPpQqXHsXtGBls8xZazG76cfJ2iu8sWY+b7T
	RRfM6rk+WJ2QRX3YNNMkHmB8TjSAgeDH9Vo8sQY4TRUqvuAhKg791D6aWtiiqabj
	ITcE4O/4p81Weip24c7GHM2KVOrtLCi8tS1GkN45Ua88Zh9+UdMZ0mioiQNlwF73
	2+1XTwFnCZaVAeSA1ZZjSP1062X7JpFzush0FlwZCKNf7kzjrkO0uzRKifQvBNZs
	GtVHvfxVI9rcb3TnVzwa/nWrRmYtUnn13yRMZf7tUqUAAQbGbynK9G6gZzwErmSV
	velTwRWw9LFDK67bi+epGLUQjeCH3lxFps01ttWT+d7qUpY3OCazjdh32Khfbo6j
	xIR5kAFkzrqZRixWdkugfSEUKgIl4dI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 07 Jul 2026 16:51:19 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A9C4F60374;
	Tue,  7 Jul 2026 16:51:15 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 667Dp6Hk048186;
	Tue, 7 Jul 2026 16:51:07 +0300
Date: Tue, 7 Jul 2026 16:51:06 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: netdev@vger.kernel.org, coreteam@netfilter.org, davem@davemloft.net,
        edumazet@google.com, fengxw06@126.com, fw@strlen.de,
        horms@verge.net.au, kuba@kernel.org, linux-kernel@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        pabeni@redhat.com, pablo@netfilter.org, phil@nwl.cc,
        qli01@tsinghua.edu.cn, stable@vger.kernel.org, wangao@seu.edu.cn,
        xuke@tsinghua.edu.cn, yangyx22@mails.tsinghua.edu.cn
Subject: Re: [PATCH nf v2 0/3] ipvs: use parsed transport offsets in state
 handlers
In-Reply-To: <20260706101624.69471-1-zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <f1ca1fbd-b8db-a012-3db1-c5aa7d579408@ssi.bg>
References: <20260706101624.69471-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 6 Jul 2026, Yizhou Zhao wrote:

> IPVS parses packets into struct ip_vs_iphdr before scheduling and state
> handling.  For IPv6, iph.len contains the real transport-header offset
> after ipv6_find_hdr() has skipped any extension headers.
> 
> TCP and SCTP state handlers still recompute their own transport offsets.
> They use sizeof(struct ipv6hdr) for IPv6, so packets with extension
> headers make the state machines read the wrong bytes.
> 
> Pass the parsed transport offset through the common IPVS state handling
> callback, then use it in the TCP and SCTP state lookups.
> 
> Changes in v2:
> - Pass the parsed transport offset through ip_vs_set_state() and the
>   protocol callbacks.
> - Fix TCP state handling as well as SCTP.
> - Avoid reparsing the skb in SCTP state handling.
> - Split the common plumbing, TCP fix and SCTP fix into a 3-patch series.
> 
> Yizhou Zhao (3):
>   ipvs: pass parsed transport offset to state handlers
>   ipvs: use parsed transport offset in TCP state lookup
>   ipvs: use parsed transport offset in SCTP state lookup
> 
>  include/net/ip_vs.h                   |  3 ++-
>  net/netfilter/ipvs/ip_vs_core.c       | 10 +++++-----
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 18 +++++++-----------
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  | 11 +++--------
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |  3 ++-
>  5 files changed, 19 insertions(+), 26 deletions(-)

	The patchset looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	The Sashiko comments need additional fixes:

https://sashiko.dev/#/patchset/20260706101624.69471-1-zhaoyz24%40mails.tsinghua.edu.cn

Regards

--
Julian Anastasov <ja@ssi.bg>

