From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: update real-server binding of outgoing connections
 in SIP-pe
Date: Mon, 16 May 2016 22:59:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1605162258001.1938@ja.home.ssi.bg>
References: <573a00d1.QuXMcymwFEM1R+Xz%marcoangaroni@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <573a00d1.QuXMcymwFEM1R+Xz%marcoangaroni@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Mon, 16 May 2016, Marco Angaroni wrote:

> Previous patch that introduced handling of outgoing packets in SIP
> persistent-engine did not call ip_vs_check_template() in case packet was
> matching a connection template. Assumption was that real-server was 
> healthy, since it was sending a packet just in that moment.
> 
> There are however real-server fault conditions requiring that association
> between call-id and real-server (represented by connection template)
> gets updated. Here is an example of the sequence of events:
>   1) RS1 is a back2back user agent that handled call-id1 and call-id2
>   2) RS1 is down and was marked as unavailable
>   3) new message from outside comes to IPVS with call-id1
>   4) IPVS reschedules the message to RS2, which becomes new call handler
>   5) RS2 forwards the message outside, translating call-id1 to call-id2
>   6) inside pe->conn_out() IPVS matches call-id2 with existing template
>   7) IPVS does not change association call-id2 <-> RS1
>   8) new message comes from client with call-id2
>   9) IPVS reschedules the message to a real-server potentially different
>      from RS2, which is now the correct destination
> 
> This patch introduces ip_vs_check_template() call in the handling of
> outgoing packets for SIP-pe. And also introduces a second optional
> argument for ip_vs_check_template() that allows to check if dest
> associated to a connection template is the same dest that was identified
> as the source of the packet. This is to change the real-server bound to a
> particular call-id independently from its availability status: the idea
> is that it's more reliable, for in->out direction (where internal
> network can be considered trusted), to always associate a call-id with
> the last real-server that used it in one of its messages. Think about
> above sequence of events where, just after step 5, RS1 returns instead
> to be available.
> 
> Comparison of dests is done by simply comparing pointers to struct
> ip_vs_dest; there should be no cases where struct ip_vs_dest keeps its
> memory address, but represent a different real-server in terms of
> ip-address / port.
> 
> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>

	Looks good to me.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  include/net/ip_vs.h             | 2 +-
>  net/netfilter/ipvs/ip_vs_conn.c | 5 +++--
>  net/netfilter/ipvs/ip_vs_core.c | 5 +++--
>  3 files changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 7eff508..290595e 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1232,7 +1232,7 @@ void ip_vs_conn_expire_now(struct ip_vs_conn *cp);
>  const char *ip_vs_state_name(__u16 proto, int state);
>  
>  void ip_vs_tcp_conn_listen(struct ip_vs_conn *cp);
> -int ip_vs_check_template(struct ip_vs_conn *ct);
> +int ip_vs_check_template(struct ip_vs_conn *ct, struct ip_vs_dest *cdest);
>  void ip_vs_random_dropentry(struct netns_ipvs *ipvs);
>  int ip_vs_conn_init(void);
>  void ip_vs_conn_cleanup(void);
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 2cb3c62..096a451 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -762,7 +762,7 @@ static int expire_quiescent_template(struct netns_ipvs *ipvs,
>   *	If available, return 1, otherwise invalidate this connection
>   *	template and return 0.
>   */
> -int ip_vs_check_template(struct ip_vs_conn *ct)
> +int ip_vs_check_template(struct ip_vs_conn *ct, struct ip_vs_dest *cdest)
>  {
>  	struct ip_vs_dest *dest = ct->dest;
>  	struct netns_ipvs *ipvs = ct->ipvs;
> @@ -772,7 +772,8 @@ int ip_vs_check_template(struct ip_vs_conn *ct)
>  	 */
>  	if ((dest == NULL) ||
>  	    !(dest->flags & IP_VS_DEST_F_AVAILABLE) ||
> -	    expire_quiescent_template(ipvs, dest)) {
> +	    expire_quiescent_template(ipvs, dest) ||
> +	    (cdest && (dest != cdest))) {
>  		IP_VS_DBG_BUF(9, "check_template: dest not available for "
>  			      "protocol %s s:%s:%d v:%s:%d "
>  			      "-> d:%s:%d\n",
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index a97de51..ad99837 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -321,7 +321,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>  
>  	/* Check if a template already exists */
>  	ct = ip_vs_ct_in_get(&param);
> -	if (!ct || !ip_vs_check_template(ct)) {
> +	if (!ct || !ip_vs_check_template(ct, NULL)) {
>  		struct ip_vs_scheduler *sched;
>  
>  		/*
> @@ -1153,7 +1153,8 @@ struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
>  						  vport, &param) < 0)
>  			return NULL;
>  		ct = ip_vs_ct_in_get(&param);
> -		if (!ct) {
> +		/* check if template exists and points to the same dest */
> +		if (!ct || !ip_vs_check_template(ct, dest)) {
>  			ct = ip_vs_conn_new(&param, dest->af, daddr, dport,
>  					    IP_VS_CONN_F_TEMPLATE, dest, 0);
>  			if (!ct) {
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
