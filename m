From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch nf-next-2.6] IPVS: one-packet scheduling
Date: Tue, 22 Jun 2010 08:08:01 +0200
Message-ID: <4C205341.4020904@trash.net>
References: <20100622021405.GA19071@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100622021405.GA19071@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
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
>
> Signed-off-by: Nick Chalk <nick@loadbalancer.org>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> --- 
> U
> Up-port of http://www.ssi.bg/~ja/tmp/ops-2.4.32-1.diff
>
> Patrick, you asked me to repost this when nf-next was open again.
> It seems to be open now.

Yes, its open again. Applied, thanks Simon.

