From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/2] ipvs: Remove possibly unused variable from ip_vs_out
Date: Wed,  7 Oct 2015 14:23:22 +0900
Message-ID: <1444195403-4288-2-git-send-email-horms@verge.net.au>
References: <1444195403-4288-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1444195403-4288-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, David Ahern <dsa@cumulusnetworks.com>, Simon Horman <horms@verge.net.au>

=46rom: David Ahern <dsa@cumulusnetworks.com>

Eric's net namespace changes in 1b75097dd7a26 leaves net unreferenced i=
f
CONFIG_IP_VS_IPV6 is not enabled:

=2E./net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_out=E2=
=80=99:
=2E./net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variable =
=E2=80=98net=E2=80=99 [-Wunused-variable]

After the net refactoring there is only 1 user; push the reference to t=
he
1 user. While the line length slightly exceeds 80 it seems to be the
best change.

=46ixes: 1b75097dd7a26("ipvs: Pass ipvs into ip_vs_out")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
[horms: updated subject]
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index d08df435c2aa..3773154d9b71 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1172,7 +1172,6 @@ drop:
 static unsigned int
 ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buf=
f *skb, int af)
 {
-	struct net *net =3D ipvs->net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1272,7 +1271,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int h=
ooknum, struct sk_buff *skb, in
 #ifdef CONFIG_IP_VS_IPV6
 				if (af =3D=3D AF_INET6) {
 					if (!skb->dev)
-						skb->dev =3D net->loopback_dev;
+						skb->dev =3D ipvs->net->loopback_dev;
 					icmpv6_send(skb,
 						    ICMPV6_DEST_UNREACH,
 						    ICMPV6_PORT_UNREACH,
--=20
2.1.4

