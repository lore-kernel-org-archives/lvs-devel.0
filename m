From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] IPVS: one-packet scheduling
Date: Thu, 20 May 2010 17:17:40 +0200
Message-ID: <4BF55294.9030908@trash.net>
References: <20100519031408.GC18534@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100519031408.GC18534@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Simon Horman wrote:
> From: Nick Chalk <nick@loadbalancer.org>
> 
> IPVS: one-packet scheduling
> 
> Allow one-packet scheduling for UDP connections. When the fwmark-based or
> normal virtual service is marked with '-o' or '--ops' options all
> connections are created only to schedule one packet. Useful to schedule UDP
> packets from same client port to different real servers. Recommended with
> RR or WRR schedulers (the connections are not visible with ipvsadm -L).

I'm afraid its too late in this merge window for new features
since Dave has already sent his merge request to Linus.

Please resend once the net-next (and nf-next) tree opens up.
