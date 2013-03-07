From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 06/12] ipvs: optimize dst usage for real
 server
Date: Thu, 7 Mar 2013 02:14:00 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1303070119020.2312@ja.ssi.bg>
References: <1362559342-18784-7-git-send-email-ja@ssi.bg> <20130306.151810.1494132480233578627.davem@davemloft.net> <alpine.LFD.2.00.1303062321230.1899@ja.ssi.bg> <20130306.170637.1142655516995808574.davem@davemloft.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20130306.170637.1142655516995808574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Wed, 6 Mar 2013, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed, 6 Mar 2013 23:58:09 +0200 (EET)
> 
> > 	There are two choices: __ip_vs_get_out_rt
> > to return refdst as implemented in this patchset or
> > to return dst with additional 'bool *noref' argument,
> > so that caller can decide between skb_dst_set or
> > skb_set_dst_noref. Then may be we will need just
> > a new skb_dst_set_noref_{always,force} func that will
> > contain the old skb_set_dst_noref code, i.e. without
> > dst_hold? Not sure which variant sounds better.
> 
> Both variants are starting to sound equally ugly :-)
> 
> Let me ask about this situation in another way.
> 
> IP input route lookup clients handle this transparently,
> even for routes with next-hop exceptions and nocache
> routes, by passing the SKB into the lookup function and
> there it will sort out whether noref is actually possible.
> 
> Is there a reason that IPVS's route lookup architecture
> can't work this way too?

	May be it is possible, eg. by adding more
arguments to __ip_vs_get_out_rt and moving all dst
checks and icmp_send there. But there are some dst
checks specific to the forwarding method, so I'm not
sure in the end result yet.

	For IPVS, noref is always possible because the
dst_cache var holds reference, even for the NOCACHE case
which is more likely to occur. So, some new variant of
skb_dst_set_noref that supports NOCACHE without dst_hold
is still needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
