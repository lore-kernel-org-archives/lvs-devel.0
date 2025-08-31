Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 771B817993;
	Sun, 31 Aug 2025 13:01:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1756645315; cv=none; b=t/FrLyuxMib17LUO2CsEuJF794+0mqXWK5xwI6tc1Ha6XXiiREJzgC4aZKu0o1PnNr9aLxu8vj39R8wckecg+57EUyjdK/qKjOED5J3qm3lUieJOE9Suf/h+palbpgJrtN3sbDJYV77JTdRYQxvOsBInV3r4Duy4g3SdjnhswAA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1756645315; c=relaxed/simple;
	bh=hLFF4WN8hk7nZWPCu4/90Ce5a43DJKgQDKAD+d5Qp8k=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=sAmAIKZPa8QZng2qG7uMrB/4ilx33srM1D+79REpM6np2KJZZewWyULYd8BIrGDaRHBZMXjm7PS4yul91GqyrpiaZbBu+DunVt4EhuHUMTyTEZi73MkBfyLFadywl3DjupJ4MmognaRaoyp9LUko7/g8jBdOInFdaTJvkYRxRNg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=BcJYU9yg; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="BcJYU9yg"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 583D624001;
	Sun, 31 Aug 2025 16:01:42 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=NsjH5C8ipA5ojAw0RMExDUIHr3+XPfORIVJkrWZpODE=; b=BcJYU9ygPcGl
	lQZX58JBwvnc32PyEy2OxvVs9/FRabxDIreb0XolU1pNwaW1vFpTaiqMUXfH3I/g
	i6xEhRRTc14/PV9PpU7TU547PAFNuYsS0nxjVl6cVH+6SQOKTEd1Nx6RoYXQbg4N
	iUGYH8zNPO0pLX3xaF6YeR0w0kACRBQbs3bHvvZO07QskuCBRNrQNyxNOwY/xYKY
	Fs4x65KyxfWtdVfahmWceEQIXp5OGs+AsZQpKC4JNGoJRPiO3JYQV3LEuANZJBP5
	UNQw13p3KKdiORV9Gj+n3P/GBtiHvBWf19RnvJlXjRDLmUL/COQYrCnDsOkOrSBp
	yQIED1iKXcf7kcBdLii0uP8ZOXIw9JiBd/SsX1K93nDJwlKmgMNkMSSxiCnEuPgB
	gCR2mexHDcl7NV/mVxBg4X5u4zyduEf1I/9TZY5YiWARi5305VfkvqXSWPC0EM6P
	ne6DGsYsmypiCRTsaz2cIHKSv+L1oEIo04iIvOGYh/puoL+p7pDTPHMvAJ2Pzn00
	LhZ5rqfLFadesVD2E6pUjt8dnBiCmAerSB+QxAmLDNxEGuYNCbpvxErSjFWzsQZ0
	YVd7kngMQnaRO/jDS3ijUEWminS8gnyhtiXsPHLenmy8UbyvTThh4q2hsI2cbO48
	XMutImFOjWWOeDp1vc4jENmMqZ5fKio=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 31 Aug 2025 16:01:41 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id C621C6512A;
	Sun, 31 Aug 2025 16:01:38 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 57VD1L3T032845;
	Sun, 31 Aug 2025 16:01:22 +0300
Date: Sun, 31 Aug 2025 16:01:21 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zhang Tengfei <zhtfdev@gmail.com>
cc: coreteam@netfilter.org, davem@davemloft.net, dsahern@kernel.org,
        edumazet@google.com, fw@strlen.de, horms@verge.net.au,
        kadlec@netfilter.org, kuba@kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, pabeni@redhat.com,
        pablo@netfilter.org,
        syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
Subject: Re: [PATCH v2] net/netfilter/ipvs: Use READ_ONCE/WRITE_ONCE for
 ipvs->enable
In-Reply-To: <20250827223322.4896-1-zhtfdev@gmail.com>
Message-ID: <3a737b68-5a80-845d-ff36-6a1926b792a0@ssi.bg>
References: <2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg> <20250827223322.4896-1-zhtfdev@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 28 Aug 2025, Zhang Tengfei wrote:

> KCSAN reported a data-race on the `ipvs->enable` flag, which is
> written in the control path and read concurrently from many other
> contexts.
> 
> Following a suggestion by Julian, this patch fixes the race by
> converting all accesses to use `WRITE_ONCE()/READ_ONCE()`.
> This lightweight approach ensures atomic access and acts as a
> compiler barrier, preventing unsafe optimizations where the flag
> is checked in loops (e.g., in ip_vs_est.c).
> 
> Additionally, the `enable` checks in the fast-path hooks
> (`ip_vs_in_hook`, `ip_vs_out_hook`, `ip_vs_forward_icmp`) are
> removed. They are considered unnecessary because the `enable=0`

	It was good idea to mention about the 857ca89711de
commit here as in the previous v2 version. You can even add
it as Fixes tag as suggested here:

scripts/checkpatch.pl --strict /tmp/file.patch

	As for the Subject line, you probably can use
[PATCH v3 nf-next] ipvs: Use READ_ONCE/WRITE_ONCE for ipvs->enable
to specify the desired target tree ('nf-next' or 'nf' if such
data-race needs it).

	As for the patch code, it looks ok.

> condition they check for can only occur in two rare and non-fatal
> scenarios: 1) after hooks are registered but before the flag is set,
> and 2) after hooks are unregistered on cleanup_net. In the worst
> case, a single packet might be mishandled (e.g., dropped), which
> does not lead to a system crash or data corruption. Adding a check
> in the performance-critical fast-path to handle this harmless
> condition is not a worthwhile trade-off.
> 
> Reported-by: syzbot+1651b5234028c294c339@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=1651b5234028c294c339
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Link: https://lore.kernel.org/lvs-devel/2189fc62-e51e-78c9-d1de-d35b8e3657e3@ssi.bg/
> Signed-off-by: Zhang Tengfei <zhtfdev@gmail.com>
> 
> ---
> v2:
> - Switched from atomic_t to the suggested READ_ONCE()/WRITE_ONCE().
> - Removed obsolete checks from the packet processing hooks.
> - Polished commit message based on feedback from maintainers.

...

Regards

--
Julian Anastasov <ja@ssi.bg>

