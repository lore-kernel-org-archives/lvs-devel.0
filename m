From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH V4 0/7] ipvs: IPv6 fragment handling for IPVS
Date: Fri, 28 Sep 2012 20:21:44 +0200 (CEST)
Message-ID: <1jj3ert.72366b742299319232fdb641d38cb87b@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jesper Dangaard Brouer <brouer@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, davem@davemloft.net
Cc: lvs-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

Hello
>Subject: [PATCH V4 0/7] ipvs: IPv6 fragment handling for IPVS
>
>The following patch set implement IPv6 fragment handling for IPVS.

I've been running this patch set for a while now I seems to work well.

Netns tests with 4k nets ns have passed without problems (nothing left on loopback)

All tcp/udp fragment test - OK
sctp  didn't pass but that is not related to IPVS.
esp/ah  not affected by this patch, basic tests works fine.
ipvs sync (backup)  - OK

IPv4 DR, Tunnel, NAT - OK
IPv6 DR, Tunnel OK  
IPv6 NAT and Patrick's IPv6 NAT seems to work, however SIP or sipp doesn''t like IPv6 NAT yet

ICMPv6 - "packet to big" works except for
pmtu when using esp/ah, but that didn't work without the patch set either. 

Performance: No noticeable effects

My recommendation is that this patch set OK for inclusion in 3.7 

Thanks for a great work Jesper.

All seven patches:
Acked-by: Hans Schillstrom <hans@schillstrom.com>

Regards
Hans 

