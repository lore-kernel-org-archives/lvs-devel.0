Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794923011;
	b=RjUAH2SvhnRIVjOpjVANssnRaBJtk2u2QGmp6rGzTzipD3ZbQo7bAuZWBT1/YHcMcW+Q
	 dWelu+rz85U6aD/gFGZqQKRHYv4DlhHIiCa8Pea5L6zxiwUeyk1CBP1WuwtYE5qbT1fDN
	 8dbIZRrM/XxxsVhDUML640lSznC5vAJkawSWWf+d2eBdTGdLxvGWH1iNJvmF4z9LHehCK
	 mlCq48gYlsAzlUPXsaVdbn4VMPXGnCCE3tCItwTNz0Od829GjloheLMItBYI81xEA5NkV
	 lvwgKqRyNfnU1nYI/fUOg6VIPYPwMF80WkfMhbRcGlBDM0sPBXoHupLeENwppKWzdYw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794923011;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=oj2zs7YpNjut+Fle9NDI2/nVbuq1xcuWOh/20pAlrQ0=;
	b=L+KkmlYIq99tcYHpuJ87QNCemkgaRJl007swRNaSIfx5gxL46BgO3MrumaimpkEP5ffy
	 Fpd7ElDX5xPkfe5Nm4TONEqZ546MlVLQereLjYD4JLfJ0fXvAVkLJnz+8zrl6smAVyoLp
	 s5S0x9EtaDB5t3HcS9f1vXXt9xRGGhN/iVdK2X3F6/C3kkDxeM+U/ox1dApoE4+YWgy4n
	 fQx4UdFNJfhnKp/NXoMtZ41ANA02u10RukPSjDYsJhnXzw1Wq5rgheGDLGgmobYJdVNoZ
	 YXsK4+p7HaBHPVDrt6V4o/8puHYetyPjn4Ia/ZswPR3qHbJjqdDbjkFaV6FsQAWGA5g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SsjGLb8s;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91E23606A331;
	Tue, 17 Nov 2026 13:43:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SsjGLb8s
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A13AF1F000C5;
	Tue, 17 Nov 2026 13:43:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794923011;
	bh=oj2zs7YpNjut+Fle9NDI2/nVbuq1xcuWOh/20pAlrQ0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SsjGLb8sBV+Zz0wAypiaaSJjxHRsplBFwiy0qxghlK2bF3EDuXEPUvLft5akaKxSB
	 IYq1ZGV8gAR8uGzDgQNnpvErz0jR6LNG2RigFVFA4sJHTGC5N+I6g11W/m4xonnmlu
	 JOt8KY0Zskkh7DnnhjoyBSGoyYokCT+WYdxH8gr1yzUffUc4IJ12n8q3mVwe1knuYh
	 FoJ2LK5sx9jSyutoMTEpiT3HO1xGoRTExjyRlmiiYNWSiI4d6LDtQKCEixrX2iuT2c
	 RKu+U2t2XLlM0IpX4b3AbmLNt78kb/2shSyPG1zHvR+PcdA5JM3KmR23rvdz6A3agd
	 UOK4OOhohdLZw==
From: netdev-bot+sinfo@kernel.org
To: Axel Mierczuk <axel.mierczuk@1password.com>
Cc: ja@ssi.bg, horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, dsahern@kernel.org, kuba@kernel.org, edumazet@kernel.org,
 pabeni@redhat.com, davem@davemloft.net, netfilter-devel@vger.kernel.org,
 lvs-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org,
 w@1wt.eu
Subject: Re: [PATCH nf v2 0/2] ipvs: fix OOB write when NATing ICMPv6 errors
 quoting non-first fragments
Date: Tue, 17 Nov 2026 13:43:30 +0000
Message-ID: <179492301022.3291.11880484738373509395@kernel.org>
In-Reply-To: <20261117134049.52386-1-axel.mierczuk@1password.com>
References: <20261117134049.52386-1-axel.mierczuk@1password.com>
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

 - Whether the issue was actually triggered, or is only theoretical
   (e.g. found by LLM and not proven at runtime). If it was triggered
   please include the symptoms, like the stack trace or kernel messages.

Please do not repost the series just to address the above. Instead,
reply to this email with the missing information, so that reviewers
can take it into account.

*IMPORTANT*: If you do repost (for other reasons) - please include
the relevant info in the cover letter or commit messages.
-- 
The evaluation is done by an LLM so it may be wrong, if you think
that is the case please reply and explain.
