From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] ipvs: Keep track of backlog connections
Date: Thu, 2 Sep 2010 03:16:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009020249090.14356@u.domain.uli>
References: <alpine.LNX.2.00.1008311411190.5292@titan.stealer.net>
 <Pine.LNX.4.58.1009011113560.5403@u.domain.uli> <20100901132834.GI4998@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100901132834.GI4998@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Sven Wegener <sven.wegener@stealer.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Wed, 1 Sep 2010, Simon Horman wrote:

> On the kernel-side of things, internally it should be easy
> enough to either expand flags or add a new element to the structure.
> So it seems to me that the problem is the kernel/user-space interface.
> And if that is the case, I think the best idea is to just use
> the netlink interface for all new configuration options and have
> new features unsupported through the old, legacy, ioctl interface.

	No, there should be no problem with the interface,
it already uses 32 bits. We should change only cp->flags
to 32 bits and new flags should go after bit 16 if they
are not needed for sync. Some flags can be changed safely,
for example, IP_VS_CONN_F_SYNC: it is not used by ipvsadm,
it is set only in backup, so it can be moved after bit 16.
May be another idea is to create 2nd version for the
struct ip_vs_sync_conn to support more features.

Regards

--
Julian Anastasov <ja@ssi.bg>
