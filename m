Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B30943F8BA;
	Mon, 14 Sep 2026 18:01:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789408895; cv=none; b=Sx2LmyWi5JdMjc0lNi5zQaH0NOg741nvzeRSQCIfzM8y/Blaf1eaz8z+jHFy3prvlqE1IGfT+Jk9OqRalQ2hs8K7GxmPmDorjs85RI+LibOCTcCWwpVUZO5suC6Nr0d+kH8mMD+eLLcq7D7Rn287MbYI7ocV0vXWnWqnrn7vkfE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789408895; c=relaxed/simple;
	bh=9+fGYeEjtiTKqk/einnKtTETXeD5V3fNRtMu5LF9Io8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=mvkboDdDjPSG2rSQAd2mTIb4qtI54K8FBHNVq4YYTwalH3eTFtNNO8oDelK7DgKZ/AguQC/V1/+eijveB6Tjs+Nk9w+xGwjM3u9IBRhzj2AaQ2trVrEKFx0Vl/HaBUdpRj6oHzlFnNf3uiFAop6jANMLt+7feTHMP7UK1Qklodk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=CH8CX88b; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="CH8CX88b"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CE054217BE;
	Mon, 14 Sep 2026 21:01:18 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=mF6FBjhglviK2VMYQ+p5BfLpRV6mFZnEExMk/j+gSg0=; b=CH8CX88bPRO3
	OjHI5AD7imBTZf7BaaDMMvJdtkq3vZjdGKB7S/84pi8joki3vCung/dTjK/h9nTb
	9iEftA7HAk8f1wffhViUG/57ZbIa78jZ8OuNUqTMq67+EMt8CgAPc58Yxf5ANqBe
	ud9EAGXaHl0EakKM7CXg6SXnFiTZahUfTVGlCoRSZTgaQV6OkJfRa82M9HVLjYdG
	WQg5rnEUyoTauvu0BpuyB4mW0RVNHfAZ4qcKPoRrFbdkJCOhH1hSFYBARj4qWzFk
	sNsUTEBXc6pJW8Y2Y/sJGTHS3TnqlyIXkQCKAJNq3GypJsHAzG19zsXLv0C/urPm
	5GirFoc/4CmjxkL7URjWwb//rRFD2VtaMwshYkzJ+EBujwgUz2BKWo2hkU7OZB4S
	HMLMdsuvGYx1oOgZbLrxGBqedtLT+M5MT5tmrlOnRaHZThYS3ckCkouBmY5dWCQE
	NcHIgtbs5EcwILRlg2Ri/LA9Pi4O9cIjPA4mOMfh9PL1gd4qX4tm8fViA0DfbGEw
	P11xREwRk7OuY9s3XkexUxDPbSEiZpVS5YbQ46GXSHcnT3e51ADkzy7uo8MySExJ
	uQrCFH/kLsbmL5RZos0rFYGobXxLA6u1p/b8+s9rzr0iw1znBF95oCQzbtn9ErKp
	HAh9p+21iHsDO4IPSC69If2ZwnGF4YY=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 14 Sep 2026 21:01:18 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8BFBD60F41;
	Mon, 14 Sep 2026 21:01:20 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68EI158E048412;
	Mon, 14 Sep 2026 21:01:07 +0300
Date: Mon, 14 Sep 2026 21:01:05 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ren Wei <weir@nebusec.ai>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Simon Horman <horms@verge.net.au>, pablo@netfilter.org, fw@strlen.de,
        phil@nwl.cc, darby.payne@gmail.com, vega@nebusec.ai,
        zzyy19904204639@163.com
Subject: Re: [PATCH net 0/1] ipvs: bound twos scheduler destination walks
In-Reply-To: <cover.1789117690.git.zzyy19904204639@163.com>
Message-ID: <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg>
References: <cover.1789117690.git.zzyy19904204639@163.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sun, 13 Sep 2026, Ren Wei wrote:

> From: Darong Lu <zzyy19904204639@163.com>
> 
> Hi Linux kernel maintainers,
> 
> We found and validated an issue in net/netfilter/ipvs/ip_vs_twos.c. The
> bug is reachable by a non-root user via user and net namespace.
> We've tested it, and it should not affect any other functionality.
> 
> We will provide detailed information about the bug
> in this email, along with a PoC to trigger it.
> 
> ---- details below ----
> 
> Bug details:
> 
> The IPVS TWOS scheduler performs two RCU-protected walks over the service
> destination list. The reproducer repeatedly deletes and recreates the
> service, including its destinations, while the scheduler is traversing the
> list. If a destination list entry is relinked before the RCU reader
> completes, the reused entry can make the iterator follow a link outside the
> original service list.
> 
> The root cause is that both walks are unbounded. If the iterator follows a
> reused list entry, it can continue walking indefinitely and prevent the
> scheduler from returning. The fix reads the service destination count before
> each walk and stops after that many entries, while preserving the existing
> scheduler algorithm and RCU list traversal.

	I'm trying to understand how the iterator can be
tricked to loop forever: to loop, it should never reach 
&svc->destinations, so it must walk unlinked nodes which
create some loop between them. But READ_ONCE soon or later
will read actual ptr from memory, so it should reach to
&svc->destinations. We know that entries end up in reverse
order in the list after they are added but how looks the
list that causes the loop?

	OTOH, I don't understand why we need two full lookups to
trigger the problem, can it happen with one list_for? Other
schedulers also walk the list twice, for example, RR remembers
previous position.

	I assume the problem is caused by the dest_trash.
It seems, we need a general solution to this problem.
One option is to penalize with synchronize_rcu() if we detect
dest that is reused too soon. But even that looks complex to
implement.

Regards

--
Julian Anastasov <ja@ssi.bg>

