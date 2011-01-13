From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 00/22] ipvs namespaces v3.3
Date: Thu, 13 Jan 2011 22:18:22 +0900
Message-ID: <20110113131822.GB11202@verge.net.au>
References: <1294883588-5683-1-git-send-email-horms@verge.net.au>
 <4D2EDDD0.8060903@netfilter.org>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D2EDDD0.8060903@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>

On Thu, Jan 13, 2011 at 12:11:12PM +0100, Pablo Neira Ayuso wrote:
> On 13/01/11 02:52, Simon Horman wrote:
> > Hi Pablo,
> > 
> > this changest includes the following changes since the v3.2 series
> > which was most recently posted as "[GIT PULL nf-next-2.6] ipvs namespaces".
> > 
> > * Remove several hunks that only make whitespace changes
> 
> Thanks a lot for doing this.
> 
> > * Add Acked-by: Julian Anastasov <ja@ssi.bg>
> >   (It was an omission from v3.2)
> > * Fix merge conflicts
> > 
> > There are two changes that produce conflicts
> > * In the current net-next-2.6 tree but absent from the current nf-next-2.6 tree
> >   there is "workqueue: convert
> >   cancel_rearming_delayed_work[queue]() users to cancel_delayed_work_sync()"
> > * And in the current nf-next-2.6 tree  but absent from the current
> >   net-next-2.6 tree there is "net: use the macros defined for the members
> >   of flowi"
> 
> nf-*-2.6 are Patrick's trees. My trees are here:
> 
> http://1984.lsi.us.es/git/

Thanks, noted.

> > In order to create this series I merged net-next-2.6 into nf-next-2.6.
> > The result is at
> > git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6 ipvs-netns3.3
> > 
> > However, I guess that you have already done your own merge and simply
> > pulling the branch above will create a bit of a mess. Please let me know
> > if you have a tree/branch that I should use as a base for a pull request.
> 
> I have pulled it, everything was fine. Thanks Simon!

Great!
