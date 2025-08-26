Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8F63350D7F;
	Tue, 26 Aug 2025 14:18:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756217934; cv=none; b=CwObNESKlB7/PRR2fdCmTm1smyD72EOHj7ijg7rXYv6zMrmxqTXDIeF0bbEKgjrWBULjAVv2vVDfsmmS54GW8TsR/Kj9LWK7zC2wnZOrnsVMUnTqh/pP0UU0R2s5zLUEkExt+FJJ9GC22Hhnl8Dta9igpZ/+NkTfPXZVGCfBHNA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756217934; c=relaxed/simple;
	bh=+fotUMxKdBFVqdCvmZNEwgNf1+Kq3d7yFh1kb1zLVdU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=mGBMu+pkVqNMJXhNXAR8Rfvd5rcpzufq9iyEYyWE780ruP7bogA3Hpi5svJiMJ2qEUWiO3N8vK40dRDGaTxv1iNHyyRv4U6I33Snrblx7vnCd4za103pvN3zIRw9XOozCOAw5l8gAvjMKqfRJJPsXhgbUDugi0aiv3krA1cXj9w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id 26F7460B33; Tue, 26 Aug 2025 16:18:44 +0200 (CEST)
Date: Tue, 26 Aug 2025 16:18:43 +0200
From: Florian Westphal <fw@strlen.de>
To: Zhang Tengfei <zhtfdev@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	"David S . Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	coreteam@netfilter.org,
	syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: Re: [PATCH] net/netfilter/ipvs: Fix data-race in ip_vs_add_service /
 ip_vs_out_hook
Message-ID: <aK3CQ1yNTtP4NgP4@strlen.de>
References: <20250826133104.212975-1-zhtfdev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20250826133104.212975-1-zhtfdev@gmail.com>

Zhang Tengfei <zhtfdev@gmail.com> wrote:
> A data-race was detected by KCSAN between ip_vs_add_service() which
> acts as a writer, and ip_vs_out_hook() which acts as a reader. This
> can lead to unpredictable behavior and crashes.

Really?  How can this cause a crash?

> The race occurs on the `enable` flag within the `netns_ipvs`
> struct. This flag was being written in the configuration path without
> any protection, while concurrently being read in the packet processing
> path. This lack of synchronization means a reader on one CPU could see a
> partially initialized service, leading to incorrect behavior.
> 
> To fix this, convert the `enable` flag from a plain integer to an
> atomic_t. This ensures that all reads and writes to the flag are atomic.
> More importantly, using atomic_set() and atomic_read() provides the
> necessary memory barriers to guarantee that changes to other fields of
> the service are visible to the reader CPU before the service is marked
> as enabled.

> -	int			enable;		/* enable like nf_hooks do */
> +	atomic_t	enable;		/* enable like nf_hooks do */

Julian, Simon, I will defer to your judgment but I dislike this,
because I see no reason for atomic_t.  To me is seems better to use
READ/WRITE_ONCE as ->enable is only ever set but not modified
(increment for instance).
