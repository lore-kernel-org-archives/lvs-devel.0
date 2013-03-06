From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 06/12] ipvs: optimize dst usage for real
 server
Date: Wed, 6 Mar 2013 23:58:09 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303062321230.1899@ja.ssi.bg>
References: <1362559342-18784-1-git-send-email-ja@ssi.bg> <1362559342-18784-7-git-send-email-ja@ssi.bg> <20130306.151810.1494132480233578627.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130306.151810.1494132480233578627.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Wed, 6 Mar 2013, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed,  6 Mar 2013 10:42:16 +0200
> 
> > 	Currently when forwarding requests to real servers
> > we use dst_lock and atomic operations when cloning the
> > dst_cache value. As the dst_cache value does not change
> > most of the time it is better to use RCU and to lock
> > dst_lock only when we need to replace the obsoleted dst.
> > For this to work we keep dst_cache in new structure protected
> > by RCU. For packets to remote real servers we will use noref
> > version of dst_cache, it will be valid while we are in RCU
> > read-side critical section because now dst_release for replaced
> > dsts will be invoked after the grace period. NAT-ed packets
> > via loopback that are not sent but are passed to local stack
> > with NF_ACCEPT need a dst clone (skb_dst_force).
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> It think it's much cleaner to have the callers of route lookups do
> skb_set_dst_noref().

	This was my first thought but commit 27b75c95f1
(net: avoid RCU for NOCACHE dst) uses dst_hold for
DST_NOCACHE dsts. IPVS wants to cache DST_NOCACHE entries
(due to known-NH reasons) and later to use them for
noref dsts...

	Also, in the IPVS case we can not set skb_dst
at the time when route is looked up because due to
MTU and other checks we can fail, functions like
icmp_send() will need the original skb_dst in
such case.

	There are two choices: __ip_vs_get_out_rt
to return refdst as implemented in this patchset or
to return dst with additional 'bool *noref' argument,
so that caller can decide between skb_dst_set or
skb_set_dst_noref. Then may be we will need just
a new skb_dst_set_noref_{always,force} func that will
contain the old skb_set_dst_noref code, i.e. without
dst_hold? Not sure which variant sounds better.

> Then you don't need any new interfaces, and you therefore don't need
> to expose bits of the noref implementation and semantics at all.

Regards

--
Julian Anastasov <ja@ssi.bg>
