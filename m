From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 4/4] ipvs: stats should not depend on CPU 0
Date: Fri, 30 Aug 2013 12:53:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308301246200.2263@ja.ssi.bg>
References: <1377848768.12846.122.camel@hawk.mlab.se> <alpine.LFD.2.00.1308301029350.1837@ja.ssi.bg> <20130830085332.GA10484@verge.net.au> <20130830085819.GA13017@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130830085819.GA13017@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans@schillstrom.com>, lvs-devel@vger.kernel.org


	Hello,

On Fri, 30 Aug 2013, Simon Horman wrote:

> > > > Can I confirm that this problem was introduced by
> > > > b17fc9963f837ef1 ("IPVS: netns, ip_vs_stats and its procfs")?
> > > 
> > > 	That is correct, I forgot to track the initial
> > > commit, you can freely add such information before
> > > applying.

> Bother, I messed up the commit-id in the changelog.
> The corrected version, which I will queue up, is.

	OK, I noticed it too. Later you post pull request
with wrong commit, I hope Pablo will pull a fixed
patch because ipvs-fixes-for-v3.11 still has old commit.

> >From 77f12c00cd6603e93dcb729aa6dc206cb8bb3a46 Mon Sep 17 00:00:00 2001
> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed, 28 Aug 2013 19:29:36 +0300
> Subject: [PATCH] ipvs: stats should not depend on CPU 0
> 
> When reading percpu stats we need to properly reset
> the sum when CPU 0 is not present in the possible mask.
> 
> This problem was introduced by b17fc9963f837ef1
> ("IPVS: netns, ip_vs_stats and its procfs").

Regards

--
Julian Anastasov <ja@ssi.bg>
