From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: Re: ipvs: handle outgoing messages in SIP persistence engine
Date: Mon, 21 Mar 2016 16:50:03 +0100
Message-ID: <CANHHuCXVMM7jVjCF7NwQPkwBf=zMARR2MzYBv78uhy9Paf_6qQ@mail.gmail.com>
References: <56df0925.qHrv/3RM88lO4eNe%marcoangaroni@gmail.com>
	<alpine.LFD.2.11.1603192021230.1621@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:date:message-id:subject:from:to
         :cc:content-transfer-encoding;
        bh=aDlCzSnbLlYtNGX6VPJyiFOxSfOaw+Evm6RIpdAQT7c=;
        b=mfXw/DCLm4LEYQgvsruQp2ip3b8zHBtL+oZvPBkUgQ0Gd2Gih/5ziLOjHLs27Y0UAO
         LeyrmCiQL3iffSJ3so1/GbuMD0P5zLR49ZEIQJ8LxhrP57smBad8EPX9m2YpYg33WoDQ
         JBNbYj0/3+RMuOi66Ry0+6ntfck9Hbx4/LU1pSEaoadUDLbYjlUNFokfSM+BFHBNXupl
         FbYDGqQ9Va6RMSmHR2oo/GsyTE2Ww/SDuiUU3tsDmAkVFfhIDZR7whAbBw/4Ka+sspeE
         sWkE4DWoy5w9kykGjWc7Id/EMTRpQ+0h4xaD3D9d2xPXbM+pMJ+bcgkWr26NxL3J5wTf
         Oymg==
In-Reply-To: <alpine.LFD.2.11.1603192021230.1621@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hello,

please check my responses / comments inline.

=46or architectural aspects, in short:

- In my opinion it's reasonable that IPVS handles only SIP traffic and
not media traffic. RTP     packets typically follow a different path
and don't need to traverse a load-balancer.

- I find OPS mode a good compromise for balancing multiple SIP calls
coming from the same IP/port over UDP. However it's fundamental that
outgoing packets have source-nat applied, so that internal topology is
hidden. And also that call-id is learned in the "out" way. These are
the main reason behind my patches.

- One additional missing big feature is probably the possibility to
keep the connection template (where call-id is stored) alive for the
entire SIP call instead of a timer-based management. This would be
useful for stateful real-servers that don't have a shared DB.

- Seems that conntrack for SIP has problems in handling multiple SIP
calls using the same UDP src and dest tuple, so at the moment we
cannot rely on nf_nat_sip for SIP packet mangling.

=46or the suggested implementations, in short:

- I agree with all modifications, but I still can't find a solution
for fwmark services (cannot retrieve vaddr in the "out" phase).

- Ignoring real-server port in ip_vs_get_real_service() would break my
use-case where there are multiple virtual-services that are associated
to the same internal ip address but with different ports.

See inline for details.

Thanks,
Marco Angaroni

2016-03-19 22:27 GMT+01:00 Julian Anastasov <ja@ssi.bg>:
>
>         Hello,
>
> On Tue, 8 Mar 2016, Marco Angaroni wrote:
>
>> I=E2=80=99m trying to use IPVS as a high performance load-balancer w=
ith minimal
>> SIP-protocol awareness (routing based on Call-ID header).
>> I started from the patch by Simon Horman as described here:
>> https://lwn.net/Articles/399571/.
>
>         From point 2 looks like you are balancing SIP calls?
> How do you route the media packets?

media traffic uses another subnet (it's also handled by a different
application, driven by SIP servers), so it does not match any IPVS
virtual service.
As far as I know it is very common to separate SIP and media traffic
(often even at layer 2), especially in telco use cases.
In open-source world you can think about kamailio that, at least in
standard configuration, leaves media to be handled by endpoints.

