From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [rfc 09/13] [RFC 09/13] IPVS: Add persistence engine data to
 /proc/net/ip_vs_conn
Date: Thu, 5 Aug 2010 14:46:22 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008051446060.13201@obet.zrqbmnf.qr>
References: <20100805114755.118303531@vergenet.net> <20100805115241.289541021@vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100805115241.289541021@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Thursday 2010-08-05 13:48, Simon Horman wrote:

>This shouldn't break compatibility with userspace as the new data
>is at the end of the line.
>
>I have confirmed that this doesn't break ipvsadm, the main (only?)
>user-space user of this data.

Wouldn't it be best if this be done over Netlink?


