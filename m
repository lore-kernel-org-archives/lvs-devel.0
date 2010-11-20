From: Simon Horman <horms@verge.net.au>
Subject: Re: [*v6 PATCH 0/8] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Sun, 21 Nov 2010 07:07:09 +0900
Message-ID: <20101120220709.GN3914@verge.net.au>
References: <201011191424.56351.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1011192220060.1670@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011192220060.1670@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, Daniel Lezcano <daniel.lezcano@free.fr>, Hans Schillstrom <hans@schillstrom.com>

On Fri, Nov 19, 2010 at 10:22:40PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 19 Nov 2010, Hans Schillstrom wrote:
> 
> >This patch series adds/(updates) the following functionality
> >in the synchronization between master and backup daemons.
> >
> >- IPv6
> >- Persistence Engine
> >- Firewall marks transferred
> >- Time-outs transferred.
> >- Flag field increased to 32 bits.
> 
> >*v6
> >Patch 4 Handling scheduling errors, was forgotten it has also been rewritten.
> >see comments in that patch
> 
> 	v6 looks ok to me, thanks!

These look good to me too.
Julian, can I add acked-by you?

