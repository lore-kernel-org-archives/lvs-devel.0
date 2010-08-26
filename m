From: Simon Horman <horms@verge.net.au>
Subject: Re: Status of NFCT patch?
Date: Thu, 26 Aug 2010 10:32:25 +0900
Message-ID: <20100826013222.GA13923@verge.net.au>
References: <4C6378CE.2030909@imprecise.org>
 <20100825075312.GB21278@verge.net.au>
 <Pine.LNX.4.58.1008252238510.2907@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.1008252238510.2907@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Matt Moor <m@imprecise.org>, lvs-devel@vger.kernel.org

On Wed, Aug 25, 2010 at 10:48:39PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 25 Aug 2010, Simon Horman wrote:
> 
> > On Thu, Aug 12, 2010 at 02:30:06PM +1000, Matt Moor wrote:
> > > Hi All,
> > > 
> > > What's the merge status of the NFCT patch? We're deploying some new
> > > boxes on 2.6.32 (the first ones for a while), and were surprised it
> > > hadn't made it into mainline yet.
> > 
> > Julian,
> > 
> > do you have any particular concerns in relation to merging NFCT?
> 
> 	May be it is time NFCT patch to be merged. It is
> even later because code from the NFCT patch went to wrong
> place (ip_vs_ftp.c) when the recent changes from Hannes Eder
> were applied. I prefer ip_vs_nfct.c to contain all NFCT-related
> code as in my patch. May be I should resync it to more recent
> tree, may be this weekend.

Thanks, that would be great.

