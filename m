Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793274944;
	b=uG+drtaPe98LTFwt2kXcBI2AinEe0jf7Zro6XpVfZjLB7chA5/0HlfCZmHG+h3O+SfDC
	 dtK05sWd9oCa8k8BMH5bT1WGP6y1RqbI7MlAferV3c7RdUgPj2Qx3AuMV/u6+8WCKsIeV
	 AEYVJMdynB2hrE9YRWo6aqbNHToyLmftC8KOIEZPME9Pp8I4IgD6rzF42pM4csBEGOf2Y
	 lU6yhmNM29yqUXvtyFZbyH9QD6993aF/DKXmS4hb31sxuU/bSIdnuqEtCYnTtBfW9QZD5
	 g67018kTw82x1RiRygWeds8f2Kcb/KNW31dSuonYtGZUzRfeQ9gZVUc2zhbj+H9KojA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793274944;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=KTQVFO6lzA96PIqvJ8pV9UqSzjjQB2hOeeMYeqx+0tA=;
	b=oyn5+35HNSmSGsYMpEJiEII5MalAlXl+HPObfjkchIW9UiVr/w+ZX8h0ra/+q8bNyTJa
	 BNGobEpjKQ1QCgWbBysf2uraQmRw15UQ6CwWG4U+Pp4TAomo+9IGhK0pvBaZ4BAMWfwXh
	 8vvUOk0poron6Y/LXwyIRJrp9XxD0wLiglxPScFvjjWFTjaaNnZYadlYG2quhFtBE/SHU
	 FjBWlbxTEgWkDAVzt7Itt7LcS4VqH5KCGzjLY1A5kfhid6lXyQYQogQ88eITWOevtX/dS
	 H5HNaTeNkSeybKy0XYx83j7c7+JdVCna6tIJV4AS6F7nfYGwubBbmpKZqLjADvM5t0g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=ACSa9OZQ;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D706F606A31A;
	Thu, 29 Oct 2026 11:55:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D706F606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=ACSa9OZQ
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C82ED21F6D;
	Thu, 29 Oct 2026 13:55:38 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=KTQVFO6lzA96PIqvJ8pV9UqSzjjQB2hOeeMYeqx+0tA=; b=ACSa9OZQh9B+
	LAp8VRdwAqHwOR2Px2EB24IG9wkcUZzO2qCihGkGemEj6o/KdD6WfeOgrhbPtzNi
	NM6PmVipshH1D2DpyxZxITRocvyZtVsdaYDpPg+ZLOh4egb52aOmJbTMEoQ1Mnkt
	WmK1EM13CoeR114C+ged3t8hBQ24BQMLulwX0vcCEX95GoneF+IVETdRuBb7slmI
	6gQvThBfupm/lmJCy/2YwtXZyjHmGiYmGalPmbHcL1ape56DRzBb/flBS1I3skCv
	7jTQ/Xnj6bSjnCrd68D80XbK01tkmcD+MaxlPcgnPT0hd4q6OwkGmfAjLSy8Wuw1
	cRMjRpbgVmVWfJ8zEHnju/CdwkiFzEfnJWdBR7wFKb0x/X1dV2JmVW+Ja7DjHLdg
	LRNo24A+w/HvC4lx4avRctelUOvyaMVJ81lCNi4sjPLrh1mPSB+oFVeK92n8Jl53
	tkyD5TjHqxHGKTeSVOays7c2eW0h5ub8RqMQJV5h9Es2Cqny9cj+JKfLEOghqR7L
	53fi6b3q7W84bQUaVSJGr4VWe5ntyhygjG2N8iwQFiw4iAzNy6BkBLQcWgDo3EUY
	PsxctM++wP2k1khWszkzmkZLLrB7zmWsVunAGCoUByEMUsgSbZzSgcnSXPa/7yJl
	9hbSIJ8Zo/5fvA3NCyl2U3RLFD3YP6g=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 29 Oct 2026 13:55:38 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 6121160A0E;
	Thu, 29 Oct 2026 13:55:38 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 69TBtWKA036805;
	Thu, 29 Oct 2026 13:55:33 +0200
