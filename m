From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 0/2] IPVS: Add Generic Netlink configuration interface
Date: Tue, 22 Jul 2008 10:34:05 +1000
Message-ID: <20080722003403.GC9041@verge.net.au>
References: <1216645375-20410-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1216645375-20410-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

On Mon, Jul 21, 2008 at 03:02:53PM +0200, Julius Volz wrote:
> This is the second version of the Generic Netlink interface for
> IPVS. I integrated some comments from Thomas Graf, Patrick McHardy and
> Yoshifuji Hideaki and changed a few things myself. The interface should
> now follow existing Netlink conventions more closely and has been
> tested without problems.
> 
> The two patches add a Generic Netlink interface to IPVS while keeping
> the old get/setsockopt interface for userspace backwards compatibility.
> The motivation for this is to have a more extensible interface for
> future changes, such as the planned IPv6 support. ipvsadm is currently
> being extended to support the new interface and features.

I'm not an expert on netlink, but these patches are looking good to me.
Is the user-space portion available somewhere?

> The ip_vs.h header change depends on this patch I sent previously:
> "IPVS: Move userspace definitions to include/linux/ip_vs.h"
> (this one looked good to Horms, can it go in?)

Yes, it can. I'll repost it with an Ack.

-- 
Horms

