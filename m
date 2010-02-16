From: Simon Horman <horms@verge.net.au>
Subject: Re: SCTP Trasport Loadbalancing Support for IPVS
Date: Tue, 16 Feb 2010 16:13:55 +1100
Message-ID: <20100216051355.GF28421@verge.net.au>
References: <20100212122301.GA4376@mohan-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100212122301.GA4376@mohan-laptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Mohan Reddy <mohanreddykv@gmail.com>
Cc: wensong@linux-vs.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, ja@ssi.bg, kvmrdy@gmail.com

On Fri, Feb 12, 2010 at 05:53:04PM +0530, Mohan Reddy wrote:
> Hi Simon&Wensong,
>=20
> Please some review this code and let me know your comments. I am re-p=
osting this
> as there is no response from any one. You are welcome for any type of=
 comments.
>=20
> This patch enhances IPVS to load balance SCTP transport protocol pack=
ets. This
> is done based on the SCTP rfc 4960. All possible control chunks have =
been=20
> taken care. The state machine used in this code looks some what lengt=
hy. I
> tried to make the state machine easy to understand.=20
>=20
> This patch is against nf-next.2.6 tree.
>=20
> Thanks,
> Mohan Reddy

Hi Mohan,

sorry once again for the very long delay in reviewing your patch.

I'm not an export on SCTP but the patch seems quite clean to me
and looks unlikely to break the existing LVS code. So I think
it is worth getting upstream so people can test it. By which I mean,
this looks like a good candidate for 2.6.35.

I have made some comments in-line, almost exclusively style issues.

