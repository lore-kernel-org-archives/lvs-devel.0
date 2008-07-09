From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] IPVS: Move userspace definitions to include/linux/ip_vs.h
Date: Wed, 9 Jul 2008 13:24:35 +0200
Message-ID: <f4845fc0807090424lc592889o7f9626385eb83d0f@mail.gmail.com>
References: <1215527396-15135-1-git-send-email-juliusv@google.com>
	 <20080709011110.GA600@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1215602678; bh=DbU7EUCe0+1X4C2pZ0+3lheMC8k=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=YAzCTCO33UMa+xT2wHLAfO0kqyiJ8nKB
	dQ0tRBmu9sTWjWkIVVHI1u09JrtBWg8gguSlpcL38t3bmpZ62yj9WA==
In-Reply-To: <20080709011110.GA600@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Jul 9, 2008, Simon Horman wrote:
> Firstly these changes look fine: Acked

Thanks!

> Secondly, What are your plans for ipvsadm? Do you think that a fork will
> be neccessasry to utilise the netlink interface? Or even a new tool with
> a completely new name?

Vince is converting the latest available ipvsadm version to support
the Netlink interface and IPv6 features. So ideally, there will be no
fork or new tool, just a new version. We are keeping the old sockopt
interface in the kernel for userspace backwards compatibility, so
people will only need the new ipvsadm version if they need the new
features. The way Vince is currently implementing it, the new ipvsadm
will probably also keep supporting the sockopt interface as a
fallback, which would mean full backwards compatibility in both
directions.

As for the kernel part, I'm planning to post the Netlink interface
implementation (with minimal stubs for IPv6 support) sometime the next
days.

Julius

-- 
Google Switzerland GmbH
