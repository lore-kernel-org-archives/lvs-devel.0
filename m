From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Status of NFCT patch?
Date: Wed, 25 Aug 2010 22:48:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1008252238510.2907@u.domain.uli>
References: <4C6378CE.2030909@imprecise.org> <20100825075312.GB21278@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100825075312.GB21278@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Matt Moor <m@imprecise.org>, lvs-devel@vger.kernel.org


	Hello,

On Wed, 25 Aug 2010, Simon Horman wrote:

> On Thu, Aug 12, 2010 at 02:30:06PM +1000, Matt Moor wrote:
> > Hi All,
> > 
> > What's the merge status of the NFCT patch? We're deploying some new
> > boxes on 2.6.32 (the first ones for a while), and were surprised it
> > hadn't made it into mainline yet.
> 
> Julian,
> 
> do you have any particular concerns in relation to merging NFCT?

	May be it is time NFCT patch to be merged. It is
even later because code from the NFCT patch went to wrong
place (ip_vs_ftp.c) when the recent changes from Hannes Eder
were applied. I prefer ip_vs_nfct.c to contain all NFCT-related
code as in my patch. May be I should resync it to more recent
tree, may be this weekend.

Regards

--
Julian Anastasov <ja@ssi.bg>
