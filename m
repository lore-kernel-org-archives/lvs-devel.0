From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was
 on FIN_WAIT or TIME_WAIT
Date: Thu, 11 Dec 2014 10:44:31 -0200
Message-ID: <548991AF.1050502@redhat.com>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com> <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg> <54883DCA.7050906@redhat.com> <54887B3C.2000709@redhat.com> <alpine.LFD.2.11.1412102217500.4043@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412102217500.4043@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com

On 10-12-2014 19:27, Julian Anastasov wrote:
>
> 	Hello,
>
> On Wed, 10 Dec 2014, Marcelo Ricardo Leitner wrote:
>
>>>>      return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
>>>>             (cp->state == IP_VS_TCP_S_FIN_WAIT &&
>>>>          (cp->flags & IP_VS_CONN_F_NOOUTPUT) &&
>>>>          time_after_eq(jiffies + cp->timeout,
>>>>                    cp->timer.expires + 1 * HZ));
>>>>
>>>>      I.e. for INPUT+OUTPUT IP_VS_TCP_S_FIN_WAIT is
>>>> not expired because only one side sent FIN. For
>>>
>>> And when the other side send it too, it will be in TIME_WAIT then. Ok.
>
> 	Yes, for IPVS-NAT TIME_WAIT means both sides closed.
>
>>>>      If such checks look dangerous we can try to expire
>>>> only in IP_VS_TCP_S_TIME_WAIT.
>>>
>>> Or only enable it within some sysctl, like we have expire_nodest_conn? We
>>> could have a "(tcp_)rebalance_on_port_reuse" or something like that.
>>
>> Actually, I'm more for this tunable than a timeout, as it would allow one to
>> easily rebalance the cluster when one add new nodes. More like:
>>
>>       return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
>> 	    (sysctl_tcp_reschedule_on_syn &&
>> 	     cp->state == IP_VS_TCP_S_FIN_WAIT &&
>> 	     (cp->flags & IP_VS_CONN_F_NOOUTPUT));
>>
>> Then we play safe, leave that sysctl_tcp_reschedule_on_syn off by default, but
>> one may use it when applicable. WDYT?
>
> 	Agreed, a sysctl var is ok. Only that my preference
> is to have sysctl var that is checked even before
> is_new_conn() call to save some CPU cycles for a rare packet
> such as SYN :)
>
> 	In theory, skb_header_pointer() is fast and we will
> get pointer to header in the common case (without copy) but
> checks here and there cost some cycles...
>
> 	One option would be to implement "conn_reuse_mode"
> as a bitmask (for now 2 bits), values 0, 1 or 3:
>
> 0: do not call is_new_conn(), even for sysctl_expire_nodest_conn()
> purposes. Fastest but without any expiation (reuse always).
>
> 1: default: TIME_WAIT-only check for TCP,
> allow the sysctl_expire_nodest_conn check for TCP/SCTP.
> In fact, check for this state is the global conn_reuse_mode != 0.
>
> 3 (&2 if treated as bitmask): like 1 but also
> allows DR/TUN in FIN_WAIT to expire (int conn_reuse_mode can
> come as argument):
>
> 	return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> 	       ((conn_reuse_mode & 2) &&
> 		cp->state == IP_VS_TCP_S_FIN_WAIT &&
> 		(cp->flags & IP_VS_CONN_F_NOOUTPUT));
>
> 	In fact, 2 and 3 will do the same.
>
> 	Then we will have:
>
> 	int conn_reuse_mode;
>
> 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> 	if (conn_reuse_mode && !iph.fragoffs &&
> 	    is_new_conn(skb, &iph) && cp &&
> 	    ...
> 	    unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {

Looks great! Thanks for all the directions.

One question: at this if(), shouldn't we also check for &cp->n_control or you 
considered it in the '...'? Because as you said, if this connection controls 
another one we won't expire it and AFAICT we may end up with two duplicate 
entries for the given src host/port/service.

Currently I'm with:
         if (conn_reuse_mode && !iph.fragoffs &&
             is_new_conn(skb, &iph) && cp &&
             !atomic_read(&cp->n_control) &&
             ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
               unlikely(!atomic_read(&cp->dest->weight))) ||
              unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {

Thanks,
Marcelo

> 	conn_reuse_mode=0 will work as global disable for reuse.
> But 1 will be the default value.
>
> 	You can grep in following way to see the places that
> define sysctl vars, "backup_only" is a good example to use
> as reference:
> # grep -r backup_only include/net/ip_vs.h net/netfilter/ipvs/
>
> 	Order of vars in struct, vs_vars and
> ip_vs_control_net_init_sysctl() should be same, we
> have per-netns vars. You can add the new var after backup_only.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

