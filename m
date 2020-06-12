From: YangYuxi <yx.atom1@gmail.com>
Subject: [PATCH] ipvs: avoid drop first packet to reuse conntrack
Date: Fri, 12 Jun 2020 21:59:49 +0800
Message-ID: <20200612135949.GA30179@VM_111_229_centos>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=Hh9i/SAu/XN5uCB1Th1rOCzGyl5/Jk4Mbw10dKZ3R6E=;
        b=OoePVJ97S0dChRChmKkt7AZdBKjpcR90mt2XoX1NpjFvAFZux+NDX5hD7FdJ57lZ4r
         oep2MH3ngXJ9XRFND/XFjFIpJv5zOKnyFcsfQzFarkY4V8GpPuI4aUQOUYhHAmxlCX7n
         rbFBOlG0kJVFmEcT448PMtKFubQR9kl3W7ifFEU5NHHFMmym66azLUtF0ptySLy1Ca9F
         QStlSBMJw/7ri0fsgxObQxO0ty2TTk4AFMHi+6EEeIs1Itpub4FeRk60Ao4OJN9AtEgC
         EN9XHKhgeQLPodp+SfyJEBEwpr0hC+kNcRlohjzjdct9MMRypoXjaHLYrWrdb76WVVQ5
         36qg==
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, yx.atom1@gmail.com

Since 'commit f719e3754ee2 ("ipvs: drop first packet to
redirect conntrack")', when a new TCP connection meet
the conditions that need reschedule, the first syn packet
is dropped, this cause one second latency for the new
connection, more discussion about this problem can easy
search from google, such as:

1)One second connection delay in masque
https://marc.info/?t=3D151683118100004&r=3D1&w=3D2

2)IPVS low throughput=A0#70747
https://github.com/kubernetes/kubernetes/issues/70747

3)Apache Bench can fill up ipvs service proxy in seconds #544
https://github.com/cloudnativelabs/kube-router/issues/544

4)Additional 1s latency in `host -> service IP -> pod`
https://github.com/kubernetes/kubernetes/issues/90854

The root cause is when the old session is expired, the
conntrack related to the session is dropped by
ip_vs_conn_drop_conntrack. The code is as follows:
```
static void ip_vs_conn_expire(struct timer_list *t)
{
...

                if ((cp->flags & IP_VS_CONN_F_NFCT) &&
                    !(cp->flags & IP_VS_CONN_F_ONE_PACKET)) {
                        /* Do not access conntracks during subsys cleanup
                         * because nf_conntrack_find_get can not be used af=
ter
                         * conntrack cleanup for the net.
                         */
                        smp_rmb();
                        if (ipvs->enable)
                                ip_vs_conn_drop_conntrack(cp);
                }
...
}
```
As the code show, only if the condition  (cp->flags & IP_VS_CONN_F_NFCT)
is true, ip_vs_conn_drop_conntrack will be called.
So we optimize this by following steps:
1) erase the IP_VS_CONN_F_NFCT flag (it is safely because no packets will
   use the old session)
2) call ip_vs_conn_expire_now to release the old session, then the related
   conntrack will not be dropped
3) then ipvs unnecessary to drop the first syn packet,
   it just continue to pass the syn packet to the next process,
   create a new ipvs session, and the new session will related to
   the old conntrack(which is reopened by conntrack as a new one),
   the next whole things is just as normal as that the old session
   isn't used to exist.

The above scenario has no problems except passive FTP and
connmarks (state matching (-m state)). So, ipvs can give
users the right to choose, when FTP or connmarks is not used,
they can choose a high performance one by set net.ipv4.vs.conn_reuse_old_co=
nntrack=3D1,
this is necessary because most scenarios, such as kubernetes,
do not have FTP and connmarks scenarios, but are very sensitive
to TCP short link performance.

This patch has been verified on our thousands of kubernets node servers on =
Tencent Inc.
Signed-off-by: YangYuxi <yx.atom1@gmail.com>
---
 include/net/ip_vs.h             | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_core.c | 10 ++++++++--
 net/netfilter/ipvs/ip_vs_ctl.c  |  2 ++
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 83be2d93b407..052fa87d2a44 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -928,6 +928,7 @@ struct netns_ipvs {
 	int			sysctl_pmtu_disc;
 	int			sysctl_backup_only;
 	int			sysctl_conn_reuse_mode;
+	int			sysctl_conn_reuse_old_conntrack;
 	int			sysctl_schedule_icmp;
 	int			sysctl_ignore_tunneled;
=20
@@ -1049,6 +1050,11 @@ static inline int sysctl_conn_reuse_mode(struct netn=
s_ipvs *ipvs)
 	return ipvs->sysctl_conn_reuse_mode;
 }
=20
+static inline int sysctl_conn_reuse_old_conntrack(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_conn_reuse_old_conntrack;
+}
+
 static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_schedule_icmp;
@@ -1136,6 +1142,11 @@ static inline int sysctl_conn_reuse_mode(struct netn=
s_ipvs *ipvs)
 	return 1;
 }
=20
+static inline int sysctl_conn_reuse_old_conntrack(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
 {
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_cor=
e.c
index aa6a603a2425..0b89c872ea46 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2066,7 +2066,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, =
struct sk_buff *skb,
=20
 	conn_reuse_mode =3D sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
-		bool uses_ct =3D false, resched =3D false;
+		bool uses_ct =3D false, resched =3D false, drop =3D false;
=20
 		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
 		    unlikely(!atomic_read(&cp->dest->weight))) {
@@ -2086,10 +2086,16 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs=
, struct sk_buff *skb,
 		}
=20
 		if (resched) {
+			if (uses_ct) {
+				if (likely(sysctl_conn_reuse_old_conntrack(ipvs)))
+					cp->flags &=3D ~IP_VS_CONN_F_NFCT;
+				else
+					drop =3D true;
+			}
 			if (!atomic_read(&cp->n_control))
 				ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
-			if (uses_ct)
+			if (drop)
 				return NF_DROP;
 			cp =3D NULL;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 412656c34f20..eeb87994c21f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4049,7 +4049,9 @@ static int __net_init ip_vs_control_net_init_sysctl(s=
truct netns_ipvs *ipvs)
 	tbl[idx++].data =3D &ipvs->sysctl_pmtu_disc;
 	tbl[idx++].data =3D &ipvs->sysctl_backup_only;
 	ipvs->sysctl_conn_reuse_mode =3D 1;
+	ipvs->sysctl_conn_reuse_old_conntrack =3D 1;
 	tbl[idx++].data =3D &ipvs->sysctl_conn_reuse_mode;
+	tbl[idx++].data =3D &ipvs->sysctl_conn_reuse_old_conntrack;
 	tbl[idx++].data =3D &ipvs->sysctl_schedule_icmp;
 	tbl[idx++].data =3D &ipvs->sysctl_ignore_tunneled;
=20
--=20
1.8.3.1

