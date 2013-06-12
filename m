From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: sloppy TCP and SCTP
Date: Wed, 12 Jun 2013 22:43:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306122229120.1773@ja.ssi.bg>
References: <20130612104754.GA29327@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130612104754.GA29327@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Wed, 12 Jun 2013, Alexander Frolkin wrote:

> This adds support for sloppy TCP and SCTP mode to IPVS.
> 
> When enabled (sysctls net.ipv4.vs.sloppy_tcp and
> net.ipv4.vs.sloppy_sctp), allows IPVS to create connection state on any
> packet, not just a TCP SYN (or SCTP INIT).
> 
> This allows connections to fail over from one IPVS director to another
> mid-flight.
> 
> Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>

	extra empty line here

> 
> ---

> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 8646488..fd8f587 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c

> @@ -27,13 +28,14 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  	if (sch == NULL)
>  		return 0;
>  	net = skb_net(skb);
> +	ipvs = net_ipvs(net);
>  	rcu_read_lock();
> -	if ((sch->type == SCTP_CID_INIT) &&
> +	if ((sysctl_sloppy_sctp(ipvs) || (sch->type == SCTP_CID_INIT)) &&

	Can you change the above line to:

	if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&

	i.e.

1. No () around sch->type == SCTP_CID_INIT

2. Check for sch->type == SCTP_CID_INIT is usually true,
so lets try it first

> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index 50a1594..3fd23fa 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c

> @@ -46,14 +47,15 @@ tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  		return 0;
>  	}
>  	net = skb_net(skb);
> +	ipvs = net_ipvs(net);
>  	/* No !th->ack check to allow scheduling on SYN+ACK for Active FTP */
>  	rcu_read_lock();
> -	if (th->syn &&
> +	if ((sysctl_sloppy_tcp(ipvs) || th->syn) && !th->rst &&

	Same here:

	if ((th->syn || sysctl_sloppy_tcp(ipvs)) && !th->rst &&

	Also, you can check the "IPVS" entry in the
MAINTAINERS file for actual list of addresses to use (M and L)
when submitting patches.

Regards

--
Julian Anastasov <ja@ssi.bg>
