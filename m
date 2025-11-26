Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E8C019006B;
	Wed, 26 Nov 2025 20:16:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764188210; cv=none; b=sH0yLVKTkL57xuZm7LjNba7mwUQInI8yjjUNujGY4vGNlca2SlaqDjQrN54o2w3awxTH60fYP7OvcSlEzK3GKgsd1msekWGkEHnVHz1VlRKUYivzQdyITCj3AVTlNrfVKg/jhoC6I00w5NUJjxATXY2Q3UcYJOW9alCK52ONhkI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764188210; c=relaxed/simple;
	bh=E6eG/BxClPiFo8K2hLTm4D6hyhOqn3PzsT+P2KR/gGY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=gWzD1zYDBI2jt/T8aPe2jJt95OLE08Lc7eiPFO7HjC7uj7JwGxMBp92EofGqsKAXzMZk6Y42ikm1ypJM5PDjQdvGo2620nULNKkZjLBuNX6kVcKMcHPrnGU062PGKblKVqTi49o2Dsjkz5SyruZn8Dw21OKHBCjpp7qTLn56ozc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=gqBoqNZz; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="gqBoqNZz"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8E9A72112A;
	Wed, 26 Nov 2025 22:16:46 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=coor/eoQQzzCHqDWQtCH5agJhI+CICL9w/RCA9WrzZg=; b=gqBoqNZzZfr1
	yjlza3qZZkNjYJHjHbkV8YG2/wwI/ueHowVEnLHOQegrIVGNE93IGbVracr5q3i1
	jitUI3J2gtPD/SN9WRzY19Xp1hUlFhkKQBvdOtFbJz8JI4Xq3f9afv+67pLB+180
	8/QLEoR6LjF9S/VNExLVqE0PE4Xbt7IxMqhc7urDGvzkd4kDRtdMBqMncaIY8G9A
	GaY8KalusWqnPGM3pkUH2NtWaqkNGGo21J5Jda/YIjWf1nj69Av2+kA+f/2/8zM0
	ax8vLuF9G6qgFpUViRTXPit4HjTCpqLVMiX+QScXCDNpU055Svcua2zXmYlhBuvT
	mAxjUxY5BYWD3ZKH7JZqiYThjM4cP+JQBTS4aROEHnRuN5Kl0zKtrV4G+DO1B8EL
	4hapEljn7UTqHIu21f/I1zMdu/RUKngIrqoJ0fCbC26NrfawJv4L4jpjCYCFGc+9
	D+Z6GqbJRKmj8COpbyFqHA9En0X4aEATX3rgyPZHICPGmBCTYBeetjDNkANtxKaD
	7erah6CkeIm9nH5h1ZUiciVUy5eN2R/CJt8Nio/0MfLPz0z6RBJLJVg/GlTYnPpM
	whqfJfsQu4NvbKv8wqjCqQj9YLcFtGZOmCahtChtg8hHabhlaQQVi+0Gd2JI5Tu6
	KfLp3qNpsC9ztvoYmypPlj6u3fyAL9g=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 26 Nov 2025 22:16:45 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3A43464C41;
	Wed, 26 Nov 2025 22:16:44 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 5AQKGgUO043740;
	Wed, 26 Nov 2025 22:16:42 +0200
Date: Wed, 26 Nov 2025 22:16:42 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 00/14] ipvs: per-net tables and
 optimizations
In-Reply-To: <aSTSSTFT9j5eldzv@calendula>
Message-ID: <83fec0a6-6a24-13c1-d59c-777367aff75c@ssi.bg>
References: <20251019155711.67609-1-ja@ssi.bg> <aSTSSTFT9j5eldzv@calendula>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 24 Nov 2025, Pablo Neira Ayuso wrote:

> Hi Julian,
> 
> This is v6 and you have work hard on this, and I am coming late to
> review... but may I suggest to split this series?
> 
> >From my understanding, here I can see initial preparation patches,
> including improvements, that could be applied initially before the
> per-netns support.
> 
> Then, follow up with initial basic per-netns conversion.
> 
> Finally, pursue more advanced datastructures / optimizations.
> 
> If this is too extreme/deal breaker, let me know.

	It should be possible to split it to 2-3 parts.
And may be I'll change the ip_vs_dst_event() code to be
faster and race free...

Regards

--
Julian Anastasov <ja@ssi.bg>

