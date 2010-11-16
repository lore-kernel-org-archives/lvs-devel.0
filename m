From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v5 PATCH 0/7] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Wed, 17 Nov 2010 00:40:54 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011170039180.2222@ja.ssi.bg>
References: <201011162032.10807.hans.schillstrom@ericsson.com> <20101116214843.GE2647@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101116214843.GE2647@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, Daniel Lezcano <daniel.lezcano@free.fr>, hans@schillstrom.com


 	Hello,

On Wed, 17 Nov 2010, Simon Horman wrote:

> Hi Hans,
>
> thanks. I can apply the patches cleanly this time.
> Sorry about yesterday's mess.
>
> I have looked over the patches and they seem good to me.
> Julian, can you ack the patches that you are ok with pushing?
> Perhaps all of them?

 	Yes, v5 looks ok

> Also, some of the changes look like they might be stable material.
> Especially "IPVS: Split ports[3] into src_port and dst_port" and
> "IPVS: skb defrag in L7 helpers". Any thoughts?

 	Agreed.

Regards

--
Julian Anastasov <ja@ssi.bg>
