Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A141E3E0082;
	Mon, 27 Jul 2026 20:29:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785184198; cv=none; b=ZQxoCM7NdXnAMTUY8SWw5l4LmtTPX19sHcLbvVwkwGXcdxdNp42ZIdZ2uUhkUS8X5K6MHTuKfC3EACRK6yxsQKAqTKB0CK0jBE84siTe5E2iotW0ZMJgFrpSV8ioGX8DJloRVANej+uJotmc4XJ328dDeWS2Y8rFILs1Ai9Vzeg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785184198; c=relaxed/simple;
	bh=azBdmjFcUan1cGZEgw2MRCNoKvq+SPsr0rUO+RQr4Vo=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=P/aDOqnAXYLivFG7Ed0ZdEdQeko4DS7GZmM15KxWLsp+gkbdnkVd4/DDpuSmTfs/FBTcIML9mhcTnKjWo0WPgu9IBdLiTlwqSfHBeOHkRPBSVjMoUbdyXgoXWONKTUS/+my5YYi/0UbX/S6/AKgmgVzebKvyOnKFcFHNp0CoeJM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=dkT3ZUjl; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="dkT3ZUjl"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2445421B1A;
	Mon, 27 Jul 2026 23:29:49 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=YGP4SVauzFH96UHVQG5HR9nPrqFdyCo1oXtz6YSemtM=; b=dkT3ZUjl7Wsr
	OIq3O9GhjHduqzCw1Cmfb6XvfaZfHdBeaw6FAZ8g0BzActZG74S+fbe4VTt6lpIo
	2StZdGCzaQBOy1UhGD49HuIC5/dv2eaYs3BBb8SL4kzu/r6mKYUhatd5zlSmmWhH
	MKfkUq2WY7LH+1rZ3jmPf85C/MQiItSVUmvNM1Uyh/ip8hpnX9DlmmnokpRDoxR/
	KOmYF4iDDcjfgZpK4HfvSnLIyVU9r4lTwwMdnAXfC6uo8B9+RZ6kzVKA0iP7SrfR
	AV8PS8esgudUrT/JZ9TaqM7luqsPwI4wKiUoeiNEdSYQ643YjREizls82ef0m6ij
	lXw5w+jMf/ZZgBkXuDfQBA3oCcYAQpnv8+G1Nb/fCWD0Gx/FWuzCwwESrfWhzqqz
	M4X7v0ca9v41C2Y5Lu6/yireEJBelMHFSg5Ru1TctDI7QNskdkdQ8zrxaie0goc0
	+E6zwt+5PBXg0v51+GL0e05VtIggsWNJclLsbgAHaBWfaAfVCAp/2URGuUBbUst+
	gQb2M2nLGZZUVq2hAOHmnVeBcgcxTtfF8RbMMhYcaCGbPVKPnw2eBbtP49cleJ/a
	ve6uqGdonpynT/ar2qRl04H0gpBBb5Db9KZjiDryJ9/xuwXULaP2REJPrm4e3o+s
	QvkAVfxF/WtFibBow751cJ3LNPJek2w=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 27 Jul 2026 23:29:48 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C6B566005A;
	Mon, 27 Jul 2026 23:29:49 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66RKTjU8087273;
	Mon, 27 Jul 2026 23:29:48 +0300
Date: Mon, 27 Jul 2026 23:29:45 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf 0/2] ipvs: csum validations, part 2
In-Reply-To: <20260727185024.67534-1-ja@ssi.bg>
Message-ID: <01f8c2a3-57dc-76c5-c214-cfee9cd2255d@ssi.bg>
References: <20260727185024.67534-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 27 Jul 2026, Julian Anastasov wrote:

>         This patchset contains more fixes after the
> previous batch of fixes for checksum validations.
> 
>         The first patch avoids reading the IPv4 ihl field
> multiple times to prevent local attacker to cause
> out-of-bounds write in ip_vs_nat_icmp.
> 
>         The second patch returns the per-proto checksum
> validations which can be needed for the FORWARD hook and
> provides helper for ICMP.
> 
> Julian Anastasov (2):
>   ipvs: avoid out-of-bounds write in ip_vs_nat_icmp
>   ipvs: return the per-proto csum validations

	According to Sashiko we are returning to broken
TCP/UDP checksum for IPv6 on CHECKSUM_COMPLETE, will send v2...

https://sashiko.dev/#/patchset/20260727185024.67534-1-ja%40ssi.bg

pw-bot: changes-requested

> 
>  include/net/ip_vs.h                   |  31 +-------
>  net/netfilter/ipvs/ip_vs_core.c       | 102 ++++++++++++++++----------
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |   2 +-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |  40 +++++++++-
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |  47 ++++++++++--
>  net/netfilter/ipvs/ip_vs_xmit.c       |   2 +-
>  6 files changed, 143 insertions(+), 81 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>

