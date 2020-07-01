From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] ipvs: allow connection reuse for unconfirmed conntrack
Date: Wed,  1 Jul 2020 18:17:19 +0300
Message-ID: <20200701151719.4751-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org, YangYuxi <yx.atom1@gmail.com>

YangYuxi is reporting that connection reuse
is causing one-second delay when SYN hits
existing connection in TIME_WAIT state.
Such delay was added to give time to expire
both the IPVS connection and the corresponding
conntrack. This was considered a rare case
at that time but it is causing problem for
some environments such as Kubernetes.

As nf_conntrack_tcp_packet() can decide to
release the conntrack in TIME_WAIT state and
to replace it with a fresh NEW conntrack, we
can use this to allow rescheduling just by
tuning our check: if the conntrack is
confirmed we can not schedule it to different
real server and the one-second delay still
applies but if new conntrack was created,
we are free to select new real server without
any delays.

YangYuxi lists some of the problem reports:

- One second connection delay in masquerading mode:
https://marc.info/?t=3D151683118100004&r=3D1&w=3D2

- IPVS low throughput=C2=A0#70747
https://github.com/kubernetes/kubernetes/issues/70747

- Apache Bench can fill up ipvs service proxy in seconds #544
https://github.com/cloudnativelabs/kube-router/issues/544

- Additional 1s latency in `host -> service IP -> pod`
https://github.com/kubernetes/kubernetes/issues/90854

Fixes: f719e3754ee2 ("ipvs: drop first packet to redirect conntrack")
Co-developed-by: YangYuxi <yx.atom1@gmail.com>
Signed-off-by: YangYuxi <yx.atom1@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             | 10 ++++------
 net/netfilter/ipvs/ip_vs_core.c | 12 +++++++-----
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 83be2d93b407..fe96aa462d05 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1624,18 +1624,16 @@ static inline void ip_vs_conn_drop_conntrack(struct=
 ip_vs_conn *cp)
 }
 #endif /* CONFIG_IP_VS_NFCT */
=20
-/* Really using conntrack? */
-static inline bool ip_vs_conn_uses_conntrack(struct ip_vs_conn *cp,
-					     struct sk_buff *skb)
+/* Using old conntrack that can not be redirected to another real server? =
*/
+static inline bool ip_vs_conn_uses_old_conntrack(struct ip_vs_conn *cp,
+						 struct sk_buff *skb)
 {
 #ifdef CONFIG_IP_VS_NFCT
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct;
=20
-	if (!(cp->flags & IP_VS_CONN_F_NFCT))
-		return false;
 	ct =3D nf_ct_get(skb, &ctinfo);
-	if (ct)
+	if (ct && nf_ct_is_confirmed(ct))
 		return true;
 #endif
 	return false;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_cor=
e.c
index aa6a603a2425..517f6a2ac15a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2066,14 +2066,14 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hook=
num, struct sk_buff *skb, int
=20
 	conn_reuse_mode =3D sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
-		bool uses_ct =3D false, resched =3D false;
+		bool old_ct =3D false, resched =3D false;
=20
 		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
 		    unlikely(!atomic_read(&cp->dest->weight))) {
 			resched =3D true;
-			uses_ct =3D ip_vs_conn_uses_conntrack(cp, skb);
+			old_ct =3D ip_vs_conn_uses_old_conntrack(cp, skb);
 		} else if (is_new_conn_expected(cp, conn_reuse_mode)) {
-			uses_ct =3D ip_vs_conn_uses_conntrack(cp, skb);
+			old_ct =3D ip_vs_conn_uses_old_conntrack(cp, skb);
 			if (!atomic_read(&cp->n_control)) {
 				resched =3D true;
 			} else {
@@ -2081,15 +2081,17 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hook=
num, struct sk_buff *skb, int
 				 * that uses conntrack while it is still
 				 * referenced by controlled connection(s).
 				 */
-				resched =3D !uses_ct;
+				resched =3D !old_ct;
 			}
 		}
=20
 		if (resched) {
+			if (!old_ct)
+				cp->flags &=3D ~IP_VS_CONN_F_NFCT;
 			if (!atomic_read(&cp->n_control))
 				ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
-			if (uses_ct)
+			if (old_ct)
 				return NF_DROP;
 			cp =3D NULL;
 		}
--=20
2.26.2

