From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipvs: handle outgoing messages in SIP persistence engine
Date: Sat, 19 Mar 2016 23:27:53 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1603192021230.1621@ja.home.ssi.bg>
References: <56df0925.qHrv/3RM88lO4eNe%marcoangaroni@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1441014336-1458422874=:1621"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <56df0925.qHrv/3RM88lO4eNe%marcoangaroni@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1441014336-1458422874=:1621
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Tue, 8 Mar 2016, Marco Angaroni wrote:

> I’m trying to use IPVS as a high performance load-balancer with minimal 
> SIP-protocol awareness (routing based on Call-ID header).
> I started from the patch by Simon Horman as described here:
> https://lwn.net/Articles/399571/.

	From point 2 looks like you are balancing SIP calls?
How do you route the media packets?

> However I found the following problems / limitations (I’m using LVS-NAT
> and SIP over UDP):
> 
>   1) To actually have load-balancing based on Call-ID header, you need to
>      use one-packet-scheduling (see Simon’s statement in above article: 
>      “It is envisaged that the SIP persistence engine will be used in 
>      conjunction with one-packet scheduling”). But with one-packet-
>      scheduling the connection is deleted just after packet is forwarded, 
>      so SIP responses coming from real-servers do not match any connection 
>      and SNAT is not applied.

	It is also possible that response is sent to
different client port, see B.2 below.

>   2) If you do not use "-o", IPVS behave as normal UDP load balancer, so
>      different SIP calls (each one identified by a different Call-ID) 
>      coming from the same ip-address/port go to the same RS. So basically 
>      you don’t have load-balancing based on Call-ID as intended.

	Agreed, IPVS is not good at balancing traffic
from same port.

