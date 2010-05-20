From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] IPVS: one-packet scheduling
Date: Fri, 21 May 2010 07:31:42 +0900
Message-ID: <20100520223141.GH3444@verge.net.au>
References: <20100519031408.GC18534@verge.net.au>
 <4BF55294.9030908@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BF55294.9030908@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

On Thu, May 20, 2010 at 05:17:40PM +0200, Patrick McHardy wrote:
> Simon Horman wrote:
> > From: Nick Chalk <nick@loadbalancer.org>
> > 
> > IPVS: one-packet scheduling
> > 
> > Allow one-packet scheduling for UDP connections. When the fwmark-based or
> > normal virtual service is marked with '-o' or '--ops' options all
> > connections are created only to schedule one packet. Useful to schedule UDP
> > packets from same client port to different real servers. Recommended with
> > RR or WRR schedulers (the connections are not visible with ipvsadm -L).
> 
> I'm afraid its too late in this merge window for new features
> since Dave has already sent his merge request to Linus.
> 
> Please resend once the net-next (and nf-next) tree opens up.

Sure, will do.

