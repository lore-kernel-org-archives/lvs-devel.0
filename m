From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs] ipvs: call skb_sender_cpu_clear
Date: Fri, 10 Jul 2015 09:46:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507100944380.1488@ja.home.ssi.bg>
References: <1436429727-6527-1-git-send-email-ja@ssi.bg> <20150709085037.GA31426@verge.net.au> <alpine.LFD.2.11.1507092138370.1682@ja.home.ssi.bg> <20150710061814.GA1656@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150710061814.GA1656@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Fri, 10 Jul 2015, Simon Horman wrote:

> On Thu, Jul 09, 2015 at 09:43:39PM +0300, Julian Anastasov wrote:
> > 
> > 	I saw Eric fixes for sender_cpu. Here are
> > some references:
> > 
> > - from today @netdev, targets net tree:
> > bridge: fix potential crash in __netdev_pick_tx()
> > 
> > - this commit explains the problem:
> > commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
> 
> Thanks, I have queued this up in the ipvs tree with
> 
> Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")

	Thanks, that looks correct.

Regards

--
Julian Anastasov <ja@ssi.bg>