>
>> However I found the following problems / limitations (I=E2=80=99m us=
ing LVS-NAT
>> and SIP over UDP):
>>
>>   1) To actually have load-balancing based on Call-ID header, you ne=
ed to
>>      use one-packet-scheduling (see Simon=E2=80=99s statement in abo=
ve article:
>>      =E2=80=9CIt is envisaged that the SIP persistence engine will b=
e used in
>>      conjunction with one-packet scheduling=E2=80=9D). But with one-=
packet-
>>      scheduling the connection is deleted just after packet is forwa=
rded,
>>      so SIP responses coming from real-servers do not match any conn=
ection
>>      and SNAT is not applied.
>
>         It is also possible that response is sent to
> different client port, see B.2 below.
>
>>   2) If you do not use "-o", IPVS behave as normal UDP load balancer=
, so
>>      different SIP calls (each one identified by a different Call-ID=
)
>>      coming from the same ip-address/port go to the same RS. So basi=
cally
>>      you don=E2=80=99t have load-balancing based on Call-ID as inten=
ded.
>
>         Agreed, IPVS is not good at balancing traffic
> from same port.
>
>>   3) Call-ID is not learned when a new SIP call is started by a real=
-server
>>      (inside-to-outside direction), but only in the outside-to-insid=
e
>>      direction (see also my comment on the LVS-users mailing list:
>>      http://archive.linuxvirtualserver.org/html/lvs-users/2016-01/ms=
g00000.html).
>>      This is not specific to my deploy, but would be a general probl=
em
>>      for all SIP servers acting as B2BUA
>>      (https://en.wikipedia.org/wiki/Back-to-back_user_agent).
>
>         So, the minimum is to create connection template
> for the packet sent by real server, it will hold the Call-ID
> for the second leg.
>
>>   4) One-packet-scheduling is the most expensive mode in IPVS from
>>      performance point of view: for each packet to be processed a ne=
w
>>      connection data structure is created and, after packet is sent,
>>      deleted by starting a new timer set to expire immediately.
>
>         Agreed.
>
>> Below you can find two patches that I used to solve such problems.
>> At the moment, I just would like to have your opinion as IPVS expert=
s,
>> and understand if such modifications can be considered a viable opti=
on
>> to solve problems listed above.
>> If you consider implementation is fine, I can think to submit such p=
atches
>> later. Otherwise I would be really happy to receive suggestions abou=
t
>> alternative implementations.
>
>         They are a good start for SIP...
>
>> And if I simply misunderstood something, please let me know.
>
>         IMHO, for SIP we have two options:
>
> 1. Use OPS:
>         - PRO:
>                 - Can route every UDP packet to different real server
>         - CON:
>                 - No SYNC: ip_vs_sync_conn does not support SYNC for =
OPS

Haven't tested yet IPVS redundancy, but in source code I see that
connection templates are synced, only OPS connections are not, but
since they last just the time to forward the packet, this seems
reasonable and it should not prevent you from having a redundant
system. Correct ?

>                 - Performance problems: connections are allocated
>                 and released for every packet. Does not look so fatal
>                 for calls where the media connection has more traffic
>                 than the SIP connection. But what if media is also
>                 forwarded in OPS mode?

I fear that with OPS + SIP_pe media would probably be dropped because
callid search would fail, while with OPS-only media would go to random
RS at each packet. I would not make
media traverse IPVS Load-Balancer, wouldn't iptables rules be better
to simply NAT media packets from outside to inside ?

>                 - bad for NAT because OPS supports only requests,
>                 not replies
>                 - OPS is disabled for TCP but anyways, TCP can not be
>                 routed per Call-ID, not mention SSL
>

To my knowledge, if SIP is over TCP, you can just balance TCP
connections (this is probably where IPVS works best) and ignore what's
inside TCP payload. With TCP you won't have multiple connections with
same L4 ports, and I think it's unlikely to have a single TCP
connection transporting so many SIP calls that they need to be
distributed to different real-servers.

