From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/18] export sysctl symbols needed by ip_vs_sync
Date: Sun, 06 May 2012 17:19:38 -0400 (EDT)
Message-ID: <20120506.171938.850582286130598907.davem@davemloft.net>
References: <1335939762-1912-1-git-send-email-horms@verge.net.au>
	<1335939762-1912-19-git-send-email-horms@verge.net.au>
	<20120506205412.GA22406@1984>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120506205412.GA22406@1984>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: pablo@netfilter.org
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg, hans.schillstrom@ericsson.com, brouer@redhat.com

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 6 May 2012 22:54:12 +0200

> Hi David,
> 
> The IPVS people needs this patch for net-next to allow to tune the
> socket buffer for ipvs_sync (the state synchronization that they do
> from kernel-space). This exports sysctl_wmem_max and sysctl_rmem_max
> living in net/core/sock.c. So far, they've been using global socket
> tuning to make them bigger (this avoids overruning the socket under
> high peak of state-change synchronization).
> 
> I think this is out of my scope (since it's out of the netfilter
> tree).
> 
> Would you acknowledge it, please?

Feel free to merge it via your tree:

Acked-by: David S. Miller <davem@davemloft.net>
