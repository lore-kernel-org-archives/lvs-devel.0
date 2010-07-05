From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipvs: Kconfig cleanup
Date: Mon, 05 Jul 2010 10:43:04 +0200
Message-ID: <4C319B18.10409@trash.net>
References: <1278102728-20217-1-git-send-email-mmarek@suse.cz> <20100704070516.GA9437@verge.net.au> <20100704071347.GB9437@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100704071347.GB9437@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: Michal Marek <mmarek@suse.cz>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, linux-kernel@vger.kernel.org

Simon Horman wrote:
> [ Added Patrick McHardy to CC ]
>
> On Sun, Jul 04, 2010 at 04:05:16PM +0900, Simon Horman wrote:
>   
>> On Fri, Jul 02, 2010 at 10:32:08PM +0200, Michal Marek wrote:
>>     
>>> IP_VS_PROTO_AH_ESP should be set iff either of IP_VS_PROTO_{AH,ESP} is
>>> selected. Express this with standard kconfig syntax.
>>>
>>> Signed-off-by: Michal Marek <mmarek@suse.cz>
>>>       
>> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
