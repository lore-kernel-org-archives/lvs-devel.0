From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs-next] ipvs: count pre-established TCP states as
 active
Date: Mon, 6 Jun 2016 10:23:20 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1606060943060.1691@ja.home.ssi.bg>
References: <20160603155650.292BEA0E60@unicorn.suse.cz>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20160603155650.292BEA0E60@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michal Kubecek <mkubecek@suse.cz>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>


	Hello,

On Fri, 3 Jun 2016, Michal Kubecek wrote:

> Some users observed that "least connection" distribution algorithm doesn't
> handle well bursts of TCP connections from reconnecting clients after
> a node or network failure.
> 
> This is because the algorithm counts active connection as worth 256
> inactive ones where for TCP, "active" only means TCP connections in
> ESTABLISHED state. In case of a connection burst, new connections are
> handled before previous ones have finished the three way handshaking so
> that all are still counted as "inactive", i.e. cheap ones. The become
> "active" quickly but at that time, all of them are already assigned to one
> real server (or few), resulting in highly unbalanced distribution.
> 
> Address this by counting the "pre-established" states as "active".
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

	LC and WLC are bursty by nature. May be a new
scheduler is needed that combines the LC algorithm with
WRR mode to adaptively reduce the difference in load,
especially for the case when new server is started in
a setup with many servers.

	Give me some days or week to analyze the effects of
your patch, mostly in situations of SYN attack. Note that
there can be schedulers affected by this change but I think
they will only benefit from it.
For example:

- LBLC, LBLCR: can use weight as threshold for activeconns
- NQ, SED: only activeconns are used
- OVF: weight is used as threshold for activeconns,
	inactconns are not used

	Schedulers not part of the kernel can be affacted
too. So, for now the plan is to apply this patch. If there
are other opinions, please speak up.

> ---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c | 25 +++++++++++++++++++++++--
>  1 file changed, 23 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> index d7024b2ed769..5117bcb7d2f0 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
> @@ -395,6 +395,20 @@ static const char *const tcp_state_name_table[IP_VS_TCP_S_LAST+1] = {
>  	[IP_VS_TCP_S_LAST]		=	"BUG!",
>  };
>  
> +static const bool tcp_state_active_table[IP_VS_TCP_S_LAST] = {
> +	[IP_VS_TCP_S_NONE]		=	false,
> +	[IP_VS_TCP_S_ESTABLISHED]	=	true,
> +	[IP_VS_TCP_S_SYN_SENT]		=	true,
> +	[IP_VS_TCP_S_SYN_RECV]		=	true,
> +	[IP_VS_TCP_S_FIN_WAIT]		=	false,
> +	[IP_VS_TCP_S_TIME_WAIT]		=	false,
> +	[IP_VS_TCP_S_CLOSE]		=	false,
> +	[IP_VS_TCP_S_CLOSE_WAIT]	=	false,
> +	[IP_VS_TCP_S_LAST_ACK]		=	false,
> +	[IP_VS_TCP_S_LISTEN]		=	false,
> +	[IP_VS_TCP_S_SYNACK]		=	true,
> +};
> +
>  #define sNO IP_VS_TCP_S_NONE
>  #define sES IP_VS_TCP_S_ESTABLISHED
>  #define sSS IP_VS_TCP_S_SYN_SENT
> @@ -418,6 +432,13 @@ static const char * tcp_state_name(int state)
>  	return tcp_state_name_table[state] ? tcp_state_name_table[state] : "?";
>  }
>  
> +static bool tcp_state_active(int state)
> +{
> +	if (state >= IP_VS_TCP_S_LAST)
> +		return false;
> +	return tcp_state_active_table[state];
> +}
> +
>  static struct tcp_states_t tcp_states [] = {
>  /*	INPUT */
>  /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
> @@ -540,12 +561,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
>  
>  		if (dest) {
>  			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
> -			    (new_state != IP_VS_TCP_S_ESTABLISHED)) {
> +			    !tcp_state_active(new_state)) {
>  				atomic_dec(&dest->activeconns);
>  				atomic_inc(&dest->inactconns);
>  				cp->flags |= IP_VS_CONN_F_INACTIVE;
>  			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
> -				   (new_state == IP_VS_TCP_S_ESTABLISHED)) {
> +				   tcp_state_active(new_state)) {
>  				atomic_inc(&dest->activeconns);
>  				atomic_dec(&dest->inactconns);
>  				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
> -- 
> 2.8.3

Regards
