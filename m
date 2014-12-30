From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH RFC] ipvs: reschedule new connections if previous was
 on FIN_WAIT or TIME_WAIT
Date: Tue, 30 Dec 2014 17:49:01 -0200
Message-ID: <54A301AD.8060002@redhat.com>
References: <f285101382023a28aaaf35dbf1433e09964e979d.1418048197.git.mleitner@redhat.com> <alpine.LFD.2.11.1412092248390.2374@ja.home.ssi.bg> <54883DCA.7050906@redhat.com> <54887B3C.2000709@redhat.com> <alpine.LFD.2.11.1412102217500.4043@ja.home.ssi.bg> <548991AF.1050502@redhat.com> <alpine.LFD.2.11.1412112207350.2098@ja.home.ssi.bg> <548AD85D.1070109@redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <548AD85D.1070109@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, hannes@redhat.com, jbrouer@redhat.com

Hi Julian,

On 12-12-2014 09:58, Marcelo Ricardo Leitner wrote:
> Hi,
> 
> On 11-12-2014 20:39, Julian Anastasov wrote:
>>
>>     Hello,
>>
>> On Thu, 11 Dec 2014, Marcelo Ricardo Leitner wrote:
>>
>>> On 10-12-2014 19:27, Julian Anastasov wrote:
>>>>
>>>>   int conn_reuse_mode;
>>>>
>>>>   conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
>>>>   if (conn_reuse_mode && !iph.fragoffs &&
>>>>       is_new_conn(skb, &iph) && cp &&
>>>>       ...
>>>>       unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
>>>
>>> Looks great! Thanks for all the directions.
>>>
>>> One question: at this if(), shouldn't we also check for &cp->n_control or you
>>> considered it in the '...'? Because as you said, if this connection controls
>>> another one we won't expire it and AFAICT we may end up with two duplicate
>>> entries for the given src host/port/service.
>>>
>>> Currently I'm with:
>>>          if (conn_reuse_mode && !iph.fragoffs &&
>>>              is_new_conn(skb, &iph) && cp &&
>>>              !atomic_read(&cp->n_control) &&
>>>              ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
>>>               unlikely(!atomic_read(&cp->dest->weight))) ||
>>>               unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
>>
>>     I think, the cp->n_control check is not needed,
>> we can live with many connections... in master server.
> 
> Okay, good.
> 
>>     But it looks like the new mechanism opens the door
>> for problems with the sync protocol. The master will
>> send sync messages for the new connection that we
>> create but backup server will hit the old connection
>> that can be to another real server (daddr). Backup will update
>> the cp->flags and cp->state but cp->dest can not be changed.
>> Our old (expired) connection will try to send sync messages
>> but as its state does not change ip_vs_sync_conn_needed()
>> will prevent the sending for FW/TW. Even if the old connection
>> does not cause problems, the new connection is not properly synced,
>> ip_vs_proc_conn() will call ip_vs_conn_in_get() and
>> we do not notice that daddr/dport differs.
>>
>>     May be it can be solved by adding daddr+dport
>> comparison after the ip_vs_conn_in_get() call in
>> ip_vs_proc_conn(), so that we can support multiple
>> connections that differ in daddr+dport. Or even
>> daddr+dport check in ip_vs_conn_in_get just for the backup.
>> But even in this case there is a risk because the sync messages
>> can come in random order, for example, a short connection
>> is expired in TW state, we create new connection but
>> the backup server gets sync messages in reverse order,
>> i.e. first for the new connection.
>>
>>     If above is not implemented, the
>> '!(ipvs->sync_state & IP_VS_STATE_MASTER) &&' check
>> should prevent the expiration. We will create new connection
>> due to weight=0 but backup can remain with wrong daddr
>> from the old connection, that is the price we pay on
>> rescheduling to different real server.
>>
>>     And may be we have to add also a cp->control check
>> in is_new_conn_expected(), the reason: persistence
>> should have priority. 'cp->control' check should be in
>> is_new_conn_expected(). IIRC, people use expire_nodest_conn
>> even for setups with persistence, so cp->control should
>> not prevent rescheduling in this case. cp->control also covers
>> the case with FTP DATA, such conns should use the same
>> real server.
>>
>>     What about:
>>
>> static inline bool can_expire_connection()
>> {
>>     /* Controlled (FTP DATA or persistence)? */
>>     if (cp->control)
>>         return false;
>>     ---> Below is the previous version, unchanged:
>>          return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
>>                 ((conn_reuse_mode & 2) &&
>>                  cp->state == IP_VS_TCP_S_FIN_WAIT &&
>>                  (cp->flags & IP_VS_CONN_F_NOOUTPUT));
>> }
>>
>>     New version:
>>
>>          conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
>>          if (conn_reuse_mode && !iph.fragoffs &&
>>              is_new_conn(skb, &iph) && cp &&
>>         ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
>>           unlikely(!atomic_read(&cp->dest->weight))) ||
>>          (!(ipvs->sync_state & IP_VS_STATE_MASTER) &&
>>           unlikely(can_expire_connection(cp, conn_reuse_mode))))) {
>>
>>     As result, actions by priority are as follows:
>>
>> - reschedule for expire_nodest_conn=1 when weight=0, even
>> if daddr/dport can become different in backup, even on persistence
>>
>> - sync protocol is active: reuse to prevent conns with different
>> real server in master and backup
>>
>> - reuse on persistence
>>
>> - reschedule on FW/TW: when no sync and no persistence
>>
>> - reuse, by default
> 
> TBH now I have to read more on the sync mechanism, it's been a while. I'll try 
> going with the first option, a way to get this properly synced to backup 
> server instead of disabling it when with sync enabled, because this last would 
> put a severe limitation on this feature. I haven't seen many single node 
> setups...

What if we make the backup server purge the old entry, just like the active server does, and ignore old updates if needed? Please note the new hunk on ip_vs_sync.c. This is the patch I'm using so far, and I'm seeing good results with even with master/backup. Backup server successfully purges the old and creates a new entry when it detects such update:

[  344.971673] IPVS: Bind-dest TCP c:192.168.122.1:22222 v:192.168.122.200:80 d:192.168.122.67:80 fwd:R s:0 conn->flags:A3 conn->refcnt:1 dest->refcnt:2
[  344.972071] IPVS: Unbind-dest TCP c:192.168.122.1:22222 v:192.168.122.200:80 d:192.168.122.95:80 fwd:R s:4 conn->flags:1A3 conn->refcnt:0 dest->refcnt:2

-- 8< --

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 7a3c047295914cbc8c4273506a9b6d35246a1750..3ba709531adba970595251fa73d6d471ed14c5c1 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -22,6 +22,27 @@ backup_only - BOOLEAN
 	If set, disable the director function while the server is
 	in backup mode to avoid packet loops for DR/TUN methods.
 
+conn_reuse_mode - INTEGER
+	1 - default
+
+	Controls how ipvs will deal with connections that are detected
+	port reuse. It is a bitmap, with the values being:
+
+	0: disable any special handling on port reuse. The new
+	connection will be delivered to the same real server that was
+	servicing the previous connection. This will effectively
+	disable expire_nodest_conn.
+
+	bit 1: enable rescheduling of new connections when it is safe.
+	That is, whenever expire_nodest_conn and for TCP sockets, when
+	the connection is in TIME_WAIT state (which is only possible if
+	you use NAT mode).
+
+	bit 2: it is bit 1 plus, for TCP connections, when connections
+	are in FIN_WAIT state, as this is the last state seen by load
+	balancer in Direct Routing mode. This bit helps on adding new
+	real servers to a very busy cluster.
+
 conntrack - BOOLEAN
 	0 - disabled (default)
 	not 0 - enabled
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 615b20b585452111a25085890d8fa875657dbe76..6c7ee0ae7ef1694671e4b6af0906b2fa077f5c7c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -924,6 +924,7 @@ struct netns_ipvs {
 	int			sysctl_nat_icmp_send;
 	int			sysctl_pmtu_disc;
 	int			sysctl_backup_only;
+	int			sysctl_conn_reuse_mode;
 
 	/* ip_vs_lblc */
 	int			sysctl_lblc_expiration;
@@ -1042,6 +1043,11 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
 	       ipvs->sysctl_backup_only;
 }
 
+static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_conn_reuse_mode;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -1109,6 +1115,11 @@ static inline int sysctl_backup_only(struct netns_ipvs *ipvs)
 	return 0;
 }
 
