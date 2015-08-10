From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH net-next] ipvs: enable the scheduling of icmp
 packets
Date: Mon, 10 Aug 2015 23:51:10 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1508102208260.1843@ja.home.ssi.bg>
References: <1439171610-226215-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1439171610-226215-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Sun, 9 Aug 2015, Alex Gartrell wrote:

> If the schedule_icmp sysctl is set, ICMP messages for unseen flows will be
> handed off to the appropriate schedulers.  This is very necessary for us at
> Facebook, because we ECMP load balance down to the IPVS instances and rely
> on a deterministic scheduler rather than sync'ing, so a TCP SYN and an
> ICMPv6 PACKET_TOO_BIG packet are unlikely to end up on the same ipvs host.

	You mean related ICMP comes to one of the directors
because it was scheduled randomly by routers and the IPVS
scheduler will schedule it to the right real server even
if the original TCP connection is on another director?

	If I understand it correctly, this patch tries to
schedule related ICMP only, right? And it creates new
connection, for example, from ICMP-TCP_data packet?

	commit bba54de5bdd1 ("ipvs: provide iph to schedulers")
added iph to the schedule() method, now we need to provide also
"bool inverse" ? Needed only for the SH scheduler...
Another option is to add the inverse flag to struct ip_vs_iphdr.
It will benefit functions like ip_vs_leave(), ->packet_xmit,
anything that uses iph addresses.

> @@ -420,6 +420,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
>  	struct ip_vs_dest *dest;
>  	__be16 _ports[2], *pptr;
>  	unsigned int flags;
> +	__be16 client_port, svc_port;

	sport and dport looks better to me

>  	if (svc->flags & IP_VS_SVC_F_PERSISTENT)
> -		return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
> -					   iph);
> +		return ip_vs_sched_persist(svc, skb, client_port, svc_port,
> +					   ignored, iph);

	We will need inverse flag for ip_vs_sched_persist
because the addresses are reversed too :(

>  		ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
> -				      &iph->saddr, pptr[0], &iph->daddr,
> -				      pptr[1], &p);
> +				      &iph->saddr, client_port, &iph->daddr,
> +				      svc_port, &p);

	Above addresses may be reversed too.

>  		cp = ip_vs_conn_new(&p, dest->af, &dest->addr,
> -				    dest->port ? dest->port : pptr[1],
> +				    dest->port ? dest->port : svc_port,
>  				    flags, dest, skb->mark);
>  		if (!cp) {
>  			*ignored = -1;

>  	rcu_read_lock();
> -	if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&
> -	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
> -				      &iph->daddr, sh->dest))) {

	So, the inverse flag should simply imply sloppy mode?
Because if sloppy mode is disabled below code will not
schedule the ICMP for non-INIT packet... Even, we should
skip the 'sch = skb_header_pointer' code if inverse=1.
What we need is just the port to be present in skb when
inverse=1.

> +
> +	if (!sysctl_sloppy_sctp(ipvs)) {
> +		sctp_chunkhdr_t _schunkh, *sch;
> +
> +		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
> +					 sizeof(_schunkh), &_schunkh);
> +		if (!sch) {
> +			*verdict = NF_DROP;
> +			return 0;
> +		}
> +		if (sch->type != SCTP_CID_INIT) {
> +			*verdict = NF_ACCEPT;
> +			return 0;
> +		}
> +	}
> +
> +	if (inverse)
> +		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
> +					 &iph->saddr, ports[0]);
> +	else
> +		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
> +					 &iph->daddr, ports[1]);
> +
> +	if (svc) {
>  		int ignored;
>  
>  tcp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  		  int *verdict, struct ip_vs_conn **cpp,
> -		  struct ip_vs_iphdr *iph)
> +		  struct ip_vs_iphdr *iph, int inverse)
>  {
>  	struct net *net;
>  	struct ip_vs_service *svc;
>  	struct tcphdr _tcph, *th;
>  	struct netns_ipvs *ipvs;
> +	__be16 _ports[2];
> +	__be16 *ports = NULL;
>  
> -	th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
> -	if (th == NULL) {
> +	net = skb_net(skb);
> +	ipvs = net_ipvs(net);
> +
> +	if (sysctl_sloppy_tcp(ipvs)) {

	if (sysctl_sloppy_tcp(ipvs) || inverse) {
because inverse=1 means embedded TCP packet can be
with any flags.

> +		/* We're going to schedule any tcp that looks even vaguely
> +		 * like a tcp header (important for ICMP where many fields
> +		 * may be lost)
> +		 */
> +		ports = skb_header_pointer(
> +			skb, iph->len, sizeof(_ports), &_ports);
> +	} else {
> +		th = skb_header_pointer(
> +			skb, iph->len, sizeof(_tcph), &_tcph);
> +		if (th && th->syn && !th->rst) {
> +			/* We are not scheduling sloppily and we seem to
> +			 * have a valid SYN or SYN-ACK (for active FTP)
> +			 * here.
> +			 */
> +			ports = &th->source;
> +		}
> +	}
> +
> +	if (!ports) {

Regards

--
Julian Anastasov <ja@ssi.bg>
