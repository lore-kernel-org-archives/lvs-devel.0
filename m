From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next 0/2] ipvs: minor clean ups flagged by sparse
Date: Mon, 22 Apr 2013 13:07:02 +0900
Message-ID: <20130422040702.GL15680@verge.net.au>
References: <1366336315-25823-1-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304201218001.1593@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304201218001.1593@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Sat, Apr 20, 2013 at 12:19:36PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 19 Apr 2013, Simon Horman wrote:
> 
> > Hi,
> > 
> > this short series cleans up two minor problems flagged by sparse,
> > in both cases shadowed variables.
> > 
> > [PATCH 1/2] ipvs: Avoid shadowing net variable in ip_vs_leave()
> > [PATCH 2/2] ipvs: Use min3() in ip_vs_dbg_callid()
> 
> 	Both look good to me. In case you wait for ack,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I was waiting.
I have now queued these up in ipvs-next.