> 2. Do not use OPS:
>         - PRO:
>                 - Performance: no per-packet connection reallocations
>                 - works ok with many connections with different CIP
>                 - with persistence even the media can be routed to th=
e
>                 same real server by using fwmark-based virtual servic=
e.
>                 - SYNC for UDP is supported
>                 - Netfilter conntrack is supported, this can allow
>                 one day IPVS-SIP to support expectations for media
>                 connections

I would add that no-OPS would be useful in SIP scenarios where you
have many clients each having a different source-IP/port and making a
single SIP call per source-IP/port.

>         - CON:
>                 - Can not route every packet to different real server=
,
>                 not without ability to support multiple connections
>                 with same CIP-VIP but different RIP. So, bad if
>                 many Call-IDs come from same client port.
>
>
>         Below I'm trying to explain it:
>
> A. Some IPVS facts that we should consider in the SIP case
>
> A.1. IPVS-SYNC (ip_vs_proc_conn) considers the CIP and VIP as
> keys to find the concerned connection with ip_vs_conn_in_get.
> Then RIP/RPORT is updated. The idea here is that the backup
> server uses its own timeouts and it can easily go out of sync
> with the master. What we want here is to avoid obsolete
> connections to live in backup if they are already expired and
> probably recreated in master. It means, currently we keep
> only one backup connection from same client port. As result,
> currently IPVS-SYNC does not support multiple connections
> with same CIP-VIP pair but with different RIP.
>
> A.2. Netfilter's conntrack uses hashing while managing the
> reply direction. When first packet in original direction
> is confirmed by __nf_conntrack_confirm, the reply tuple is
> used for the hash and later for next packets it can not be
> changed. As result, one connection can not be rerouted after
> initial NAT setup is done while forwarding the first packet.
> It means, NF Conntrack/NAT does not support multiple connections
> with same CIP-VIP pair but with different RIP. Bad for the
> non-OPS case.
>

BTW, I noticed that conntrack object, with OPS + SIP_pe, is created
and destroyed at each packet, so it is not able to evolve its state.
Even if you prevent conntrack destroy inside ip_vs_conn_expire(),
conntrack is not able to distinguish multiple SIP calls inside the
same tuple IP/port.

> A.3. Currently, __ip_vs_conn_in_get returns only first
> connection in hash, no additional lookup by Call-ID to
> support multiple connections from same client that differ
> in the used real server. Even if we want to support multiple
> connections with same CIP-VIP pair but different RIP keys
> we should be able to match the Call-ID. The problem is that
> at the first phase when we lookup for connection we do not
> know the virtual service that is used, it is searched only
> if new connection should be created. As result, we can not
> easily (without slowing down the processing of normal
> traffic) map the packet from same CIP to the correct RIP by
> using Call-ID match because the PE is configured in the
> virtual service.
>
> B. Some SIP facts that we should consider in the IPVS case
>
> B.1. Requests and responses are not always sent from well-known
> port and can be sent from ephemeral/random ports, not just for
> TCP/SCTP but also for UDP
>
> - While this is not common for real servers, clients can do this.
> The effect would be that we see same Call-ID on many connections.
> In such case, persistence (PE-SIP) may be needed to send all
> SIP packets to same real server.
>
> B.2. SIP responses are usually routed depending on the Via/sent-by,
> Call-ID does not help here.
>
> - SIP responses are usually sent to well-known port but NAT can
> change that. Sometimes response can be sent back to the same
> port ignoring the Via port (eg. in NAT case) and IPVS should find
> such connection when forwarding the response from real server.
> This happens also in the common case when client sends only from
> the well-known port. OTOH, without NAT, it is possible that client
> sends request from one ephemeral port but then the server sends
> the response to the well-known port (Via/sent-by). As result,
> it is possible that IPVS can work with packet sent by real server
> to some client port but there is no connection from this client
> port. Currently, IPVS has no support for SNAT mode, i.e. to create
> connection from response.
>

