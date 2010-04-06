From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: replace sprintf to snprintf to avoid stack
 buffer overflow
Date: Tue, 6 Apr 2010 13:22:49 +1000
Message-ID: <20100406032248.GF30359@verge.net.au>
References: <20100406025020.GA2741@localhost.localdomain>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100406025020.GA2741@localhost.localdomain>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wzt.wzt@gmail.com
Cc: linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>

On Tue, Apr 06, 2010 at 10:50:20AM +0800, wzt.wzt@gmail.com wrote:
> IPVS not check the length of pp->name, use sprintf will cause stack buffer overflow.
> struct ip_vs_protocol{} declare name as char *, if register a protocol as:
> struct ip_vs_protocol ip_vs_test = {
>         .name =			"aaaaaaaa....128...aaa",
> 	.debug_packet =         ip_vs_tcpudp_debug_packet,
> };
> 
> when called ip_vs_tcpudp_debug_packet(), sprintf(buf, "%s TRUNCATED", pp->name); 
> will cause stack buffer overflow.
>
> Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

I think that the simple answer is, don't do that.
But your patch seems entirely reasonable to me.

Acked-by: Simon Horman <horms@verge.net.au>

Patrick, please consider merging this.