>   3) Call-ID is not learned when a new SIP call is started by a real-server
>      (inside-to-outside direction), but only in the outside-to-inside 
>      direction (see also my comment on the LVS-users mailing list: 
>      http://archive.linuxvirtualserver.org/html/lvs-users/2016-01/msg00000.html). 
>      This is not specific to my deploy, but would be a general problem 
>      for all SIP servers acting as B2BUA
>      (https://en.wikipedia.org/wiki/Back-to-back_user_agent).

	So, the minimum is to create connection template
for the packet sent by real server, it will hold the Call-ID
for the second leg.

>   4) One-packet-scheduling is the most expensive mode in IPVS from 
>      performance point of view: for each packet to be processed a new 
>      connection data structure is created and, after packet is sent, 
>      deleted by starting a new timer set to expire immediately.

	Agreed.

> Below you can find two patches that I used to solve such problems.
> At the moment, I just would like to have your opinion as IPVS experts,
> and understand if such modifications can be considered a viable option
> to solve problems listed above.
> If you consider implementation is fine, I can think to submit such patches
> later. Otherwise I would be really happy to receive suggestions about 
> alternative implementations.

	They are a good start for SIP...

> And if I simply misunderstood something, please let me know.

	IMHO, for SIP we have two options:

1. Use OPS:
	- PRO:
		- Can route every UDP packet to different real server
	- CON:
		- No SYNC: ip_vs_sync_conn does not support SYNC for OPS
		- Performance problems: connections are allocated
		and released for every packet. Does not look so fatal
		for calls where the media connection has more traffic
		than the SIP connection. But what if media is also
		forwarded in OPS mode?
		- bad for NAT because OPS supports only requests,
		not replies
		- OPS is disabled for TCP but anyways, TCP can not be
		routed per Call-ID, not mention SSL

2. Do not use OPS:
	- PRO:
		- Performance: no per-packet connection reallocations
		- works ok with many connections with different CIP
		- with persistence even the media can be routed to the
		same real server by using fwmark-based virtual service.
		- SYNC for UDP is supported
		- Netfilter conntrack is supported, this can allow
		one day IPVS-SIP to support expectations for media
		connections
	- CON:
		- Can not route every packet to different real server,
		not without ability to support multiple connections
		with same CIP-VIP but different RIP. So, bad if
		many Call-IDs come from same client port.


	Below I'm trying to explain it:

A. Some IPVS facts that we should consider in the SIP case

A.1. IPVS-SYNC (ip_vs_proc_conn) considers the CIP and VIP as
keys to find the concerned connection with ip_vs_conn_in_get.
Then RIP/RPORT is updated. The idea here is that the backup
server uses its own timeouts and it can easily go out of sync
with the master. What we want here is to avoid obsolete
connections to live in backup if they are already expired and
probably recreated in master. It means, currently we keep
only one backup connection from same client port. As result,
currently IPVS-SYNC does not support multiple connections
with same CIP-VIP pair but with different RIP.

A.2. Netfilter's conntrack uses hashing while managing the
reply direction. When first packet in original direction
is confirmed by __nf_conntrack_confirm, the reply tuple is
used for the hash and later for next packets it can not be
changed. As result, one connection can not be rerouted after
initial NAT setup is done while forwarding the first packet.
It means, NF Conntrack/NAT does not support multiple connections
with same CIP-VIP pair but with different RIP. Bad for the
non-OPS case.

A.3. Currently, __ip_vs_conn_in_get returns only first
connection in hash, no additional lookup by Call-ID to
support multiple connections from same client that differ
in the used real server. Even if we want to support multiple
connections with same CIP-VIP pair but different RIP keys
we should be able to match the Call-ID. The problem is that
at the first phase when we lookup for connection we do not
know the virtual service that is used, it is searched only
if new connection should be created. As result, we can not
easily (without slowing down the processing of normal
traffic) map the packet from same CIP to the correct RIP by
using Call-ID match because the PE is configured in the
virtual service.

B. Some SIP facts that we should consider in the IPVS case

B.1. Requests and responses are not always sent from well-known
port and can be sent from ephemeral/random ports, not just for
TCP/SCTP but also for UDP

- While this is not common for real servers, clients can do this.
The effect would be that we see same Call-ID on many connections.
In such case, persistence (PE-SIP) may be needed to send all
SIP packets to same real server.

B.2. SIP responses are usually routed depending on the Via/sent-by,
Call-ID does not help here.

- SIP responses are usually sent to well-known port but NAT can
change that. Sometimes response can be sent back to the same
port ignoring the Via port (eg. in NAT case) and IPVS should find
such connection when forwarding the response from real server.
This happens also in the common case when client sends only from
the well-known port. OTOH, without NAT, it is possible that client
sends request from one ephemeral port but then the server sends
the response to the well-known port (Via/sent-by). As result,
it is possible that IPVS can work with packet sent by real server
to some client port but there is no connection from this client
port. Currently, IPVS has no support for SNAT mode, i.e. to create
connection from response.

B.3. The client can be some PROTO-to-SIP gateway or proxy that sends
from same port. This looks like a single UDP connection and
IPVS wants to balance it packet per packet by using Call-ID,
so that we utilize all real servers.

B.4 SIP also can include media. Currently, IPVS simply relies
on persistence to forward the client's media to the right server.
It means SIP should be balanced with fwmark-based virtual
service and persistence. Some questions for LVS-NAT: what happens
if the first media packet is sent by server and not by client?
IPVS does not have media connection yet. Also, who changes the
media address and port in the SDP coming from real server and
what happens if we do not mangle them?

	As result, here are my concerns about using SIP with IPVS:

- LVS-NAT adds questions about forwarding of responses and media
from real server: SDP translation is needed, SIP and media
connections should be created and used for many packets.

- What if nf_conntrack_sip.c is loaded too?

	IMHO, what can work currently for IPVS-SIP, in theory:

- OPS:
	- overhead from reallocations but SIP traffic should be low
	- overhead if media is forwarded with OPS
	- good for DR/TUN, not for NAT because SIP has replies,
	sometimes sent to other port
	- only for UDP

- to support TCP, SSL, SCTP together with UDP:
	- fwmark-based virtual service for all SIP protos

- to support media connections:
	- fwmark-based virtual service for all SIP protos and
	media protos/port ranges, with persistence
	- not supported by PE-SIP?
	- LVS-DR or LVS-TUN
	- LVS-NAT needs SDP mangling support which is missing

>   p1) The basic idea is to make packets, that do not match any existent 
>       connection but come from real-servers, create new connections instead
>       of let them pass without any effect. This is the opposite of the 
>       behaviour enabled by sysctl_nat_icmp_send, where packets that do not 
>       match a connection but come from a RS generate an ICMP message back.
> 
>       When such packets pass through ip_vs_out(), if their source ip 
>       address and source port match a configured real-server, a new 
>       connection is automatically created in the same way as it would have
>       happened if the packet had come from outside-to-inside direction.
>       A new connection template is created too, if the virtual-service is 
>       persistent and there is no matching connection template found.
>       The new connection automatically created, if the service had "-o" 
>       option, is an OPS connection that lasts only the time to forward the
>       packet, just like it happens on the ingress side.
> 
>       This behavior should obviously be made configurable by adding a 
>       specific sysctl (not implemented yet).

	May be a new optional svc->pe->conn_out method can be
