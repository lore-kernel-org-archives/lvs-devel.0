Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 291B4377EBA;
	Tue, 28 Jul 2026 21:39:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785274753; cv=none; b=ib5H28a1UpnA5N4Se2pavAD9/7V3IroT9HF3QDd1LKlE5SWcIYr88+oopSgXvH7VMqASDvOMj3LdepeQjeh4pHuAw74PyPSb4WrErZrojiZlhbCblduPiJ9lqi3cI3Hvh/qgWGHR9WkygMzBT4b39sDItbItP6v7T6hVEUB7zs0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785274753; c=relaxed/simple;
	bh=WITMqrzgHTQPgRpxWFsk0ZorQQBI/emyWWpjDqNJycg=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=N03FeNiAg0bh/+XOSMk0RwvNU3W53/w9zyzvucw1VXgWcWv3MMvcVQ+KQvlGzoFf+/ErrSO6orHy2m5lKVT5PFfw4xx6yzMrq9PEpZUbp4Rs8/lnpLSn8KweW5SaxUA2qIstIdFcXVZ1HXb0IsjhT0AXbMWqzNImxBFAl8WqeD4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=se8ye342; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="se8ye342"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 50DA521311;
	Wed, 29 Jul 2026 00:39:04 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=YfIx3cDuf0IbRvRgyzQM8ZdkXNZbLqHN3hcf8u9ULgc=; b=se8ye342vF9u
	YYggMzJBqPF4Nu6LIIbyxJeOsyqa5Nf0X+pfWETZzlXHSDtOXv+mJqCVzMNO+sfx
	DktKNhyyqAO4wlUZzph1g3cGk5VuVaVus47KeVC/VxP6f98jJ9Sy7GWIVCKRkH3o
	T5Chh+w1703gxeEL3CHCqVSGivoIsbQ0ok7/8ZigLyMJiBNALoeC1fxFnH8PgxxB
	sD04OBPX7a1bRxhZ+DGIzQaY/5XfuCrGXgdUWTzjzuabPA1+B4fbqaYu8B3XWqtj
	PwDMzmdthF6isjDQETUD1yoAWP9i2eDRS93Xk54ib6jDcyM8bRGvkUu4/C+pSGv7
	UQ1Pxj5w5S/Tv6WN943DpEtMMjsz6HENC4ckT3KmjzBcLC5Pkn/UbXBnJHGHlYVp
	IgDs1ePfJ97ETFL9cwRefME9y6qPDetQS50hN8l2zb4PbykV/5yUH6cp3CLaB3aA
	c5ejOyHiuIPFb2D8yIRMCRhGT2bgMFZmoD/ZGvq1VzRJMHphQ8J2vF4Ukj16ky2Y
	kdGEB0M+0HieF6wOwPjXnJQ0uSj/Rm833n+h5x7WATgyGGS9ai5vkrCUzVzlcAGR
	0Bvp/iid/cQVv08GoL/oL0wVTq3nhrMa3ehqHV8t1b0gsu+zp8N4XEED78tdDqnZ
	4MDVYEzaSxqkZXjmILSl9MAtQeSYxtw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 29 Jul 2026 00:39:04 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 01F7560B6E;
	Wed, 29 Jul 2026 00:39:04 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66SLd3Mf066828;
	Wed, 29 Jul 2026 00:39:03 +0300
Date: Wed, 29 Jul 2026 00:39:03 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v2 0/2] ipvs: csum validations, part 2
In-Reply-To: <20260728202520.59179-1-ja@ssi.bg>
Message-ID: <2274a119-991c-ccf3-8636-059ba65eb88a@ssi.bg>
References: <20260728202520.59179-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 28 Jul 2026, Julian Anastasov wrote:

>         This patchset contains more fixes after the
> previous batch of fixes for checksum validations.
> 
>         The first patch avoids reading the IPv4 ihl field
> multiple times to prevent local attacker to cause
> out-of-bounds write in ip_vs_nat_icmp.
> 
>         The second patch returns the checksum validations
> which can be needed for the FORWARD hook.
> 
> Julian Anastasov (2):
>   ipvs: avoid out-of-bounds write in ip_vs_nat_icmp
>   ipvs: return the csum validation for forward hook

	There is something more to fix, will send v3:

https://sashiko.dev/#/patchset/20260728202520.59179-1-ja%40ssi.bg

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

