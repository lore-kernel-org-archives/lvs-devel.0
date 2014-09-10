From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 00/20] Support v6 real servers in v4 pools and
 vice versa
Date: Thu, 11 Sep 2014 08:55:04 +0900
Message-ID: <20140910235504.GB29858@verge.net.au>
References: <1410306039-2977-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1409100853260.6338@ja.home.ssi.bg>
 <20140910062201.GA11468@verge.net.au>
 <20140910151617.GA4830@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140910151617.GA4830@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, David Miller <davem@davemloft.net>

On Wed, Sep 10, 2014 at 05:16:17PM +0200, Pablo Neira Ayuso wrote:
> On Wed, Sep 10, 2014 at 03:22:01PM +0900, Simon Horman wrote:
> > [ CC Pablo, Dave M ]
> > 
> > On Wed, Sep 10, 2014 at 09:01:34AM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Tue, 9 Sep 2014, Alex Gartrell wrote:
> > > 
> > > > The following patch set has been iterated upon in the lvs-devel mailing
> > > > list.  I am submitting it here per Julian's advice for inclusion in the
> > > > net-next tree.
> > > 
> > > Acked-by: Julian Anastasov <ja@ssi.bg>
> > > 
> > > 	Simon, please apply the patchset to ipvs-next.
> > > I guess ipvs-next and nf-next need to be updated
> > > before that due to dependency on net-next commit ea1d5d7755a3e556
> > > ("ipvs: properly declare tunnel encapsulation").
> > 
> > Thanks Julian, yes that does seem to be the case.
> > 
> > Pablo, could you merge nf into nf-next and push the result
> > so that I can apply this series on top?
> 
> Let me flush out my nf-next queue first, many updates in it, I'll ping
> to let you know once you can prepare your series. Thanks.

Thanks, much appreciated.
