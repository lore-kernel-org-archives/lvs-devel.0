From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: ipvs: handle outgoing messages in SIP persistence engine
Date: Tue, 08 Mar 2016 18:17:25 +0100
Message-ID: <56df0925.qHrv/3RM88lO4eNe%marcoangaroni@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=date:from:to:subject:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=DponZIDYxYAm7QDW7KWIYLXb4WyBtZGKFcD3zkXKcXc=;
        b=EoPiNPYBrTpcIc+JxhBc90sadh61ERQvpz8x6Coh7gc/fz0nebuQsl7e5CV7rbbA8S
         2MF/w+a3OkFZFnmTnYL+7IC1h04ehuPoVZa6C24VGDI4bXtK5XClIc+qO5E3xQcwHIXR
         0t6Y0i4HpJEKkCR++2so4omYrWJbkTveodkwigdQVD1ahW6PI1FFcN1ygfd6JnFhuNc4
         0eYI7/dg1wcqzAtKja9p6hLm5IWNXdU5VMrKZoEpKOrIbJN/Zxvmd3kxeuN5Mf/9ad32
         Dd57ahZ4cHICpwB+Ml0xdjQXKaJlmdPO8nRyRU4U0GUx7+BnnYsVlTBlqEfS45NizoEk
         lidQ==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: lvs-devel@vger.kernel.org

Hello,

I=E2=80=99m trying to use IPVS as a high performance load-balancer with=
 minimal=20
SIP-protocol awareness (routing based on Call-ID header).
I started from the patch by Simon Horman as described here:
https://lwn.net/Articles/399571/.

However I found the following problems / limitations (I=E2=80=99m using=
 LVS-NAT
and SIP over UDP):

  1) To actually have load-balancing based on Call-ID header, you need =
to
     use one-packet-scheduling (see Simon=E2=80=99s statement in above =
article:=20
     =E2=80=9CIt is envisaged that the SIP persistence engine will be u=
sed in=20
     conjunction with one-packet scheduling=E2=80=9D). But with one-pac=
ket-
     scheduling the connection is deleted just after packet is forwarde=
d,=20
     so SIP responses coming from real-servers do not match any connect=
ion=20
     and SNAT is not applied.

  2) If you do not use "-o", IPVS behave as normal UDP load balancer, s=
o
     different SIP calls (each one identified by a different Call-ID)=20
     coming from the same ip-address/port go to the same RS. So basical=
ly=20
     you don=E2=80=99t have load-balancing based on Call-ID as intended=
=2E

  3) Call-ID is not learned when a new SIP call is started by a real-se=
rver
     (inside-to-outside direction), but only in the outside-to-inside=20
     direction (see also my comment on the LVS-users mailing list:=20
     http://archive.linuxvirtualserver.org/html/lvs-users/2016-01/msg00=
000.html).=20
     This is not specific to my deploy, but would be a general problem=20
     for all SIP servers acting as B2BUA
     (https://en.wikipedia.org/wiki/Back-to-back_user_agent).

  4) One-packet-scheduling is the most expensive mode in IPVS from=20
     performance point of view: for each packet to be processed a new=20
     connection data structure is created and, after packet is sent,=20
     deleted by starting a new timer set to expire immediately.

Below you can find two patches that I used to solve such problems.
At the moment, I just would like to have your opinion as IPVS experts,
and understand if such modifications can be considered a viable option
to solve problems listed above.
If you consider implementation is fine, I can think to submit such patc=
hes
later. Otherwise I would be really happy to receive suggestions about=20
alternative implementations.
And if I simply misunderstood something, please let me know.

  p1) The basic idea is to make packets, that do not match any existent=
=20
      connection but come from real-servers, create new connections ins=
tead
      of let them pass without any effect. This is the opposite of the=20
      behaviour enabled by sysctl_nat_icmp_send, where packets that do =
not=20
      match a connection but come from a RS generate an ICMP message ba=
ck.

      When such packets pass through ip_vs_out(), if their source ip=20
      address and source port match a configured real-server, a new=20
      connection is automatically created in the same way as it would h=
ave
      happened if the packet had come from outside-to-inside direction.
      A new connection template is created too, if the virtual-service =
is=20
      persistent and there is no matching connection template found.
      The new connection automatically created, if the service had "-o"=
