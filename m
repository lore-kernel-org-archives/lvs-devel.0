Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9858F37B3FD;
	Fri,  8 May 2026 09:58:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778234320; cv=none; b=H0JLbxe4YaPknRD8vLPD3x4okhdtd0e2smS6RbJ4AfgxMrx6i26sME+qUx1qLYdbuNCojviMX+nx7YFeGPeGQ+/zM7ca9hFrlYKFllU+XIuA11a7FN62KZQSFn07ZrtWY+RZ2GAqsmcZLTtfJIdetFWIhIAamOTM/jpzfFhLQdU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778234320; c=relaxed/simple;
	bh=8bvxPzKbAlDPWPw35knQKGirxZU7g2TQQtFv5uxMx1I=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Dw59ZIw5V6aqYMsDwkNcP5aSQGRERP87Um+6PNl/LJHnArvnunHvlm1y4moeXHT/qMtmvxsZ3OMbRNtRU6sDzZubqdBRHO4c32Ijf4mn43NrWAM+9mWdsMYYNbEywghu3WPEaQ65C+IXpqe5CAx6+w2PpVL0/RgsIrDAortQwjs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=0HtTbtvr; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="0HtTbtvr"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id EBAB922940;
	Fri, 08 May 2026 12:58:32 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=s2ydG5kmo8cMxihIV2dJlbHVpqp8QLoudRSn/nYUOI0=; b=0HtTbtvrpWpv
	EClg6NKv2tiKmWC12eae2GFCl1rI6dEr2X3H9/RLpEyCoDkWY2F/TJ2/nlnpP1Ap
	HbCDmOQ7oEFGRij1Yps3ZzjwAW7AcuXIikdZpWK61PpAobJh7ghoXrLp4Co9NucW
	DW2JwWzamY877CItfv/V2jMBQnzK3A2DHtnJWwDYIrfKw12oN2/VSMEE9WSg91VE
	nE21l6pTrCGHBnxBY5X21bO3Cs7oBw/DZYOY+ANRF05X9AuE0XO59BD1UCndXeZB
	4/fzsI8miHPihQXxLOQcgay3uQp8IfBL5R5uWMgFA86vW43kunmySx3qp9gggIol
	R2ZrvcfLsOxHLJ/ewTPfd0lhQffKXtrXTe1D9B4fwB76uC2b66HW7I6svn0j6Ddn
	h9mrsNy/s0M5S8bEGzLCUpvrmVxUcfaywg3IPLQA9/Be7Y2d0piCQ3irqISDc3dH
	utYUppus8AmbSmde6DMKZdiVrLXMTzNuE9vv9JSPIkODf58CHCuAQ8lX1yKU/8tj
	FibOd9F3WZIk5ZwiaJ5Sk0iqMajZcvyadSxrw3YcaALm0L2UARmVtbbT2K2hbvno
	tQG8VHlMMxLa77nFKegI/NVpzMrUvg+x5qHEgevzhjLildiFuYnAAczQZ/wPT1sV
	n7p+hL25sPtJhTbRxqtfP+mpd4Ka9vE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 08 May 2026 12:58:32 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B050860873;
	Fri,  8 May 2026 12:58:31 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 6489wQeI027394;
	Fri, 8 May 2026 12:58:29 +0300
Date: Fri, 8 May 2026 12:58:26 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH v2 nf] ipvs: avoid possible loop in ip_vs_dst_event on
 resizing
In-Reply-To: <20260507192336.79978-1-ja@ssi.bg>
Message-ID: <0afabc6e-0c8e-b77d-40eb-2cd5bf55eee1@ssi.bg>
References: <20260507192336.79978-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 7 May 2026, Julian Anastasov wrote:

> Sashiko points out that unprivileged user can frequently
> call ip_vs_flush() or ip_vs_del_service() to trigger
> svc_table_changes updates that can lead to infinite loop
> in ip_vs_dst_event(). This can also happen if the user
> triggers frequent table resizing without deleting all
> services. We should also consider the possible effects
> if the user triggers many NETDEV_DOWN events.
> 
> One way to solve it is to hold svc_resize_sem in
> ip_vs_dst_event() but this can block the dev notifier
> during the whole resizing process.
> 
> Instead, use new rw_semaphore svc_replace_sem to protect just
> the svc_table replacement which is a short code section.
> Then hold svc_replace_sem in ip_vs_dst_event() to serialize
> with replacing the svc_table. As result, loop is avoided
> as there is no need to repeat the table walking from the
> start. By this way changes in svc_table_changes can happen
> only when all services are removed and all dev references
> dropped which allows us to abort the table walking.
> 
> As IP_VS_WORK_SVC_NORESIZE is the flag used to stop the
> svc_resize_work under service_mutex, we should check only
> this flag often but not while under service_mutex.
> 
> Link: https://sashiko.dev/#/patchset/20260505001648.360569-1-pablo%40netfilter.org
> Fixes: 840aac3d900d ("ipvs: use resizable hash table for services")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	There is a way to remove the trylock in svc_resize_work,
will send v3 later today.

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

