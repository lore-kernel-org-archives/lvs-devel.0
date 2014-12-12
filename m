From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was
 on FIN_WAIT or TIME_WAIT
Date: Fri, 12 Dec 2014 09:58:21 -0200
Message-ID: <548AD85D.1070109@redhat.com>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com> <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg> <54883DCA.7050906@redhat.com> <54887B3C.2000709@redhat.com> <alpine.LFD.2.11.1412102217500.4043@ja.home.ssi.bg> <548991AF.1050502@redhat.com> <alpine.LFD.2.11.1412112207350.2098@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1412112207350.2098@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com

Hi,

On 11-12-2014 20:39, Julian Anastasov wrote:
>
> 	Hello,
>
> On Thu, 11 Dec 2014, Marcelo Ricardo Leitner wrote:
>
>> On 10-12-2014 19:27, Julian Anastasov wrote:
>>>
>>>   int conn_reuse_mode;
>>>
>>>   conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
>>>   if (conn_reuse_mode && !iph.fragoffs &&
>>>       is_new_conn(skb, &iph) && cp &&
>>>       ...
>>>       unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
>>
>> Looks great! Thanks for all the directions.
>>
>> One question: at this if(), shouldn't we also check for &cp->n_control or you
>> considered it in the '...'? Because as you said, if this connection controls
>> another one we won't expire it and AFAICT we may end up with two duplicate
>> entries for the given src host/port/service.
>>
>> Currently I'm with:
>>          if (conn_reuse_mode && !iph.fragoffs &&
>>              is_new_conn(skb, &iph) && cp &&
>>              !atomic_read(&cp->n_control) &&
>>              ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
>>               unlikely(!atomic_read(&cp->dest->weight))) ||
>>               unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
>
> 	I think, the cp->n_control check is not needed,
> we can live with many connections... in master server.

Okay, good.

> 	But it looks like the new mechanism opens the door
> for problems with the sync protocol. The master will
> send sync messages for the new connection that we
> create but backup server will hit the old connection
> that can be to another real server (daddr). Backup will update
> the cp->flags and cp->state but cp->dest can not be changed.
> Our old (expired) connection will try to send sync messages
> but as its state does not change ip_vs_sync_conn_needed()
> will prevent the sending for FW/TW. Even if the old connection
> does not cause problems, the new connection is not properly synced,
> ip_vs_proc_conn() will call ip_vs_conn_in_get() and
> we do not notice that daddr/dport differs.
>
> 	May be it can be solved by adding daddr+dport
> comparison after the ip_vs_conn_in_get() call in
> ip_vs_proc_conn(), so that we can support multiple
> connections that differ in daddr+dport. Or even
> daddr+dport check in ip_vs_conn_in_get just for the backup.
> But even in this case there is a risk because the sync messages
> can come in random order, for example, a short connection
> is expired in TW state, we create new connection but
> the backup server gets sync messages in reverse order,
> i.e. first for the new connection.
>
> 	If above is not implemented, the
> '!(ipvs->sync_state & IP_VS_STATE_MASTER) &&' check
> should prevent the expiration. We will create new connection
> due to weight=0 but backup can remain with wrong daddr
> from the old connection, that is the price we pay on
> rescheduling to different real server.
>
> 	And may be we have to add also a cp->control check
> in is_new_conn_expected(), the reason: persistence
> should have priority. 'cp->control' check should be in
> is_new_conn_expected(). IIRC, people use expire_nodest_conn
> even for setups with persistence, so cp->control should
> not prevent rescheduling in this case. cp->control also covers
> the case with FTP DATA, such conns should use the same
> real server.
>
> 	What about:
>
> static inline bool can_expire_connection()
> {
> 	/* Controlled (FTP DATA or persistence)? */
> 	if (cp->control)
> 		return false;
> 	---> Below is the previous version, unchanged:
>          return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
>                 ((conn_reuse_mode & 2) &&
>                  cp->state == IP_VS_TCP_S_FIN_WAIT &&
>                  (cp->flags & IP_VS_CONN_F_NOOUTPUT));
> }
>
> 	New version:
>
>          conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
>          if (conn_reuse_mode && !iph.fragoffs &&
>              is_new_conn(skb, &iph) && cp &&
> 	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> 	      unlikely(!atomic_read(&cp->dest->weight))) ||
> 	     (!(ipvs->sync_state & IP_VS_STATE_MASTER) &&
> 	      unlikely(can_expire_connection(cp, conn_reuse_mode))))) {
>
> 	As result, actions by priority are as follows:
>
> - reschedule for expire_nodest_conn=1 when weight=0, even
> if daddr/dport can become different in backup, even on persistence
>
> - sync protocol is active: reuse to prevent conns with different
> real server in master and backup
>
> - reuse on persistence
>
> - reschedule on FW/TW: when no sync and no persistence
>
> - reuse, by default

TBH now I have to read more on the sync mechanism, it's been a while. I'll try 
going with the first option, a way to get this properly synced to backup 
server instead of disabling it when with sync enabled, because this last would 
put a severe limitation on this feature. I haven't seen many single node setups...

I'll get back to you by Tue I think.

Thanks,
Marcelo

