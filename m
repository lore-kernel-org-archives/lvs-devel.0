From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] lvs sctp protocol handler is incorrectly invoked ip_vs_app_pkt_out
Date: Fri, 09 Jul 2010 17:29:56 +0200
Message-ID: <4C374074.8000103@trash.net>
References: <AANLkTikS9SSVT5soWZYmzxeJkR5vO__cuedk7ZgmTx5y@mail.gmail.com> <20100708121319.GC17985@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100708121319.GC17985@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: xiaoyu Du <tingsrain@gmail.com>, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, NetDev <netdev@vger.kernel.org>

Am 08.07.2010 14:13, schrieb Simon Horman:
> On Thu, Jul 08, 2010 at 09:55:04AM +0800, xiaoyu Du wrote:
>> lvs sctp protocol handler is incorrectly invoked ip_vs_app_pkt_out
>> Since there's no sctp helpers at present, it does the same thing as
>> ip_vs_app_pkt_in.
>>
>> Signed-off-by: Xiaoyu Du <tingsrain@gmail.com>
> 
> Thanks Xiaoyu.
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Patrick, please consider applying this.
> nf-next should be sufficient, as according
> to Xiaoyu there aren't actually helpers
> that exercise this code at the moment.

Applied, thanks.

