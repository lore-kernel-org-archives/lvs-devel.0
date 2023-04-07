From: Markus Elfring <Markus.Elfring@web.de>
Subject: [PATCH] ipvs: Fix exception handling in two functions
Date: Fri, 7 Apr 2023 09:50:12 +0200
Message-ID: <64e1977a-ffd8-4948-951a-29608fe631f8@web.de>
References: <f9303bdc-b1a7-be5e-56c6-dfa8232b8b55@web.de>
 <8f785de5-ebe2-edd9-2155-f440acacc643@web.de>
Reply-To: Markus Elfring <Markus.Elfring@web.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <cocci-owner@inria.fr>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=inria.fr; s=dc;
  h=message-id:date:mime-version:from:to:references:cc:
   in-reply-to:content-transfer-encoding:subject:reply-to:
   sender:list-id:list-help:list-subscribe:list-unsubscribe:
   list-post:list-owner:list-archive;
  bh=rM6ZtimIJzHjZ0LqGrAUagjcVzmFrRHqU2zg15sMrGc=;
  b=E4buZJKSmQ/yYlMBLRIJYBJxwRVqL0+A8SFCAZtWsLAPf3uFlTEZvfsF
   PMhHJL9saGZ0mB9fK4u8cCSqi+FBSa4zr2n48fastv6sdshHNoOmI0ZhI
   DwSJhBtVaCjTuWWrKbq9geUNgWU3rA8S8Vevxi2aF3vEa2q5Kqy8cEZLV
   A=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=web.de; s=s29768273;
	t=1680853814; i=markus.elfring@web.de;
	bh=XeTrvo4c7c7EY8OpqNaDpVzfsH12ErYXcgkrGuBZzog=;
	h=X-UI-Sender-Class:Date:Subject:From:To:References:Cc:In-Reply-To;
	b=ADSa6MlwvcVt149D+3gtOacO3kH74BpN5w1UYbc01rXXNENuwAuUZU4NBg7hxgSre
	 pkiLZXv1dBWs0I4AZFmFecfxhSGycxIMrOU9INYaBcSsa+DDyCnT1NlV5fgj/ckD/l
	 BkvSkyYPzVMvrTKVyxESeudTP74/sXNkG39Qd6rCo6yndWR5cusL0ol3N8a60TMrG8
	 XhGjDJPrGZKkgiL/3Zmjdx7cr7qwjQsIbkzUamw27oNHC7qIsAsRLwHqUvCmYRG7Fz
	 FrzCE44sPNwXoAtoxeihMLU52I5AoQIbyPVcR4KMAX2YkeJTL9iBT+I7JYEPjLoQyP
	 Nok8NleqezCng==
Content-Language: en-GB
In-Reply-To: <8f785de5-ebe2-edd9-2155-f440acacc643@web.de>
Errors-To: cocci-owner@inria.fr
Sender: cocci-request@inria.fr
List-Id: <lvs-devel.vger.kernel.org>
List-Help: <mailto:sympa_inria@inria.fr?subject=help>
List-Subscribe: <mailto:sympa_inria@inria.fr?subject=subscribe%20cocci>
List-Unsubscribe: <mailto:sympa_inria@inria.fr?subject=unsubscribe%20cocci>
List-Post: <mailto:cocci@inria.fr>
List-Owner: <mailto:cocci-request@inria.fr>
List-Archive: <https://sympa.inria.fr/sympa/arc/cocci>
Content-Type: text/plain; charset="utf-8"
To: kernel-janitors@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, coreteam@netfilter.org, Alex Gartrell <agartrell@fb.com>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Jakub Kicinski <kuba@kernel.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@verge.net.au>
Cc: cocci@inria.fr, LKML <linux-kernel@vger.kernel.org>

Date: Fri, 7 Apr 2023 09:33:43 +0200

The label =E2=80=9Ctx_error=E2=80=9D was used to jump to another pointer c=
heck
despite of the detail in these function implementations
that it was determined already that the corresponding variable
contained an error pointer because of a failed call of
the function =E2=80=9Cip_vs_prepare_tunneled_skb=E2=80=9D.

* Thus use an additional label.

* Delete two redundant checks.


This issue was detected by using the Coccinelle software.

Fixes: ea1d5d7755a3e556de78cc757d1895d5c7180548 ("ipvs: properly declare t=
unnel encapsulation")
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
=2D--
 net/netfilter/ipvs/ip_vs_xmit.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xm=
it.c
index 99c349c0d968..68343ee380e1 100644
=2D-- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1199,7 +1199,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_=
conn *cp,
 					 &next_protocol, NULL, &dsfield,
 					 &ttl, dfp);
 	if (IS_ERR(skb))
-		goto tx_error;
+		goto leave_function;

 	gso_type =3D __tun_gso_type_mask(AF_INET, cp->af);
 	if (tun_type =3D=3D IP_VS_CONN_F_TUNNEL_TYPE_GUE) {
@@ -1266,16 +1266,14 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_v=
s_conn *cp,
 		ip_local_out(net, skb->sk, skb);
 	else if (ret =3D=3D NF_DROP)
 		kfree_skb(skb);
-
+leave_function:
 	LeaveFunction(10);

 	return NF_STOLEN;

   tx_error:
-	if (!IS_ERR(skb))
-		kfree_skb(skb);
-	LeaveFunction(10);
-	return NF_STOLEN;
+	kfree_skb(skb);
+	goto leave_function;
 }

 #ifdef CONFIG_IP_VS_IPV6
@@ -1347,7 +1345,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_=
vs_conn *cp,
 					 &next_protocol, &payload_len,
 					 &dsfield, &ttl, NULL);
 	if (IS_ERR(skb))
-		goto tx_error;
+		goto leave_function;

 	gso_type =3D __tun_gso_type_mask(AF_INET6, cp->af);
 	if (tun_type =3D=3D IP_VS_CONN_F_TUNNEL_TYPE_GUE) {
@@ -1413,16 +1411,14 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct i=
p_vs_conn *cp,
 		ip6_local_out(net, skb->sk, skb);
 	else if (ret =3D=3D NF_DROP)
 		kfree_skb(skb);
-
+leave_function:
 	LeaveFunction(10);

 	return NF_STOLEN;

 tx_error:
-	if (!IS_ERR(skb))
-		kfree_skb(skb);
-	LeaveFunction(10);
-	return NF_STOLEN;
+	kfree_skb(skb);
+	goto leave_function;
 }
 #endif

=2D-
2.40.0

