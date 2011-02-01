From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [GIT PULL nf-next-2.6] IPVS build fixes and clean-ups
Date: Mon, 31 Jan 2011 16:50:09 -0800
Message-ID: <20110131165009.66999952.randy.dunlap@oracle.com>
References: <1296519255-10602-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1296519255-10602-1-git-send-email-horms@verge.net.au>
Sender: linux-next-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Hans Schillstrom <hans@schillstrom.com>, Patrick McHardy <kaber@trash.net>

On Tue,  1 Feb 2011 11:14:11 +1100 Simon Horman wrote:

> Hi,
> 
> This short patch series addresses two linux-next build problems
> raised by Randy Dunlap:
> 
> * net/netfilter/ipvs/ip_vs_core.c:1891: warning: format '%lu' expects type 'long unsigned int', but argument 2 has type 'unsigned int'
> * ERROR: "unregister_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko]
>   ERROR: "register_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!
> 
> The remainder of the changset is cleanups that I noticed along the way.

These 4 patches build successfully for me.
However, I do see these warnings (sorry I missed them earlier):

WARNING: net/netfilter/ipvs/ip_vs.o(.init.text+0x161): Section mismatch in reference from the function init_module() to the function .exit.text:ip_vs_sync_cleanup()
WARNING: net/netfilter/ipvs/ip_vs.o(.init.text+0x161): Section mismatch in reference from the function init_module() to the function .exit.text:ip_vs_sync_cleanup()


Thanks for the patch series.

> The changes are available at
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
> 
> They are currently compile-tested only.
> 
>  include/net/ip_vs.h              |    2 --
>  net/netfilter/ipvs/ip_vs_core.c  |    2 +-
>  net/netfilter/ipvs/ip_vs_ctl.c   |   17 +++++++++--------
>  net/netfilter/ipvs/ip_vs_lblc.c  |   20 ++++++++++----------
>  net/netfilter/ipvs/ip_vs_lblcr.c |   20 ++++++++++----------
>  5 files changed, 30 insertions(+), 31 deletions(-)


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