=20
      option, is an OPS connection that lasts only the time to forward =
the
      packet, just like it happens on the ingress side.

      This behavior should obviously be made configurable by adding a=20
      specific sysctl (not implemented yet).
      This fixes problems 1) and 3) and keeps OPS mode mandatory for SI=
P-UDP,
      so 2) would not be a problem anymore.

      The following requisites are needed for automatic connection crea=
tion;
      if any is missing the packet simply goes the same way as usual.
      -  Virtual-Service is not fwmark based (this is because fwmark se=
rvices
         do not store address and port of the Virtual-Service, required=
 to=20
         build the connection data).
      -  Virtual-Service and real-servers must not have been configured=
 with=20
         omitted port (this is again to have all data to create the=20
         connection).

  p2) A costly operation done by OPS for every packet is the start of t=
imer=20
      to free the connection data. Instead of starting a timer to make=20
      it expire immediately, I found it=E2=80=99s more efficient to cal=
l the expire
      callback directly (under certain conditions). In my tests, this m=
ore=20
      than halved CPU usage at high loads on a virtual-machine with a s=
ingle
      CPU, and seemed a good improvement for issue described in 4).

Thanks in advance,
Marco Angaroni

Subject: [PATCH 1/2] handle connections started by real-servers

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
---
 include/net/ip_vs.h             |   4 ++
 net/netfilter/ipvs/ip_vs_core.c | 142 ++++++++++++++++++++++++++++++++=
++++++++
 net/netfilter/ipvs/ip_vs_ctl.c  |  31 +++++++++
 3 files changed, 177 insertions(+)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 0816c87..28db660 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1378,6 +1378,10 @@ ip_vs_service_find(struct netns_ipvs *ipvs, int =
af, __u32 fwmark, __u16 protocol
 bool ip_vs_has_real_service(struct netns_ipvs *ipvs, int af, __u16 pro=
tocol,
 			    const union nf_inet_addr *daddr, __be16 dport);
=20
+struct ip_vs_dest *
+ip_vs_get_real_service(struct netns_ipvs *ipvs, int af, __u16 protocol=
,
+		       const union nf_inet_addr *daddr, __be16 dport);
+
 int ip_vs_use_count_inc(void);
 void ip_vs_use_count_dec(void);
 int ip_vs_register_nl_ioctl(void);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index f57b4dc..e3f5a70 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1099,6 +1099,132 @@ static inline bool is_new_conn_expected(const s=
truct ip_vs_conn *cp,
 	}
 }
