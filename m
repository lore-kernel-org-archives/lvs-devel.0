Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 018EE25393B;
	Fri, 17 Oct 2025 03:52:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760673162; cv=none; b=mx1/trgyCFS375hefgdMiyDomhX1O9pLlFJflCajj1y3AGtflY3fvMct845SRUBlhdH2jpF222hUoQHRWLHdBKmRTIMgdMdtjt20PCw/NvzqgSzDJpc4ri4eWbi1+4p56BOytkdSjonfD7K7ilETkQOOMLmWhM4FWWV2z8eSBr0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760673162; c=relaxed/simple;
	bh=EBOGwYg9jmALwaq3J2j4VtYudF/oXi4P1EwMjuf2QrA=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=NKrVGjHrEfbOLxbrL7s+pZ8Ff3E/wC7zca18BYDCc/TD7wUIRdk4RbGP7HojA3RUnfpOK0Yvg4auIpC1E4LPqUDn2fxU3wryeawRTXIDMNuJwLlbhqo/nf9ib+aCg1Zi6Jha/x+t7TOK1zGHeavkvtF1Xqo/muJtrtJtL+mSOwA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=g28bOtHQ; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="g28bOtHQ"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6004621EE6;
	Fri, 17 Oct 2025 06:45:19 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=IyTR1bEXLC6inBPNHIRXjPhSRhTUSL4tSaaexA8NSkc=; b=g28bOtHQByIP
	/3cMxdLWyguZxJEURmxoT2qbpQgADeSClp+C/Q971XmuEDJGDFrD28MkPYjKNLxQ
	gnB/Xny67uVlVcJRPmH8n/pEc0EAGwEvsRCJYQ7I2Z+OkJjJDoUg/i3D1f3oRwhf
	8VjFKkgHjVaGMfZdkLmKxweAIeDVET+YU9PsYCy4RC4X/QF0QNoR8Vn6LukSPSv5
	qUYgGspIbpQ2aEtBe66GNairPCjaEc30/zctiWnT3NxtdmZl0F2wqdlF5vUXL+GR
	d7avN3y/7kU3nMMHNcqxXRhaE7dv/fgDjar6UdU913ySE83huY39zX+bWYoUtcMa
	lPg+oMmE1NrMNvNTSNmjRQD+sBE0HY/H0uU979CB/nrDO9NqIaa2Z63x+FbYapb8
	2h2SuXBCgu5Lj79Zk8jExhOnHe5HuoI8Kk8t/vrKzOUE7V0Qd+8GWBCxm748pzCY
	w9iMAZV7pPKu0LNQOzN3FFUXHKSCMxxwkspO1Os310eAe6vu2uk/j/yhNuMFCJn0
	hmdCiU5HeTJmgOr+wDIUZmiJo5ZWzp8XYUccj6ljWbBaClCUlhWeu/r0tgnJWB5t
	J8rXZ/obsRpCKz7vJ29TctJ4htf1I2TZnlds+m2EhcwheghVqnWPuo6QAZKjMAAe
	qdNi+iLfH0Fy76GMh6DawsK3oNVXirs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 17 Oct 2025 06:45:18 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4EDF2659C8;
	Fri, 17 Oct 2025 06:45:17 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 59H3j8lw006251;
	Fri, 17 Oct 2025 06:45:09 +0300
Date: Fri, 17 Oct 2025 06:45:08 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Dust Li <dust.li@linux.alibaba.com>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv4 net-next 00/14] ipvs: per-net tables and
 optimizations
In-Reply-To: <aPGwAl_XsR-D93Li@linux.alibaba.com>
Message-ID: <feb86d0e-4ca5-cff0-c281-06739682aa74@ssi.bg>
References: <20240528080234.10148-1-ja@ssi.bg> <aPGwAl_XsR-D93Li@linux.alibaba.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 17 Oct 2025, Dust Li wrote:

> On 2024-05-28 11:02:20, Julian Anastasov wrote:
> >	Hello,
> >
> >	This patchset targets more netns isolation when IPVS
> >is used in large setups and also includes some optimizations.
> 
> 
> Hi Julian,
> 
> It looks like this patchset is ready to be upstreamed, but progress may
> have stalled. Just checking, do you still intend to move forward with it?

	Yep, I'll prepare fresh version for review...
Thanks for the reminder!

> Best regards,
> Dust

Regards

--
Julian Anastasov <ja@ssi.bg>

