From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/12] ipvs: optimize dst usage for real server
Date: Wed, 06 Mar 2013 15:18:10 -0500 (EST)
Message-ID: <20130306.151810.1494132480233578627.davem@davemloft.net>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg>
	<1362559342-18784-7-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1362559342-18784-7-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Wed,  6 Mar 2013 10:42:16 +0200

> 	Currently when forwarding requests to real servers
> we use dst_lock and atomic operations when cloning the
> dst_cache value. As the dst_cache value does not change
> most of the time it is better to use RCU and to lock
> dst_lock only when we need to replace the obsoleted dst.
> For this to work we keep dst_cache in new structure protected
> by RCU. For packets to remote real servers we will use noref
> version of dst_cache, it will be valid while we are in RCU
> read-side critical section because now dst_release for replaced
> dsts will be invoked after the grace period. NAT-ed packets
> via loopback that are not sent but are passed to local stack
> with NF_ACCEPT need a dst clone (skb_dst_force).
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

It think it's much cleaner to have the callers of route lookups do
skb_set_dst_noref().

Then you don't need any new interfaces, and you therefore don't need
to expose bits of the noref implementation and semantics at all.
