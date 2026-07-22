Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5EA9640F72E;
	Wed, 22 Jul 2026 11:56:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784721372; cv=none; b=EdkXOhvWeeyDUTUmzK2Em3uv5iTY4mRcT6w2GlLHNDYsVLof25Y8OCkkTInHX1nu8d0uE2fuG5uf90DCd2QPuDelh9EqUtozPdBMIlXUZtdP7XBzGjE3RK0+mlIAZENsXL1+pVp23s0QYyoHTFsB+D3oeA8fL2K6xedFR6lLvoU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784721372; c=relaxed/simple;
	bh=o6DdAHfK0WK3kOP6d+3+BGqLk26R+me47AsAcP1Eyc0=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=nj6+Fh2SOorLuBo1rWR9lU8b/ZSE20+cy4aZ1U5ygJE5apAEECFE57wXPiyTScX1EVkLXdynVYICfvCXPG9/s4sJiJxflwuinChOzMLuI06QTzQgcbGk4vZDxC1l9q7HLFulrViGYUHTFul+cvgT1zwhVsw2buDXS2/keJUByS4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=UAJDfUw+; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="UAJDfUw+"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 7968521B14;
	Wed, 22 Jul 2026 14:56:04 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=o8rwjnGnINebYBzOw9QyXB5m8fYjYdG/pkf8Q1uWN8s=; b=UAJDfUw+CiEP
	+WMXtRj+W4ygA6UALsaJ6cv6bO/pkvsa2MLQgJn/ymkG8xTBUJe8ktKob90MBhmF
	++0hGzHeHoj9yu8NEmBDOwHCP7u70wihwZUEU1yT1E41KStNVudlDdFaRaxEniQv
	Wi5O5PIIcoD+vd9cmNrE8NKhUwFmv0MdVK3Cu4JBtR2ML81QhDbJgbjmpS8cI6Xj
	vA48I7nZf5Fcrt/u5iT6Zr+45RuoY+TlMTaSeNldaeSiPdifX7MDblIJLnvcXMHC
	s18w6PStee2k3GDQlBIA9DXC07/7Z3Yu1vA5WiFUZ0LySkNUrOuPY0IWUI4ugBmv
	s7bMH4rOm8/AQbPjdR4ZnXTRi5d7m/sLOqb09uFiSypNGyZe3TXI8eqwzUGPC/3M
	qfOvu86KBqf7smlIz6TkY1RuuiptBv6tPYqCfU/ZuVRaJjuWR9t2mFqxDXfEMRUM
	jUusRd/2QoojYjNZQgK/6/YTaqLyIKkg2GIWABRBZqjinEUjxS+If/8CPPgzARxF
	cDKlfZah6EzSU1S+0LqHrlZUX4D0t4Kt4WQD7eHFMrZBiBHoOQYiMTX2fWdkkl3t
	Y+djt1QawHKP0igi7+uIzTzmu/prnGg7dL1f9AfJT7cdppcsiFbH9x6Pu26WERQF
	3XmoPFCPQ9Zj2k2bQ8v9ZXxrHxAyfBg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Jul 2026 14:56:04 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 85397609FD;
	Wed, 22 Jul 2026 14:56:04 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66MBu2GF047135;
	Wed, 22 Jul 2026 14:56:03 +0300
Date: Wed, 22 Jul 2026 14:56:02 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v3 0/3] ipvs: csum validations and data offsets
In-Reply-To: <20260722101517.36313-1-ja@ssi.bg>
Message-ID: <500fc6d8-1808-9600-3eac-17f4027e302d@ssi.bg>
References: <20260722101517.36313-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 22 Jul 2026, Julian Anastasov wrote:

> 	This patchset contains fixes for the checksum
> validations for ICMPv6 and switches TCP, UDP and ICMP to
> use nf_checksum for LOCAL_IN.
> 
> 	It also corrects offsets to be based on skb->data and to
> respect the network offset.
> 
>         Finally, it prevents to read/write ICMP payload for
> non-first embedded fragments wrongly assuming the TCP/UDP/SCTP
> ports are present there.
> 
> Changes:
> 
> v2->v3:
> * patch 2: add __maybe_unused to coff and outer_proto to silence
>   the compiler warnings when IPVS debugging is not enabled, reported
>   by the kernel test robot <lkp@intel.com>:
>   https://lore.kernel.org/oe-kbuild-all/202607210623.du5PqolJ-lkp@intel.com/
> * add patch 3
> 
> v1->v2:
> * patch 1: switch to using nf_checksum, validate only at LOCAL_IN and
>   for MASQ
> * add patch 2
> 
> Julian Anastasov (3):
>   ipvs: fix the checksum validations
>   ipvs: fix places with wrong packet offsets
>   ipvs: do not mangle ICMP replies for non-first fragments

	Comments about the Sashiko review:

https://sashiko.dev/#/patchset/20260722101517.36313-1-ja%40ssi.bg

	About patch 2 for ip_vs_in_icmp() and the offset for wlen:

- there is a 'offset = ciph.len;' statement just after
ip_vs_fill_iph_skb_icmp(AF_INET, skb, offset, !tunnel, &ciph)

	which accounts the embedded IP header. So, if I don't
miss something, Sashiko is wrong here. Not sure if the confusion
comes from the fact that patch 3 removes this statement and
the wlen argument

	About patch 3 and the double-fetch of ciph->ihl:

- this is a pre-existing issue, unless there is no new version
for patch 2, I'll create a followup patch to fix it as it is
done in ip_vs_nat_icmp_v6 in patch 2.

>  include/net/ip_vs.h                   |  48 +++++--
>  net/netfilter/ipvs/ip_vs_app.c        |   4 +-
>  net/netfilter/ipvs/ip_vs_core.c       | 180 +++++++++++++-------------
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |  19 +--
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |  48 ++-----
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |  54 ++------
>  net/netfilter/ipvs/ip_vs_xmit.c       |  42 ++++--
>  7 files changed, 193 insertions(+), 202 deletions(-)
> 
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

