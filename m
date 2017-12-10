From: Inju Song <inju.song@navercorp.com>
Subject: [PATCH 0/3] netfilter: =?iso-8859-1?Q?ipvs?=
 =?iso-8859-1?B?OqBBZGQ=?= Maglev consistent hashing scheduler
Date: Sun, 10 Dec 2017 16:33:02 +0900
Message-ID: <cover.1512888407.git.inju.song@navercorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel@vger.kernel.org
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>

Implements the Google's Maglev hashing algorithm as a IPVS scheduler.
Basically it provides consistent hashing but=A0offers some special
features about disruption and load balancing.

Seel also: [3.4 Consistent Hasing]
in=A0https://static.googleusercontent.com/media/research.google.com/ko//pub=
s/archive/44824.pdf

V2: Fix some methods and add features based on Julian's advice.

Inju Song (3):
  netfilter: ipvs: handle memory allocation fail in mh scheduler.
  netfilter: ipvs: release refcnt and improve ip_vs_mh_reassign()
  netfilter: ipvs: change method to fill lookup table based on weight.

 net/netfilter/ipvs/ip_vs_mh.c | 147 +++++++++++++++++++++++++++++---------=
----
 1 file changed, 101 insertions(+), 46 deletions(-)

--=20
1.8.3.1


--=20
Inju Song
NAVER Corporation