Seems that OPS mode helps here: it does not matter if response is sent
to a different port than the source port of the request, there are no
connections saved, you have only template connections for callid
match. I think it is instead important that the outgoing response is
source-natted, so that real server ip address is hidden. To have SNAT
applied, I found that you have to make the packet pass through
handle_reponse() function, and you must have a connection object with
vaddr / vport set.

> B.3. The client can be some PROTO-to-SIP gateway or proxy that sends
> from same port. This looks like a single UDP connection and
> IPVS wants to balance it packet per packet by using Call-ID,
> so that we utilize all real servers.
>
> B.4 SIP also can include media. Currently, IPVS simply relies
> on persistence to forward the client's media to the right server.
> It means SIP should be balanced with fwmark-based virtual
> service and persistence. Some questions for LVS-NAT: what happens
> if the first media packet is sent by server and not by client?
> IPVS does not have media connection yet. Also, who changes the
> media address and port in the SDP coming from real server and
> what happens if we do not mangle them?
>
>         As result, here are my concerns about using SIP with IPVS:
>
> - LVS-NAT adds questions about forwarding of responses and media
> from real server: SDP translation is needed, SIP and media
> connections should be created and used for many packets.
>
> - What if nf_conntrack_sip.c is loaded too?
>
>         IMHO, what can work currently for IPVS-SIP, in theory:
>
> - OPS:
>         - overhead from reallocations but SIP traffic should be low
>         - overhead if media is forwarded with OPS
>         - good for DR/TUN, not for NAT because SIP has replies,
>         sometimes sent to other port
>         - only for UDP
>
> - to support TCP, SSL, SCTP together with UDP:
>         - fwmark-based virtual service for all SIP protos
>
> - to support media connections:
>         - fwmark-based virtual service for all SIP protos and
>         media protos/port ranges, with persistence
>         - not supported by PE-SIP?
>         - LVS-DR or LVS-TUN
>         - LVS-NAT needs SDP mangling support which is missing
>
>>   p1) The basic idea is to make packets, that do not match any exist=
ent
>>       connection but come from real-servers, create new connections =
instead
>>       of let them pass without any effect. This is the opposite of t=
he
>>       behaviour enabled by sysctl_nat_icmp_send, where packets that =
do not
>>       match a connection but come from a RS generate an ICMP message=
 back.
>>
>>       When such packets pass through ip_vs_out(), if their source ip
>>       address and source port match a configured real-server, a new
>>       connection is automatically created in the same way as it woul=
d have
>>       happened if the packet had come from outside-to-inside directi=
on.
>>       A new connection template is created too, if the virtual-servi=
ce is
>>       persistent and there is no matching connection template found.
>>       The new connection automatically created, if the service had "=
-o"
>>       option, is an OPS connection that lasts only the time to forwa=
rd the
>>       packet, just like it happens on the ingress side.
>>
>>       This behavior should obviously be made configurable by adding =
a
>>       specific sysctl (not implemented yet).
>
>         May be a new optional svc->pe->conn_out method can be
> set to some generic function, like your new __ip_vs_new_conn_out.
> Just like ip_vs_has_real_service can find dest and its svc
> we can create new function to call the conn_out method under
> RCU lock. The sysctl var should not be needed.
>

ok, I will try to do that.

>>       This fixes problems 1) and 3) and keeps OPS mode mandatory for=
 SIP-UDP,
>>       so 2) would not be a problem anymore.
>>
>>       The following requisites are needed for automatic connection c=
reation;
>>       if any is missing the packet simply goes the same way as usual=
=2E
>>       -  Virtual-Service is not fwmark based (this is because fwmark=
 services
>>          do not store address and port of the Virtual-Service, requi=
red to
>>          build the connection data).
>>       -  Virtual-Service and real-servers must not have been configu=
red with
>>          omitted port (this is again to have all data to create the
>>          connection).
>
>         I prefer that we should support the fwmark case,
> we should risk and use the packet's sport as vport.

