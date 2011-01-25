From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Tue, 25 Jan 2011 23:09:35 +1000
Message-ID: <20110125130933.GA2841@verge.net.au>
References: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com>
 <20110125050535.GB7183@verge.net.au>
 <4D3EA526.5030704@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D3EA526.5030704@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: Changli Gao <xiaosuo@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Tue, Jan 25, 2011 at 11:25:42AM +0100, Patrick McHardy wrote:
> On 25.01.2011 06:05, Simon Horman wrote:
> > On Tue, Jan 25, 2011 at 12:40:18PM +0800, Changli Gao wrote:
> >> Fix compiler warnings when IP_VS_DBG() isn't defined.
> >>
> >> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > 
> > Thanks, I will queue this up for when nf-next-2.6 is open again.
> 
> It's already open.
> 

Hi Patrick,

I'm a little unsure how you would like me to differentiate
between fixes for 2.6.38 - e.g. my previous two pull requests.
And patches intended for 2.6.39.

In any case I will send a pull request that includes
Changli's change against nf-next-2.6.
