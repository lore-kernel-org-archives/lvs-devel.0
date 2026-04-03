Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A91953C4568;
	Fri,  3 Apr 2026 14:29:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775226552; cv=none; b=qL1tkecBqPdb9HMkRSrP0wlUFN9kfSe887/jtuJCGX7BnFVn1+PeivZ1+ePgE4vWTmVidz1lt8Ly5IBzpc1rg5mcz0F0hBenIN/qr7194kHdGljLf3A/s+fyHdFcd/XncveZOiT5gqjdrGd4NdGOjy9a8wd1mybeZ7RITE9xVPc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775226552; c=relaxed/simple;
	bh=Q8qjsmqNAraAJvaJy3VYZsFagpV6fVCDd5UdLIJD01s=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=C8AKkkgpHHNs783Qqoaotk+t68FJagqMpo+mLcQyB6WiLbNtAOUZMvKicvON31QIUGkBzgE6BLFGr6em4iKyLxQk1Gkl0EP26LAVXSyv57q4t09yWByR3OMztavBVPSDc6AYRB+a+BJKdpV08964mzTHd/fAemc38S+Aww+9dVU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=YiNCIvFc; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="YiNCIvFc"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id BFA1860265;
	Fri,  3 Apr 2026 16:29:08 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1775226548;
	bh=U4OCDIev93PFXK9ajmKbwQB4cm8t6Rku1D2I1wMB/ME=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=YiNCIvFc+v9ST74eUMxKLOuhzEHsMrHMFeF0AIuVRbpVKbH5HAGpFQOCld2ySCrlR
	 qn6Vu0S+oPZkJcr0+ENzFTNPowt0tarUsptcaO1/iFDfUyDSB/F6s8dUNxK+keuV51
	 MhAICAjIBOaIv1GDUHheIN230C8w0jaDjdN4REnwPl3yhNG4sIpPJBOCozo8jHreSa
	 k5WXQiyiRwzaRvs42j9hI1dGoh4ZjVpZ/Ia5e+BCqxbaqet3v9iqqKy1jn8TdHfOWI
	 a3Pgzn3nOQdslW7M3QVOif2FO1Fkdy+vOZl+yDe/SR6r8Q85i7Gp4aXCXxaHPsmgKu
	 0ozd3o9IKpPGg==
Date: Fri, 3 Apr 2026 16:29:05 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Waiman Long <longman@redhat.com>, Simon Horman <horms@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsahern@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	Frederic Weisbecker <frederic@kernel.org>,
	Chen Ridong <chenridong@huawei.com>, Phil Auld <pauld@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, sheviks <sheviks@gmail.com>
Subject: Re: [PATCH-next v2 0/2] ipvs: Fix incorrect use of HK_TYPE_KTHREAD
 housekeeping cpumask
Message-ID: <ac_OscBPYRwt73ic@lemonverbena>
References: <20260331165015.2777765-1-longman@redhat.com>
 <cd9afe18-9862-6005-f7d9-d69425b7d4cf@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cd9afe18-9862-6005-f7d9-d69425b7d4cf@ssi.bg>

On Fri, Apr 03, 2026 at 05:15:50PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 31 Mar 2026, Waiman Long wrote:
> 
> >  v2:
> >   - Rebased on top of linux-next
> > 
> > Since commit 041ee6f3727a ("kthread: Rely on HK_TYPE_DOMAIN for preferred
> > affinity management"), the HK_TYPE_KTHREAD housekeeping cpumask may no
> > longer be correct in showing the actual CPU affinity of kthreads that
> > have no predefined CPU affinity. As the ipvs networking code is still
> > using HK_TYPE_KTHREAD, we need to make HK_TYPE_KTHREAD reflect the
> > reality.
> > 
> > This patch series makes HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> > and uses RCU to protect access to the HK_TYPE_KTHREAD housekeeping
> > cpumask.
> > 
> > Waiman Long (2):
> >   sched/isolation: Make HK_TYPE_KTHREAD an alias of HK_TYPE_DOMAIN
> >   ipvs: Guard access of HK_TYPE_KTHREAD cpumask with RCU
> 
> 	The patchset looks good to me for nf-next, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Pablo, Florian, as a bugfix this patchset missed
> the chance to be applied before the changes that are in
> nf-next in ip_vs.h, there is little fuzz there. If there
> is no chance to resolve it somehow, we can apply it
> on top of nf-next where it now applies successfully.

One way to handle this is to follow up with nf-next as you suggest,
then send a backport that applies cleanly for -stable once it is
released.

Else, let me know if I am misunderstanding.
