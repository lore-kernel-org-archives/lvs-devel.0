From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was
 on FIN_WAIT or TIME_WAIT
Date: Wed, 10 Dec 2014 10:34:18 -0200
Message-ID: <54883DCA.7050906@redhat.com>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com> <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com

On 09-12-2014 21:37, Julian Anastasov wrote:
>
> 	Hello,
>
> On Mon, 8 Dec 2014, Marcelo Ricardo Leitner wrote:
>
>> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
>> ---
>>
>> Notes:
>>      Hi,
>>
>>      We have a report that not doing so may cause poor load balacing if
>>      applications reuse src port. With a patch like this, it would make
>>      new SYNs on a given connection to drop the old one and start a new
>>      one.
>
> 	People complained about UDP, such as RADIUS, etc.
> I guess, for TCP it is some local client that can benefit
> from balancing, it can be also a local testing tool.

So it's a new type of issue, ok. I don't have info on what their application 
is, just that it ends up reusing port numbers.

>>      One could say that this reuse can be done on purpose and carefully
>>      as a way to cause poor load balancing to cause a DoS.
>>
>>      Thing is, I'm unsure if we really should do this, as it may end up
>>      doing more harm than good.
>>
>>      WDYT? And if we do additional checks, like at least validating seq
>>      number, would it be better?
>
> 	I think, checking of SEQ will not help, tw_recycle
> works by checking the timestamp option, SEQ of SYN is
> arbitrary.

I thought for time wait assassination it would have to use a bigger seq 
together with the timestamps. But anyway, Windows (since Vista, even 8) 
doesn't use timestamps by default, unfortunately. Windows is not really 
involved, it's just to have that in mind, as by relying on timestamps we would 
be limiting the solution.

> 	Also, not all connections can be expired, for
> example controlling conns (FTP CTL), i.e. our attempt
> to expire conn will not succeed if FTP DATA is still in
> progress (cp->n_control != 0 check) or in some FW/TW state.

Interesting. I hadn't thought about this case.

>>      Thanks,
>>      Marcelo
>>
>>   net/netfilter/ipvs/ip_vs_core.c | 15 ++++++++++++---
>>   1 file changed, 12 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
>> index 990decba1fe418e36e59a1f081fcf0e47188da29..e81a9ac3c7e4e25fb14953b7faa4ace054f51274 100644
>> --- a/net/netfilter/ipvs/ip_vs_core.c
>> +++ b/net/netfilter/ipvs/ip_vs_core.c
>> @@ -1036,6 +1036,14 @@ static inline bool is_new_conn(const struct sk_buff *skb,
>>   	}
>>   }
>>
>> +static inline bool is_new_conn_expected(const struct ip_vs_conn *cp)
>> +{
>> +	if (cp->protocol != IPPROTO_TCP)
>> +		return false;
>> +	return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
>> +		(cp->state == IP_VS_TCP_S_FIN_WAIT);
>
> 	For conns with cp->flags & IP_VS_CONN_F_NOOUTPUT the
> FIN_WAIT state is problematic, we see only packets from
> client (eg. DR method) and can not tell if server has sent its
> FIN packet. I.e. diverting large transfer from one real to
> another will lead to sending of FIN+ACKs from client to
> new place.
>
> 	So, I'm not sure if we should restrict the FW state, eg:
>
> 	return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> 	       (cp->state == IP_VS_TCP_S_FIN_WAIT &&
> 		(cp->flags & IP_VS_CONN_F_NOOUTPUT) &&
> 		time_after_eq(jiffies + cp->timeout,
> 			      cp->timer.expires + 1 * HZ));
>
> 	I.e. for INPUT+OUTPUT IP_VS_TCP_S_FIN_WAIT is
> not expired because only one side sent FIN. For

And when the other side send it too, it will be in TIME_WAIT then. Ok.

> INPUT-ONLY we can allow expiration in IP_VS_TCP_S_FIN_WAIT,
> for example, when FIN+ACK was not seen recently, say in
> last second?

That's interesting.

> 	If such checks look dangerous we can try to expire
> only in IP_VS_TCP_S_TIME_WAIT.

Or only enable it within some sysctl, like we have expire_nodest_conn? We 
could have a "(tcp_)rebalance_on_port_reuse" or something like that.

>> +}
>> +
>>   /* Handle response packets: rewrite addresses and send away...
>>    */
>>   static unsigned int
>> @@ -1642,9 +1650,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
>>   	 */
>>   	cp = pp->conn_in_get(af, skb, &iph, 0);
>>
>> -	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
>> -	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
>> -	    is_new_conn(skb, &iph)) {
>> +	if (cp && cp->dest && !iph.fragoffs && is_new_conn(skb, &iph) &&
>> +	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) &&
>> +	      unlikely(!atomic_read(&cp->dest->weight))) ||
>> +	     unlikely(is_new_conn_expected(cp)))) {
>
> 	This check can be optimized:
>
> 	if (!iph.fragoffs && is_new_conn(skb, &iph) && cp &&
> 	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> 	      unlikely(!atomic_read(&cp->dest->weight))) ||
> 	     unlikely(is_new_conn_expected(cp)))) {

Yup. Okay.

I'll wait on the sysctl thing before posting as all the rest seems aligned. 
Thanks!

   Marcelo

>>   		ip_vs_conn_expire_now(cp);
>>   		__ip_vs_conn_put(cp);
>>   		cp = NULL;
>> --
>> 1.9.3
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

