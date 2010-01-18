From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: SCTP Tranport Load Balancing Support to IPVS
Date: Tue, 19 Jan 2010 12:21:48 +1300
Message-ID: <20100118232148.GB20302@verge.net.au>
References: <20100118175009.GA7812@mohan-laptop>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100118175009.GA7812@mohan-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mohan Reddy <mohanreddykv@gmail.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

On Mon, Jan 18, 2010 at 11:20:11PM +0530, Mohan Reddy wrote:
> This patch adds SCTP packet load balancing support to IPVS. This patch is written against linux-2.6.32.3 kernel. This has been written based on the SCTP FSM desribed in the RFC 4960. All the posibilities of chunks have been taken care. 
> 
> Once the IPVS receives an SCTP packet with INIT chunk we will create a 
> connection object and chooses a real and forward the packet based on the
> forwarding method. After creating the connection we will drive the FSM based 
> on the chunks(in this code they are called as events). The return packet from
> the server will be an INIT ACK chunck, then we will move the FSM state to
> IP_VS_S_INIT_ACK_SER. Like this all the chunks have next states. 
> 
> As all the packets are destined to the virtual server (VIP) we haven't handled
> multihomed endpoints.
> 
> 
> Signed-off-by : Venkata Mohan Reddy Koppula <mohanreddykv@gmail.com>
> 
> 
>   

Hi,

I haven't had time to review your patch properly yet.
But I have two minor comments.

Firstly, could you please base your work on Patrick McHardy's nf-next-2.6
tree or at least Dave Miller's the net-next-2.6 tree. At this stage it just
looks like you'll need to re-diff the patch.

[snip]

> diff -Npaur linux-2.6.32.3/net/netfilter/ipvs/Kconfig linux-2.6.32.3_new/net/netfilter/ipvs/Kconfig
> --- linux-2.6.32.3/net/netfilter/ipvs/Kconfig	2010-01-07 04:37:45.000000000 +0530
> +++ linux-2.6.32.3_new/net/netfilter/ipvs/Kconfig	2010-01-16 21:19:54.772760964 +0530
> @@ -100,6 +100,12 @@ config	IP_VS_PROTO_AH
>  	  This option enables support for load balancing AH (Authentication
>  	  Header) transport protocol. Say Y if unsure.
>  
> +config  IP_VS_PROTO_SCTP
> +	bool "SCTP load balancing support"

You need 

	select CRC32C

here.

> +	---help---
> +	  This option enables support for load balancing SCTP transport
> +	  protocol. Say Y if unsure.
> +
>  comment "IPVS scheduler"
>  
>  config	IP_VS_RR

[snip]
