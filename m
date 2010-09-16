From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] net/netfilter/ipvs: Eliminate memory leak
Date: Thu, 16 Sep 2010 07:42:43 +0200
Message-ID: <4C91AE53.2050901@trash.net>
References: <Pine.LNX.4.64.1008241639300.15172@ask.diku.dk>	<20100825013443.GC7237@verge.net.au> <20100825.163812.242150096.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100825.163812.242150096.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, julia@diku.dk, wensong@linux-vs.org, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 26.08.2010 01:38, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Wed, 25 Aug 2010 10:34:43 +0900
> 
>> On Tue, Aug 24, 2010 at 04:39:49PM +0200, Julia Lawall wrote:
>>> Signed-off-by: Julia Lawall <julia@diku.dk>
>>
>> Thanks Julia, that looks good to me.
>>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
>>
>> Patrick, I guess that this should go through nf-next-2.6.
> 
> Since Patrick appears to be offline, I'll apply this directly so
> he has less to do when he comes back online :)

Thanks Dave. I should be done catching up by tonight and will start
taking care of IPVS patches again.
