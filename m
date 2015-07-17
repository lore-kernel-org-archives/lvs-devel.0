From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ovf scheduler
Date: Fri, 17 Jul 2015 09:16:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507170912230.1587@ja.home.ssi.bg>
References: <CAA0i4Bp0n-PooNaUq=F7MgD2Ou8=hdA6w+B0te5tcWP4ODxTfw@mail.gmail.com> <alpine.LFD.2.11.1507132328500.1708@ja.home.ssi.bg> <CAA0i4Bph-Gw00+-kUovvvfSgEta6XEH2-hGtSnusuPNdro2nCA@mail.gmail.com> <alpine.LFD.2.11.1507142152450.1833@ja.home.ssi.bg>
 <CAA0i4Bo3w3msK9Tdn1T3BNa-ZyQ6mon=XeXFRkSfsWHRVEua=w@mail.gmail.com> <alpine.LFD.2.11.1507161044500.1681@ja.home.ssi.bg> <CAA0i4BrKP91wiFOWpPpmFP3L1ZdVCPTdDk6PkJrGYGPWkqpxxw@mail.gmail.com> <alpine.LFD.2.11.1507162119020.2164@ja.home.ssi.bg>
 <CAA0i4Bp6cXF9u9vSWoJkaG98KNro3FweW3t_Fp05TjqybW8vtA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAA0i4Bp6cXF9u9vSWoJkaG98KNro3FweW3t_Fp05TjqybW8vtA@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raducu Deaconu <rhadoo.io88@gmail.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Fri, 17 Jul 2015, Raducu Deaconu wrote:

> Hello,
> 
> I have done the corrections.
> 
> 
> Subject: [PATCH] Add ovf scheduler
> 
> Signed-off-by: Raducu Deaconu <rhadoo.io88@gmail.com>

	Thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, please apply the attached patch to -next
tree after adding the "ipvs: " prefix.

> ---
>  net/netfilter/ipvs/Kconfig     |   11 +++++
>  net/netfilter/ipvs/Makefile    |    1 +
>  net/netfilter/ipvs/ip_vs_ovf.c |   86
> ++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 98 insertions(+)
>  create mode 100644 net/netfilter/ipvs/ip_vs_ovf.c
> 
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index 3b6929d..b32fb0d 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -162,6 +162,17 @@ config  IP_VS_FO
>           If you want to compile it in kernel, say Y. To compile it as
> a
>           module, choose M here. If unsure, say N.
> 
> +config  IP_VS_OVF
> +       tristate "weighted overflow scheduling"
> +       ---help---
> +         The weighted overflow scheduling algorithm directs network
> +         connections to the server with the highest weight that is
> +         currently available and overflows to the next when active
> +         connections exceed the node's weight.
> +
> +         If you want to compile it in kernel, say Y. To compile it as a
> +         module, choose M here. If unsure, say N.
> +
>  config IP_VS_LBLC
>         tristate "locality-based least-connection scheduling"
>         ---help---
> diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
> index 38b2723..67f3f43 100644
> --- a/net/netfilter/ipvs/Makefile
> +++ b/net/netfilter/ipvs/Makefile
> @@ -27,6 +27,7 @@ obj-$(CONFIG_IP_VS_WRR) += ip_vs_wrr.o
>  obj-$(CONFIG_IP_VS_LC) += ip_vs_lc.o
>  obj-$(CONFIG_IP_VS_WLC) += ip_vs_wlc.o
>  obj-$(CONFIG_IP_VS_FO) += ip_vs_fo.o
> +obj-$(CONFIG_IP_VS_OVF) += ip_vs_ovf.o
>  obj-$(CONFIG_IP_VS_LBLC) += ip_vs_lblc.o
>  obj-$(CONFIG_IP_VS_LBLCR) += ip_vs_lblcr.o
>  obj-$(CONFIG_IP_VS_DH) += ip_vs_dh.o
> diff --git a/net/netfilter/ipvs/ip_vs_ovf.c b/net/netfilter/ipvs/ip_vs_ovf.c
> new file mode 100644
> index 0000000..f7d62c3
> --- /dev/null
> +++ b/net/netfilter/ipvs/ip_vs_ovf.c
> @@ -0,0 +1,86 @@
> +/*
> + * IPVS:        Overflow-Connection Scheduling module
> + *
> + * Authors:     Raducu Deaconu <rhadoo_io@yahoo.com>
> + *
> + *              This program is free software; you can redistribute it and/or
> + *              modify it under the terms of the GNU General Public License
> + *              as published by the Free Software Foundation; either version
> + *              2 of the License, or (at your option) any later version.
> + *
> + * Scheduler implements "overflow" loadbalancing according to number of active
> + * connections , will keep all conections to the node with the highest weight
> + * and overflow to the next node if the number of connections exceeds
> the node's
> + * weight.
> + * Note that this scheduler might not be suitable for UDP because it only uses
> + * active connections
> + *
> + */
> +
> +#define KMSG_COMPONENT "IPVS"
> +#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +
> +#include <net/ip_vs.h>
> +
> +/* OVF Connection scheduling  */
> +static struct ip_vs_dest *
> +ip_vs_ovf_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> +                  struct ip_vs_iphdr *iph)
> +{
> +       struct ip_vs_dest *dest, *h = NULL;
> +       int hw = 0, w;
> +
> +       IP_VS_DBG(6, "ip_vs_ovf_schedule(): Scheduling...\n");
> +       /* select the node with highest weight, go to next in line if active
> +       * connections exceed weight
> +       */
> +       list_for_each_entry_rcu(dest, &svc->destinations, n_list) {
> +               w = atomic_read(&dest->weight);
> +               if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
> +                   atomic_read(&dest->activeconns) > w ||
> +                   w == 0)
> +                       continue;
> +               if (!h || w > hw) {
> +                       h = dest;
> +                       hw = w;
> +               }
> +       }
> +
> +       if (h) {
> +               IP_VS_DBG_BUF(6, "OVF: server %s:%u active %d w %d\n",
> +                             IP_VS_DBG_ADDR(h->af, &h->addr),
> +                             ntohs(h->port),
> +                             atomic_read(&h->activeconns),
> +                             atomic_read(&h->weight));
> +               return h;
> +       }
> +
> +       ip_vs_scheduler_err(svc, "no destination available");
> +       return NULL;
> +}
> +
> +static struct ip_vs_scheduler ip_vs_ovf_scheduler = {
> +       .name =                 "ovf",
> +       .refcnt =               ATOMIC_INIT(0),
> +       .module =               THIS_MODULE,
> +       .n_list =               LIST_HEAD_INIT(ip_vs_ovf_scheduler.n_list),
> +       .schedule =             ip_vs_ovf_schedule,
> +};
> +
> +static int __init ip_vs_ovf_init(void)
> +{
> +       return register_ip_vs_scheduler(&ip_vs_ovf_scheduler);
> +}
> +
> +static void __exit ip_vs_ovf_cleanup(void)
> +{
> +       unregister_ip_vs_scheduler(&ip_vs_ovf_scheduler);
> +       synchronize_rcu();
> +}
> +
> +module_init(ip_vs_ovf_init);
> +module_exit(ip_vs_ovf_cleanup);
> +MODULE_LICENSE("GPL");
> -- 
> 1.7.10.4

Regards

--
Julian Anastasov <ja@ssi.bg>
