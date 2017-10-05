From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] libipvs: discrepancy with libnl genlmsg_put
Date: Thu, 5 Oct 2017 12:03:33 +0200
Message-ID: <20171005120333.3de32b15@redhat.com>
References: <20170927153105.7222-1-baloo@gandi.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20170927153105.7222-1-baloo@gandi.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: baloo@gandi.net
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, brouer@redhat.com

On Wed, 27 Sep 2017 15:31:05 +0000
baloo@gandi.net wrote:

> From: Arthur Gautier <baloo@gandi.net>
> 
> There is a mixup between NL_AUTO_PORT and NL_AUTO_PID. The
> first should be used with genlmsg_put while the second with
> nlmsg_put.
> 
> This is not a problem, because both NL_AUTO_PORT and NL_AUTO_PID
> have the same value, but still a discrepancy with libnl documentation.
> 
> see documentation of genlmsg_put here:
>   http://www.infradead.org/~tgr/libnl/doc/api/group__genl.html#ga9a86a71bbba6961d41b8a75f62f9e946
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Arthur Gautier <baloo@gandi.net>
> ---

Applied this here:
 https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=76c12701481

Thank you Arthur for bringing this discrepancy in-order :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
