Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B49C3A963D;
	Mon,  6 Jul 2026 14:17:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783347478; cv=none; b=BpQrRjwQw2pd5y4JHUE9KXpDucYcRwSNXpfOGLvaTcu4fAyXTU3PFAOF3N2nTO4FQF26EPkPQIb0pRl2odrgTJUboNM3JHdg2SaSAN2uRenQL/SpT5DXcacLshkCOTwndBsTHZp/xEDlNJUcFYbZI+dsvQS1RlymLIi5r5YQAX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783347478; c=relaxed/simple;
	bh=5rB+tcWjPVVWfW6ycYrFHi0qPClI3epYHo2xDUT70Ww=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=oiDPmRM/zz5xuAprp4S5ZAC4c9ReUhNRvNmNB+VLi02mwp3BiolsAHTzZq6V8eNLENBD+pTX/4N+bvsoqKW6T9H8jgp94vNnMF1r0gh7LNygd8ykYaxjAdMxC3YN+xWRczJFkF3UH3U58xsYfxhxJQFYWrohEwlJlOd+nqZvKPM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=sdwh+UwC; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="sdwh+UwC"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 365422121F;
	Mon, 06 Jul 2026 17:17:50 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=H2kYV2YNGwRbDpvUxivqC0uqB2DTUR1fxY9v63DflU8=; b=sdwh+UwCJLvB
	Clp4C2RDPFw1foh+ob0EyuIg32UOTuyouSy5whBrJgCVAHX6VnvomZXf4QummmGz
	UWrF26Kj1Hh/ZNuoJZELwCEEqL0s18YE9QClgJd5mRQ80PpObxFNH2nS1gXtlaew
	ZnLh9B2pFPr9+mlM+SBPnDvxmJKxvsq3UbJ/9yNbrWJ+AeSMv/W2wRoZFzs5Nu1g
	Ppzj/JnnZDv8Xusj5QrLn6pFQLwiOlZskXZ0ezsFrK3uZvDVjKks7t3Dq+E7xOhL
	e8s6/Noij2vSsYTCQhaaP1XhJhtmyRG9e4smr48qz+OndzgtwU6bHH5eBMkLXCNp
	phhgS7EOY9yokgW3jzsGgrDCTq2tR1orxRZkcQuEfZXa9ZUAlWu5kPn/aBpxDhVW
	rQHm4IR+QKRM8NgARnBtz3RxL8awZtp3Aakd7tl9RK5Wz5sCcraHALMsOGDyg5tw
	RKhSn6waYfgtOVE+UAfy0rbMj7eDHejkbSimebQYqRYud+b3LU0j+JCjcfQ5zZWP
	UKDpD7HkCTHjkkbsXYNtPZSlmJGLXCpxsXachJshmki1vsAPErMMibziv7r1NF6n
	BRN1WQ83SUMRAgfJ6/5WLplaLuCSCeVTAEutrf5m90DDaK4sDKUqq9ZjANSPChYK
	7jy7WZiSm+j0rMrVawIGK4YSRAUGBz8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 06 Jul 2026 17:17:50 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4597E60B74;
	Mon,  6 Jul 2026 17:17:46 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 666EHc2t054134;
	Mon, 6 Jul 2026 17:17:39 +0300
Date: Mon, 6 Jul 2026 17:17:38 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org,
        Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>,
        stable@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: skip IPv6 extension headers in SCTP state
 lookup
In-Reply-To: <87E04893-B2B2-485F-B242-9CACF2F176D6@mails.tsinghua.edu.cn>
Message-ID: <bcd7f0e6-b2fc-4e54-f9ac-e1c8b1b0c497@ssi.bg>
References: <20260705123040.35755-1-zhaoyz24@mails.tsinghua.edu.cn> <92783c87-7e6a-e90a-b2fc-e5d1332139e0@ssi.bg> <87E04893-B2B2-485F-B242-9CACF2F176D6@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 6 Jul 2026, Yizhou Zhao wrote:

> > On Jul 6, 2026, at 01:35, Julian Anastasov <ja@ssi.bg> wrote:
> > 
> > May be it is better starting from ip_vs_set_state()
> > to provide new arg 'int iph_len/offset' (set to iph.len), down to
> > state_transition(), sctp_state_transition() and set_sctp_state().
> > Same for all protos. It should cost less stack and ipv6_find_hdr()
> > calls and what matters most, correct iph context in case we
> > have IP+ICMP+TCP (with just two ports or even with TCP flags)
> > and are scheduling ICMP, i.e. not IP+TCP as usually.
> 
> I agree that the already parsed transport-header offset should be 
> passed from ip_vs_set_state() down to the protocol state_transition() 
> callbacks, instead of reparsing the skb in set_sctp_state(). We will 
> send a v2 that does this for SCTP, TCP and the other IPVS protocols 
> in one combined fix.
> 
> > But what I see is that ip_vs_in_icmp*() are missing
> > the ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd) call just
> > after ip_vs_in_stats() and before ip_vs_icmp_xmit() where
> > we should provide ciph.len. That is why we don't reach the
> > set_tcp_state() calls to set correct cp->state and timeout
> > when scheduling related ICMP. So, this should be fixed too.
> 
> For the ICMP path, I agree that the missing ip_vs_set_state() call is
> worth looking at, but using ICMP errors to drive the upper L4 state 
> needs some care, because spoofed ICMP packets can match an 
> existing embedded tuple before the endpoint TCP/SCTP stack 
> performs its own validation. Maybe this change needs further
> discussion?

	May be only for the schedule_icmp case while the other
ICMP replies should not change it:

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7f93239898ff..05fdcf4ce2c0 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1971,6 +1971,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
+	if (new_cp)
+		ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd, offset);
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol ||
 	    IPPROTO_SCTP == cih->protocol)
 		offset += 2 * sizeof(__u16);

	Here is why schedule_icmp was added:

https://archive.linuxvirtualserver.org/html/lvs-devel/2015-08/msg00015.html

	But the inner TCP header should be generated by the
real server, not from the client, so things can go wrong. We can
leave it as it is now - we will forward the ICMP to the right real 
server by using short conn timeout...

Regards

--
Julian Anastasov <ja@ssi.bg>

