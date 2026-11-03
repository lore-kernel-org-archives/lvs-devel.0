Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793722687;
	b=He8kreOFFEfucHrcJDbIf/FHGSH8DJJyWQaNz7wf7+UE/a3JtkmTxO9/1GKW/z8SS2r5
	 DViY3BBGXWDHVxuQt8/Yfek8R72kVBB/lVzaMN0FRXMy3tKyLKw5HKTDufXBeiKHHt6Hv
	 P/qcjHbJ30OqTEbkTcw2Qg5RqFEWp7kITz/Eruy+B0jBBpDdtb2LeX2theiIEkJQ///UU
	 AjzSuWUVRHwetvKt/mJYLHoIeeI6GHKOZjIgoLUGfL+MjU5S/wuLwVemOnq+FBSN/7xDY
	 rNWQb+qjA1N/xpcPt3oJNBag10qHp9Ia+HmuYCXic4KBenSSUs3mQGySr86pYG+ASTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793722687;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	b=SCVHjTzMUSTmHlm8ONdGw0ypScRNXOVJZAESUcOw6lF8XCIR4bD6IemaiFY1rV8xlD8R
	 OsGc8tcMgNY7O/sZjZvUPHdmED+M2pcVc8Jp2INByiE1iaDETlyYyP4T94MPtj8NH7Z5t
	 x/h0hmw+LsuH2vTRXrrEXbLsEkfZtnVuw2+4gxrmqIkn4GQgAyibKuy9g1coCwO6YEtFw
	 wG44upfhUw6jkIym0KcDNEowWP4RefXB/ov4rHkCBIC9GKxbTDipVpSp0N9JvJeAls+P3
	 CKtmzJa9TG4hWPv+cPILHSQAenCs647fvT1TG2824Ze4/B4bOpih9PI8nOzBF98LXxQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JEh3zYKP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A9A2606A327;
	Tue,  3 Nov 2026 16:18:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JEh3zYKP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B8DA1F000C1;
	Tue,  3 Nov 2026 16:18:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793722687;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JEh3zYKPyru8GOWgP8nxKUhgqKolhZVzxDR3aIas2roc9/v3Z5lwx+Ltg09RcHwDq
	 3LjckZY42xhDEcj78H3mWJ+RNAdIOAbthbTaQTRRiBg+Yf8IzhUM0mXNA1IYw3Ky7E
	 2QKpPdtYEqw+dXR3v+wxXyv9ZP5Mw9CTH5wc9QUFW5ZBPXAWCB/SN6r3W7WuwLdYDr
	 zKZAmaxMW/qhTOWtz4Njw7A8zW+D4jXPAVBHM++hRYO959zATRXwDtgqYN8tfQtB+n
	 dUfPDKTzkW0pzWDbVjHtxbf4kR7kI3JmbVuLjKUcGy3NSw3gWPkLBY/VAer5Iqd5aH
	 ClyTDo+1oumHA==
From: netdev-bot+sinfo@kernel.org
To: Yingjie Wang <1075151112@qq.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au,
 ja@ssi.bg, dsahern@kernel.org, idosch@nvidia.com, pablo@netfilter.org,
 fw@strlen.de, phil@nwl.cc, davem@davemloft.net, edumazet@kernel.org,
 kuba@kernel.org, pabeni@redhat.com, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH nf v2] ipvs: reject negative sync_refresh_period values
Date: Tue, 03 Nov 2026 16:18:05 +0000
Message-ID: <179372268573.488859.9878173276038035271@kernel.org>
In-Reply-To: <tencent_9109FFF19F0341A556269E694408976E2708@qq.com>
References: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
 <tencent_9109FFF19F0341A556269E694408976E2708@qq.com>
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
