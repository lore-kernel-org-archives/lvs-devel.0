Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793612629;
	b=h/9qDMETs0kLwtUKIOM0ld5FcMm2u+lpTObJhUAu0unldeQn7AzkV7kse0buQsQ8cvd7
	 EbgNDP9v7PsT0vJXiH/ST2nuOo24yOjf2nHz30wKFKjBcZRrEyr8aIwZkR8EJtrLUaJTe
	 5Vs0NKVueDQ4ITJ/Si6mjUuTf1+XON70TpQKBnDqm6Hh8SBGV6i3Qa2rXNuHKfWOf7Kbz
	 jZwhyObX/d+5sEB2VOgRLhq0JImAu1NJLmHFvEnuhRJ0Rgar8LgB+MPSDsqr+JP6AwKsh
	 ap59jo3fTryFF+CudD0JCRILOx8JrU13j/FOiYtDDjKyDWw3t3hv6d6q25HB2H8HWfQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793612629;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	b=vRv+sP7KYKEBMW7AabFmNVpO59EeIxjrZF5gfhG+XtiqYcg0blzPCYE0uhygQ/ZLQQMk
	 Whk22+nF/em4knRgSXW8uVFNfIvpwewheC8gQyAvOvpSPPmH4w6aZBcgI6y/fwG6pXhv7
	 8c65qzWBD7KBET3ErnmB+qk8wP4hHurESczZR6DCKCxjUBjANbWQdiCZHff4HOdW9OxmC
	 xd4dkkqkwsE0KjWi8kSZYS9vGpw39GnxQSeEP2WtgP7fAiGBZI8rbyBGzcpl2f+rREWc6
	 2kWBflqlG9K4+fwGjgeneJA3Vu2/yDimb7IC26nEkQnPwc/lxc3Htu//nVa9IhBa/og==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XOwN+BGz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4682D606A324;
	Mon,  2 Nov 2026 09:43:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XOwN+BGz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12C231F000C1;
	Mon,  2 Nov 2026 09:43:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793612628;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XOwN+BGz4c+LNEExSJNvwJZ+EyLJn+w5D3lK3G8vTCxWYW59QOksuxewQtFBFNPFt
	 ngAVLZA1i6YULtLVvCVOu8DgwyygEie+SGlNx1JIjtiVhcMwK9ZZJMvx+PwOoBUDdo
	 NAXWmfrY8SBWTRFa3OnsyiEztw21kTsypVfNYVfcKZEBFw6JzwwC1hnnvh2J6Hwyw0
	 68zPVnGSk8dRvRvuuGP6jk4Gj/iUFl/TZWJWD2JjSkuaqU5dnV44fOQ6LkrtXUQpoG
	 bUV/WVt6DSzBB7/EdUPYBrUbSaOqXWKHKQud1kFj89gVTaKAjY6bGGnXcK204eZ10j
	 gyAfm4y/kQxVg==
From: netdev-bot+sinfo@kernel.org
To: Yingjie Wang <1075151112@qq.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au,
 ja@ssi.bg, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
 davem@davemloft.net, edumazet@kernel.org, kuba@kernel.org, pabeni@redhat.com,
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH net] ipvs: reject negative sync_refresh_period values
Date: Mon, 02 Nov 2026 09:43:47 +0000
Message-ID: <179361262757.3286.17211339869225167788@kernel.org>
In-Reply-To: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
References: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
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
