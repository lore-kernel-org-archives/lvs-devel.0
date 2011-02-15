From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fix timer in get_curr_sync_buff
Date: Wed, 16 Feb 2011 07:33:38 +0900
Message-ID: <20110215223338.GQ8703@verge.net.au>
References: <alpine.LFD.2.00.1102090214460.3494@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1102090214460.3494@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Tinggong Wang <wangtinggong@gmail.com>

On Wed, Feb 09, 2011 at 02:21:59AM +0200, Julian Anastasov wrote:
> 
> From: Tinggong Wang <wangtinggong@gmail.com>
> 
> 	Fix get_curr_sync_buff to keep buffer for 2 seconds
> as intended, not just for the current jiffie. By this way
> we will sync more connection structures with single packet.
> 
> Signed-off-by: Tinggong Wang <wangtinggong@gmail.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	Patch is against lvs-test-2.6 from 09-FEB-2011
> but should apply cleanly to net-next.

Thanks, I have pushed this change into the master branch of lvs-test-2.6.
I am waiting for one or two more patches to settle down before
sending my next pull request to Patrick.

