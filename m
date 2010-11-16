From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v5 PATCH 0/7] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Tue, 16 Nov 2010 23:17:22 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011162316020.1627@ja.ssi.bg>
References: <201011162032.10807.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011162032.10807.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, Daniel Lezcano <daniel.lezcano@free.fr>, hans@schillstrom.com


 	Hello,

On Tue, 16 Nov 2010, Hans Schillstrom wrote:

> This patch series adds/(updates) the following functionality
> in the synchronization between master and backup daemons.
>
> - IPv6
> - Persistence Engine
> - Firewall marks transferred
> - Time-outs transferred.
> - Flag field increased to 32 bits.

 	v5 looks ok to me with the padding before current entry.

Regards

--
Julian Anastasov <ja@ssi.bg>
