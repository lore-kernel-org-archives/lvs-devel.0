From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: ipvs: fix compiler warnings
Date: Tue, 25 Jan 2011 11:25:42 +0100
Message-ID: <4D3EA526.5030704@trash.net>
References: <1295930418-14980-1-git-send-email-xiaosuo@gmail.com> <20110125050535.GB7183@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20110125050535.GB7183@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Changli Gao <xiaosuo@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On 25.01.2011 06:05, Simon Horman wrote:
> On Tue, Jan 25, 2011 at 12:40:18PM +0800, Changli Gao wrote:
>> Fix compiler warnings when IP_VS_DBG() isn't defined.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Thanks, I will queue this up for when nf-next-2.6 is open again.

It's already open.
