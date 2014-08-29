From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs,v4 19/20] ipvs: use the new dest addr family field
Date: Fri, 29 Aug 2014 13:32:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408291259510.4876@ja.home.ssi.bg>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com> <1409301549-5284-20-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1409301549-5284-20-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Fri, 29 Aug 2014, Alex Gartrell wrote:

> From: Julian Anastasov <ja@ssi.bg>
> 
> Use the new address family field cp->daf when printing
> cp->daddr in logs or connection listing.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

...

> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -27,6 +27,7 @@
>  
>  #include <linux/interrupt.h>
>  #include <linux/in.h>
> +#include <linux/inet.h>
>  #include <linux/net.h>
>  #include <linux/kernel.h>
>  #include <linux/module.h>
> @@ -77,6 +78,13 @@ static unsigned int ip_vs_conn_rnd __read_mostly;
>  #define CT_LOCKARRAY_SIZE  (1<<CT_LOCKARRAY_BITS)
>  #define CT_LOCKARRAY_MASK  (CT_LOCKARRAY_SIZE-1)
>  
> +/* We need an addrstrlen that works with or without v6 */
> +#ifdef CONFIG_IP_VS_IPV6
> +#define IP_VS_ADDRSTRLEN INET6_ADDRSTRLEN
> +#else
> +#define IP_VS_ADDRSTRLEN INET_ADDRSTRLEN
> +#endif

	Thanks! Note that for v4 we use 8+1 (hex).
All other patches look ok. It is early to ack them,
right? We need to post them again at the right time.
I hope "ipvs: properly declare tunnel encapsulation"
will be moved further soon.

	For now we have to find a way to support sync
protocol and to update ipvsadm.

Regards

--
Julian Anastasov <ja@ssi.bg>
