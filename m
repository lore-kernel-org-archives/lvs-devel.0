From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC] ipvs: Keep track of backlog connections
Date: Wed, 1 Sep 2010 22:28:35 +0900
Message-ID: <20100901132834.GI4998@verge.net.au>
References: <alpine.LNX.2.00.1008311411190.5292@titan.stealer.net>
 <Pine.LNX.4.58.1009011113560.5403@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.1009011113560.5403@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Sven Wegener <sven.wegener@stealer.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Wed, Sep 01, 2010 at 11:32:39AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 31 Aug 2010, Sven Wegener wrote:
> 
> > Hi all,
> > 
> > this patch has been sitting in my local repository for quite some time 
> > now. The number of backlog connections helps diagnosing realserver related 
> > overload and configuration problems. Is it worth merging? If yes, I'm 
> > going to tidy it up and prepare the userspace portion for ipvsadm.
> > 
> > Sven
> > 
> > 
> > From: Sven Wegener <sven.wegener@stealer.net>
> > Subject: [PATCH] ipvs: Keep track of backlog connections
> > 
> > A backlog connection is a connection that is on its way from inactive to
> > active. Speaking in TCP language, a connection from which we've seen the
> > initial SYN packet, but the three-way handshake hasn't finished yet.
> > These connections are expected to move to active soon. When a
> > destination is overloaded or isn't able to successfully establish
> > connections for various reasons, this count increases quickly and is an
> > indication for a problem.
> 
> 	Looks good but should not be applied now because
> we should first put some changes for cp->flags, we are
> reaching the limit of 16 bits for cp->flags. Your
> intention is IP_VS_CONN_F_BACKLOG not to be sync-ed and
> I agree. So, your patch will be applied after other
> changes. I think, Simon will fix it later.

Hi Julian,

thanks for spotting this bits issue.

On the kernel-side of things, internally it should be easy
enough to either expand flags or add a new element to the structure.
So it seems to me that the problem is the kernel/user-space interface.
And if that is the case, I think the best idea is to just use
the netlink interface for all new configuration options and have
new features unsupported through the old, legacy, ioctl interface.

