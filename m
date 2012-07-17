From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf] IPVS
Date: Tue, 17 Jul 2012 22:50:18 +0900
Message-ID: <20120717135018.GH17325@verge.net.au>
References: <1341965963-7275-1-git-send-email-horms@verge.net.au>
 <20120717101406.GC3812@1984>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120717101406.GC3812@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, Jul 17, 2012 at 12:14:06PM +0200, Pablo Neira Ayuso wrote:
> On Wed, Jul 11, 2012 at 09:19:20AM +0900, Simon Horman wrote:
> > 
> > Hi Pablo,
> > 
> > this pull request consists of three bug fixes for IPVS.
> > Please consider for inclusion in 3.5 and stable.
> > 
> > The bug fix from Julian, "ipvs: fix oops in ip_vs_dst_event on rmmod"
> > fixes a regression introduced in 3.4 and thus I believe it is
> > only relevant to 3.5 and 3.4-stable.
> > 
> > The other two fixes appear to have been present since at least 2.6.37
> > (there were a lot of changes to IPVS around that time).
> 
> I have passed the two of these patches to David. The one for the FTP
> needs a consistent description.
> 
> It's fairly late in the development cycle (-rc7), but these are small.
> Let's see if David is still in time to accept them. Otherwise, they go
> to net-next and we will ask for -stable submission.

Thanks, it seems that David was in an accepting mood.
