From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was on
 FIN_WAIT or TIME_WAIT
Date: Wed, 10 Dec 2014 01:37:32 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com


	Hello,

On Mon, 8 Dec 2014, Marcelo Ricardo Leitner wrote:

> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> ---
> 
> Notes:
>     Hi,
> 
>     We have a report that not doing so may cause poor load balacing if
>     applications reuse src port. With a patch like this, it would make
>     new SYNs on a given connection to drop the old one and start a new
>     one.

	People complained about UDP, such as RADIUS, etc.
I guess, for TCP it is some local client that can benefit
from balancing, it can be also a local testing tool.

>     One could say that this reuse can be done on purpose and carefully
>     as a way to cause poor load balancing to cause a DoS.
> 
>     Thing is, I'm unsure if we really should do this, as it may end up
>     doing more harm than good.
> 
>     WDYT? And if we do additional checks, like at least validating seq
>     number, would it be better?

	I think, checking of SEQ will not help, tw_recycle
works by checking the timestamp option, SEQ of SYN is
arbitrary.

	Also, not all connections can be expired, for
example controlling conns (FTP CTL), i.e. our attempt
to expire conn will not succeed if FTP DATA is still in
progress (cp->n_control != 0 check) or in some FW/TW state.

>     Thanks,
>     Marcelo
> 
>  net/netfilter/ipvs/ip_vs_core.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index 990decba1fe418e36e59a1f081fcf0e47188da29..e81a9ac3c7e4e25fb14953b7faa4ace054f51274 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1036,6 +1036,14 @@ static inline bool is_new_conn(const struct sk_buff *skb,
>  	}
>  }
>  
> +static inline bool is_new_conn_expected(const struct ip_vs_conn *cp)
> +{
> +	if (cp->protocol != IPPROTO_TCP)
> +		return false;
> +	return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> +		(cp->state == IP_VS_TCP_S_FIN_WAIT);

	For conns with cp->flags & IP_VS_CONN_F_NOOUTPUT the
FIN_WAIT state is problematic, we see only packets from
client (eg. DR method) and can not tell if server has sent its
FIN packet. I.e. diverting large transfer from one real to
another will lead to sending of FIN+ACKs from client to
new place.

	So, I'm not sure if we should restrict the FW state, eg:

	return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
	       (cp->state == IP_VS_TCP_S_FIN_WAIT &&
		(cp->flags & IP_VS_CONN_F_NOOUTPUT) &&
		time_after_eq(jiffies + cp->timeout,
			      cp->timer.expires + 1 * HZ));

	I.e. for INPUT+OUTPUT IP_VS_TCP_S_FIN_WAIT is
not expired because only one side sent FIN. For
INPUT-ONLY we can allow expiration in IP_VS_TCP_S_FIN_WAIT,
for example, when FIN+ACK was not seen recently, say in
last second?

	If such checks look dangerous we can try to expire
only in IP_VS_TCP_S_TIME_WAIT.

> +}
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1642,9 +1650,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>  	 */
>  	cp = pp->conn_in_get(af, skb, &iph, 0);
>  
> -	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
> -	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
> -	    is_new_conn(skb, &iph)) {
> +	if (cp && cp->dest && !iph.fragoffs && is_new_conn(skb, &iph) &&
> +	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) &&
> +	      unlikely(!atomic_read(&cp->dest->weight))) ||
> +	     unlikely(is_new_conn_expected(cp)))) {

	This check can be optimized:

	if (!iph.fragoffs && is_new_conn(skb, &iph) && cp &&
	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
	      unlikely(!atomic_read(&cp->dest->weight))) ||
	     unlikely(is_new_conn_expected(cp)))) {

>  		ip_vs_conn_expire_now(cp);
>  		__ip_vs_conn_put(cp);
>  		cp = NULL;
> -- 
> 1.9.3

Regards

--
Julian Anastasov <ja@ssi.bg>
