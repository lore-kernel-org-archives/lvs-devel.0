From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Move userspace definitions to
 include/linux/ip_vs.h
Date: Thu, 31 Jul 2008 20:45:44 -0700 (PDT)
Message-ID: <20080731.204544.241976724.davem@davemloft.net>
References: <f4845fc0807240446k224215cn7aee7f57a0fa9100@mail.gmail.com>
	<1216900716-4448-1-git-send-email-juliusv@google.com>
	<20080731020926.GA16274@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080731020926.GA16274@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, juliusv@google.com, kaber@trash.net, vbusam@google.com

From: Simon Horman <horms@verge.net.au>
Date: Thu, 31 Jul 2008 12:09:28 +1000

> Current versions of ipvsadm include "/usr/src/linux/include/net/ip_vs.h"
> directly. This file also contains kernel-only definitions. Normally, public
> definitions should live in include/linux, so this patch moves the
> definitions shared with userspace to a new file, "include/linux/ip_vs.h".
> 
> This also removes the unused NFC_IPVS_PROPERTY bitmask, which was once
> used to point into skb->nfcache.
> 
> To make old ipvsadms still compile with this, the old header file includes
> the new one.
> 
> Thanks to Dave Miller and Horms for noting/adding the missing Kbuild entry
> for the new header file.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks everyone.
