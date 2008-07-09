From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Move userspace definitions to
	include/linux/ip_vs.h
Date: Wed, 9 Jul 2008 11:11:12 +1000
Message-ID: <20080709011110.GA600@verge.net.au>
References: <1215527396-15135-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1215527396-15135-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Tue, Jul 08, 2008 at 04:29:56PM +0200, Julius Volz wrote:
> Current versions of ipvsadm include "/usr/src/linux/include/net/ip_vs.h"
> directly. This file also contains kernel-only definitions. Normally, public
> definitions should live in include/linux, so this patch moves the
> definitions shared with userspace to a new file, "include/linux/ip_vs.h".
> 
> To make old ipvsadms still compile with this, the old header file includes
> the new one.
> 
> The motivation for this cleanup is the planned Netlink interface for IPVS.

Hi Julius,

Firstly these changes look fine: Acked

Secondly, What are your plans for ipvsadm? Do you think that a fork will
be neccessasry to utilise the netlink interface? Or even a new tool with
a completely new name?

-- 
Horms

