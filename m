Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793431132;
	b=0bvXmPiZP1vxchw0PpfbZ0Hm+3/2MV0efWADhCJwz09o2xNOnReJSQcz7CMurtOSoZAX
	 UKWmPJ/B1DZYZz7VfqsmjWsrhGWJkwhPSuKd0g0MkF0S8m9jnpEvpGA24TVnt4TQo0D+R
	 czI208lE1wPmfSKh+37EBbWC9sldz2x6W4VuFInwGBfn5DV5KlF9qXJcwWTds76iGF8uL
	 lOtxmcx8iwfMCLiQ/fCzHnzNRfGtGzF2Nam7KHRBOLxWWKsPZziZaZl7bMz0VPBrB42UA
	 Gv70ItkiVH6IsAUaiDVPR4bvgIhNC9eYWP3lcEJOzjbpqYdO08XntAwH1ZC/BsXqd2w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793431132;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	b=lQfcgj3de0fJHnZrBYmUUbFTJ5R1HqVrrguk9VjJ8Z3/P2nHqJpi6sl2svBW1iMmkDOR
	 y0iZTxwCoMa5cv78TcFpHxI6PT1ZfU0ncodvCDaMmJhpfQcEOW+wyuaOR/e3eAD1FTZnV
	 gX6Ddzqq07lmP7gJ0mKZA8xWv4HbjyXHdYueY0+LzTQvH5P1oku+E4su5YLX+/qsbu4wK
	 sXKqf4+ZR54t8FO09ED7V4NFLgDxe53JZTpbevPgkuDdZt+1Pq3TDAVKTm/mFBNweaEUU
	 xKwWinPkF3TM4/XX0io7WKCvvDxQb60kFUVhAsr25exbgVWve6DTbpOoaw3ihLvV+dQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UGMTfTtU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B8B2606A31A;
	Sat, 31 Oct 2026 07:18:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UGMTfTtU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 360DD1F000C1;
	Sat, 31 Oct 2026 07:18:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793431132;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UGMTfTtUI4jyMeDyY5MO68Qzg0kPpTcqeRwrsUSpRolYBYBfCOXcT/YSqDFOtRYmv
	 qY1X0/wSeoGDgEmRY1dkN/AfqfrbrihTbnwG8MCGu14Y4CQU7puooadPesOzvbaYi9
	 G4WtWSqeQQEilqjS2HZFIUKEv5ZXbKfo34sjzLBcFdDoCR+KbkSx6V35JCrcHHLI4O
	 PWAoyA4xxe9hYd1fALQ/etz9cjUc9TdyFpBstb1qEvZs3qdPHqrJ51ON8y9zVs4Hxm
	 M15mgtTHezakTqIywM4EajcKHnw5FyZDR7L67XwvgIAQf8z7ORk8TWlwA8IIpt4K4K
	 J31yR6WcF6xQw==
From: netdev-bot+sinfo@kernel.org
To: Yingjie Wang <x-professor@outlook.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>,
 "pablo@netfilter.org" <pablo@netfilter.org>, "fw@strlen.de" <fw@strlen.de>,
 "phil@nwl.cc" <phil@nwl.cc>, "davem@davemloft.net" <davem@davemloft.net>,
 "edumazet@kernel.org" <edumazet@kernel.org>,
 "kuba@kernel.org" <kuba@kernel.org>, "pabeni@redhat.com" <pabeni@redhat.com>,
 "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
 "coreteam@netfilter.org" <coreteam@netfilter.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH nf] ipvs: avoid wrapping persistent service timeouts
Date: Sat, 31 Oct 2026 07:18:50 +0000
Message-ID: <179343113072.3286.7677762943925650936@kernel.org>
In-Reply-To: =?utf-8?q?=3C4f420fda8690ac470be44b3da284b65501c77bb5=2E1793430?=
 =?utf-8?q?892=2Egit=2Ex-professor=40outlook=2Ecom=3E?=
References: =?utf-8?q?=3C4f420fda8690ac470be44b3da284b65501c77bb5=2E17934308?=
 =?utf-8?q?92=2Egit=2Ex-professor=40outlook=2Ecom=3E?=
Auto-Submitted: auto-generated
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

Hi!

This is an automated message. This series looks like a fix, but its
commit messages seem to be missing some information:

 - How the issue was discovered, e.g. hit in production, hit during
   development, syzbot report, manual code inspection, LLM or static
   analysis tool scan.

Please do not repost the series just to address the above. Instead,
reply to this email with the missing information, so that reviewers
can take it into account. If the series needs another revision for
other reasons, please include the information in the commit messages
then.

The evaluation is done by an LLM so it may be wrong, if you think
that is the case please reply and explain.
