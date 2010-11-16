From: Simon Horman <horms@verge.net.au>
Subject: Re: [*v5 PATCH 0/7] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Wed, 17 Nov 2010 06:48:43 +0900
Message-ID: <20101116214843.GE2647@verge.net.au>
References: <201011162032.10807.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201011162032.10807.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, Daniel Lezcano <daniel.lezcano@free.fr>, hans@schillstrom.com

On Tue, Nov 16, 2010 at 08:32:10PM +0100, Hans Schillstrom wrote:
> This patch series adds/(updates) the following functionality
> in the synchronization between master and backup daemons.
> 
>  - IPv6
>  - Persistence Engine
>  - Firewall marks transferred
>  - Time-outs transferred.
>  - Flag field increased to 32 bits.
> 
> Note:
> This patch set is build upon lvs-next-2.6
> i.e. last patch in master was "ipvs: allow transmit of GRO aggregated skbs"

Hi Hans,

thanks. I can apply the patches cleanly this time.
Sorry about yesterday's mess.

I have looked over the patches and they seem good to me.
Julian, can you ack the patches that you are ok with pushing?
Perhaps all of them?

Also, some of the changes look like they might be stable material.
Especially "IPVS: Split ports[3] into src_port and dst_port" and
"IPVS: skb defrag in L7 helpers". Any thoughts?