=20
+/* Creates a new connection for outgoing packets which are considered
+ * requests initiated by the real server, so that subsequent responses=
 from
+ * external client are routed to the right real server.
+ *
+ * Pre-requisites:
+ * 1) Real Server is identified by searching source ip-address and
+ *    source port of the packet in RS table.
+ * 2) Virtual Service is NOT fwmark based.
+ *    In fwmark-virtual-services actual vaddr and vport are unknown un=
til
+ *    packets are received from external network.
+ * 3) One RS is associated with only one VS.
+ *    Otherwise the first match found is used.
+ * 4) Virtual Service and Real Server must not have omitted port.
+ *    This is because all paramaters to create the connection must be =
known.
+ *
+ * This is outgoing packet, so:
+ * source-ip-address of packet is address of real-server
+ * dest-ip-address of packet is address of external client
+ */
+static struct ip_vs_conn *__ip_vs_new_conn_out(struct netns_ipvs *ipvs=
, int af,
+					       struct sk_buff *skb,
+					       const struct ip_vs_iphdr *iph)
+{
+	struct ip_vs_service *svc;
+	struct ip_vs_conn_param pt, pc;
+	struct ip_vs_conn *ct =3D NULL, *cp =3D NULL;
+	struct ip_vs_dest *dest;
+	__be16 _ports[2], *pptr;
+	const union nf_inet_addr *vaddr, *daddr;
+	union nf_inet_addr snet;
+	__be16 vport, dport;
+	unsigned int flags;
+
+	EnterFunction(12);
+	/* get net and L4 ports
+	 */
+	pptr =3D frag_safe_skb_hp(skb, iph->len, sizeof(_ports), _ports, iph)=
;
+	if (!pptr)
+		return NULL;
+	/* verify packet comes from a real-server and get service record
+	 */
+	dest =3D ip_vs_get_real_service(ipvs, af, iph->protocol,
+				      &iph->saddr, pptr[0]);
+	if (!dest)
+		return NULL;
+	/* check we have all pre-requisites
+	 */
+	rcu_read_lock();
+	svc =3D rcu_dereference(dest->svc);
+	if (!svc)
+		goto out_no_new_conn;
+	if (svc->fwmark)
+		goto out_no_new_conn;
+	vaddr =3D &svc->addr;
+	vport =3D svc->port;
+	daddr =3D &dest->addr;
+	dport =3D dest->port;
+	if (!vport || !dport)
+		return NULL;
+	/* for persistent service first create connection template
+	 */
+	if (svc->flags & IP_VS_SVC_F_PERSISTENT) {
+		/* apply netmask the same way ingress-side does
+		 */
+#ifdef CONFIG_IP_VS_IPV6
+		if (af =3D=3D AF_INET6)
+			ipv6_addr_prefix(&snet.in6, &iph->daddr.in6,
+					 (__force __u32)svc->netmask);
+		else
+#endif
+			snet.ip =3D iph->daddr.ip & svc->netmask;
+		/* fill params and create template if not existent
+		 */
+		if (ip_vs_conn_fill_param_persist(svc, skb, iph->protocol,
+						  &snet, 0, vaddr,
+						  vport, &pt) < 0)
+			goto out_no_new_conn;
+		ct =3D ip_vs_ct_in_get(&pt);
+		if (!ct) {
+			ct =3D ip_vs_conn_new(&pt, dest->af, daddr, dport,
+					    IP_VS_CONN_F_TEMPLATE, dest, 0);
+			if (!ct) {
+				kfree(pt.pe_data);
+				goto out_no_new_conn;
+			}
+			ct->timeout =3D svc->timeout;
+		} else {
+			kfree(pt.pe_data);
+		}
+	}
+	/* connection flags
+	 */
+	flags =3D ((svc->flags & IP_VS_SVC_F_ONEPACKET) &&
+		 iph->protocol =3D=3D IPPROTO_UDP) ? IP_VS_CONN_F_ONE_PACKET : 0;
+	/* create connection
+	 */
+	ip_vs_conn_fill_param(svc->ipvs, svc->af, iph->protocol,
+			      &iph->daddr, pptr[1], vaddr, vport, &pc);
+	cp =3D ip_vs_conn_new(&pc, dest->af, daddr, dport, flags, dest, 0);
+	if (!cp) {
+		ip_vs_conn_put(ct);
+		goto out_no_new_conn;
+	}
+	if (ct) {
+		ip_vs_control_add(cp, ct);
+		ip_vs_conn_put(ct);
+	}
+	ip_vs_conn_stats(cp, svc);
+	rcu_read_unlock();
+	/* return connection (will be used to handle outgoing packet)
+	 */
+	IP_VS_DBG_BUF(6, "New connection RS-initiated:%c c:%s:%u v:%s:%u "
+		      "d:%s:%u conn->flags:%X conn->refcnt:%d\n",
+		      ip_vs_fwd_tag(cp),
+		      IP_VS_DBG_ADDR(svc->af, &cp->caddr), ntohs(cp->cport),
+		      IP_VS_DBG_ADDR(svc->af, &cp->vaddr), ntohs(cp->vport),
+		      IP_VS_DBG_ADDR(svc->af, &cp->daddr), ntohs(cp->dport),
+		      cp->flags, atomic_read(&cp->refcnt));
+	LeaveFunction(12);
+	return cp;
+
+out_no_new_conn:
+	rcu_read_unlock();
+	return NULL;
+}
+
 /* Handle response packets: rewrite addresses and send away...
  */
 static unsigned int
