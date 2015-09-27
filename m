From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2] ipvs: drop first packet to dead server
Date: Sun, 27 Sep 2015 20:25:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509272004230.1618@ja.home.ssi.bg>
References: <20150925093737.GA5047@midget.suse.cz> <20150925094820.GB5047@midget.suse.cz>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20150925094820.GB5047@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Bohac <jbohac@suse.cz>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Fri, 25 Sep 2015, Jiri Bohac wrote:

>  		if (!atomic_read(&cp->n_control))
>  			ip_vs_conn_expire_now(cp);
>  		__ip_vs_conn_put(cp);
> -		cp = NULL;
> +		return NF_DROP;

	So, at this point we do not know whether we have
one or many real servers, with same or different forwarding
method. For example, if we know that old real server is DR
and the new real server is again DR we can reuse the conntrack.

	Without such info we have to drop the connection
_only_ when conntrack is used. But if the connection is referenced
by others, eg. FTP:21 referenced by data connection, it is not
going to expire soon. We have to reuse it, otherwise client
will retransmit for long time. See below...

	Also, according to RFC 5961, 4.2. Mitigation, client can
send RST during its SYN retransmissions. So, may be we have to
allow rescheduling by adding IP_VS_TCP_S_CLOSE check after the
IP_VS_TCP_S_TIME_WAIT check in is_new_conn_expected(). This should
allow restarted client to be rescheduled. But this can be in
separate patch.

	Here is a RFC patch (not for latest tree, not tested):

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9b9ca87..e989841 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1591,6 +1591,23 @@ static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 }
 #endif /* CONFIG_IP_VS_NFCT */
 
+/* Really using conntrack? */
+static inline bool ip_vs_conn_uses_conntrack(struct ip_vs_conn *cp,
+					struct sk_buff *skb)
+{
+#ifdef CONFIG_IP_VS_NFCT
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	if (!(cp->flags & IP_VS_CONN_F_NFCT))
+		return false;
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct && !nf_ct_is_untracked(ct))
+		return true;
+#endif
+	return false;
+}
+
 static inline int
 ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
 {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 38fbc19..a26bd65 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1689,15 +1689,34 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	cp = pp->conn_in_get(af, skb, &iph, 0);
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
-	if (conn_reuse_mode && !iph.fragoffs &&
-	    is_new_conn(skb, &iph) && cp &&
-	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
-	      unlikely(!atomic_read(&cp->dest->weight))) ||
-	     unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
-		if (!atomic_read(&cp->n_control))
-			ip_vs_conn_expire_now(cp);
-		__ip_vs_conn_put(cp);
-		cp = NULL;
+	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
+		bool uses_ct = false, resched = false;
+
+		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
+		    unlikely(!atomic_read(&cp->dest->weight))) {
+			resched = true;
+			uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
+		} else if (is_new_conn_expected(cp, conn_reuse_mode)) {
+			uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
+			if (!atomic_read(&cp->n_control)) {
+				resched = true;
+			} else {
+				/* Do not reschedule controlling connection
+				 * that uses conntrack while it is still
+				 * referenced by controlled connection(s).
+				 */
+				resched = !uses_ct;
+			}
+		}
+
+		if (resched) {
+			if (!atomic_read(&cp->n_control))
+				ip_vs_conn_expire_now(cp);
+			__ip_vs_conn_put(cp);
+			if (uses_ct)
+				return NF_DROP;
+			cp = NULL;
+		}
 	}
 
 	if (unlikely(!cp) && !iph.fragoffs) {

Regards

--
Julian Anastasov <ja@ssi.bg>
