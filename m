Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793725450;
	b=sUEJVZ46Wp4r+dJqta22Bz4zTCTp+DLq163fRhN1X7ol2v2HGzl3BDe05lytW910Klk7
	 53+IhcFxKsP8J+8juxLR0wnjFSfuWh/R2zLt/HWr4/Kizuyh9BvMFmJKhcLuXbK87CAV7
	 YzWQiqEnGEFFVrCaD5GiXelqXkbP1mNfUaALOP1+WAL5RFMhWYSpYO6GEZvJbL/xcYYJk
	 C8BRoNRH5COYnKZ9TuOUkIpOvQnPXK5FbUZKDHlln1CjS6pXRHxs52b4r4s3Xax1e0+U5
	 E9EpB9e8nFeycJB4zLcF1G1CanIn03lT9IzdCRRZ+st7iD/N33a9dcc6cAC1hBN8DJw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793725450;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=Z9zRtXHe/J1k/4/9wAeq1n+PwAt+ioXmV3zyjSNrjDw=;
	b=vL5UfEd8N88oKl9qe59YMuFPicBCrmUu58yrrswp5z/klt+JYicvUmDjjb4KDOw4W9JV
	 kSxCVAGxnLJTtfcyTBVUdatazNpiO0R8UHBpK3TwF93VV82hO1vJBVbyEeJ9JFtnG8xeN
	 fPNGmn3uns4BspZAcrJ51tbKASdrupHHpGIIYeOCwmXt8XMGNug9ytOhv8dl3LWzJzJuU
	 7EeF9EossqH1TxMbzKJx2HBA+NcK1/D3BYovaxJP3Qnb2PogZLMRD16ySACKBImgKYSs5
	 kAseg+Yn51Seea/8NRCnUv8JYmvh3ZMtlpxJpXg2JYpqYV9qqPWF9vfF9kcOBJSYvhA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="W+3/hN1U";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1ACC606D81F;
	Tue,  3 Nov 2026 17:04:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W+3/hN1U
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B09941F00A16;
	Tue,  3 Nov 2026 17:04:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793725449;
	bh=Z9zRtXHe/J1k/4/9wAeq1n+PwAt+ioXmV3zyjSNrjDw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=W+3/hN1UJz01eY8tROWdhymnLGp/DidlPW79jfq32fvO8mLAGqXsXQg02DxZcVSly
	 1aesqVpPysVrrYJcVnr/JMp+1Fg9yL9yhfanBQ5atoVYiDoCkIoaZg5RBFOZuYggf8
	 KVGucXxXAjoLCjuroF9fKysL3lzfueQmDReG48AOyDQDziyS+xodvODAubxkW56Ok5
	 kDGhHUZV2zLG9pDmBPyTHrPqJd4ICSscQjZy5SEHtT+68x7UKf6HpaK8qTQQKj4f0V
	 V7ky1hpBvNhVPwVxmRg5ttW0t+5HUplRAt37Pv/F+hEHEC7BFzkKfc6VsvKTuqQhM+
	 OIf4SxtRQl35A==
From: netdev-bot+sinfo@kernel.org
To: Axel Mierczuk <axel.mierczuk@1password.com>
Cc: ja@ssi.bg, horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
 phil@nwl.cc, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
 coreteam@netfilter.org, netdev@vger.kernel.org, w@1wt.eu
Subject: Re: [PATCH nf v2 0/2] ipvs: keep templates and cport 0 conns away
 from packet lookups
Date: Tue, 03 Nov 2026 17:04:08 +0000
Message-ID: <179372544820.488859.4285133355770816407@kernel.org>
In-Reply-To: <20261103165746.39516-1-axel.mierczuk@1password.com>
References: <20261103165746.39516-1-axel.mierczuk@1password.com>
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
   (e.g. found by code inspection). If it was triggered please include
   the symptoms, like the stack trace or error messages.

Please do not repost the series just to address the above. Instead,
reply to this email with the missing information, so that reviewers
can take it into account. If the series needs another revision for
other reasons, please include the information in the commit messages
then.

The evaluation is done by an LLM so it may be wrong, if you think
that is the case please reply and explain.
