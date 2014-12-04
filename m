From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ipvsadm PATCH 1/2] ipvsadm: fix compile warning in print_largenum
Date: Thu, 04 Dec 2014 10:38:55 +0100
Message-ID: <20141204093855.20470.31558.stgit@localhost>
References: <20141204093757.20470.92421.stgit@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20141204093757.20470.92421.stgit@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: lvs-devel@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Ryan O'Hara <rohara@redhat.com>, Jesper Dangaard Brouer <brouer@redhat.com>

=46rom: Daniel Borkmann <dborkman@redhat.com>

ipvsadm.c: In function =E2=80=98print_largenum=E2=80=99:
ipvsadm.c:1445:3: warning: field width specifier =E2=80=98*=E2=80=99 ex=
pects argument of type =E2=80=98int=E2=80=99, but argument 2 has type =E2=
=80=98size_t=E2=80=99 [-Wformat=3D]
   printf("%*llu", len <=3D 8 ? 9 : len + 1, i);
   ^

=46ix by reducing the scope and use int for len instead.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 ipvsadm.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 1190839..8931412 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1437,15 +1437,15 @@ static inline char *fwd_switch(unsigned flags)
=20
 static void print_largenum(unsigned long long i, unsigned int format)
 {
-	char mytmp[32];
-	size_t len;
