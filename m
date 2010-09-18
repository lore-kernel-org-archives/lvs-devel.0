From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v1 00/12] IPVS: SIP Persistence Engine
Date: Sat, 18 Sep 2010 21:52:22 +0900
Message-ID: <20100918125219.GA15548@verge.net.au>
References: <20100822124457.339517323@vergenet.net>
 <4C91D157.1090804@trash.net>
 <20100917025232.GH30855@verge.net.au>
 <4C9356A6.5080208@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C9356A6.5080208@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Fri, Sep 17, 2010 at 01:53:10PM +0200, Patrick McHardy wrote:
> Am 17.09.2010 04:52, schrieb Simon Horman:
> > On Thu, Sep 16, 2010 at 10:12:07AM +0200, Patrick McHardy wrote:
> >> Am 22.08.2010 14:44, schrieb Simon Horman:
> >>> This patch series adds load-balancing of UDP SIP based on Call-ID to
> >>> IPVS as well as a frame-work for extending IPVS to handle alternate
> >>> persistence requirements.
> >>>
> >>> REVISIONS
> >>>
> >>> This is "patch v1" of this series, which addresses a few minor problems, as
> >>> annotated on a per-patch basis, since the initial "rfc" posting. Internally
> >>> there were 4 rfc versions, 0.1, 0.2, 0.3 and 0.4, some of the notes for
> >>> some of the patches reflect those versions.
> >>
> >> This looks fine to me as far as I can judge.
> >>
> >>> CODE AVAILABILITY
> >>>
> >>> The kernel patches (13) are available in git as the pe-0.4 branch of
> >>> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git
> >>
> >> Just to clarify, do you want me to merge this version?
> > 
> > Assuming that it applies cleanly, yes.
> > Otherwise I can re-base an re-post.
> 
> There are some smaller conflicts, please rebase to the current nf-next
> tree. Thanks.

Unfortunately a few bugs have shown up.
I'll get them ironed out before reposting.