Date: Thu, 29 Oct 2026 13:55:32 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Linkui Xiao <xiaolinkui@126.com>
cc: horms@verge.net.au, dsahern@kernel.org, idosch@nvidia.com,
        davem@davemloft.net, edumazet@kernel.org, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Linkui Xiao <xiaolinkui@kylinos.cn>
Subject: Re: [PATCH net-next] ipvs: annotate the lockless read of
 sysctl_sync_threshold[0]
In-Reply-To: <ede3104a-7e14-40ac-b16c-9750d5b2a8a7@126.com>
Message-ID: <7bcb4225-b6d8-3815-a6f8-61b5f885f929@ssi.bg>
References: <20261026083708.617278-1-xiaolinkui@126.com> <45d598e6-3625-0879-59b0-51f649ebe509@ssi.bg> <ede3104a-7e14-40ac-b16c-9750d5b2a8a7@126.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 29 Oct 2026, Linkui Xiao wrote:

> Hi Julian, Simon,
> 
> Thanks for the reviews.
> 
> On Wed, Oct 28, 2026 at 07:15:34PM +0300, Julian Anastasov wrote:
> > Yes, ACCESS_ONCE was used to solve possible division-by-zero problem,
> > not to solve the data race. Even if memcpy is converted to 2 int copies
> > on some archs (eg. x86) may be it is time to use 2 WRITE_ONCE instead of
> > the last memcpy. Can you include this change in v2. Post it when net-next
> > opens again by using nf-next tag.
> 
> Agreed. v2 replaces the last memcpy() in proc_do_sync_threshold() with
> two WRITE_ONCE() stores, one per element. The if/else branches gained
> braces to keep checkpatch --strict happy about the now multi-statement
> else.
> 
> net-next is currently closed and is scheduled to reopen on November 9th
> (https://netdev.bots.linux.dev/net-next.html). I will post it as
> [PATCH nf-next v2] then.
> 
> On Tue, Oct 28, 2026 at 12:49:35PM +0000, Simon Horman wrote:
> > I wonder if it would also be appropriate to call
> > sysctl_sync_threshold() only once (per-packet) in
> > ip_vs_sync_conn_needed(). Stashing the value in a local variable if
> > appropriate.
> 
> Agreed, and thank you. v2 reads the value once into a local variable,
> sync_threshold, before the branch and uses it in either branch.
> 
> One precision while re-checking the code: the two call sites are on
> mutually exclusive branches of the same if/else, so a single packet
> never reads the value twice at runtime. My v1 commit message overstated
> this ("the two comparisons ... can observe different values for one and
> the same packet"); v2 rewords that paragraph and notes the rewording in
> Changes in v2. Stashing a single snapshot is still the cleaner shape, so
> the change is worthwhile regardless.

	IMHO, ip_vs_sync_conn_needed() should not be changed, 
sysctl_sync_threshold() is not called twice in same flow. OTOH,
sysctl_sync_period() is properly stored in sync_period because
it is used twice. 

	But there is still little gap where proc_do_sync_threshold()
changes the two values one after another while ip_vs_sync_conn_needed()
can not take snapshot without using some common lock, eg. some
seqcount should be more appropriate for this. Writers are already
synchronized with the mutex, so ip_vs_sync_conn_needed() can read the two
values into temp vars under read_seqcount_begin()+read_seqcount_retry().
And later to use the temp vars. proc_do_sync_threshold() can use 
write_seqcount_begin() and write_seqcount_end():

	local_bh_disable();
	preempt_disable_nested();
	write_seqcount_begin();
	2 WRITE_ONCE
	write_seqcount_end();
	preempt_enable_nested();
	local_bh_enable();

Regards

--
Julian Anastasov <ja@ssi.bg>

