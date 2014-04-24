From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-next] IPVS Updates for v3.16
Date: Thu, 24 Apr 2014 09:50:37 +0900
Message-ID: <20140424005037.GB5064@verge.net.au>
References: <1398039407-12060-1-git-send-email-horms@verge.net.au>
 <20140423121715.GA12169@localhost>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140423121715.GA12169@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Apr 23, 2014 at 02:17:15PM +0200, Pablo Neira Ayuso wrote:
> Hi Simon,
> 
> On Mon, Apr 21, 2014 at 09:16:46AM +0900, Simon Horman wrote:
> > Hi Pablo,
> > 
> > please consider the following updates for IPVS for v3.16.
> > 
> > It consists of a format string fix from Masanari Iida.
> > 
> > 
> > The following changes since commit 6125c94e6972fca79214809a43eb60e27feff3ee:
> > 
> >   netfilter: nft_ct: split nft_ct_init() into two functions for get/set (2014-03-30 13:31:44 +0200)
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.16
> 
> I'm going to manually apply this small patch.
> 
> There was a small cleanup for nfnetlink that has reached David's tree
> in a bigger batch that I already applied in my tree, so I needed to
> REbase to avoid problems. You'll also have to rebase as well. Sorry.

Thanks, that is perfectly fine by me.
