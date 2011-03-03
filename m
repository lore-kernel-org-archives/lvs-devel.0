From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-2.6] IPVS
Date: Thu, 3 Mar 2011 16:47:34 +0900
Message-ID: <20110303074731.GA8025@verge.net.au>
References: <1299020375-11362-1-git-send-email-horms@verge.net.au>
 <4D6E22CA.2020305@trash.net>
 <20110302220637.GD8193@verge.net.au>
 <4D6F3AD2.30502@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D6F3AD2.30502@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

On Thu, Mar 03, 2011 at 07:53:06AM +0100, Patrick McHardy wrote:
> On 02.03.2011 23:06, Simon Horman wrote:
> > On Wed, Mar 02, 2011 at 11:58:18AM +0100, Patrick McHardy wrote:
> >> Am 01.03.2011 23:59, schrieb Simon Horman:
> >>> Hi Patrick,
> >>>
> >>> please consider pulling
> >>> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
> >>> to get the following change from Julian. Please note that it is an nf-2.6
> >>> (that is 2.6.38-rc) change.
> >>>
> >>> Julian Anastasov (1):
> >>>       ipvs: fix dst_lock locking on dest update
> >>
> >> Pulled, thanks Simon.
> > 
> > Thanks Patrick.
> > 
> > This change is also needed in nf-next-2.6 but I assume that
> > will automatically happen when nf-2.6 is merged into nf-next-2.6,
> > possibly via a merge of net-2.6 into net-next-2.6.
> 
> Yes. If you need it as base for further work, the fastest way
> is to ask Dave to pull net-2.6 into net-next-2.6, I can then
> pull it into nf-next.

There is no rush at this time.

