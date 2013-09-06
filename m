From: Simon Horman <horms@verge.net.au>
Subject: Re: [ipvsadm PATCH 0/3] Patchset in preparation for ipvsadm release
 v1.27
Date: Fri, 6 Sep 2013 11:20:25 +0900
Message-ID: <20130906022025.GC9158@verge.net.au>
References: <20130905112303.5071.14612.stgit@localhost>
 <alpine.LFD.2.00.1309052231370.1774@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1309052231370.1774@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Ryan O'Hara <rohara@redhat.com>

On Thu, Sep 05, 2013 at 10:33:10PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 5 Sep 2013, Jesper Dangaard Brouer wrote:
> 
> > Here are some patches in preparation for the upcomming ipvsadm release
> > v1.27.  No real coded changes to ipvsadm, just maintainer related
> > updates and changes.
> > 
> > If nobody objects and when Simon ACKs, I'm going to apply this
> > patchset myself to the ipvsadm git tree:
> > 
> >   https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git
> 
> 	Patchset looks ok to me.

It looks good to me too.

Acked-by: Simon Horman <horms@verge.net.au>

Please feel free to push this if you haven't done so already.

> 
> > ---
> > 
> > Jesper Dangaard Brouer (3):
> >       Make README more generic and reference new kernel.org location
> >       Add MAINTAINERS style file
> >       Maintainer script for releasing tarballs
> > 
> > 
> >  MAINTAINERS        |   33 ++++++++++++++
> >  README             |   26 ++++++++---
> >  release-tarball.sh |  123 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 174 insertions(+), 8 deletions(-)
> >  create mode 100644 MAINTAINERS
> >  create mode 100755 release-tarball.sh
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