+static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 #endif
 
 /* IPVS core functions
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 990decba1fe418e36e59a1f081fcf0e47188da29..da2760496314d49a5b4f6f588de7cb565a28e223 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1036,6 +1036,20 @@ static inline bool is_new_conn(const struct sk_buff *skb,
 	}
 }
 
+static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
+					int conn_reuse_mode)
+{
+	if ((cp->protocol != IPPROTO_TCP) && (cp->protocol != IPPROTO_SCTP))
+		return false;
+	/* Controlled (FTP DATA or persistence)? */
+	if (cp->control)
+		return false;
+	return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
+	       ((conn_reuse_mode & 2) &&
+		(cp->state == IP_VS_TCP_S_FIN_WAIT) &&
+		(cp->flags & IP_VS_CONN_F_NOOUTPUT));
+}
+
 /* Handle response packets: rewrite addresses and send away...
  */
 static unsigned int
@@ -1574,6 +1588,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	struct ip_vs_conn *cp;
 	int ret, pkts;
 	struct netns_ipvs *ipvs;
+	int conn_reuse_mode;
 
 	/* Already marked as IPVS request or reply? */
 	if (skb->ipvs_property)
@@ -1642,9 +1657,13 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, 0);
 
-	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
-	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
-	    is_new_conn(skb, &iph)) {
+	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
+	if (conn_reuse_mode && !iph.fragoffs &&
+	    is_new_conn(skb, &iph) && cp &&
+	    !atomic_read(&cp->n_control) &&
+	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
+	      unlikely(!atomic_read(&cp->dest->weight))) ||
+	     unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
 		ip_vs_conn_expire_now(cp);
 		__ip_vs_conn_put(cp);
 		cp = NULL;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b8295a430a5600d35b6de4163ba3b98e75c5f28c..4a24879c6aefd55cd0d65b08efc191febb45c19d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1808,6 +1808,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "conn_reuse_mode",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
 		.procname	= "debug_level",
@@ -3729,6 +3735,8 @@ static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	ipvs->sysctl_pmtu_disc = 1;
 	tbl[idx++].data = &ipvs->sysctl_pmtu_disc;
 	tbl[idx++].data = &ipvs->sysctl_backup_only;
+	ipvs->sysctl_conn_reuse_mode = 1;
+	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
 
 
 	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index c47ffd7a0a709cb73834c84652f251960f25db79..7ed4484c2c93e0aed89be55c773c94f3c80cc09e 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -850,6 +850,21 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 	else
 		cp = ip_vs_ct_in_get(param);
 
+	if (cp && ((cp->dport != dport) ||
+		   !ip_vs_addr_equal(cp->af, &cp->daddr, daddr))) {
+		if (!(flags & IP_VS_CONN_F_INACTIVE)) {
+			ip_vs_conn_expire_now(cp);
+			__ip_vs_conn_put(cp);
+			cp = NULL;
+		} else {
+			/* This is the expiration message for the
+			 * connection that was already replaced, so we
+			 * just ignore it.
+			 */
+			goto out;
+		}
+	}
+
 	if (cp) {
 		/* Free pe_data */
 		kfree(param->pe_data);
@@ -925,6 +940,8 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 		else
 			cp->timeout = (3*60*HZ);
 	}
+
+out:
 	ip_vs_conn_put(cp);
 }
 
-- 
1.9.3



