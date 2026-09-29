Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AFAB51993C;
	Tue, 29 Sep 2026 18:29:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790706580; cv=none; b=JZ7oTdVxS1SXrdyPBsVB15kYhST1FJSxnrBjEizeqvlJOaKrlo1rfrBjTVuOTCnYlNg1bvvkAFYCIgb9G5FYS6pSugs0fdZxjgXaZyk/8hmBbOQgunbCk81G/fH2YK20GHYkMMI2W2Q0AQD/LZu8YKT7WeY2qWWKsgdFRcYW3e4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790706580; c=relaxed/simple;
	bh=MkjYg9lJjQHLexc4kE8JBS2fARX5648jN9MXBQEw8e8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=NtGufULQ042K74l/NZTNlFy9+6OgeTdSRbKs2n0F3yz7TfTivhf2ajVYSFySC7pKUBUKHf+MFwmc14kV4NUxbEbpwXbrFqLSDOimReampPivQQFefx+rO6dZscOchQJ8itgurSgsZvK1VaHnYasqbPUgezy9fmF/qzBRIU2/B8M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=DkXWT1qW; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="DkXWT1qW"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0A083213E8;
	Tue, 29 Sep 2026 21:29:33 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=EGPlfOni74HY9vCawk06lL/V5/Z16mKPBfpzZXIDPZU=; b=DkXWT1qWq+9V
	D/CAhKwvOdz6qrqms/6cVCHVmhaQEAzqxzGKULTp8QoIrf7cRvkQzs/mGG92zGiu
	+wRmrK43rtRdjN1S2+YbiSrjWCGpAY804jjgxLbiPMFUmcAenz5tCe5dsRPF5vgn
	645lltg+cNH5KZ8XjLa+zLIAEXDYV06apvgrB9eAhaPHOJyCSXXvKxMhdhkTinhC
	uRATUVfQuEqNrwJAAj6WHx41pNb2ga/HXanGLG4VwueaspLAY4ywNgN4xxWYoLNR
	FkvSW2A//tmE1VlIoc/vDMyq1QoPJl7Do23YNKptrHX6tj0/18GlWUbYGDSCZHG1
	dc+N8VJ5EKNbgaGE7FcpJsZyY9Bdc6STI5Qc+rYQtx28Wg3oB3F1B005xa1D6USi
	Bei3YcPGjCA7WNqci+dqepyKrSu+0arduFQsD3xxdSofQ68NuLT156BUmrJA3WA6
	Ex1dRdODtSYJRLGTSt81CQIZiQEeJbkreXdxG1XzmRG1ThHqCojfvu63TdBCbrYc
	AKSz7l49i8YqCTvhU9Al/r3Z43RHEs09a4WpYsPOq+bqZNwVLHruE2ONzTITjRrZ
	juwz2tTeAlSPgRKxj/SqltZCv08mUdagKFeE6EvN++0tz/RCzy0AdnftPTlr3+Md
	LKW8YYrPYzImNWWoBAqNDJWMngvYouI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 29 Sep 2026 21:29:32 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4858461DC8;
	Tue, 29 Sep 2026 21:29:35 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68TITWpf080057;
	Tue, 29 Sep 2026 21:29:33 +0300
Date: Tue, 29 Sep 2026 21:29:32 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Willy Tarreau <w@1wt.eu>, Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: keep templates and cport 0 conns away from
 packet lookups
In-Reply-To: <20260925141115.16126-1-axel.mierczuk@1password.com>
Message-ID: <002e2c69-ae17-4321-ba3d-74cca0e57123@ssi.bg>
References: <20260925141115.16126-1-axel.mierczuk@1password.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 25 Sep 2026, Axel Mierczuk wrote:

> A template received over the unauthenticated sync protocol with a
> nonzero cport is matched by data packets in ip_vs_conn_in_get() and
> the protocol state machine runs on it. Patch 1 rejects sync records
> with inconsistent cport and IP_VS_CONN_F_NO_CPORT combinations on
> the backup.
> 
> Patch 2 requires a nonzero cp->cport in ip_vs_conn_out_get() so that
> templates and connections still waiting for their cport cannot be
> matched through the out hook.
> 
> The companion patch "ipvs: filter some flags received in the backup
> server" rejects template records carrying IP_VS_CONN_F_NO_CPORT.
> 
> Axel Mierczuk (2):
>   ipvs: validate cport in received sync records
>   ipvs: skip cport 0 connections in ip_vs_conn_out_get()
> 
>  net/netfilter/ipvs/ip_vs_conn.c |  3 ++-
>  net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
>  2 files changed, 21 insertions(+), 1 deletion(-)

	Axel, this Sashiko review is shattering:

https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com

	I'll be back with analyze how should we fix the
problems...

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

