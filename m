From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Move userspace definitions to
	include/linux/ip_vs.h
Date: Wed, 9 Jul 2008 22:20:30 +1000
Message-ID: <20080709122029.GC7151@verge.net.au>
References: <1215527396-15135-1-git-send-email-juliusv@google.com> <20080709011110.GA600@verge.net.au> <f4845fc0807090424lc592889o7f9626385eb83d0f@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0807090424lc592889o7f9626385eb83d0f@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Jul 09, 2008 at 01:24:35PM +0200, Julius Volz wrote:
> On Wed, Jul 9, 2008, Simon Horman wrote:
> > Firstly these changes look fine: Acked
> 
> Thanks!
> 
> > Secondly, What are your plans for ipvsadm? Do you think that a fork will
> > be neccessasry to utilise the netlink interface? Or even a new tool with
> > a completely new name?
> 
> Vince is converting the latest available ipvsadm version to support
> the Netlink interface and IPv6 features. So ideally, there will be no
> fork or new tool, just a new version. We are keeping the old sockopt
> interface in the kernel for userspace backwards compatibility, so
> people will only need the new ipvsadm version if they need the new
> features. The way Vince is currently implementing it, the new ipvsadm
> will probably also keep supporting the sockopt interface as a
> fallback, which would mean full backwards compatibility in both
> directions.

That sounds great.

> As for the kernel part, I'm planning to post the Netlink interface
> implementation (with minimal stubs for IPv6 support) sometime the next
> days.

-- 
Horms

