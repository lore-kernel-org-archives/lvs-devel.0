From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 09/13] [RFC 09/13] IPVS: Add persistence engine data to
 /proc/net/ip_vs_conn
Date: Fri, 6 Aug 2010 10:45:03 +0900
Message-ID: <20100806014503.GC12311@verge.net.au>
References: <20100805114755.118303531@vergenet.net>
 <20100805115241.289541021@vergenet.net>
 <alpine.LSU.2.01.1008051446060.13201@obet.zrqbmnf.qr>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.01.1008051446060.13201@obet.zrqbmnf.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Thu, Aug 05, 2010 at 02:46:22PM +0200, Jan Engelhardt wrote:
> On Thursday 2010-08-05 13:48, Simon Horman wrote:
> 
> >This shouldn't break compatibility with userspace as the new data
> >is at the end of the line.
> >
> >I have confirmed that this doesn't break ipvsadm, the main (only?)
> >user-space user of this data.
> 
> Wouldn't it be best if this be done over Netlink?

I'm happy to add code to do that over netlink,
though it does seem to be overkill to me.