set to some generic function, like your new __ip_vs_new_conn_out.
Just like ip_vs_has_real_service can find dest and its svc
we can create new function to call the conn_out method under
RCU lock. The sysctl var should not be needed.

>       This fixes problems 1) and 3) and keeps OPS mode mandatory for SIP-UDP,
>       so 2) would not be a problem anymore.
> 
>       The following requisites are needed for automatic connection creation;
>       if any is missing the packet simply goes the same way as usual.
>       -  Virtual-Service is not fwmark based (this is because fwmark services
>          do not store address and port of the Virtual-Service, required to 
>          build the connection data).
>       -  Virtual-Service and real-servers must not have been configured with 
>          omitted port (this is again to have all data to create the 
>          connection).

	I prefer that we should support the fwmark case,
we should risk and use the packet's sport as vport.
Unfortunately, rs_table is hashed by dport. If the fwmark
service balances media ports the RPORT should be set to 0
but then functions like ip_vs_has_real_service can not
find it. May be ip_vs_rs_hashkey should be relaxed and
dport should not be used as hash key, so that we can also 
find real servers with dport 0 while walking the list.

>   p2) A costly operation done by OPS for every packet is the start of timer 
>       to free the connection data. Instead of starting a timer to make 
>       it expire immediately, I found it’s more efficient to call the expire
>       callback directly (under certain conditions). In my tests, this more 
>       than halved CPU usage at high loads on a virtual-machine with a single
>       CPU, and seemed a good improvement for issue described in 4).

	ok

> Thanks in advance,
> Marco Angaroni
> 
> Subject: [PATCH 1/2] handle connections started by real-servers
> 
> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> ---
>  include/net/ip_vs.h             |   4 ++
>  net/netfilter/ipvs/ip_vs_core.c | 142 ++++++++++++++++++++++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_ctl.c  |  31 +++++++++
>  3 files changed, 177 insertions(+)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 0816c87..28db660 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1378,6 +1378,10 @@ ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u32 fwmark, __u16 protocol
>  bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
>  			    const union nf_inet_addr *daddr, __be16 dport);
>  
> +struct ip_vs_dest *
> +ip_vs_get_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
> +		       const union nf_inet_addr *daddr, __be16 dport);
> +
>  int ip_vs_use_count_inc(void);
>  void ip_vs_use_count_dec(void);
>  int ip_vs_register_nl_ioctl(void);
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index f57b4dc..e3f5a70 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1099,6 +1099,132 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
>  	}
>  }
>  
> +/* Creates a new connection for outgoing packets which are considered
> + * requests initiated by the real server, so that subsequent responses from
> + * external client are routed to the right real server.
> + *
> + * Pre-requisites:
> + * 1) Real Server is identified by searching source ip-address and
> + *    source port of the packet in RS table.
> + * 2) Virtual Service is NOT fwmark based.
> + *    In fwmark-virtual-services actual vaddr and vport are unknown until
> + *    packets are received from external network.

	We should relax this somehow...

> + * 3) One RS is associated with only one VS.
> + *    Otherwise the first match found is used.
> + * 4) Virtual Service and Real Server must not have omitted port.
> + *    This is because all paramaters to create the connection must be known.

	this too...

> + *
> + * This is outgoing packet, so:
> + * source-ip-address of packet is address of real-server
> + * dest-ip-address of packet is address of external client
> + */
> +static struct ip_vs_conn *__ip_vs_new_conn_out(struct netns_ipvs *ipvs, int af,
> +					       struct sk_buff *skb,
> +					       const struct ip_vs_iphdr *iph)
> +{
> +	struct ip_vs_service *svc;
> +	struct ip_vs_conn_param pt, pc;
> +	struct ip_vs_conn *ct = NULL, *cp = NULL;
> +	struct ip_vs_dest *dest;
> +	__be16 _ports[2], *pptr;
> +	const union nf_inet_addr *vaddr, *daddr;
> +	union nf_inet_addr snet;
> +	__be16 vport, dport;
> +	unsigned int flags;
> +
> +	EnterFunction(12);
> +	/* get net and L4 ports
> +	 */
> +	pptr = frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph);
> +	if (!pptr)
> +		return NULL;
> +	/* verify packet comes from a real-server and get service record
> +	 */
> +	dest = ip_vs_get_real_service(ipvs, af, iph->protocol,
> +				      &iph->saddr, pptr[0]);
> +	if (!dest)
> +		return NULL;
> +	/* check we have all pre-requisites
> +	 */
> +	rcu_read_lock();

	This rcu_read_lock should be moved before
