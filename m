Received: from ganesha.gnumonks.org (ganesha.gnumonks.org [213.95.27.120])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA3B4160645;
	Thu, 29 Feb 2024 16:37:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.27.120
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709224680; cv=none; b=W4aVyJqdTQeDTYzDJn5KGvZLYhnrOM0nTNDXNDwNzeGOen3DhWzIDJPC/XUuEx59HXO56aV3BppnbpXIqObC+TVDSuW4dwTl3WujZdAbqKDTxU4GU7Tn/X9RWV8jeRGgNLAV7E12ETOpvGeI4/mtw77gjp1pnyAuPy4gpQQa4jg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709224680; c=relaxed/simple;
	bh=5izvTNhy50hCUbInUoGosso9kcaqF6F5GkqTwkmmq1w=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Zl0iJ/ILx8iblIGv0YWqEKKIsaiXYaqXxjtwHjk2Z7sa+GpPi7pvIwf7GD5f10Vf3afBKt0U9dkVQV/arRFzl4cfr01mzfiO4emiRCjCL4dnbGiJ1l29/W+Yqg4b+/S9R/unT0dXm45RbdFcfPDofLy8hfgkrAQZYSi3ow56xhc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=gnumonks.org; arc=none smtp.client-ip=213.95.27.120
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gnumonks.org
Received: from [78.30.41.52] (port=47448 helo=gnumonks.org)
	by ganesha.gnumonks.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.94.2)
	(envelope-from <pablo@gnumonks.org>)
	id 1rfjPs-0068C9-4q; Thu, 29 Feb 2024 17:37:54 +0100
Date: Thu, 29 Feb 2024 17:37:51 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Terin Stock <terin@cloudflare.com>, horms@verge.net.au,
	kadlec@netfilter.org, fw@strlen.de, netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org, kernel-team@cloudflare.com
Subject: Re: [PATCH] ipvs: generic netlink multicast event group
Message-ID: <ZeCy39VOYVB_r5bP@calendula>
References: <20240205192828.187494-1-terin@cloudflare.com>
 <51c680c7-660a-329f-8c55-31b91c8357fd@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <51c680c7-660a-329f-8c55-31b91c8357fd@ssi.bg>
X-Spam-Score: -1.9 (-)

On Wed, Feb 07, 2024 at 06:44:48PM +0200, Julian Anastasov wrote:
[...]
> 	I also worry that such events slowdown the configuration
> process for setups with many rules which do not use listeners.
> Should we enable it with some sysctl var? Currently, many CPU cycles are 
> spent before we notice that there are no listeners.

There is netlink_has_listeners(), IIRC there was a bit of missing work
in genetlink to make this work?
