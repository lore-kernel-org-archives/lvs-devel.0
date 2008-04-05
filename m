From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs in
	preparation for IPv6 support
Date: Sat, 5 Apr 2008 10:07:09 +0900
Message-ID: <20080405010707.GB27827@verge.net.au>
References: <f4845fc0804040340x5e93754crcd680d26fd8982f7@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0804040340x5e93754crcd680d26fd8982f7@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Fri, Apr 04, 2008 at 12:40:36PM +0200, Julius Volz wrote:
> Hi,
> 
> This patch moves IPVS from net/ipv4/ipvs to net/netfilter/ipvs, as
> discussed earlier with Horms and Patrick McHardy. This is done as a
> preparation for later adding IPv6 functionality to IPVS. The patch is
> 600kb, so I uploaded it here:
> 
> http://www-user.tu-chemnitz.de/~volz/move_ipvs_to_netfilter.patch
> 
> --------------------------
> Description:
> Move IPVS from net/ipv4/ipvs to net/netfilter/ipvs as a preparation
> for adding IPv6 support to IPVS later on.
> 
> Signed-off-by: Julius R. Volz <juliusv@google.com>
> --------------------------
> 
> It applies to the current net-2.6 tree and IPVS is working after these
> changes. The patch also moves the IPVS menu options into the Netfilter
> menu subtree. Please let me know if that is ok or has to be changed
> (it seems ok to me, as IPVS depends on Netfilter).
> 
> Again, I'm pretty new to kernel development, so let me know of
> anything that can be done better.

Thanks, I've grabbed the patch and will review it ASAP.
I am going to be mostly offline for about 5 days as I am moving.
So I apologise in advance for being a bit undresponsive during that time.

-- 
Horms

