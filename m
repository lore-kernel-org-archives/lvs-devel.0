From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 19:23:25 +0200
Message-ID: <48500A0D.5020304@trash.net>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> Hi,
>
> This patch series adds first experimental IPv6 support to IPVS. I have
> already posted it to the LVS mailing list as one huge patch a while ago,
> so here's the split-up version, although it is still very big. I don't see
> an easy way of breaking up the series into truly independent chunks though,
> since most of it seems very interdependent. I'm still a kernel newbie, so
> any advice is welcome :)
>   

I briefly looked over the patches I didn't comment on.
I think there's too much duplication everywhere, a lot of
them look like they could avoid almost all duplication by
handling differences at a higher layer or simply sharing
the code (like hashing).