The problem with fwmark services is that I can't find vaddr anywhere
(it's not written inside svc data). vaddr is fundamental to perform
SNAT inside handle_response() and seems to be present only in
connection objects created in the "in" direction, that with OPS are
destroyed. If you don't use OPS you would have probably a matching
connection before this part.

> Unfortunately, rs_table is hashed by dport. If the fwmark
> service balances media ports the RPORT should be set to 0
> but then functions like ip_vs_has_real_service can not
> find it. May be ip_vs_rs_hashkey should be relaxed and
> dport should not be used as hash key, so that we can also
> find real servers with dport 0 while walking the list.
>

Ignoring RS port would impact the case where you have many virtual
services exposed (possibly on different subnets) and one single
internal network for real servers. You might have the same real server
ip address (but different ports) associated to different virtual
services, so you can't match univocally the svc based on packet
source.
Ex.
SVC 1.1.1.1:5060 <-> RS 10.10.10.1:5060
SVC 2.2.2.2:5060 <-> RS 10.10.10.1:5070

>>   p2) A costly operation done by OPS for every packet is the start o=
f timer
>>       to free the connection data. Instead of starting a timer to ma=
ke
>>       it expire immediately, I found it=E2=80=99s more efficient to =
call the expire
>>       callback directly (under certain conditions). In my tests, thi=
s more
>>       than halved CPU usage at high loads on a virtual-machine with =
a single
>>       CPU, and seemed a good improvement for issue described in 4).
>
>         ok
>
>> Thanks in advance,
>> Marco Angaroni
>>
>> Subject: [PATCH 1/2] handle connections started by real-servers
>>
>> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
>> ---
>>  include/net/ip_vs.h             |   4 ++
>>  net/netfilter/ipvs/ip_vs_core.c | 142 +++++++++++++++++++++++++++++=
+++++++++++
>>  net/netfilter/ipvs/ip_vs_ctl.c  |  31 +++++++++
>>  3 files changed, 177 insertions(+)
>>
>> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
>> index 0816c87..28db660 100644
>> --- a/include/net/ip_vs.h
>> +++ b/include/net/ip_vs.h
>> @@ -1378,6 +1378,10 @@ ip_vs_service_find(struct netns_ipvs *ipvs, i=
nt af, __u32 fwmark, __u16 protocol
>>  bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 =
protocol,
>>                           const union nf_inet_addr *daddr, __be16 dp=
ort);
>>
>> +struct ip_vs_dest *
>> +ip_vs_get_real_service(struct netns_ipvs *ipvs, int af, __u16 proto=
col,
>> +                    const union nf_inet_addr *daddr, __be16 dport);
>> +
>>  int ip_vs_use_count_inc(void);
>>  void ip_vs_use_count_dec(void);
>>  int ip_vs_register_nl_ioctl(void);
>> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip=
_vs_core.c
>> index f57b4dc..e3f5a70 100644
>> --- a/net/netfilter/ipvs/ip_vs_core.c
>> +++ b/net/netfilter/ipvs/ip_vs_core.c
>> @@ -1099,6 +1099,132 @@ static inline bool is_new_conn_expected(cons=
t struct ip_vs_conn *cp,
>>       }
>>  }
>>
>> +/* Creates a new connection for outgoing packets which are consider=
ed
>> + * requests initiated by the real server, so that subsequent respon=
ses from
>> + * external client are routed to the right real server.
>> + *
>> + * Pre-requisites:
>> + * 1) Real Server is identified by searching source ip-address and
>> + *    source port of the packet in RS table.
>> + * 2) Virtual Service is NOT fwmark based.
>> + *    In fwmark-virtual-services actual vaddr and vport are unknown=
 until
>> + *    packets are received from external network.
>
>         We should relax this somehow...
>

see above

>> + * 3) One RS is associated with only one VS.
>> + *    Otherwise the first match found is used.
>> + * 4) Virtual Service and Real Server must not have omitted port.
>> + *    This is because all paramaters to create the connection must =
be known.
>
>         this too...
>

see above

>> + *
>> + * This is outgoing packet, so:
>> + * source-ip-address of packet is address of real-server
>> + * dest-ip-address of packet is address of external client
>> + */
>> +static struct ip_vs_conn *__ip_vs_new_conn_out(struct netns_ipvs *i=
pvs, int af,
>> +                                            struct sk_buff *skb,
>> +                                            const struct ip_vs_iphd=
r *iph)
>> +{
>> +     struct ip_vs_service *svc;
>> +     struct ip_vs_conn_param pt, pc;
>> +     struct ip_vs_conn *ct =3D NULL, *cp =3D NULL;
>> +     struct ip_vs_dest *dest;
>> +     __be16 _ports[2], *pptr;
>> +     const union nf_inet_addr *vaddr, *daddr;
>> +     union nf_inet_addr snet;
>> +     __be16 vport, dport;
>> +     unsigned int flags;
>> +
>> +     EnterFunction(12);
>> +     /* get net and L4 ports
>> +      */
>> +     pptr =3D frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _port=
s, iph);
>> +     if (!pptr)
>> +             return NULL;
>> +     /* verify packet comes from a real-server and get service reco=
rd
>> +      */
>> +     dest =3D ip_vs_get_real_service(ipvs, af, iph->protocol,
>> +                                   &iph->saddr, pptr[0]);
>> +     if (!dest)
>> +             return NULL;
>> +     /* check we have all pre-requisites
>> +      */
>> +     rcu_read_lock();
>
>         This rcu_read_lock should be moved before
> calling ip_vs_get_real_service because we work with dest.
>