calling ip_vs_get_real_service because we work with dest.

> +	svc = rcu_dereference(dest->svc);
> +	if (!svc)
> +		goto out_no_new_conn;
> +	if (svc->fwmark)
> +		goto out_no_new_conn;
> +	vaddr = &svc->addr;
> +	vport = svc->port;
> +	daddr = &dest->addr;
> +	dport = dest->port;
> +	if (!vport || !dport)
> +		return NULL;
> +	/* for persistent service first create connection template
> +	 */
> +	if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
> +		/* apply netmask the same way ingress-side does
> +		 */
> +#ifdef CONFIG_IP_VS_IPV6
> +		if (af == AF_INET6)
> +			ipv6_addr_prefix(&snet.in6, &iph->daddr.in6,
> +					 (__force __u32)svc->netmask);
> +		else
> +#endif
> +			snet.ip = iph->daddr.ip & svc->netmask;
> +		/* fill params and create template if not existent
> +		 */
> +		if (ip_vs_conn_fill_param_persist(svc, skb, iph->protocol,
> +						  &snet, 0, vaddr,
> +						  vport, &pt) < 0)
> +			goto out_no_new_conn;
> +		ct = ip_vs_ct_in_get(&pt);
> +		if (!ct) {

	The ip_vs_check_template was lost? Is it needed?

> +			ct = ip_vs_conn_new(&pt, dest->af, daddr, dport,
> +					    IP_VS_CONN_F_TEMPLATE, dest, 0);
> +			if (!ct) {
> +				kfree(pt.pe_data);
> +				goto out_no_new_conn;
> +			}
> +			ct->timeout = svc->timeout;
> +		} else {
> +			kfree(pt.pe_data);
> +		}
> +	}
> +	/* connection flags
> +	 */
> +	flags = ((svc->flags & IP_VS_SVC_F_ONEPACKET) &&
> +		 iph->protocol == IPPROTO_UDP) ? IP_VS_CONN_F_ONE_PACKET : 0;
> +	/* create connection
> +	 */
> +	ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol,
> +			      &iph->daddr, pptr[1], vaddr, vport, &pc);
> +	cp = ip_vs_conn_new(&pc, dest->af, daddr, dport, flags, dest, 0);
> +	if (!cp) {
> +		ip_vs_conn_put(ct);
> +		goto out_no_new_conn;
> +	}
> +	if (ct) {
> +		ip_vs_control_add(cp, ct);
> +		ip_vs_conn_put(ct);
> +	}
> +	ip_vs_conn_stats(cp, svc);
> +	rcu_read_unlock();
> +	/* return connection (will be used to handle outgoing packet)
> +	 */
> +	IP_VS_DBG_BUF(6, "New connection RS-initiated:%c c:%s:%u v:%s:%u "
> +		      "d:%s:%u conn->flags:%X conn->refcnt:%d\n",
> +		      ip_vs_fwd_tag(cp),
> +		      IP_VS_DBG_ADDR(svc->af, &cp->caddr), ntohs(cp->cport),
> +		      IP_VS_DBG_ADDR(svc->af, &cp->vaddr), ntohs(cp->vport),
> +		      IP_VS_DBG_ADDR(svc->af, &cp->daddr), ntohs(cp->dport),
> +		      cp->flags, atomic_read(&cp->refcnt));
> +	LeaveFunction(12);
> +	return cp;
> +
> +out_no_new_conn:
> +	rcu_read_unlock();
> +	return NULL;
> +}
> +
>  /* Handle response packets: rewrite addresses and send away...
>   */
>  static unsigned int
> @@ -1244,6 +1370,22 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
>  
>  	if (likely(cp))
>  		return handle_response(af, skb, pd, cp, &iph, hooknum);
> +	if (1 && /* TODO: test against specific systctl */
> +	    (pp->protocol == IPPROTO_UDP)) {
> +		/* Connection oriented protocols should not need this.
> +		 * Outgoing TCP / SCTP connections can be handled separately
> +		 * with specific iptables rules.
> +		 *
> +		 * Instead with UDP transport all packets (incoming requests +
> +		 * related responses, outgoing requests + related responses)
> +		 * might use the same set of UDP ports and pass through the LB,
> +		 * so we must create connections that allow all responses to be
> +		 * directed to the right RS and avoid them to be balanced.
> +		 */
> +		cp = __ip_vs_new_conn_out(ipvs, af, skb, &iph);
> +		if (likely(cp))
> +			return handle_response(af, skb, pd, cp, &iph, hooknum);
> +	}
>  	if (sysctl_nat_icmp_send(ipvs) &&
>  	    (pp->protocol == IPPROTO_TCP ||
>  	     pp->protocol == IPPROTO_UDP ||
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index e7c1b05..c8ad6f1 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -567,6 +567,37 @@ bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol,
>  	return false;
>  }
>  
> +/* Get real service record by <proto,addr,port>.
> + * In case of multiple records with the same <proto,addr,port>, only
> + * the first found record is returned.
> + */
> +struct ip_vs_dest *ip_vs_get_real_service(struct netns_ipvs *ipvs, int af,
> +					  __u16 protocol,
> +					  const union nf_inet_addr *daddr,
> +					  __be16 dport)
> +{
> +	unsigned int hash;
> +	struct ip_vs_dest *dest;
> +
> +	/* Check for "full" addressed entries */
> +	hash = ip_vs_rs_hashkey(af, daddr, dport);
> +
> +	rcu_read_lock();

	rcu_read_lock will be in caller

> +	hlist_for_each_entry_rcu(dest, &ipvs->rs_table[hash], d_list) {
> +		if (dest->port == dport &&
> +		    dest->af == af &&
> +		    ip_vs_addr_equal(af, &dest->addr, daddr) &&
> +			(dest->protocol == protocol || dest->vfwmark)) {
> +			/* HIT */
> +			rcu_read_unlock();
> +			return dest;
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	return NULL;
> +}
> +
>  /* Lookup destination by {addr,port} in the given service
>   * Called under RCU lock.
>   */
> 
> Subject: [PATCH 2/2] optimize release of connections in one-packet-scheduling mode
> 
> Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_conn.c | 29 +++++++++++++++++++++++++++--
>  1 file changed, 27 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 85ca189..550fe3f 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -104,6 +104,9 @@ static inline void ct_write_unlock_bh(unsigned int key)
>  	spin_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
>  }
>  
> +/* declarations
> + */
> +static void ip_vs_conn_expire(unsigned long data);
>  
>  /*
>   *	Returns hash value for IPVS connection entry
> @@ -453,10 +456,16 @@ ip_vs_conn_out_get_proto(struct netns_ipvs *ipvs, int af,
>  }
>  EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
>  
> +static void __ip_vs_conn_put_notimer(struct ip_vs_conn *cp)
> +{
> +	__ip_vs_conn_put(cp);
> +	ip_vs_conn_expire((unsigned long)cp);

	In ip_vs_conn_expire we can also call
ip_vs_conn_rcu_free directly for the IP_VS_CONN_F_ONE_PACKET
case to avoid RCU-callback overhead.

> +}
> +
>  /*
>   *      Put back the conn and restart its timer with its timeout
>   */
> -void ip_vs_conn_put(struct ip_vs_conn *cp)
> +static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
>  {
>  	unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
>  		0 : cp->timeout;
> @@ -465,6 +474,22 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
>  	__ip_vs_conn_put(cp);
>  }
>  
> +void ip_vs_conn_put(struct ip_vs_conn *cp)
> +{
> +	if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) &&
> +	    (atomic_read(&cp->refcnt) == 1) &&
> +	    !timer_pending(&cp->timer))
> +		/* one-packet-scheduling and last one referencing the
> +		 * connection: try to free connection data directly
> +		 * to avoid overhead of starting a new timer.
> +		 * If someone else will ever reference the connection
> +		 * just after the atomic_read, the ip_vs_conn_expire
> +		 * will delay and call __ip_vs_conn_put_timer as usual.
> +		 */
> +		__ip_vs_conn_put_notimer(cp);
> +	else
> +		__ip_vs_conn_put_timer(cp);
> +}
>  
>  /*
>   *	Fill a no_client_port connection with a client port number
> @@ -850,7 +875,7 @@ static void ip_vs_conn_expire(unsigned long data)
>  	if (ipvs->sync_state & IP_VS_STATE_MASTER)
>  		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
>  
> -	ip_vs_conn_put(cp);
> +	__ip_vs_conn_put_timer(cp);
>  }
>  
>  /* Modify timer, so that it expires as soon as possible.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1441014336-1458422874=:1621--
