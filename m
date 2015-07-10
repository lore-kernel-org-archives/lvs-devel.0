From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs] ipvs: call skb_sender_cpu_clear
Date: Fri, 10 Jul 2015 15:18:40 +0900
Message-ID: <20150710061814.GA1656@verge.net.au>
References: <1436429727-6527-1-git-send-email-ja@ssi.bg>
 <20150709085037.GA31426@verge.net.au>
 <alpine.LFD.2.11.1507092138370.1682@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1507092138370.1682@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Jul 09, 2015 at 09:43:39PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 9 Jul 2015, Simon Horman wrote:
> 
> > On Thu, Jul 09, 2015 at 11:15:27AM +0300, Julian Anastasov wrote:
> > > Reset XPS's sender_cpu on forwarding.
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > ---
> > >  net/netfilter/ipvs/ip_vs_xmit.c | 6 ++++++
> > >  1 file changed, 6 insertions(+)
> > > 
> > >  I see similar patches for other forwarding places...
> > > that is the reason for this patch.
> > 
> > Am I right in thinking this is not a bug fix?
> 
> 	I saw Eric fixes for sender_cpu. Here are
> some references:
> 
> - from today @netdev, targets net tree:
> bridge: fix potential crash in __netdev_pick_tx()
> 
> - this commit explains the problem:
> commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")

Thanks, I have queued this up in the ipvs tree with

Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")