ok

>> +     svc =3D rcu_dereference(dest->svc);
>> +     if (!svc)
>> +             goto out_no_new_conn;
>> +     if (svc->fwmark)
>> +             goto out_no_new_conn;
>> +     vaddr =3D &svc->addr;
>> +     vport =3D svc->port;
>> +     daddr =3D &dest->addr;
>> +     dport =3D dest->port;
>> +     if (!vport || !dport)
>> +             return NULL;
>> +     /* for persistent service first create connection template
>> +      */
>> +     if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
>> +             /* apply netmask the same way ingress-side does
>> +              */
>> +#ifdef CONFIG_IP_VS_IPV6
>> +             if (af =3D=3D AF_INET6)
>> +                     ipv6_addr_prefix(&snet.in6, &iph->daddr.in6,
>> +                                      (__force __u32)svc->netmask);
>> +             else
>> +#endif
>> +                     snet.ip =3D iph->daddr.ip & svc->netmask;
>> +             /* fill params and create template if not existent
>> +              */
>> +             if (ip_vs_conn_fill_param_persist(svc, skb, iph->proto=
col,
>> +                                               &snet, 0, vaddr,
>> +                                               vport, &pt) < 0)
>> +                     goto out_no_new_conn;
>> +             ct =3D ip_vs_ct_in_get(&pt);
>> +             if (!ct) {
>
>         The ip_vs_check_template was lost? Is it needed?
>

looks ip_vs_check_template() is needed only to check RS reachability
in the outside-to-inside direction. Since we are processing a packet
coming from a RS we can safely assume it is alive.

>> +                     ct =3D ip_vs_conn_new(&pt, dest->af, daddr, dp=
ort,
>> +                                         IP_VS_CONN_F_TEMPLATE, des=
t, 0);
>> +                     if (!ct) {
>> +                             kfree(pt.pe_data);
>> +                             goto out_no_new_conn;
>> +                     }
>> +                     ct->timeout =3D svc->timeout;
>> +             } else {
>> +                     kfree(pt.pe_data);
>> +             }
>> +     }
>> +     /* connection flags
>> +      */
>> +     flags =3D ((svc->flags & IP_VS_SVC_F_ONEPACKET) &&
>> +              iph->protocol =3D=3D IPPROTO_UDP) ? IP_VS_CONN_F_ONE_=
PACKET : 0;
>> +     /* create connection
>> +      */
>> +     ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol,
>> +                           &iph->daddr, pptr[1], vaddr, vport, &pc)=
;
>> +     cp =3D ip_vs_conn_new(&pc, dest->af, daddr, dport, flags, dest=
, 0);
>> +     if (!cp) {
>> +             ip_vs_conn_put(ct);
>> +             goto out_no_new_conn;
>> +     }
>> +     if (ct) {
>> +             ip_vs_control_add(cp, ct);
>> +             ip_vs_conn_put(ct);
>> +     }
>> +     ip_vs_conn_stats(cp, svc);
>> +     rcu_read_unlock();
>> +     /* return connection (will be used to handle outgoing packet)
>> +      */
>> +     IP_VS_DBG_BUF(6, "New connection RS-initiated:%c c:%s:%u v:%s:=
%u "
>> +                   "d:%s:%u conn->flags:%X conn->refcnt:%d\n",
>> +                   ip_vs_fwd_tag(cp),
>> +                   IP_VS_DBG_ADDR(svc->af, &cp->caddr), ntohs(cp->c=
port),
>> +                   IP_VS_DBG_ADDR(svc->af, &cp->vaddr), ntohs(cp->v=
port),
>> +                   IP_VS_DBG_ADDR(svc->af, &cp->daddr), ntohs(cp->d=
port),
>> +                   cp->flags, atomic_read(&cp->refcnt));
>> +     LeaveFunction(12);
>> +     return cp;
>> +
>> +out_no_new_conn:
>> +     rcu_read_unlock();
>> +     return NULL;
>> +}
>> +
>>  /* Handle response packets: rewrite addresses and send away...
>>   */
>>  static unsigned int
>> @@ -1244,6 +1370,22 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned i=
nt hooknum, struct sk_buff *skb, in
>>
>>       if (likely(cp))
>>               return handle_response(af, skb, pd, cp, &iph, hooknum)=
;
>> +     if (1 && /* TODO: test against specific systctl */
>> +         (pp->protocol =3D=3D IPPROTO_UDP)) {
>> +             /* Connection oriented protocols should not need this.
>> +              * Outgoing TCP / SCTP connections can be handled sepa=
rately
>> +              * with specific iptables rules.
>> +              *
>> +              * Instead with UDP transport all packets (incoming re=
quests +
>> +              * related responses, outgoing requests + related resp=
onses)
>> +              * might use the same set of UDP ports and pass throug=
h the LB,
>> +              * so we must create connections that allow all respon=
ses to be
>> +              * directed to the right RS and avoid them to be balan=
ced.
>> +              */
>> +             cp =3D __ip_vs_new_conn_out(ipvs, af, skb, &iph);
>> +             if (likely(cp))
>> +                     return handle_response(af, skb, pd, cp, &iph, =
hooknum);
>> +     }
>>       if (sysctl_nat_icmp_send(ipvs) &&
>>           (pp->protocol =3D=3D IPPROTO_TCP ||
>>            pp->protocol =3D=3D IPPROTO_UDP ||
>> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_=
vs_ctl.c
>> index e7c1b05..c8ad6f1 100644
>> --- a/net/netfilter/ipvs/ip_vs_ctl.c
>> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>> @@ -567,6 +567,37 @@ bool ip_vs_has_real_service(struct netns_ipvs *=
ipvs, int af, __u16 protocol,
>>       return false;
>>  }
>>
>> +/* Get real service record by <proto,addr,port>.
>> + * In case of multiple records with the same <proto,addr,port>, onl=
y
>> + * the first found record is returned.
>> + */
>> +struct ip_vs_dest *ip_vs_get_real_service(struct netns_ipvs *ipvs, =
int af,
>> +                                       __u16 protocol,
>> +                                       const union nf_inet_addr *da=
ddr,
>> +                                       __be16 dport)
>> +{
>> +     unsigned int hash;
>> +     struct ip_vs_dest *dest;
>> +
>> +     /* Check for "full" addressed entries */
>> +     hash =3D ip_vs_rs_hashkey(af, daddr, dport);
>> +
>> +     rcu_read_lock();
>
>         rcu_read_lock will be in caller
>

ok

>> +     hlist_for_each_entry_rcu(dest, &ipvs->rs_table[hash], d_list) =
{
>> +             if (dest->port =3D=3D dport &&
>> +                 dest->af =3D=3D af &&
>> +                 ip_vs_addr_equal(af, &dest->addr, daddr) &&
>> +                     (dest->protocol =3D=3D protocol || dest->vfwma=
rk)) {
>> +                     /* HIT */
>> +                     rcu_read_unlock();
>> +                     return dest;
>> +             }
>> +     }
>> +     rcu_read_unlock();
>> +
>> +     return NULL;
>> +}
>> +
>>  /* Lookup destination by {addr,port} in the given service
>>   * Called under RCU lock.
>>   */
>>
>> Subject: [PATCH 2/2] optimize release of connections in one-packet-s=
cheduling mode
>>
>> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
>> ---
>>  net/netfilter/ipvs/ip_vs_conn.c | 29 +++++++++++++++++++++++++++--
>>  1 file changed, 27 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip=
_vs_conn.c
>> index 85ca189..550fe3f 100644
>> --- a/net/netfilter/ipvs/ip_vs_conn.c
>> +++ b/net/netfilter/ipvs/ip_vs_conn.c
>> @@ -104,6 +104,9 @@ static inline void ct_write_unlock_bh(unsigned i=
nt key)
>>       spin_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MA=
SK].l);
>>  }
>>
>> +/* declarations
>> + */
>> +static void ip_vs_conn_expire(unsigned long data);
>>
>>  /*
>>   *   Returns hash value for IPVS connection entry
>> @@ -453,10 +456,16 @@ ip_vs_conn_out_get_proto(struct netns_ipvs *ip=
vs, int af,
>>  }
>>  EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
>>
>> +static void __ip_vs_conn_put_notimer(struct ip_vs_conn *cp)
>> +{
>> +     __ip_vs_conn_put(cp);
>> +     ip_vs_conn_expire((unsigned long)cp);
>
>         In ip_vs_conn_expire we can also call
> ip_vs_conn_rcu_free directly for the IP_VS_CONN_F_ONE_PACKET
> case to avoid RCU-callback overhead.
>

ok

>> +}
>> +
>>  /*
>>   *      Put back the conn and restart its timer with its timeout
>>   */
>> -void ip_vs_conn_put(struct ip_vs_conn *cp)
>> +static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
>>  {
>>       unsigned long t =3D (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
>>               0 : cp->timeout;
>> @@ -465,6 +474,22 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
>>       __ip_vs_conn_put(cp);
>>  }
>>
>> +void ip_vs_conn_put(struct ip_vs_conn *cp)
>> +{
>> +     if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) &&
>> +         (atomic_read(&cp->refcnt) =3D=3D 1) &&
>> +         !timer_pending(&cp->timer))
>> +             /* one-packet-scheduling and last one referencing the
>> +              * connection: try to free connection data directly
>> +              * to avoid overhead of starting a new timer.
>> +              * If someone else will ever reference the connection
>> +              * just after the atomic_read, the ip_vs_conn_expire
>> +              * will delay and call __ip_vs_conn_put_timer as usual=
=2E
>> +              */
>> +             __ip_vs_conn_put_notimer(cp);
>> +     else
>> +             __ip_vs_conn_put_timer(cp);
>> +}
>>
>>  /*
>>   *   Fill a no_client_port connection with a client port number
>> @@ -850,7 +875,7 @@ static void ip_vs_conn_expire(unsigned long data=
)
>>       if (ipvs->sync_state & IP_VS_STATE_MASTER)
>>               ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs))=
;
>>
>> -     ip_vs_conn_put(cp);
>> +     __ip_vs_conn_put_timer(cp);
>>  }
>>
>>  /* Modify timer, so that it expires as soon as possible.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
