Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A5761D5160;
	Thu,  9 Jul 2026 21:24:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783632268; cv=none; b=qM04Vo2kwcfr70jSqC0gjrVpjC8gtSlwCfcFfzo/5i4d1AF9cAiqbIGJcp+lnK3fHV7TDaTmQQIcOo4cVWDPqVpQSHYvh/A4f1fxnnoivmTifVJt1lSB0BVpEhyYNu7SZyfmOGArDmVXqbwRPIdqhmsTJcPlqhZH1PNksUCWdWM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783632268; c=relaxed/simple;
	bh=6lCScXnxAKdLScKBiarupLDikZ1YWD8rIA/8Qp74qlg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=IIzjwNbhI/u6usrwjHZoGiSZfIy/KT+SR/QvYFzgz0bzgGA79qFwLuNgFy/6W+dPclO/hsVtyFhSHM3vjuuolVi9Ze46jrtQuHadpz8/A6MOhu1/586yHo4OzW1Mbq3rMY8GD00THlk6rUwHfzGaIjQoCtkhSrKIziAnclR9SuE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id 0CB84602A9; Thu, 09 Jul 2026 23:24:24 +0200 (CEST)
Date: Thu, 9 Jul 2026 23:24:22 +0200
From: Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: fix the checksum validations
Message-ID: <alARhv8ezLbt2MBK@strlen.de>
References: <20260709202356.104307-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260709202356.104307-1-ja@ssi.bg>

Julian Anastasov <ja@ssi.bg> wrote:
> TCP/UDP checksum validation for CHECKSUM_COMPLETE is broken
> before the git history.
> 
> Expecting skb->csum to cover data starting from the protocol
> header is wrong. As IPVS works at the IP layer, the csum for
> the IP header is not subtracted yet.
> 
> ip_vs_in_icmp_v6() is missing checksum validation for ICMPv6
> packets from clients.
> 
> Also, Sashiko points out that handle_response_icmp() being
> common for IPv4 and IPv6 is missing the pseudo-header
> calculation while validating ICMPv6 messages from real
> servers which is a problem if checksum is not validated
> by the hardware.
> 
> Fix the problems by creating ip_vs_checksum_common_check()
> helper and use it for TCP/UDP/ICMP both for IPv4 and IPv6.
> 
> Also, ip_vs_checksum_complete() can be marked static.

Just FYI, I'll ignore the sashiko comment wrt.
'hardcoded sizeof(struct ipv6hdr)' as thats resolved by your
earlier patch, so I plan to include this in tomorrows batch.
