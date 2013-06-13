From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 13 Jun 2013 23:31:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg> <20130607081252.GC11902@eldamar.org.uk> <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk> <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg> <20130612141018.GC29327@eldamar.org.uk> <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg> <20130613141804.GB31356@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130613141804.GB31356@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Thu, 13 Jun 2013, Alexander Frolkin wrote:

> Hi,
> 
> I've patched ipvsadm and fixed up the kernel patch.
> 
> For the ipvsadm option, I've used (-b|--sched-flags) 123.  I don't

	Not sure if we need "-b".

> particularly like this style, but I wanted something working for
> testing.

	I guess it is difficult to maintain many options,
may be one option --sched-flags should be enough, for example:

--sched-flags sh-fallback,sh-port

	In all cases we should not use any of the
--sched-flag-1 variants, better to have scheduler
specific tokens that will set some IP_VS_SVC_F_SCHED* flags.

> I'm using ip_vs_fill_iph_skb for now (if the flag is set), until I hear
> back from you.

	OK, we will rely on provided iph later...

> When you're happy with the patches, I can open the discussion up to the
> users mailing list.
> 
> Kernel patch:
> 
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index a245377..81af9b2 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -20,6 +20,9 @@
>  #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
>  #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
>  #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
> +#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
> +#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
> +#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */

	We have to make the mapping of scheduler flags
public, for example, add:

#define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1
#define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2

	also in libipvs/ip_vs.h, as usually.

>  /*
>   *      Destination Server Flags
> diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
> index 0df269d..f9de4d2 100644
> --- a/net/netfilter/ipvs/ip_vs_sh.c
> +++ b/net/netfilter/ipvs/ip_vs_sh.c
> @@ -48,6 +48,10 @@
>  
>  #include <net/ip_vs.h>
>  
> +#include <net/tcp.h>
> +#include <linux/udp.h>
> +#include <linux/sctp.h>
> +
>  
>  /*
>   *      IPVS SH bucket
> @@ -74,7 +78,9 @@ struct ip_vs_sh_state {
>  /*
>   *	Returns hash value for IPVS SH entry
>   */
> -static inline unsigned int ip_vs_sh_hashkey(int af, const union nf_inet_addr *addr)
> +static inline unsigned int ip_vs_sh_hashkey(int af,
> +	const union nf_inet_addr *addr, __be16 port,
> +	unsigned int offset)

	Arguments should be properly aligned, you can reorder
them, if needed.

> +	if (svc->flags & IP_VS_SVC_F_SCHED2) {
> +		found = false;
> +		for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
> +			dest = ip_vs_sh_get(svc->af, s, &iph.saddr,
> +				port, offset);
> +			if (is_unavailable(dest))
> +				IP_VS_DBG_BUF(6, "SH: selected unavailable "
> +					"server %s:%d (offset %d)",
> +					IP_VS_DBG_ADDR(svc->af, &dest->addr),

	dest can be NULL => crash

> +					ntohs(dest->port),
> +					offset);

	May be we have to put this for loop in new func, so that
IP_VS_DBG_BUF args are properly aligned? Another option is
to move IP_VS_DBG_BUF into is_unavailable(svc, dest, offset)
and to use it only when dest != NULL.

Regards

--
Julian Anastasov <ja@ssi.bg>