@@ -1244,6 +1370,22 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int =
hooknum, struct sk_buff *skb, in
=20
 	if (likely(cp))
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
+	if (1 && /* TODO: test against specific systctl */
+	    (pp->protocol =3D=3D IPPROTO_UDP)) {
+		/* Connection oriented protocols should not need this.
+		 * Outgoing TCP / SCTP connections can be handled separately
+		 * with specific iptables rules.
+		 *
+		 * Instead with UDP transport all packets (incoming requests +
+		 * related responses, outgoing requests + related responses)
+		 * might use the same set of UDP ports and pass through the LB,
+		 * so we must create connections that allow all responses to be
+		 * directed to the right RS and avoid them to be balanced.
+		 */
+		cp =3D __ip_vs_new_conn_out(ipvs, af, skb, &iph);
+		if (likely(cp))
+			return handle_response(af, skb, pd, cp, &iph, hooknum);
+	}
 	if (sysctl_nat_icmp_send(ipvs) &&
 	    (pp->protocol =3D=3D IPPROTO_TCP ||
 	     pp->protocol =3D=3D IPPROTO_UDP ||
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
index e7c1b05..c8ad6f1 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -567,6 +567,37 @@ bool ip_vs_has_real_service(struct netns_ipvs *ipv=
s, int af, __u16 protocol,
 	return false;
 }
=20
+/* Get real service record by <proto,addr,port>.
+ * In case of multiple records with the same <proto,addr,port>, only
+ * the first found record is returned.
+ */
+struct ip_vs_dest *ip_vs_get_real_service(struct netns_ipvs *ipvs, int=
 af,
+					  __u16 protocol,
+					  const union nf_inet_addr *daddr,
+					  __be16 dport)
+{
+	unsigned int hash;
+	struct ip_vs_dest *dest;
+
+	/* Check for "full" addressed entries */
+	hash =3D ip_vs_rs_hashkey(af, daddr, dport);
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(dest, &ipvs->rs_table[hash], d_list) {
+		if (dest->port =3D=3D dport &&
+		    dest->af =3D=3D af &&
+		    ip_vs_addr_equal(af, &dest->addr, daddr) &&
+			(dest->protocol =3D=3D protocol || dest->vfwmark)) {
+			/* HIT */
+			rcu_read_unlock();
+			return dest;
+		}
+	}
+	rcu_read_unlock();
+
+	return NULL;
+}
+
 /* Lookup destination by {addr,port} in the given service
  * Called under RCU lock.
  */

Subject: [PATCH 2/2] optimize release of connections in one-packet-sche=
duling mode

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs=
_conn.c
index 85ca189..550fe3f 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -104,6 +104,9 @@ static inline void ct_write_unlock_bh(unsigned int =
key)
 	spin_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
=20
+/* declarations
+ */
+static void ip_vs_conn_expire(unsigned long data);
=20
 /*
  *	Returns hash value for IPVS connection entry
@@ -453,10 +456,16 @@ ip_vs_conn_out_get_proto(struct netns_ipvs *ipvs,=
 int af,
 }
 EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
=20
+static void __ip_vs_conn_put_notimer(struct ip_vs_conn *cp)
+{
+	__ip_vs_conn_put(cp);
+	ip_vs_conn_expire((unsigned long)cp);
+}
+
 /*
  *      Put back the conn and restart its timer with its timeout
  */
-void ip_vs_conn_put(struct ip_vs_conn *cp)
+static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
 {
 	unsigned long t =3D (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
 		0 : cp->timeout;
@@ -465,6 +474,22 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
 	__ip_vs_conn_put(cp);
 }
=20
+void ip_vs_conn_put(struct ip_vs_conn *cp)
+{
+	if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) &&
+	    (atomic_read(&cp->refcnt) =3D=3D 1) &&
+	    !timer_pending(&cp->timer))
+		/* one-packet-scheduling and last one referencing the
+		 * connection: try to free connection data directly
+		 * to avoid overhead of starting a new timer.
+		 * If someone else will ever reference the connection
+		 * just after the atomic_read, the ip_vs_conn_expire
+		 * will delay and call __ip_vs_conn_put_timer as usual.
+		 */
+		__ip_vs_conn_put_notimer(cp);
+	else
+		__ip_vs_conn_put_timer(cp);
+}
=20
 /*
  *	Fill a no_client_port connection with a client port number
@@ -850,7 +875,7 @@ static void ip_vs_conn_expire(unsigned long data)
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
=20
-	ip_vs_conn_put(cp);
+	__ip_vs_conn_put_timer(cp);
 }
=20
 /* Modify timer, so that it expires as soon as possible.
