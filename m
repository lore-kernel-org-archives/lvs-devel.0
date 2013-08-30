From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 4/4] ipvs: stats should not depend on CPU 0
Date: Fri, 30 Aug 2013 10:31:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308301029350.1837@ja.ssi.bg>
References: <1377707376-4362-1-git-send-email-ja@ssi.bg> <1377707376-4362-5-git-send-email-ja@ssi.bg> <20130830011751.GB8360@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130830011751.GB8360@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>


	Hello,

On Fri, 30 Aug 2013, Simon Horman wrote:

> [ Cc: Hans Schillstrom ]
> 
> On Wed, Aug 28, 2013 at 07:29:36PM +0300, Julian Anastasov wrote:
> > When reading percpu stats we need to properly reset
> > the sum when CPU 0 is not present in the possible mask.
> 
> It seems reasonable to me that this condition could occur,
> though I am not aware of a specific case where that is so.
> 
> Can I confirm that this problem was introduced by
> b17fc9963f837ef1 ("IPVS: netns, ip_vs_stats and its procfs")?

	That is correct, I forgot to track the initial
commit, you can freely add such information before
applying.

Regards

--
Julian Anastasov <ja@ssi.bg>
