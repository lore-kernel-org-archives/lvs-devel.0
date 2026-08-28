Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B7A73905F0;
	Fri, 28 Aug 2026 09:33:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787909591; cv=none; b=fe21VfLeVC3KGvVPz3LiHdp1yLUb9MxEZkxdgosR+iXpf4oDMRqaYEUUXV5MGF62pvR67OY7l4wNY5grV1K4bg+QACdxdN0cBFZbkE8bWEUZizwnum4AK9EyE6vcKlYFyMerigeMWASNrrOQH/f4Ibgo3GUtTJeGJRkdkUhwTbc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787909591; c=relaxed/simple;
	bh=gFGESkEnaYY6xmTzY8wle3SNahbizO9UAow6Oloksrg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=cilhajQ2+8IfUUwUrq8cGNx9rgzQXBztrjOjgKGDQWICTrpRo9sqF3yLyYNrGVldvSbVKmiZCue/tAz1EmcSPtZqnVUaTBZ2nAFh7q8RA8bWoPozCIIfxTzIbQLvRvtRUwNkZAQ7lh8WF8FpMYa2WvjMxgIBDhn7EZRyOE6MB4Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=debian.org; spf=pass smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=SVnjDUpz; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="SVnjDUpz"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=6UJWbhtuWI0OcYV8DoACzNDsaVGPnMK9sBA1/f6ey/M=; b=SVnjDUpzFczRCwN6Z0P0ywFRqy
	2SdxrvFcxickFaj8pE3LuY/7HJWy0cTvF9IXAyD8LHSlQLm1jfU7oi2GzHgIQaOqCgTuuoSfZKcjz
	RFPEAtu3UmGwAS8ieseE44ecCZEKaZUemsj24ea6e8gai+zkr+o1Ut21ZoZD+4FL1ykiLPXTwe2OD
	iLzcihXaoXe5PNnmL1PK5od9W8jyWPHZddppGJU8swLPv1JLhLvfCHXRq4iXpeaMUCC12eL6UyeDL
	Yr16JrhDvzRNBySXXodm+UOn7k3XB0GgD0JlzgPJGy25SDh1T+cA1xBlAAn2DJpKEgKUzayCxZOFc
	T9t5IbRA==;
Received: from authenticated-user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.96)
	(envelope-from <leitao@debian.org>)
	id 1wzsxD-00Gg0A-2O;
	Fri, 28 Aug 2026 09:32:55 +0000
Date: Fri, 28 Aug 2026 02:32:50 -0700
From: Breno Leitao <leitao@debian.org>
To: Denis Arefev <arefev@swemel.ru>
Cc: stable@vger.kernel.org, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Wensong Zhang <wensong@linux-vs.org>, 
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, 
	Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, 
	Jakub Kicinski <kuba@kernel.org>, Dwip Banerjee <dwip@linux.vnet.ibm.com>, netdev@vger.kernel.org, 
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, 
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5.10/6.1] ipvs: reload ip header after head reallocation
Message-ID: <apFViEhRXxJOb3SC@gmail.com>
References: <20260828085522.31015-1-arefev@swemel.ru>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260828085522.31015-1-arefev@swemel.ru>
X-Debian-User: leitao

On Fri, Aug 28, 2026 at 11:55:21AM +0300, Denis Arefev wrote:
> From: Florian Westphal <fw@strlen.de>
> 
> commit a2f57827bf7c695b8c72dc4511cae8e86582369d upstream.
> 
> __ip_vs_get_out_rt() calls skb_ensure_writable() which may
> reallocate skb->head.
> 
> Fixes: 8d8e20e2d7bb ("ipvs: Decrement ttl")
> Cc: stable@vger.kernel.org
> Assisted-by: Claude:claude-sonnet-4-6
> Acked-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> [Denis Arefev: adapted for 5.10/6.1: keep EnterFunction/LeaveFunction
> instrumentation]

yea, the backport seems fine and match commit a2f57827bf7c69 ("ipvs:
reload ip header after head reallocation")

> Signed-off-by: Denis Arefev <arefev@swemel.ru>

Reviewed-by: Breno Leitao <leitao@debian.org>

