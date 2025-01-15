Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F188150994
	for <lvs-devel@vger.kernel.org>; Wed, 15 Jan 2025 17:50:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736963416; cv=none; b=ctStD22NEe9jR0dOidTxHDnQ0vrMc/yc4FAGsurhDw2iC67jh0WXjDBMTwpOMqLCpQiWwC8zROqzaXGGUyePNovwl735UBrQUJO6Yl7pJNqvJbY+bV6FSxSDQyS/m/dZ/sM8h+CGnp6UEF50VZ7zWw/7Bd9YMHl/kgIiYrFVFrk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736963416; c=relaxed/simple;
	bh=/etH3aBu057l8BEmBFmPbXog47UYoXGL9r8RHjn/Ed8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=ns2KsWUfrSWdEtxYPR53+kJ1zMTbgbn9OqOruetnVKQNi6ijvIWy6VTrUl9yl3nZqIIPOTXXp4hbl8oj0Debota9TTiyfUFGuke/LGR3FjZEeCXf1F2nfCGuxwxuoJ1zsSsvSb6Ee6wMXGBTrrwNfqrGn0waccu5qDubQgj+vaw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=upMkW51G; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="upMkW51G"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id BAAF2210A9;
	Wed, 15 Jan 2025 19:50:03 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=iRfM7mAGpmZCFcZCyr7ojF926HWj4Xu/0HZ+kj1xRWo=; b=upMkW51G+JLd
	Jkswv9rzQbOIkPRAdpL0t3ZHAhp+lDVNbPqg+wrfp8ey3H6hb+HlTi5Rh+h++rJk
	o15UMfbDiJhIpee/pQVZj2mUM2sNeHIfOiMk0bQXueLakx8rgiryqZmEljwNIiAL
	oWU3izTc2ScgdLNkPMISEMc65zT/P0NrfeUoAe37pIT8QeSCTs1hN0F1lCKYDtyM
	q/I0YzHhxwHd1bQHbNZ25OoFzWgAy0SYk7Kmd0jM6bYU5/08ZbKQU2A5feG24Ril
	1tnRseOvBZI7LU2Q+yZYfxDEj2bqvtTXHUuTLK2Sy/lZOuTZ+fVGz63ptwvcHl8L
	ETdgKWCn4A8hsOHdYeChb91h2Kq7FpE5rvVQPta6nUw0CAE3zwJ+KIm2JiTWEbdZ
	gTYEp9JGHondtUAcZJpRJCqukpdzUCvVtWr4B+TXg9H4Pl7tvQndm4p+JL5d0zyR
	5yRx1+aRNHlcf6WA/00SCMY+qAkBzw2XvDljemOyTJqNLaIE1EH7T5HZLqKPoLEN
	znJ8d+IZisnzOG5dVSW3+m4epeQCecwVUOz6+TTTWPCrqgk4jHmRnuhMLL5o5JrZ
	L7uLx1SJ4v0SdaJ8OhUaYbEVGCPGR6TARBYdkspdpsMh/LjCScD2ceGAi/x1qhJ9
	AhoG7/UAl55PyznrPPWmuZovx63to0w=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 15 Jan 2025 19:50:02 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id D0CE415EB8;
	Wed, 15 Jan 2025 19:50:02 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 50FHo00U066420;
	Wed, 15 Jan 2025 19:50:02 +0200
Date: Wed, 15 Jan 2025 19:50:00 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Jeremy Sowden <azazel@debian.org>
cc: LVS Devel <lvs-devel@vger.kernel.org>
Subject: Re: [PATCH ipvsadm v2 0/5] Debian package fixes
In-Reply-To: <20250113192450.3302635-1-azazel@debian.org>
Message-ID: <97803840-06f3-8f28-98c8-f6b47dd83e6c@ssi.bg>
References: <20250113192450.3302635-1-azazel@debian.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 13 Jan 2025, Jeremy Sowden wrote:

> The Debian package of ipvsadm carries a few patches.  Some of them have been
> around for years.  None of them is specific to Debian, so I'm forwarding them
> upstream.
> 
> Patch 1 bumps the maximum weight accepted by ipvsadm.
> Patch 2 fixes an unclear usage error message.
> Patches 3-5 make some improvements to the Makefiles.

	Applying the kernel rules here, the commit description
in patch 1, 2 and 5 should not exceed the maximum of 75 chars
per line:

scripts/checkpatch.pl --strict /tmp/file.patch

	Can you wrap the texts in a new v3?

> Changes since v1:
> 
> * The previous version of patch 2 changed the logic of the option parsing in
>   such a way that using `-M` after `-6` no longer worked correctly.  This version 
>   just rewords the error message.
> 
> Jeremy Sowden (5):
>   ipvsadm: increase maximum weight value
>   ipvsadm: fix ambiguous usage error message
>   Use variable for pkg-config in Makefiles
>   Support environmental and command-line `*FLAGS` variable in Makefiles
>   Make sure libipvs.a is built before ipvsadm
> 
>  Makefile         | 19 +++++++++++--------
>  ipvsadm.8        |  2 +-
>  ipvsadm.c        |  4 ++--
>  libipvs/Makefile | 29 +++++++++++++++--------------
>  4 files changed, 29 insertions(+), 25 deletions(-)
> 
> -- 
> 2.45.2

Regards

--
Julian Anastasov <ja@ssi.bg>

