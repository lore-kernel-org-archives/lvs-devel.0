Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BB4D41D131;
	Mon, 17 Aug 2026 12:41:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786970512; cv=none; b=o34GxSPmrTmAHry9nShZCYTEg1kAtljO0Q5bVP1YZBRstZbWfAjHL5m//bdaxDv4OXEZtt+59y/+K68OkNdJrhAWXvtXnrE4b9t6K7Fj7ILVeoVCiSEUTlF3S+1OqruN/mivLeRlqTiebG+/iQRncVneZU6H7ATJZzHPLhZxAtY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786970512; c=relaxed/simple;
	bh=zfRrz7xtFN8cML7zAWcaqtwHfaRnTQd5653n6MGI790=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=rSGb7IPjgZkjK7X7jcEwQSnSbz2yEkn55nBw2d5iIAn1y+oX1b+HVT43QvdjDK5hKMFB3wYz/ZS6pIFgInO7MYtSF76NZmkf2xiqAHws6ULsdLjFXelHAyeLhBRLnWm33tbQlBfIPxsGHZIpaROuLWV59IyznmQBkxIfpMDnoGc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=ZIxxJvGI; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ZIxxJvGI"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9553A21CE3;
	Mon, 17 Aug 2026 15:41:35 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=EAgjmPwBop0nYLxGKQsEdv5d+OQgoOwpt8TK8CSF/MM=; b=ZIxxJvGIc+Z0
	494EEa61I1bN60ptZvT0gpVsq3iwRSEI1siEeQ3yPRxa508AoEvaTOd47Vy1FhjX
	sBG0T8XPjnLjzZzqwhjZoisL/+981PSH0kzXeaF6Dhbfdn2VxyVpC37VIr53WotU
	FW7JdCVLbXCkAwiB7QBwIGkb9AkvXqcH09QYlmc5a5GG5BI0FWsgY617AGAoBx4g
	fo8D4J0HA/pr1Ej5ZICa5yNg2AXdu9fYMZC4V9rxfabtha78EoA7Xp4IOIgj+I4I
	EizcdrZ+r0bn8FlHyntd6sUdPOPz0VmMLuH7EaXFUIL7P3AOl9XU3OQqF8iVhjf+
	Ygztrso8IdwGQLhAstlpUqnf+m92VwdcbFc17FRfQMQqPB1FCfj5UiCEpwM5iNr1
	UQk65GWhjcr5onQXnoV2thHlijBRUhXz6kD+HiUCe8pE/sumSnQQNDqg6Dc8kKkJ
	8dmtVbdQL/A1LB0rpl6DV+68vWsIae1caFPbwApV0e+aWy2sXg8Tm5CatJ5Ojkct
	KwJ/R2HSnOIyyL/YZEC36A8EYBf/pSWFHQcW+uGYbI6S9rMNEPyP/wz+jVdDP/nL
	a5vGJcYyLI5sQ6feXcwlbSv8EUZXoZ+hlttujdRqh0xa4VlVSdSfpG+vqQ0s8ie0
	eA7/ONw8smJC1WL8I9GxJzzIFthSrXI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 17 Aug 2026 15:41:35 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id ADB6760A57;
	Mon, 17 Aug 2026 15:41:37 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67HCfXMC047864;
	Mon, 17 Aug 2026 15:41:35 +0300
Date: Mon, 17 Aug 2026 15:41:33 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhiling Zou <zhilinz@nebusec.ai>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        vega@nebusec.ai
Subject: Re: [PATCH nf v2 0/1] ipvs: bound LBLCR and LBLC cache growth
In-Reply-To: <cover.1786949472.git.zhilinz@nebusec.ai>
Message-ID: <90ff9fd0-b46b-7eac-ade3-d0ebbb0ec06b@ssi.bg>
References: <cover.1786949472.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 17 Aug 2026, Zhiling Zou wrote:

> Hi Linux kernel maintainers,
> 
> We found and validated an issue in net/netfilter/ipvs/ip_vs_lblcr.c.
> The bug is reachable by a non-root user through a new user and network
> namespace. The same cache growth bound is also missing from the sibling
> LBLC scheduler in net/netfilter/ipvs/ip_vs_lblc.c.

	Sashiko reports for a missing atomic_dec(&tbl->entries)
in ip_vs_lblc_new(), after the ip_vs_lblc_del(en) call:

https://sashiko.dev/#/patchset/17cbb1d0649f4e19aa2e407ab4b528d42b8edac4.1786949472.git.zhilinz%40nebusec.ai

	But it is not related to this patch. The GC
probably needs to be improved because with this patch
we should be freeing 16 entries in average from single
bucket but before that we are not caching new dests for
60 secs.

	While max_size works like a low threshold for
entries in cache, we do not define maximum to apply.
After checking the code again, we may need to provide more
bonus for the normal traffic to cache entries in the next
minute (eg. +50%) while we are freeing cached entries in
the background to free space for the new dests. Because
without caching we are not using the servers persistently.

	May be separate patch can rename max_size to
min_size and to add max_size = min_size * 3 / 2 as a
limit for allocations. For this patch we can use just
"max_size * 3 / 2".

Regards

--
Julian Anastasov <ja@ssi.bg>

