Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793513894;
	b=pU1YkeFDwXL1WtsYReR8v+AUo9Cemi38grZo32hxQmJT2l2wl0UsTp82PIgZ9GpB05jB
	 pvFlUrOh/FU19KtCMM2Jo5vGKa4leb9+XfTg03VAkblnTGSJ/O2jFw3ZQ1Ttd6swmNXxC
	 CNeJsXcOERwDL3W7fj6ozInFmoZ1AhSRMeNYuwpt+wxTCLI8Tw6CpZj/+sPkyD+fN2ufv
	 RbLSnbJY888Fwsav0zSzgMNn58T/+Qam5BLwxYQnCA1wbox0wKQKPgcJUAFBZTyAZx1M3
	 c8XUdolDZRX6eZi6G/dFEvGa4hxRwyEqrjBzYxr5oGSzSY9O1F93l+4D7tDE7NAF/qA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793513894;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	b=H9wdTaT6odwKDgLv/O2G6N/JygTCF53rVcC81+pj987KJ5l5nfdqhqu579MxfuWhWFzd
	 frsDmQGkiwYoiajz6l9tUnmHbPrmstUjmVpfsyz9DfnMvVXfUcMD6ElfYYXEMQrIz/pp+
	 VhsaoIfZUB6H60dIiw9OToj0kZKE3/UdLReQtjh/fzA/A1uHaj0GPizUHEx02Nq2HvX+l
	 WR+XzlCrYBeT/MwzHgr07kDgqAGZ9YEW5sSbvyjCynm0M4R5qhAhcYuRmNYVy4Xiv17cb
	 XpZZhgZLnuBqNavrC9T69ZnrPLRXLHOkvgMMhNkDZvRYnRQzFWXHnT0AfSghgZgiSbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="D2i/w82m";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F174D606A324;
	Sun,  1 Nov 2026 06:18:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=D2i/w82m
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C0B821F000C1;
	Sun,  1 Nov 2026 06:18:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793513893;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=D2i/w82mCbN/c5tfy/EF16yRse2kNOGRNZW3jBbca0I+N17PzXQuxnQ28ngY801XM
	 C5FcyEamu/QUe1Urhiwys4rAdmtxGydBL3v1bSG9hWNVCmaDpP9bbM4AIpylNJL9lE
	 jBTP9w7T7gVgCYxu/47woGG/TXtBqC59PxOY7HWE9678ZTQqf1nJ39QV6pY6d9yrxb
	 zf7LzbLtp3kYFoZCmQScrbJKVUyrD0bP32GpO+BgrgfOyJwADrrA8aVn7qOAHBm9W4
	 hQ7fe1dHYQWgox6ValueUIBp3se4qYJpGf/xqXSpEspO4dw8rN3TY0cYucglljbGtj
	 mS3kulsY//Yxg==
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
Subject: Re: [PATCH nf v2] ipvs: avoid wrapping persistent service timeouts
Date: Sun, 01 Nov 2026 06:18:12 +0000
Message-ID: <179351389228.3286.8166624547411855559@kernel.org>
In-Reply-To: =?utf-8?q?=3C969309eb180c2e577dd6bb54a7d28afcbb2efeb3=2E1793513?=
 =?utf-8?q?714=2Egit=2Ex-professor=40outlook=2Ecom=3E?=
References: =?utf-8?q?=3C969309eb180c2e577dd6bb54a7d28afcbb2efeb3=2E17935137?=
 =?utf-8?q?14=2Egit=2Ex-professor=40outlook=2Ecom=3E?=
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
