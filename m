From: Inju Song <inju.song@navercorp.com>
Subject: [PATCH 3/3] netfilter: ipvs: change method to fill lookup table
 based on weight.
Date: Sun, 10 Dec 2017 16:35:13 +0900
Message-ID: <8d82b58e8f7ba28917bd609be8992eae7f2ff0c9.1512888407.git.inju.song@navercorp.com>
References: <cover.1512888407.git.inju.song@navercorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1512888407.git.inju.song@navercorp.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="windows-1252"
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>

 Fill lookup table with dests based on their weight.
   - They are assigned by considering weight as the relative
     frequency of the backends=E2=80=99 turn.

Signed-off-by: Inju Song <inju.song@navercorp.com>
---
 net/netfilter/ipvs/ip_vs_mh.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
index bb20b96..d1bf50a 100644
--- a/net/netfilter/ipvs/ip_vs_mh.c
+++ b/net/netfilter/ipvs/ip_vs_mh.c
@@ -109,7 +109,7 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_st=
ate *s,
 static inline int
 ip_vs_mh_populate(struct ip_vs_mh_state *s, struct ip_vs_service *svc)
 {
-	int i, ret;
+	int i, ret, dw_count;
 	unsigned int *next;
 	unsigned int **pmt;
 	struct ip_vs_mh_lookup *entry, *l;
@@ -134,18 +134,20 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_=
state *s,
 	for (i =3D 0; i < IP_VS_MH_LOOKUP_SIZE; i++)
 		RCU_INIT_POINTER(entry[i].dest, NULL);
=20
-	n =3D 0;
 	p =3D &svc->destinations;
 	empty =3D list_empty(p);
 	if (empty)
 		goto out;
=20
+	n =3D 0;
+	dw_count =3D 0;
 	pmt =3D s->permutation;
 	while (n < IP_VS_MH_LOOKUP_SIZE) {
-		for (i =3D 0; i < svc->num_dests; i++) {
-			if (p =3D=3D &svc->destinations)
-				p =3D p->next;
+		if (p =3D=3D &svc->destinations)
+			p =3D p->next;
=20
+		i =3D 0;
+		while (p !=3D &svc->destinations) {
 			c =3D pmt[i][next[i]];
=20
 			while (entry[c].dest) {
@@ -161,7 +163,11 @@ static inline int ip_vs_mh_permutate(struct ip_vs_mh_s=
tate *s,
 			if (n =3D=3D IP_VS_MH_LOOKUP_SIZE)
 				break;
=20
-			p =3D p->next;
+			if (++dw_count >=3D atomic_read(&dest->weight)) {
+				p =3D p->next;
+				dw_count =3D 0;
+				i++;
+			}
 		}
 	}
=20
--=20
1.8.3.1


--=20
Inju Song
NAVER Corporation

