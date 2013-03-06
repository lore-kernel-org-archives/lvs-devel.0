From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/12] ipvs: optimize dst usage for real server
Date: Wed, 06 Mar 2013 17:06:37 -0500 (EST)
Message-ID: <20130306.170637.1142655516995808574.davem@davemloft.net>
References: <1362559342-18784-7-git-send-email-ja@ssi.bg>
	<20130306.151810.1494132480233578627.davem@davemloft.net>
	<alpine.LFD.2.00.1303062321230.1899@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1303062321230.1899@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 6 Mar 2013 23:58:09 +0200 (EET)

> 	There are two choices: __ip_vs_get_out_rt
> to return refdst as implemented in this patchset or
> to return dst with additional 'bool *noref' argument,
> so that caller can decide between skb_dst_set or
> skb_set_dst_noref. Then may be we will need just
> a new skb_dst_set_noref_{always,force} func that will
> contain the old skb_set_dst_noref code, i.e. without
> dst_hold? Not sure which variant sounds better.

Both variants are starting to sound equally ugly :-)

Let me ask about this situation in another way.

IP input route lookup clients handle this transparently,
even for routes with next-hop exceptions and nocache
routes, by passing the SKB into the lookup function and
there it will sort out whether noref is actually possible.

Is there a reason that IPVS's route lookup architecture
can't work this way too?
