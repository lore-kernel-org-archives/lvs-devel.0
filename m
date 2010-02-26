From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] IPVS: ip_vs_lblcr: use list head
Date: Fri, 26 Feb 2010 06:59:00 +0100
Message-ID: <4B876324.6050802@trash.net>
References: <20100226030211.GB6111@verge.net.au> <20100225.215540.94527171.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100225.215540.94527171.davem@davemloft.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Fri, 26 Feb 2010 14:02:11 +1100
> 
>> Use list_head rather than a custom list implementation.
>>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Thanks for doing this, I'm sure Patrick will integrate this
> patch for you.
> 

Will do, I'll send another pull request tonight.
