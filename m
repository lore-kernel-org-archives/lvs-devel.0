Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 372593AA4EF;
	Mon, 20 Apr 2026 18:13:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776708802; cv=none; b=e71Hs7nyXQGTlMnWUCN+V35aqulANnof9ZpEcjDO3hxK6ZpR+7UA+yOx2SxedUMQep2xaQ5qWPigQZBON4zllZRPamj2/RXR7n9jqmvxrBgOs4r3Q6JVmM3xtpKdv6EQjPTHg4EgLJXp8zPPTkMPBRaE3zGuo0FAdsGseig2ix8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776708802; c=relaxed/simple;
	bh=cxVGMdE6L96ddpqs6Inup1x6USZFMhZs/roXduj9jNU=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=MB7urSA1yG/TlYa1wfMaI5Rhx+7zgvns/GbNCUt0iT826twhU3RCVqCnceDckRgIjrPIzSzlDiCzf746gvMP2cVMkZzbD9CGMfukavLiFwcE1ueGPHFYSvjtAoUyxzhxKUhWyRQgmSjjZQVfxKZz3GxnFOF99MFIe4OntGivQLs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=zE8Jtx/V; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="zE8Jtx/V"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id F3378210DF;
	Mon, 20 Apr 2026 21:13:14 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=nMeWIr0htb4bW9OWfJG0PMZeV9tSGQNMeRdA+QlQHmI=; b=zE8Jtx/VW4z7
	7c0isnG+Dqa3Xa160uv1hRBeX2iOUs/NU7hYJghvL5fCYyey03xYViGnUyhYYLyP
	PCj3wpvWnALmgzYdLk/CqBZ0JD48YtEnTEZrOkdc0fXiAh6nA9elfcFIZRVLiIU4
	hp9eukF6xVF0MiBytHoL5zVHSTa6KkefA/oeOjm5NRl3rP0gt0SOrEjoR6LcdXvG
	Zf4A4bTjgHukmLvA4FbTdpWtByXuGYD2kKxZXAn2ZzW77ENAesOVuu8wl6noyKHS
	1go0VpQergMN9wUTtqEUbmBHYxg+lEi9koKEZAUbMbDyHJT1wwvhCjn5w9ztPe/B
	yI1yQqEOaPtvnILQPGISazGp//P5/HloWgmNgz/TQCkPz1hCFYNJPmlCk2h8BevZ
	HnvXG16bA5nxge0I76P3YJFo3R1JluflB66KagZHc3L8Pj6RiySyXwF7Lc+sN1Rj
	vweb5nMS+AZwszV1xLpoV0Rn1FcuDdAHUAju8uH9ID2EeH+MltWYC6AdwSlXrBXj
	jOnC79IuOrY3Q9YnBtDwEn1smrZPMD3Ae1uDipuCA4doDrDCdpkACwfdu4bPBEvb
	MYcfyRXh13fNmSb0ZUmFOF9P0+Om9LKHJU50mAXPBg+K6iqyvIcvUZrXxZ/jm9sM
	HU9Utsl0tgwy2WZGGWvmXsSaXEgFCa0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 20 Apr 2026 21:13:13 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 90C7060A4B;
	Mon, 20 Apr 2026 21:13:12 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63KID9Ms094936;
	Mon, 20 Apr 2026 21:13:09 +0300
Date: Mon, 20 Apr 2026 21:13:09 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Waiman Long <longman@redhat.com>, Simon Horman <horms@verge.net.au>,
        "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>,
        Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        Frederic Weisbecker <frederic@kernel.org>,
        Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, sheviks <sheviks@gmail.com>
Subject: Re: [PATCH-next v2 0/2] ipvs: Fix incorrect use of HK_TYPE_KTHREAD
 housekeeping cpumask
In-Reply-To: <aeZmVMaMymU6ZS5S@chamomile>
Message-ID: <1325dd28-1911-8975-0672-0c9377d4e19f@ssi.bg>
References: <20260331165015.2777765-1-longman@redhat.com> <cd9afe18-9862-6005-f7d9-d69425b7d4cf@ssi.bg> <ac_OscBPYRwt73ic@lemonverbena> <097db82c-c9d1-4532-694a-b7ecbdd67532@ssi.bg> <aeZmVMaMymU6ZS5S@chamomile>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 20 Apr 2026, Pablo Neira Ayuso wrote:

> On Mon, Apr 20, 2026 at 08:24:56PM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Fri, 3 Apr 2026, Pablo Neira Ayuso wrote:
> > 
> > > On Fri, Apr 03, 2026 at 05:15:50PM +0300, Julian Anastasov wrote:
> > > > 
> > > > 	Hello,
> > > > 
> > > > On Tue, 31 Mar 2026, Waiman Long wrote:
> > > > 
> > > > >  v2:
> > > > >   - Rebased on top of linux-next
> > > > > 
> > > > > Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
> > > > > affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
> > > > > longer be correct in showing the actual CPU affinity of kthreads that
> > > > > have no predefined CPU affinity. As the ipvs networking code is still
> > > > > using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
> > > > > reality.
> > > > > 
> > > > > This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> > > > > and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
> > > > > cpumask.
> > > > > 
> > > > > Waiman Long (2):
> > > > >   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> > > > >   ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
> > > > 
> > > > 	The patchset looks good to me for nf-next, thanks!
> > > > 
> > > > Acked-by: Julian Anastasov <ja@ssi.bg>
> > > > 
> > > > 	Pablo, Florian, as a bugfix this patchset missed
> > > > the chance to be applied before the changes that are in
> > > > nf-next in ip_vs.h, there is little fuzz there. If there
> > > > is no chance to resolve it somehow, we can apply it
> > > > on top of nf-next where it now applies successfully.
> > > 
> > > One way to handle this is to follow up with nf-next as you suggest,
> > > then send a backport that applies cleanly for -stable once it is
> > > released.
> > > 
> > > Else, let me know if I am misunderstanding.
> > 
> > 	This patchset is now material for the net tree. To help it,
> > I just posted patch "ipvs: fix races around est_mutex and est_cpulist"
> > that can be applied before this patchset to the net tree.
> > Can we get this patchset for the net tree?
> 
> Yes, I am preparing a PR.
> 
> BTW, did you get look at the report provided by the AI assistant?
> 
> https://sashiko.dev/#/?list=org.kernel.vger.netfilter-devel

	Yes, I monitor it. I'm waiting the review for
my 3+1 patches from today. And I hope the review for
this HK_TYPE_KTHREAD patchset is addressed too with
"ipvs: fix races around est_mutex and est_cpulist".

> If not, please repost to get initial feedback from it.
> 
> Thanks.

Regards

--
Julian Anastasov <ja@ssi.bg>

