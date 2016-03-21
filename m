From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvs: handle outgoing messages in SIP persistence engine
Date: Mon, 21 Mar 2016 23:08:30 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1603212216260.1760@ja.home.ssi.bg>
References: <56df0925.qHrv/3RM88lO4eNe%marcoangaroni@gmail.com> <alpine.LFD.2.11.1603192021230.1621@ja.home.ssi.bg> <CANHHuCXVMM7jVjCF7NwQPkwBf=zMARR2MzYBv78uhy9Paf_6qQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CANHHuCXVMM7jVjCF7NwQPkwBf=zMARR2MzYBv78uhy9Paf_6qQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 21 Mar 2016, Marco Angaroni wrote:

> - In my opinion it's reasonable that IPVS handles only SIP traffic and
> not media traffic. RTP     packets typically follow a different path
> and don't need to traverse a load-balancer.

	I see, ok

> - I find OPS mode a good compromise for balancing multiple SIP calls
> coming from the same IP/port over UDP. However it's fundamental that
> outgoing packets have source-nat applied, so that internal topology is
> hidden. And also that call-id is learned in the "out" way. These are
> the main reason behind my patches.

	ok

> - One additional missing big feature is probably the possibility to
> keep the connection template (where call-id is stored) alive for the
> entire SIP call instead of a timer-based management. This would be
> useful for stateful real-servers that don't have a shared DB.

	In OPS mode the connection templates are alone.
May be PE-SIP can modify the ct timer depending on the
SIP method, session timer, I don't know. Even BYE can be lost,
so we should have timer in every case.

> - Seems that conntrack for SIP has problems in handling multiple SIP
> calls using the same UDP src and dest tuple, so at the moment we
> cannot rely on nf_nat_sip for SIP packet mangling.
> 
> For the suggested implementations, in short:
> 
> - I agree with all modifications, but I still can't find a solution
> for fwmark services (cannot retrieve vaddr in the "out" phase).

	I see. So, one should use non-fwmark service to
get proper handling for SNAT connections.

> - Ignoring real-server port in ip_vs_get_real_service() would break my
> use-case where there are multiple virtual-services that are associated
> to the same internal ip address but with different ports.

	ok

> > 1. Use OPS:
> >         - PRO:
> >                 - Can route every UDP packet to different real server
> >         - CON:
> >                 - No SYNC: ip_vs_sync_conn does not support SYNC for OPS
> 
> Haven't tested yet IPVS redundancy, but in source code I see that
> connection templates are synced, only OPS connections are not, but
> since they last just the time to forward the packet, this seems
> reasonable and it should not prevent you from having a redundant
> system. Correct ?

	Yep

> >                 - Performance problems: connections are allocated
> >                 and released for every packet. Does not look so fatal
> >                 for calls where the media connection has more traffic
> >                 than the SIP connection. But what if media is also
> >                 forwarded in OPS mode?
> 
> I fear that with OPS + SIP_pe media would probably be dropped because
> callid search would fail, while with OPS-only media would go to random
> RS at each packet. I would not make
> media traverse IPVS Load-Balancer, wouldn't iptables rules be better
> to simply NAT media packets from outside to inside ?

	Yes, this needs more investigation...

> 
> >                 - bad for NAT because OPS supports only requests,
> >                 not replies
> >                 - OPS is disabled for TCP but anyways, TCP can not be
> >                 routed per Call-ID, not mention SSL
> >
> 
> To my knowledge, if SIP is over TCP, you can just balance TCP
> connections (this is probably where IPVS works best) and ignore what's
> inside TCP payload. With TCP you won't have multiple connections with
> same L4 ports, and I think it's unlikely to have a single TCP
> connection transporting so many SIP calls that they need to be
> distributed to different real-servers.

	My concern was if fwmark service is used with OPS
and when UDP and TCP are used at the same time for same
Call-ID.

> > 2. Do not use OPS:
> >         - PRO:
> >                 - Performance: no per-packet connection reallocations
> >                 - works ok with many connections with different CIP
> >                 - with persistence even the media can be routed to the
> >                 same real server by using fwmark-based virtual service.
> >                 - SYNC for UDP is supported
> >                 - Netfilter conntrack is supported, this can allow
> >                 one day IPVS-SIP to support expectations for media
> >                 connections
> 
> I would add that no-OPS would be useful in SIP scenarios where you
> have many clients each having a different source-IP/port and making a
> single SIP call per source-IP/port.

	Yes, this is 2nd item in above PRO

> BTW, I noticed that conntrack object, with OPS + SIP_pe, is created
> and destroyed at each packet, so it is not able to evolve its state.
> Even if you prevent conntrack destroy inside ip_vs_conn_expire(),
> conntrack is not able to distinguish multiple SIP calls inside the
> same tuple IP/port.

	Yes

> >         May be a new optional svc->pe->conn_out method can be
> > set to some generic function, like your new __ip_vs_new_conn_out.
> > Just like ip_vs_has_real_service can find dest and its svc
> > we can create new function to call the conn_out method under
> > RCU lock. The sysctl var should not be needed.
> >
> 
> ok, I will try to do that.

	We should protect it with ipvs->conn_out_counter:

	if (atomic_read(&ipvs->conn_out_counter)) {
		find RS, svc, PE
		try to create outgoing connection
	}

	The conn_out_counter should be changed like
ftpsvc_counter but also in ip_vs_edit_service near
the rcu_assign_pointer(svc->pe, pe) where we can check
presence of the conn_out method.

> >         I prefer that we should support the fwmark case,
> > we should risk and use the packet's sport as vport.
> 
> The problem with fwmark services is that I can't find vaddr anywhere
> (it's not written inside svc data). vaddr is fundamental to perform
> SNAT inside handle_response() and seems to be present only in
> connection objects created in the "in" direction, that with OPS are
> destroyed. If you don't use OPS you would have probably a matching
> connection before this part.

	The vport does not matter much in SIP but the
vaddr may be expected by the remote side. So, we will
ignore the fwmark case for now...

> > Unfortunately, rs_table is hashed by dport. If the fwmark
> > service balances media ports the RPORT should be set to 0
> > but then functions like ip_vs_has_real_service can not
> > find it. May be ip_vs_rs_hashkey should be relaxed and
> > dport should not be used as hash key, so that we can also
> > find real servers with dport 0 while walking the list.
> >
> 
> Ignoring RS port would impact the case where you have many virtual
> services exposed (possibly on different subnets) and one single
> internal network for real servers. You might have the same real server
> ip address (but different ports) associated to different virtual
> services, so you can't match univocally the svc based on packet
> source.
> Ex.
> SVC 1.1.1.1:5060 <-> RS 10.10.10.1:5060
> SVC 2.2.2.2:5060 <-> RS 10.10.10.1:5070

	Agreed

> >         The ip_vs_check_template was lost? Is it needed?
> >
> 
> looks ip_vs_check_template() is needed only to check RS reachability
> in the outside-to-inside direction. Since we are processing a packet
> coming from a RS we can safely assume it is alive.

	ok

Regards

--
Julian Anastasov <ja@ssi.bg>
