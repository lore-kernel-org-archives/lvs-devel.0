From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Move userspace definitions to
	include/linux/ip_vs.h
Date: Thu, 24 Jul 2008 10:20:59 +1000
Message-ID: <20080724002057.GA3032@verge.net.au>
References: <20080722003755.GA7962@verge.net.au> <20080723.164215.101337333.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080723.164215.101337333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, juliusv@google.com, kaber@trash.net, vbusam@google.com

On Wed, Jul 23, 2008 at 04:42:15PM -0700, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Tue, 22 Jul 2008 10:37:57 +1000
> 
> > From: Julius Volz <juliusv@google.com>
> > 
> > Current versions of ipvsadm include "/usr/src/linux/include/net/ip_vs.h"
> > directly. This file also contains kernel-only definitions. Normally, public
> > definitions should live in include/linux, so this patch moves the
> > definitions shared with userspace to a new file, "include/linux/ip_vs.h".
> > 
> > To make old ipvsadms still compile with this, the old header file includes
> > the new one.
> > 
> > The motivation for this cleanup is the planned Netlink interface for IPVS.
> > 
> > Signed-off-by: Julius Volz <juliusv@google.com>
> > Acked-by: Simon Horman <horms@verge.net.au>
> 
> Userland exported headers need to have an entry in include/linux/Kbuild
> 
> Since this linux/ip_vs.h file is new, a new entry needs to be added there.

Thanks, I wasn't aware of that.

Julius, I think this is the bit we are missing:

Index: net-next-2.6/include/linux/Kbuild
===================================================================
--- net-next-2.6.orig/include/linux/Kbuild	2008-07-24 10:15:52.000000000 +1000
+++ net-next-2.6/include/linux/Kbuild	2008-07-24 10:19:08.000000000 +1000
@@ -97,6 +97,7 @@ header-y += ioctl.h
 header-y += ip6_tunnel.h
 header-y += ipmi_msgdefs.h
 header-y += ipsec.h
+header-y += ip_vs.h
 header-y += ipx.h
 header-y += irda.h
 header-y += iso_fs.h
