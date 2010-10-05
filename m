From: David Miller <davem@davemloft.net>
Subject: Re: ipvs: Use frag walker helper in SCTP proto support.
Date: Tue, 05 Oct 2010 00:27:38 -0700 (PDT)
Message-ID: <20101005.002738.91349565.davem@davemloft.net>
References: <20101003.234601.232735559.davem@davemloft.net>
	<20101004075911.GB2359@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101004075911.GB2359@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net

From: Simon Horman <horms@verge.net.au>
Date: Mon, 4 Oct 2010 16:59:12 +0900

> On Sun, Oct 03, 2010 at 11:46:01PM -0700, David Miller wrote:
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Dave, I'm happy for this to go via your tree or Partick's.
> I don't believe it conflicts with any of the other changes
> that are pending.

I'll toss it into net-next-2.6, thanks for reviewing.
