From: Patrick McHardy <kaber@trash.net>
Subject: Re: [GIT PULL nf-next-2.6 v2] IPVS build fixes and clean-ups
Date: Tue, 01 Feb 2011 14:24:11 +0100
Message-ID: <4D48097B.9000406@trash.net>
References: <1296554868-17002-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1296554868-17002-1-git-send-email-horms@verge.net.au>
Sender: linux-next-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Hans Schillstrom <hans@schillstrom.com>

On 01.02.2011 11:07, Simon Horman wrote:
> This short patch series addresses two linux-next build problems
> raised by Randy Dunlap:
> 
> * net/netfilter/ipvs/ip_vs_core.c:1891: warning: format '%lu' expects type 'long unsigned int', but argument 2 has type 'unsigned int'
> * ERROR: "unregister_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko]
>   ERROR: "register_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!
> * WARNING: net/netfilter/ipvs/ip_vs.o(.init.text+0x161): Section mismatch in reference from the function init_module() to the function .exit.text:ip_vs_sync_cleanup()
> 
> The remainder of the changsets are cleanups that I noticed along the way.
> 
> The changes are available at
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
> 
> They are currently compile-tested only.

Just to avoid any confusion, do you want me to pull these patches
already?
