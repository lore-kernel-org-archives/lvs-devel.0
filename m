From: Arthur Gautier <baloo@gandi.net>
Subject: Re: [PATCH] libipvs: discrepancy with libnl genlmsg_put
Date: Thu, 5 Oct 2017 17:20:04 +0000
Message-ID: <20171005172004.shovu7sftamaid5i@khany>
References: <20170927153105.7222-1-baloo@gandi.net>
 <20171005120333.3de32b15@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171005120333.3de32b15@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

On Thu, Oct 05, 2017 at 12:03:33PM +0200, Jesper Dangaard Brouer wrote:
> On Wed, 27 Sep 2017 15:31:05 +0000
> baloo@gandi.net wrote:
> 
> > From: Arthur Gautier <baloo@gandi.net>
> > 
> > There is a mixup between NL_AUTO_PORT and NL_AUTO_PID. The
> > first should be used with genlmsg_put while the second with
> > nlmsg_put.
> > 
> > This is not a problem, because both NL_AUTO_PORT and NL_AUTO_PID
> > have the same value, but still a discrepancy with libnl documentation.
> > 
> > see documentation of genlmsg_put here:
> >   http://www.infradead.org/~tgr/libnl/doc/api/group__genl.html#ga9a86a71bbba6961d41b8a75f62f9e946
> > 
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Cc: Simon Horman <horms@verge.net.au>
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Arthur Gautier <baloo@gandi.net>
> > ---
> 
> Applied this here:
>  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=76c12701481
> 
> Thank you Arthur for bringing this discrepancy in-order :-)

My OCD says thank you.

-- 
\o/ Arthur
 G  Gandi.net
