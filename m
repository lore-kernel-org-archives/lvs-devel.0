From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Please pull updates for IPVS
Date: Thu, 18 Sep 2008 14:44:28 -0700 (PDT)
Message-ID: <20080918.144428.138835100.davem@davemloft.net>
References: <20080917002146.GC15750@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080917002146.GC15750@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, brian.haley@hp.com, sven.wegener@stealer.net, juliusv@google.com, vbusam@google.com, wensong@linux-vs.org, ja@ssi.bg

From: Simon Horman <horms@verge.net.au>
Date: Wed, 17 Sep 2008 10:21:48 +1000

> the following are several cleanup patches, mainly resulting from
> the IPv6 merge. The "ipvs: supply a valid 0 address to ip_vs_conn_new()"
> change appears to be a fix for a regression caused by that merge,
> though I don't believe that anyone has observed it causing a problem.
> 
> The following changes are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git lvs-next-2.6
> 
> They should apply cleanly to net-next-2.6, which I pulled and merged this
> morning.

Pulled, thanks a lot Simon.
