From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvs: don't alter conntrack in OPS mode
Date: Tue, 12 Apr 2016 23:14:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604122312420.1611@ja.home.ssi.bg>
References: <5708f21f.jc8RYqMS4IkxB05t%marcoangaroni@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <5708f21f.jc8RYqMS4IkxB05t%marcoangaroni@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sat, 9 Apr 2016, Marco Angaroni wrote:

> When using OPS mode in conjunction with SIP persistent-engine, packets
> originating from the same ip-address/port could be balanced to different
> real servers, and (to properly handle SIP responses) OPS connections 
> are created in the in-out direction too, where ip_vs_update_conntrack()
> is called to modify the reply tuple.
> 
> As a result, there can be collision of conntrack tuples, causing random
> packet drops, as explained below:
> 
> conntrack1: orig=CIP->VIP, reply=RIP1->CIP
> conntrack2: orig=RIP2->CIP, reply=CIP->VIP
> 
> Tuple CIP->VIP is both in orig of conntrack1 and reply of conntrack2.
> The collision triggers packet drop inside nf_conntrack processing.
> 
> In addition, the current implementation deletes the conntrack object at
> every expire of an OPS connection (once every forwarded packet), to have
> it recreated from scratch at next packet traversing IPVS.
> 
> Since in OPS mode, by definition, we don't expect any associated 
> response, the choices implemented in this patch are:
> a) don't call nf_conntrack_alter_reply() for OPS connections inside
>    ip_vs_update_conntrack().
> b) don't delete the conntrack object at OPS connection expire.
> 
> The result is that created conntrack objects for each tuple CIP->VIP,
> RIP-N->CIP, etc. are left in UNREPLIED state and not modified by IPVS
> OPS connection management. This eliminates packet drops and leaves
> a single conntrack object for each tuple packets are sent from.
> 
> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>

	Thanks! Looks good to me. Simon, please apply.

Signed-off-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 3 ++-
>  net/netfilter/ipvs/ip_vs_nfct.c | 4 ++++
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index dd75d41..292365f 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -836,7 +836,8 @@ static void ip_vs_conn_expire(unsigned long data)
>  		if (cp->control)
>  			ip_vs_control_del(cp);
>  
> -		if (cp->flags & IP_VS_CONN_F_NFCT) {
> +		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
> +		    !(cp->flags & IP_VS_CONN_F_ONE_PACKET)) {
>  			/* Do not access conntracks during subsys cleanup
>  			 * because nf_conntrack_find_get can not be used after
>  			 * conntrack cleanup for the net.
> diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
> index 30434fb..f04fd8d 100644
> --- a/net/netfilter/ipvs/ip_vs_nfct.c
> +++ b/net/netfilter/ipvs/ip_vs_nfct.c
> @@ -93,6 +93,10 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
>  	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
>  		return;
>  
> +	/* Never alter conntrack for OPS conns (no reply is expected) */
> +	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
> +		return;
> +
>  	/* Alter reply only in original direction */
>  	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
>  		return;
> -- 
> 1.8.3.1

Regards

--
Julian Anastasov <ja@ssi.bg>