> Signed-off-by: Venkata Mohan Reddy Koppula <mohanreddykv@gmail.com>
>=20
>=20
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index a816c37..fe82b1e 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -225,6 +225,26 @@ enum {
>  };
> =20
>  /*
> + *	SCTP State Values
> + */
> +enum ip_vs_sctp_states {
> +	IP_VS_SCTP_S_NONE,
> +	IP_VS_SCTP_S_INIT_CLI,
> +	IP_VS_SCTP_S_INIT_SER,
> +	IP_VS_SCTP_S_INIT_ACK_CLI,
> +	IP_VS_SCTP_S_INIT_ACK_SER,
> +	IP_VS_SCTP_S_ECHO_CLI,
> +	IP_VS_SCTP_S_ECHO_SER,
> +	IP_VS_SCTP_S_ESTABLISHED,
> +	IP_VS_SCTP_S_SHUT_CLI,
> +	IP_VS_SCTP_S_SHUT_SER,
> +	IP_VS_SCTP_S_SHUT_ACK_CLI,
> +	IP_VS_SCTP_S_SHUT_ACK_SER,
> +	IP_VS_SCTP_S_CLOSED,
> +	IP_VS_SCTP_S_LAST
> +};
> +
> +/*
>   *	Delta sequence info structure
>   *	Each ip_vs_conn has 2 (output AND input seq. changes).
>   *      Only used in the VS/NAT.
> @@ -741,7 +761,7 @@ extern struct ip_vs_protocol ip_vs_protocol_udp;
>  extern struct ip_vs_protocol ip_vs_protocol_icmp;
>  extern struct ip_vs_protocol ip_vs_protocol_esp;
>  extern struct ip_vs_protocol ip_vs_protocol_ah;
> -
> +extern struct ip_vs_protocol ip_vs_protocol_sctp;
> =20
>  /*
>   *      Registering/unregistering scheduler functions
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index c71e543..6dba1e8 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -104,6 +104,13 @@ config	IP_VS_PROTO_AH
>  	  This option enables support for load balancing AH (Authentication
>  	  Header) transport protocol. Say Y if unsure.
> =20
> +config  IP_VS_PROTO_SCTP
> +	bool "SCTP load balancing support"
> +	select LIBCRC32C
> +	---help---
> +	  This option enables support for load balancing SCTP transport
> +	  protocol. Say Y if unsure.
> +

I wonder if this should be marked as EXPERIMENTAL

>  comment "IPVS scheduler"
> =20
>  config	IP_VS_RR
> diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefil=
e
> index 73a46fe..e3baefd 100644
> --- a/net/netfilter/ipvs/Makefile
> +++ b/net/netfilter/ipvs/Makefile
> @@ -7,6 +7,7 @@ ip_vs_proto-objs-y :=3D
>  ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_TCP) +=3D ip_vs_proto_tcp.o
>  ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_UDP) +=3D ip_vs_proto_udp.o
>  ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_AH_ESP) +=3D ip_vs_proto_ah_es=
p.o
> +ip_vs_proto-objs-$(CONFIG_IP_VS_PROTO_SCTP) +=3D ip_vs_proto_sctp.o
> =20
>  ip_vs-objs :=3D	ip_vs_conn.o ip_vs_core.o ip_vs_ctl.o ip_vs_sched.o	=
   \
>  		ip_vs_xmit.o ip_vs_app.o ip_vs_sync.o	   		   \
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_=
vs_core.c
> index 847ffca..dae3af0 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -31,6 +31,7 @@
>  #include <linux/kernel.h>
>  #include <linux/ip.h>
>  #include <linux/tcp.h>
> +#include <linux/sctp.h>
>  #include <linux/icmp.h>
> =20
>  #include <net/ip.h>
> @@ -81,6 +82,8 @@ const char *ip_vs_proto_name(unsigned proto)
>  		return "UDP";
>  	case IPPROTO_TCP:
>  		return "TCP";
> +	case IPPROTO_SCTP:
> +		return "SCTP";
>  	case IPPROTO_ICMP:
>  		return "ICMP";
>  #ifdef CONFIG_IP_VS_IPV6
> @@ -589,8 +592,9 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct i=
p_vs_protocol *pp,
>  		ip_send_check(ciph);
>  	}
> =20
> -	/* the TCP/UDP port */
> -	if (IPPROTO_TCP =3D=3D ciph->protocol || IPPROTO_UDP =3D=3D ciph->p=
rotocol) {
> +	/* the TCP/UDP/SCTP port */
> +	if (IPPROTO_TCP =3D=3D ciph->protocol || IPPROTO_UDP =3D=3D ciph->p=
rotocol ||
> +			IPPROTO_SCTP =3D=3D ciph->protocol) {

Minor style issue, but I believe that the preferred indentation is
to align the start of continuing lines with the inside of the
preceding '(' bracket.

	if (IPPROTO_TCP =3D=3D ciph->protocol || IPPROTO_UDP =3D=3D ciph->prot=
ocol ||
	    IPPROTO_SCTP =3D=3D ciph->protocol) {

Could you fix this up throughout your patch?

In particular, I notice some changes only change indentation.
Please don't do that as it just adds noise to the change.

>  		__be16 *ports =3D (void *)ciph + ciph->ihl*4;
> =20
>  		if (inout)
> @@ -630,8 +634,9 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struc=
t ip_vs_protocol *pp,
>  		ciph->saddr =3D cp->daddr.in6;
>  	}
> =20
> -	/* the TCP/UDP port */
> -	if (IPPROTO_TCP =3D=3D ciph->nexthdr || IPPROTO_UDP =3D=3D ciph->ne=
xthdr) {
> +	/* the TCP/UDP/SCTP port */
> +	if (IPPROTO_TCP =3D=3D ciph->nexthdr || IPPROTO_UDP =3D=3D ciph->ne=
xthdr ||
> +			IPPROTO_SCTP =3D=3D ciph->nexthdr) {
>  		__be16 *ports =3D (void *)ciph + sizeof(struct ipv6hdr);
> =20
>  		if (inout)
> @@ -679,7 +684,8 @@ static int handle_response_icmp(int af, struct sk=
_buff *skb,
>  		goto out;
>  	}
> =20
> -	if (IPPROTO_TCP =3D=3D protocol || IPPROTO_UDP =3D=3D protocol)
> +	if (IPPROTO_TCP =3D=3D protocol || IPPROTO_UDP =3D=3D protocol ||
> +			IPPROTO_SCTP =3D=3D protocol)
>  		offset +=3D 2 * sizeof(__u16);
>  	if (!skb_make_writable(skb, offset))
>  		goto out;
> @@ -857,6 +863,21 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb=
, int *related)
>  }
>  #endif
> =20
> +/*
> + * Check if sctp chunc is ABORT chunk
> + */
> +static inline int is_sctp_abort(const struct sk_buff *skb, int nh_le=
n)
> +{
> +	sctp_chunkhdr_t *sch, schunk;
> +	sch =3D skb_header_pointer(skb, nh_len + sizeof(sctp_sctphdr_t),
> +			sizeof(schunk), &schunk);
> +	if (sch =3D=3D NULL)
> +		return 0;
> +	if (sch->type =3D=3D SCTP_CID_ABORT)
> +		return 1;
> +	return 0;
> +}
> +
>  static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len=
)
>  {
>  	struct tcphdr _tcph, *th;
> @@ -998,24 +1019,30 @@ ip_vs_out(unsigned int hooknum, struct sk_buff=
 *skb,
> =20
>  	if (unlikely(!cp)) {
>  		if (sysctl_ip_vs_nat_icmp_send &&
> -		    (pp->protocol =3D=3D IPPROTO_TCP ||
> -		     pp->protocol =3D=3D IPPROTO_UDP)) {
> +				(pp->protocol =3D=3D IPPROTO_TCP ||
> +				 pp->protocol =3D=3D IPPROTO_UDP ||
> +				 pp->protocol =3D=3D IPPROTO_SCTP)) {
>  			__be16 _ports[2], *pptr;
> =20
>  			pptr =3D skb_header_pointer(skb, iph.len,
> -						  sizeof(_ports), _ports);
> +					sizeof(_ports), _ports);
>  			if (pptr =3D=3D NULL)
>  				return NF_ACCEPT;	/* Not for me */
>  			if (ip_vs_lookup_real_service(af, iph.protocol,
> -						      &iph.saddr,
> -						      pptr[0])) {
> +						&iph.saddr,
> +						pptr[0])) {
>  				/*
>  				 * Notify the real server: there is no
>  				 * existing entry if it is not RST
>  				 * packet or not TCP packet.
>  				 */
> -				if (iph.protocol !=3D IPPROTO_TCP
> -				    || !is_tcp_reset(skb, iph.len)) {
> +				if ((iph.protocol !=3D IPPROTO_TCP &&
> +					iph.protocol !=3D IPPROTO_SCTP)
> +					|| ((iph.protocol =3D=3D IPPROTO_TCP
> +						&& !is_tcp_reset(skb, iph.len))
> +					|| (iph.protocol =3D=3D IPPROTO_SCTP
> +						&& !is_sctp_abort(skb,
> +							iph.len)))) {
>  #ifdef CONFIG_IP_VS_IPV6
>  					if (af =3D=3D AF_INET6)
>  						icmpv6_send(skb,
> @@ -1235,7 +1262,8 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *rela=
ted, unsigned int hooknum)
> =20
>  	/* do the statistics and put it back */
>  	ip_vs_in_stats(cp, skb);
> -	if (IPPROTO_TCP =3D=3D cih->nexthdr || IPPROTO_UDP =3D=3D cih->next=
hdr)
> +	if (IPPROTO_TCP =3D=3D cih->nexthdr || IPPROTO_UDP =3D=3D cih->next=
hdr ||
> +			IPPROTO_SCTP =3D=3D cih->nexthdr)
>  		offset +=3D 2 * sizeof(__u16);
>  	verdict =3D ip_vs_icmp_xmit_v6(skb, cp, pp, offset);
>  	/* do not touch skb anymore */
> @@ -1358,6 +1386,21 @@ ip_vs_in(unsigned int hooknum, struct sk_buff =
*skb,
>  	 * encorage the standby servers to update the connections timeout
>  	 */
>  	pkts =3D atomic_add_return(1, &cp->in_pkts);
> +	if (af =3D=3D AF_INET && (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
> +			cp->protocol =3D=3D IPPROTO_SCTP) {
> +		if ((cp->state =3D=3D IP_VS_SCTP_S_ESTABLISHED &&
> +			(atomic_read(&cp->in_pkts) %
> +			 sysctl_ip_vs_sync_threshold[1]
> +			 =3D=3D sysctl_ip_vs_sync_threshold[0])) ||
> +				(cp->old_state !=3D cp->state &&
> +				 ((cp->state =3D=3D IP_VS_SCTP_S_CLOSED) ||
> +				  (cp->state =3D=3D IP_VS_SCTP_S_SHUT_ACK_CLI) ||
> +				  (cp->state =3D=3D IP_VS_SCTP_S_SHUT_ACK_SER)))) {
> +			ip_vs_sync_conn(cp);
> +			goto out;
> +		}
> +	}
> +

Having a separate block for the synchronisation of SCTP seems
a bit messy. But thats mainly due to the state of the existing code.
So I think its fine.

>  	if (af =3D=3D AF_INET &&
>  	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
>  	    (((cp->protocol !=3D IPPROTO_TCP ||
> @@ -1370,6 +1413,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *=
skb,
>  	       (cp->state =3D=3D IP_VS_TCP_S_CLOSE_WAIT) ||
>  	       (cp->state =3D=3D IP_VS_TCP_S_TIME_WAIT)))))
>  		ip_vs_sync_conn(cp);
> +out:
>  	cp->old_state =3D cp->state;
> =20
>  	ip_vs_conn_put(cp);
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_v=
s_ctl.c
> index 93420ea..564a886 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2128,8 +2128,9 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void=
 __user *user, unsigned int len)
>  		}
>  	}
> =20
> -	/* Check for valid protocol: TCP or UDP, even for fwmark!=3D0 */
> -	if (usvc.protocol !=3D IPPROTO_TCP && usvc.protocol !=3D IPPROTO_UD=
P) {
> +	/* Check for valid protocol: TCP or UDP or SCTP, even for fwmark!=3D=
0 */
> +	if (usvc.protocol !=3D IPPROTO_TCP && usvc.protocol !=3D IPPROTO_UD=
P &&
> +			usvc.protocol !=3D IPPROTO_SCTP) {
>  		pr_err("set_ctl: invalid protocol: %d %pI4:%d %s\n",
>  		       usvc.protocol, &usvc.addr.ip,
>  		       ntohs(usvc.port), usvc.sched_name);
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip=
_vs_proto.c
> index 3e76716..0e58455 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -257,6 +257,9 @@ int __init ip_vs_protocol_init(void)
>  #ifdef CONFIG_IP_VS_PROTO_UDP
>  	REGISTER_PROTOCOL(&ip_vs_protocol_udp);
>  #endif
> +#ifdef CONFIG_IP_VS_PROTO_SCTP
> +	REGISTER_PROTOCOL(&ip_vs_protocol_sctp);
> +#endif
>  #ifdef CONFIG_IP_VS_PROTO_AH
>  	REGISTER_PROTOCOL(&ip_vs_protocol_ah);
>  #endif
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ip=
vs/ip_vs_proto_sctp.c
> new file mode 100644
> index 0000000..4303ec5
> --- /dev/null
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -0,0 +1,1190 @@
> +#include <linux/kernel.h>
> +#include <linux/ip.h>
> +#include <linux/sctp.h>
> +#include <net/ip.h>
> +#include <net/ip6_checksum.h>
> +#include <linux/netfilter.h>
> +#include <linux/netfilter_ipv4.h>
> +#include <net/sctp/checksum.h>
> +#include <net/ip_vs.h>
> +
> +
> +static struct ip_vs_conn *sctp_conn_in_get(int af,
> +					   const struct sk_buff *skb,
> +					   struct ip_vs_protocol *pp,
> +					   const struct ip_vs_iphdr *iph,
> +					   unsigned int proto_off,
> +					   int inverse)

Again, indentation.

> +{
> +	__be16 _ports[2], *pptr;
> +
> +	pptr =3D skb_header_pointer(skb, proto_off, sizeof(_ports), _ports)=
;
> +	if (pptr =3D=3D NULL)
> +		return NULL;
> +
> +	if (likely(!inverse)) {
> +		return ip_vs_conn_in_get(af, iph->protocol,
> +					 &iph->saddr, pptr[0],
> +					 &iph->daddr, pptr[1]);
> +	} else {
> +		return ip_vs_conn_in_get(af, iph->protocol,
> +					 &iph->daddr, pptr[1],
> +					 &iph->saddr, pptr[0]);
> +	}

There is no need for { } to enclose a single statement.
I would perfer:

	if (likely(!inverse))
		return ip_vs_conn_in_get(af, iph->protocol,
					 &iph->saddr, pptr[0],
					 &iph->daddr, pptr[1]);
	else
		return ip_vs_conn_in_get(af, iph->protocol,
					 &iph->daddr, pptr[1],
					 &iph->saddr, pptr[0]);

> +}
> +
> +static struct ip_vs_conn *sctp_conn_out_get(int af,
> +					    const struct sk_buff *skb,
> +					    struct ip_vs_protocol *pp,
> +					    const struct ip_vs_iphdr *iph,
> +					    unsigned int proto_off,
> +					    int inverse)
> +{
> +	__be16 _ports[2], *pptr;
> +
> +	pptr =3D skb_header_pointer(skb, proto_off, sizeof(_ports), _ports)=
;
> +	if (pptr =3D=3D NULL)
> +		return NULL;
> +
> +	if (likely(!inverse)) {
> +		return ip_vs_conn_out_get(af, iph->protocol,
> +					  &iph->saddr, pptr[0],
> +					  &iph->daddr, pptr[1]);
> +	} else {
> +		return ip_vs_conn_out_get(af, iph->protocol,
> +					  &iph->daddr, pptr[1],
> +					  &iph->saddr, pptr[0]);
> +	}

Again, no need for { }

> +}
> +
> +static int
> +sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protoco=
l *pp,
> +		   int *verdict, struct ip_vs_conn **cpp)
> +{
> +	struct ip_vs_service *svc;
> +	sctp_chunkhdr_t _schunkh, *sch;
> +	sctp_sctphdr_t *sh, _sctph;
> +	struct ip_vs_iphdr iph;
> +
> +	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
> +
> +	sh =3D skb_header_pointer(skb, iph.len, sizeof(_sctph), &_sctph);
> +	if (sh =3D=3D NULL)
> +		return 0;
> +
> +

Please only use at most one blank line.

> +	sch =3D skb_header_pointer(skb, iph.len + sizeof(sctp_sctphdr_t),
> +				 sizeof(_schunkh), &_schunkh);
> +	if (sch =3D=3D NULL)
> +		return 0;
> +
> +	if ((sch->type =3D=3D SCTP_CID_INIT) &&
> +	    (svc =3D ip_vs_service_get(af, skb->mark, iph.protocol,
> +				     &iph.daddr, sh->dest))) {
> +		if (ip_vs_todrop()) {
> +			/*
> +			 * It seems that we are very loaded.
> +			 * We have to drop this packet :(
> +			 */
> +			ip_vs_service_put(svc);
> +			*verdict =3D NF_DROP;
> +			return 0;
> +		}
> +		/*
> +		 * Let the virtual server select a real server for the
> +		 * incoming connection, and create a connection entry.
> +		 */
> +		*cpp =3D ip_vs_schedule(svc, skb);
> +		if (!*cpp) {
> +			*verdict =3D ip_vs_leave(svc, skb, pp);
> +			return 0;
> +		}
> +		ip_vs_service_put(svc);
> +	}
> +
> +	return 1;
> +}
> +
> +static int
> +sctp_snat_handler(struct sk_buff *skb,
> +		  struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
> +{
> +	sctp_sctphdr_t *sctph;
> +	unsigned int sctphoff;
> +	__be32 crc32;
> +
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (cp->af =3D=3D AF_INET6)
> +		sctphoff =3D sizeof(struct ipv6hdr);
> +	else
> +#endif
> +		sctphoff =3D ip_hdrlen(skb);
> +
> +	/* csum_check requires unshared skb */
> +	if (!skb_make_writable(skb, sctphoff + sizeof(*sctph)))
> +		return 0;
> +
> +	if (unlikely(cp->app !=3D NULL)) {
> +		/* Some checks before mangling */
> +		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
> +			return 0;
> +
> +		/* Call application helper if needed */
> +		if (!ip_vs_app_pkt_out(cp, skb))
> +			return 0;
> +	}
> +
> +	sctph =3D (void *) skb_network_header(skb) + sctphoff;
> +	sctph->source =3D cp->vport;
> +
> +	/* Calculate the checksum */
> +	crc32 =3D
> +	    sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
> +	for (skb =3D skb_shinfo(skb)->frag_list; skb; skb =3D skb->next)
> +		crc32 =3D
> +		    sctp_update_cksum((u8 *) skb->data, skb_headlen(skb),
> +				      crc32);

Line wrapping: I think the following is preferred (x2)

	/* Calculate the checksum */
	crc32 =3D sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
	for (skb =3D skb_shinfo(skb)->frag_list; skb; skb =3D skb->next)
		crc32 =3D sctp_update_cksum((u8 *) skb->data, skb_headlen(skb),
					  crc32);

> +	crc32 =3D sctp_end_cksum(crc32);
> +	sctph->checksum =3D crc32;
> +
> +	return 1;
> +}
> +
> +static int
> +sctp_dnat_handler(struct sk_buff *skb,
> +		  struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
> +{
> +
> +	sctp_sctphdr_t *sctph;
> +	unsigned int sctphoff;
> +	__be32 crc32;
> +
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (cp->af =3D=3D AF_INET6)
> +		sctphoff =3D sizeof(struct ipv6hdr);
> +	else
> +#endif
> +		sctphoff =3D ip_hdrlen(skb);
> +
> +	/* csum_check requires unshared skb */
> +	if (!skb_make_writable(skb, sctphoff + sizeof(*sctph)))
> +		return 0;
> +
> +	if (unlikely(cp->app !=3D NULL)) {
> +		/* Some checks before mangling */
> +		if (pp->csum_check && !pp->csum_check(cp->af, skb, pp))
> +			return 0;
> +
> +		/* Call application helper if needed */
> +		if (!ip_vs_app_pkt_out(cp, skb))
> +			return 0;
> +	}
> +
> +	sctph =3D (void *) skb_network_header(skb) + sctphoff;
> +	sctph->dest =3D cp->dport;
> +
> +	/* Calculate the checksum */
> +	crc32 =3D
> +	    sctp_start_cksum((u8 *) sctph, skb_headlen(skb) - sctphoff);
> +	for (skb =3D skb_shinfo(skb)->frag_list; skb; skb =3D skb->next)
> +		crc32 =3D
> +		    sctp_update_cksum((u8 *) skb->data, skb_headlen(skb),
> +				      crc32);

Line wrapping again.

The checksum calculation seems the same as in +sctp_snat_handler().
Perhaps this could be consolidated?

> +	crc32 =3D sctp_end_cksum(crc32);
> +	sctph->checksum =3D crc32;
> +
> +	return 1;
> +}
> +
> +static int
> +sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *=
pp)
> +{
> +	struct sk_buff *list =3D skb_shinfo(skb)->frag_list;
> +	unsigned int sctphoff;
> +	struct sctphdr *sh, _sctph;
> +	__le32 cmp;
> +	__le32 val;
> +	__u32 tmp;
> +
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (af =3D=3D AF_INET6)
> +		sctphoff =3D sizeof(struct ipv6hdr);
> +	else
> +#endif
> +		sctphoff =3D ip_hdrlen(skb);
> +
> +	sh =3D skb_header_pointer(skb, sctphoff, sizeof(_sctph), &_sctph);
> +	if (sh =3D=3D NULL)
> +		return 0;
> +
> +	cmp =3D sh->checksum;
> +
> +	tmp =3D sctp_start_cksum((__u8 *) sh, skb_headlen(skb));
> +	for (; list; list =3D list->next)
> +		tmp =3D
> +		    sctp_update_cksum((__u8 *) list->data,
> +				      skb_headlen(list), tmp);
> +
> +	val =3D sctp_end_cksum(tmp);
> +
> +	if (val !=3D cmp) {
> +		/* CRC failure, dump it. */
> +		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
> +				"Failed checksum for");
> +		return 0;
> +	}
> +	return 1;
> +}
> +
> +struct ipvs_sctp_nextstate {
> +	int next_state;
> +};
> +enum ipvs_sctp_event_t {
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_DATA_SER,
> +	IP_VS_SCTP_EVE_INIT_CLI,
> +	IP_VS_SCTP_EVE_INIT_SER,
> +	IP_VS_SCTP_EVE_INIT_ACK_CLI,
> +	IP_VS_SCTP_EVE_INIT_ACK_SER,
> +	IP_VS_SCTP_EVE_COOKIE_ECHO_CLI,
> +	IP_VS_SCTP_EVE_COOKIE_ECHO_SER,
> +	IP_VS_SCTP_EVE_COOKIE_ACK_CLI,
> +	IP_VS_SCTP_EVE_COOKIE_ACK_SER,
> +	IP_VS_SCTP_EVE_ABORT_CLI,
> +	IP_VS_SCTP_EVE__ABORT_SER,
> +	IP_VS_SCTP_EVE_SHUT_CLI,
> +	IP_VS_SCTP_EVE_SHUT_SER,
> +	IP_VS_SCTP_EVE_SHUT_ACK_CLI,
> +	IP_VS_SCTP_EVE_SHUT_ACK_SER,
> +	IP_VS_SCTP_EVE_SHUT_COM_CLI,
> +	IP_VS_SCTP_EVE_SHUT_COM_SER,
> +	IP_VS_SCTP_EVE_LAST
> +};
> +
> +static enum ipvs_sctp_event_t sctp_events[255] =3D {
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_INIT_CLI,
> +	IP_VS_SCTP_EVE_INIT_ACK_CLI,
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_ABORT_CLI,
> +	IP_VS_SCTP_EVE_SHUT_CLI,
> +	IP_VS_SCTP_EVE_SHUT_ACK_CLI,
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_COOKIE_ECHO_CLI,
> +	IP_VS_SCTP_EVE_COOKIE_ACK_CLI,
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_DATA_CLI,
> +	IP_VS_SCTP_EVE_SHUT_COM_CLI,
> +};
> +
> +static struct ipvs_sctp_nextstate
> + sctp_states_table[IP_VS_SCTP_S_LAST][IP_VS_SCTP_EVE_LAST] =3D {
> +	/*
> +	 * STATE : IP_VS_SCTP_S_NONE
> +	 */
> +	/*next state *//*event */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ },
> +	 },
> +	/*
> +	 * STATE : IP_VS_SCTP_S_INIT_CLI
> +	 * Cient sent INIT and is waiting for reply from server(In ECHO_WAI=
T)
> +	 */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_ECHO_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_INIT_SER
> +	 * Server sent INIT and waiting for INIT ACK from the client
> +	 */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_INIT_ACK_CLI
> +	 * Client sent INIT ACK and waiting for ECHO from the server
> +	 */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK has been resent by the client, let us stay is in
> +	  * the same state
> +	  */
> +	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 /*
> +	  * INIT_ACK sent by the server, close the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * ECHO by client, it should not happen, close the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 /*
> +	  * ECHO by server, this is what we are expecting, move to ECHO_SER
> +	  */
> +	 {IP_VS_SCTP_S_ECHO_SER /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, it should not happen, close the connect=
ion
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 /*
> +	  * Unexpected COOKIE ACK from server, staty in the same state
> +	  */
> +	 {IP_VS_SCTP_S_INIT_ACK_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_INIT_ACK_SER
> +	 * Server sent INIT ACK and waiting for ECHO from the client
> +	 */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * Unexpected INIT_ACK by the client, let us close the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 /*
> +	  * INIT_ACK resent by the server, let us move to same state
> +	  */
> +	 {IP_VS_SCTP_S_INIT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client send the ECHO, this is what we are expecting,
> +	  * move to ECHO_CLI
> +	  */
> +	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 /*
> +	  * ECHO received from the server, Not sure what to do,
> +	  * let us close it
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, let us stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_INIT_ACK_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 /*
> +	  * COOKIE ACK from server, hmm... this should not happen, lets clo=
se
> +	  * the connection.
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_ECHO_CLI
> +	 * Cient  sent ECHO and waiting COOKEI ACK from the Server
> +	 */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK has been by the client, let us close the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 /*
> +	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> +	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> +	  * than the COOKIE-WAIT state, the endpoint should discard the
> +	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client resent the ECHO, let us stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ECHO_CLI /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 /*
> +	  * ECHO received from the server, Not sure what to do,
> +	  * let us close it
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, this shoud not happen, let's close the
> +	  * connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 /*
> +	  * COOKIE ACK from server, this is what we are awaiting,lets move =
to
> +	  * ESTABLISHED.
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_ECHO_SER
> +	 * Server sent ECHO and waiting COOKEI ACK from the client
> +	 */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> +	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> +	  * than the COOKIE-WAIT state, the endpoint should discard the
> +	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ECHO_SER /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 /*
> +	  * INIT_ACK has been by the server, let us close the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client sent the ECHO, not sure what to do, let's close the
> +	  * connection.
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 /*
> +	  * ECHO resent by the server, stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ECHO_SER /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, this is what we are expecting, let's mo=
ve
> +	  * to ESTABLISHED.
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 /*
> +	  * COOKIE ACK from server, this should not happen, lets close the
> +	  * connection.
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_ESTABLISHED
> +	 * Association established
> +	 */
> +	{{IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> +	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> +	  * than the COOKIE-WAIT state, the endpoint should discard the
> +	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> +	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> +	  * it will send ERROR chunk. So, stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 /*
> +	  * SHUTDOWN from the client, move to SHUDDOWN_CLI
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 /*
> +	  * SHUTDOWN from the server, move to SHUTDOWN_SER
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 /*
> +	  * client sent SHUDTDOWN_ACK, this should not happen, let's close
> +	  * the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_SHUT_CLI
> +	 * SHUTDOWN sent from the client, waitinf for SHUT ACK from the ser=
ver
> +	 */
> +	/*
> +	 * We recieved the data chuck, keep the state unchanged. I assume
> +	 * that still data chuncks  can be received by both the peers in
> +	 * SHUDOWN state
> +	 */
> +
> +	{{IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> +	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> +	  * than the COOKIE-WAIT state, the endpoint should discard the
> +	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> +	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> +	  * it will send ERROR chunk. So, stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 /*
> +	  * SHUTDOWN resent from the client, move to SHUDDOWN_CLI
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 /*
> +	  * SHUTDOWN from the server, move to SHUTDOWN_SER
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 /*
> +	  * client sent SHUDTDOWN_ACK, this should not happen, let's close
> +	  * the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 /*
> +	  * Server sent SHUTDOWN ACK, this is what we are expecting, let's =
move
> +	  * to SHUDOWN_ACK_SER
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 /*
> +	  * SHUTDOWN COM from client, this should not happen, let's close t=
he
> +	  * connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_SHUT_SER
> +	 * SHUTDOWN sent from the server, waitinf for SHUTDOWN ACK from cli=
ent
> +	 */
> +	/*
> +	 * We recieved the data chuck, keep the state unchanged. I assume
> +	 * that still data chuncks  can be received by both the peers in
> +	 * SHUDOWN state
> +	 */
> +
> +	{{IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> +	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> +	  * than the COOKIE-WAIT state, the endpoint should discard the
> +	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> +	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> +	  * it will send ERROR chunk. So, stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 /*
> +	  * SHUTDOWN resent from the client, move to SHUDDOWN_CLI
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 /*
> +	  * SHUTDOWN resent from the server, move to SHUTDOWN_SER
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 /*
> +	  * client sent SHUDTDOWN_ACK, this is what we are expecting, let's
> +	  * move to SHUT_ACK_CLI
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 /*
> +	  * Server sent SHUTDOWN ACK, this should not happen, let's close t=
he
> +	  * connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 /*
> +	  * SHUTDOWN COM from client, this should not happen, let's close t=
he
> +	  * connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +
> +	/*
> +	 * State : IP_VS_SCTP_S_SHUT_ACK_CLI
> +	 * SHUTDOWN ACK from the client, awaiting for SHUTDOWN COM from ser=
ver
> +	 */
> +	/*
> +	 * We recieved the data chuck, keep the state unchanged. I assume
> +	 * that still data chuncks  can be received by both the peers in
> +	 * SHUDOWN state
> +	 */
> +
> +	{{IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> +	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> +	  * than the COOKIE-WAIT state, the endpoint should discard the
> +	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> +	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> +	  * it will send ERROR chunk. So, stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 /*
> +	  * SHUTDOWN sent from the client, move to SHUDDOWN_CLI
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 /*
> +	  * SHUTDOWN sent from the server, move to SHUTDOWN_SER
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 /*
> +	  * client resent SHUDTDOWN_ACK, let's stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_CLI /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 /*
> +	  * Server sent SHUTDOWN ACK, this should not happen, let's close t=
he
> +	  * connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 /*
> +	  * SHUTDOWN COM from client, this should not happen, let's close t=
he
> +	  * connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 /*
> +	  * SHUTDOWN COMPLETE from server this is what we are expecting.
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +
> +	/*
> +	 * State : IP_VS_SCTP_S_SHUT_ACK_SER
> +	 * SHUTDOWN ACK from the server, awaiting for SHUTDOWN COM from cli=
ent
> +	 */
> +	/*
> +	 * We recieved the data chuck, keep the state unchanged. I assume
> +	 * that still data chuncks  can be received by both the peers in
> +	 * SHUDOWN state
> +	 */
> +
> +	{{IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 /*
> +	  * We have got an INIT from client. From the spec.=E2=80=9CUpon re=
ceipt of
> +	  * an INIT in the COOKIE-WAIT state, an endpoint MUST respond with
> +	  * an INIT ACK using the same parameters it sent in its  original
> +	  * INIT chunk (including its Initiate Tag, unchanged=E2=80=9D).
> +	  */
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 /*
> +	  * INIT_ACK sent by the server, Unexpected INIT ACK, spec says,
> +	  * =E2=80=9CIf an INIT ACK is received by an endpoint in any state=
 other
> +	  * than the COOKIE-WAIT state, the endpoint should discard the
> +	  * INIT ACK chunk=E2=80=9D. Stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 /*
> +	  * Client sent ECHO, Spec(sec 5.2.4) says it may be handled by the
> +	  * peer and peer shall move to the ESTABISHED. if it doesn't handl=
e
> +	  * it will send ERROR chunk. So, stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_ESTABLISHED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 /*
> +	  * COOKIE ACK from client, not sure what to do stay in the same st=
ate
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 /*
> +	  * SHUTDOWN sent from the client, move to SHUDDOWN_CLI
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_CLI /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 /*
> +	  * SHUTDOWN sent from the server, move to SHUTDOWN_SER
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_SER /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 /*
> +	  * client sent SHUDTDOWN_ACK, this should not happen let's close
> +	  * the connection.
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 /*
> +	  * Server resent SHUTDOWN ACK, stay in the same state
> +	  */
> +	 {IP_VS_SCTP_S_SHUT_ACK_SER /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 /*
> +	  * SHUTDOWN COM from client, this what we are expecting, let's clo=
se
> +	  * the connection
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 /*
> +	  * SHUTDOWN COMPLETE from server this should not happen.
> +	  */
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 },
> +	/*
> +	 * State : IP_VS_SCTP_S_CLOSED
> +	 */
> +	{{IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_DATA_SER */ },
> +	 {IP_VS_SCTP_S_INIT_CLI /* IP_VS_SCTP_EVE_INIT_CLI */ },
> +	 {IP_VS_SCTP_S_INIT_SER /* IP_VS_SCTP_EVE_INIT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_INIT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ECHO_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_COOKIE_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_ABORT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_ACK_SER */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_CLI */ },
> +	 {IP_VS_SCTP_S_CLOSED /* IP_VS_SCTP_EVE_SHUT_COM_SER */ }
> +	 }
> +};
> +
> +/*
> + *      Timeout table[state]
> + */
> +static int sctp_timeouts[IP_VS_SCTP_S_LAST + 1] =3D {
> +	[IP_VS_SCTP_S_NONE]         =3D     2 * HZ,
> +	[IP_VS_SCTP_S_INIT_CLI]     =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_INIT_SER]     =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_INIT_ACK_CLI] =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_INIT_ACK_SER] =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_ECHO_CLI]     =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_ECHO_SER]     =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_ESTABLISHED]  =3D    15 * 60 * HZ,
> +	[IP_VS_SCTP_S_SHUT_CLI]     =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_SHUT_SER]     =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_SHUT_ACK_CLI] =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_SHUT_ACK_SER] =3D     1 * 60 * HZ,
> +	[IP_VS_SCTP_S_CLOSED]       =3D    10 * HZ,
> +	[IP_VS_SCTP_S_LAST]         =3D     2 * HZ,
> +};
> +
> +static const char *sctp_state_name_table[IP_VS_SCTP_S_LAST + 1] =3D =
{
> +	[IP_VS_SCTP_S_NONE]         =3D    "NONE",
> +	[IP_VS_SCTP_S_INIT_CLI]     =3D    "INIT_CLI",
> +	[IP_VS_SCTP_S_INIT_SER]     =3D    "INIT_SER",
> +	[IP_VS_SCTP_S_INIT_ACK_CLI] =3D    "INIT_ACK_CLI",
> +	[IP_VS_SCTP_S_INIT_ACK_SER] =3D    "INIT_ACK_SER",
> +	[IP_VS_SCTP_S_ECHO_CLI]     =3D    "COOKIE_ECHO_CLI",
> +	[IP_VS_SCTP_S_ECHO_SER]     =3D    "COOKIE_ECHO_SER",
> +	[IP_VS_SCTP_S_ESTABLISHED]  =3D    "ESTABISHED",
> +	[IP_VS_SCTP_S_SHUT_CLI]     =3D    "SHUTDOWN_CLI",
> +	[IP_VS_SCTP_S_SHUT_SER]     =3D    "SHUTDOWN_CLI",
> +	[IP_VS_SCTP_S_SHUT_ACK_CLI] =3D    "SHUTDOWN_ACK_CLI",
> +	[IP_VS_SCTP_S_SHUT_ACK_SER] =3D    "SHUTDOWN_ACK_SER",
> +	[IP_VS_SCTP_S_CLOSED]       =3D    "CLOSED",
> +	[IP_VS_SCTP_S_LAST]         =3D    "BUG!"
> +};
> +
> +
> +static const char *sctp_state_name(int state)
> +{
> +	if (state >=3D IP_VS_SCTP_S_LAST)
> +		return "ERR!";
> +	return sctp_state_name_table[state] ? sctp_state_name_table[state]
> +	    : "?";

Perhaps the following would be easier on the eye?

	if (sctp_state_name_table[state])
		return sctp_state_name_table[state];
	return "?";

> +}
> +
> +static void sctp_timeout_change(struct ip_vs_protocol *pp, int flags=
)
> +{
> +
> +

No need for empty lines here.
In particular, please don't use more than one consecutive blank line.

> +}
> +
> +static int
> +sctp_set_state_timeout(struct ip_vs_protocol *pp, char *sname, int t=
o)
> +{
> +
> +return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_SCTP_S_LAST,
> +				sctp_state_name_table, sname, to);

Need one more tab of indentation here.

	return ip_vs_set_state_timeout(pp->timeout_table, IP_VS_SCTP_S_LAST,
				       sctp_state_name_table, sname, to);

> +}
> +
> +static inline int
> +set_sctp_state(struct ip_vs_protocol *pp, struct ip_vs_conn *cp,
> +		int direction, const struct sk_buff *skb)
> +{
> +	sctp_chunkhdr_t _sctpch, *sch;
> +	unsigned char chunk_type;
> +	int event, next_state;
> +	int ihl;
> +
> +#ifdef CONFIG_IP_VS_IPV6
> +	ihl =3D cp->af =3D=3D AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6=
hdr);
> +#else
> +	ihl =3D ip_hdrlen(skb);
> +#endif
> +
> +	sch =3D skb_header_pointer(skb, ihl + sizeof(sctp_sctphdr_t),
> +				sizeof(_sctpch), &_sctpch);
> +	if (sch =3D=3D NULL)
> +		return 0;
> +
> +	chunk_type =3D sch->type;
> +	/*
> +	 * Section 3: Multiple chunks can be bundled into one SCTP packet
> +	 * up to the MTU size, except for the INIT, INIT ACK, and
> +	 * SHUTDOWN COMPLETE chunks. These chunks MUST NOT be bundled with
> +	 * any other chunk in a packet.
> +	 *
> +	 * Section 3.3.7: DATA chunks MUST NOT be bundled with ABORT. Contr=
ol
> +	 * chunks (except for INIT, INIT ACK, and SHUTDOWN COMPLETE) MAY be
> +	 * bundled with an ABORT, but they MUST be placed before the ABORT
> +	 * in the SCTP packet or they will be ignored by the receiver.
> +	 */
> +	if ((sch->type =3D=3D SCTP_CID_COOKIE_ECHO) ||
> +			(sch->type =3D=3D SCTP_CID_COOKIE_ACK)) {
> +		sch =3D skb_header_pointer(skb, (ihl + sizeof(sctp_sctphdr_t) +
> +				sch->length), sizeof(_sctpch), &_sctpch);
> +		if (sch) {
> +			if (sch->type =3D=3D SCTP_CID_ABORT)
> +				chunk_type =3D sch->type;
> +		}
> +	}
> +
> +	event =3D sctp_events[chunk_type];
> +
> +	/*
> +	 *  If the direction is IP_VS_DIR_OUTPUT, this event is from server
> +	 */
> +	if (direction =3D=3D IP_VS_DIR_OUTPUT)
> +		event++;
> +	/*
> +	 * get next state
> +	 */
> +	next_state =3D sctp_states_table[cp->state][event].next_state;
> +
> +	if (next_state !=3D cp->state) {
> +		struct ip_vs_dest *dest =3D cp->dest;
> +
> +		IP_VS_DBG_BUF(8, "%s %s  %s:%d->"
> +				"%s:%d state: %s->%s conn->refcnt:%d\n",
> +				pp->name,
> +				((direction =3D=3D IP_VS_DIR_OUTPUT) ?
> +				 "output " : "input "),
> +				IP_VS_DBG_ADDR(cp->af, &cp->daddr),
> +				ntohs(cp->dport),
> +				IP_VS_DBG_ADDR(cp->af, &cp->caddr),
> +				ntohs(cp->cport),
> +				sctp_state_name(cp->state),
> +				sctp_state_name(next_state),
> +				atomic_read(&cp->refcnt));
> +		if (dest) {
> +			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
> +				(next_state !=3D IP_VS_SCTP_S_ESTABLISHED)) {
> +				atomic_dec(&dest->activeconns);
> +				atomic_inc(&dest->inactconns);
> +				cp->flags |=3D IP_VS_CONN_F_INACTIVE;
> +			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
> +				   (next_state =3D=3D IP_VS_SCTP_S_ESTABLISHED)) {
> +				atomic_inc(&dest->activeconns);
> +				atomic_dec(&dest->inactconns);
> +				cp->flags &=3D ~IP_VS_CONN_F_INACTIVE;
> +			}
> +		}
> +	}
> +
> +	 cp->timeout =3D pp->timeout_table[cp->state =3D next_state];
> +
> +	 return 1;
> +}
> +
> +static int
> +sctp_state_transition(struct ip_vs_conn *cp, int direction,
> +		const struct sk_buff *skb, struct ip_vs_protocol *pp)
> +{
> +	int ret =3D 0;
> +
> +	spin_lock(&cp->lock);
> +	ret =3D set_sctp_state(pp, cp, direction, skb);
> +	spin_unlock(&cp->lock);
> +
> +	return ret;
> +}
> +
> +/*
> + *      Hash table for SCTP application incarnations
> + */
> +#define SCTP_APP_TAB_BITS        4
> +#define SCTP_APP_TAB_SIZE        (1 << SCTP_APP_TAB_BITS)
> +#define SCTP_APP_TAB_MASK        (SCTP_APP_TAB_SIZE - 1)
> +
> +static struct list_head sctp_apps[SCTP_APP_TAB_SIZE];
> +static DEFINE_SPINLOCK(sctp_app_lock);
> +
> +static inline __u16 sctp_app_hashkey(__be16 port)
> +{
> +	return (((__force u16)port >> SCTP_APP_TAB_BITS) ^ (__force u16)por=
t)
> +		& SCTP_APP_TAB_MASK;
> +}
> +
> +static int sctp_register_app(struct ip_vs_app *inc)
> +{
> +	struct ip_vs_app *i;
> +	__u16 hash;
> +	__be16 port =3D inc->port;
> +	int ret =3D 0;
> +
> +	hash =3D sctp_app_hashkey(port);
> +
> +	spin_lock_bh(&sctp_app_lock);
> +	list_for_each_entry(i, &sctp_apps[hash], p_list) {
> +		if (i->port =3D=3D port) {
> +			ret =3D -EEXIST;
> +			goto out;
> +		}
> +	}
> +	list_add(&inc->p_list, &sctp_apps[hash]);
> +	atomic_inc(&ip_vs_protocol_sctp.appcnt);
> +out:
> +	spin_unlock_bh(&sctp_app_lock);
> +
> +	return ret;
> +}
> +
> +static void sctp_unregister_app(struct ip_vs_app *inc)
> +{
> +	spin_lock_bh(&sctp_app_lock);
> +	atomic_dec(&ip_vs_protocol_sctp.appcnt);
> +	list_del(&inc->p_list);
> +	spin_unlock_bh(&sctp_app_lock);
> +}
> +
> +static int sctp_app_conn_bind(struct ip_vs_conn *cp)
> +{
> +	int hash;
> +	struct ip_vs_app *inc;
> +	int result =3D 0;
> +
> +	/* Default binding: bind app only for NAT */
> +	if (IP_VS_FWD_METHOD(cp) !=3D IP_VS_CONN_F_MASQ)
> +		return 0;
> +	/* Lookup application incarnations and bind the right one */
> +	hash =3D sctp_app_hashkey(cp->vport);
> +
> +	spin_lock(&sctp_app_lock);
> +	list_for_each_entry(inc, &sctp_apps[hash], p_list) {
> +		if (inc->port =3D=3D cp->vport) {
> +			if (unlikely(!ip_vs_app_inc_get(inc)))
> +				break;
> +			spin_unlock(&sctp_app_lock);

Is it necessary to spin_unlock() here?
If not, out: could also spin_unlock() which would
make the locking more obvious. But as you have
done that in sctp_register_app() I guess you
have a reason for spin_unlock()ing here.

> +
> +			IP_VS_DBG_BUF(9, "%s: Binding conn %s:%u->"
> +					"%s:%u to app %s on port %u\n",
> +					__func__,
> +					IP_VS_DBG_ADDR(cp->af, &cp->caddr),
> +					ntohs(cp->cport),
> +					IP_VS_DBG_ADDR(cp->af, &cp->vaddr),
> +					ntohs(cp->vport),
> +					inc->name, ntohs(inc->port));
> +			cp->app =3D inc;
> +			if (inc->init_conn)
> +				result =3D inc->init_conn(inc, cp);
> +			goto out;
> +		}
> +	}
> +	spin_unlock(&sctp_app_lock);
> +out:
> +	return result;
> +}
> +
> +static void ip_vs_sctp_init(struct ip_vs_protocol *pp)
> +{
> +	IP_VS_INIT_HASH_TABLE(sctp_apps);
> +	pp->timeout_table =3D sctp_timeouts;
> +}
> +
> +
> +static void ip_vs_sctp_exit(struct ip_vs_protocol *pp)
> +{
> +
> +}
> +
> +struct ip_vs_protocol ip_vs_protocol_sctp =3D {
> +	.name =3D "SCTP",
> +	.protocol =3D IPPROTO_SCTP,
> +	.num_states =3D IP_VS_SCTP_S_LAST,
> +	.dont_defrag =3D 0,
> +	.appcnt =3D ATOMIC_INIT(0),
> +	.init =3D ip_vs_sctp_init,
> +	.exit =3D ip_vs_sctp_exit,
> +	.register_app =3D sctp_register_app,
> +	.unregister_app =3D sctp_unregister_app,
> +	.conn_schedule =3D sctp_conn_schedule,
> +	.conn_in_get =3D sctp_conn_in_get,
> +	.conn_out_get =3D sctp_conn_out_get,
> +	.snat_handler =3D sctp_snat_handler,
> +	.dnat_handler =3D sctp_dnat_handler,
> +	.csum_check =3D sctp_csum_check,
> +	.state_name =3D sctp_state_name,
> +	.state_transition =3D sctp_state_transition,
> +	.app_conn_bind =3D sctp_app_conn_bind,
> +	.debug_packet =3D ip_vs_tcpudp_debug_packet,
> +	.timeout_change =3D sctp_timeout_change,
> +	.set_state_timeout =3D sctp_set_state_timeout,
> +};
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_=
vs_sync.c
> index e177f0d..2b93016 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -400,6 +400,11 @@ static void ip_vs_process_message(const char *bu=
ffer, const size_t buflen)
>  					flags |=3D IP_VS_CONN_F_INACTIVE;
>  				else
>  					flags &=3D ~IP_VS_CONN_F_INACTIVE;
> +			} else if (s->protocol =3D=3D IPPROTO_SCTP) {
> +				if (state !=3D IP_VS_SCTP_S_ESTABLISHED)
> +					flags |=3D IP_VS_CONN_F_INACTIVE;
> +				else
> +					flags &=3D ~IP_VS_CONN_F_INACTIVE;
>  			}
>  			cp =3D ip_vs_conn_new(AF_INET, s->protocol,
>  					    (union nf_inet_addr *)&s->caddr,
> @@ -434,6 +439,15 @@ static void ip_vs_process_message(const char *bu=
ffer, const size_t buflen)
>  				atomic_dec(&dest->inactconns);
>  				cp->flags &=3D ~IP_VS_CONN_F_INACTIVE;
>  			}
> +		} else if ((cp->dest) && (cp->protocol =3D=3D IPPROTO_SCTP) &&
> +				(cp->state !=3D state)) {
> +			dest =3D cp->dest;
> +			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
> +					(state !=3D IP_VS_SCTP_S_ESTABLISHED)) {
> +				atomic_dec(&dest->activeconns);
> +				atomic_inc(&dest->inactconns);
> +				cp->flags &=3D ~IP_VS_CONN_F_INACTIVE;
> +			}
>  		}
> =20
>  		if (opt)
>  =20
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
