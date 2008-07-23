From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Move userspace definitions to
 include/linux/ip_vs.h
Date: Wed, 23 Jul 2008 16:42:15 -0700 (PDT)
Message-ID: <20080723.164215.101337333.davem@davemloft.net>
References: <20080722003755.GA7962@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20080722003755.GA7962@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, juliusv@google.com, kaber@trash.net, vbusam@google.com

From: Simon Horman <horms@verge.net.au>
Date: Tue, 22 Jul 2008 10:37:57 +1000

> From: Julius Volz <juliusv@google.com>
> 
> Current versions of ipvsadm include "/usr/src/linux/include/net/ip_vs.h"
> directly. This file also contains kernel-only definitions. Normally, public
> definitions should live in include/linux, so this patch moves the
> definitions shared with userspace to a new file, "include/linux/ip_vs.h".
> 
> To make old ipvsadms still compile with this, the old header file includes
> the new one.
> 
> The motivation for this cleanup is the planned Netlink interface for IPVS.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>
> Acked-by: Simon Horman <horms@verge.net.au>

Userland exported headers need to have an entry in include/linux/Kbuild

Since this linux/ip_vs.h file is new, a new entry needs to be added there.

Thanks.
