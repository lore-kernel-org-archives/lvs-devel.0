From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ipvsadm PATCH 2/2] ipvsadm: fix compile warning in modprobe_ipvs
Date: Thu, 04 Dec 2014 10:39:00 +0100
Message-ID: <20141204093900.20470.29631.stgit@localhost>
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

ipvsadm.c: In function =E2=80=98modprobe_ipvs=E2=80=99:
ipvsadm.c:1249:6: warning: variable =E2=80=98rc=E2=80=99 set but not us=
ed [-Wunused-but-set-variable]
  int rc;
      ^
Address this by also checking if waitpid(2) returned successfully
before we check actual status information.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 ipvsadm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 8931412..72ddc8a 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1255,7 +1255,7 @@ static int modprobe_ipvs(void)
=20
 	rc =3D waitpid(child, &status, 0);
=20
-	if (!WIFEXITED(status) || WEXITSTATUS(status)) {
+	if (rc =3D=3D -1 || !WIFEXITED(status) || WEXITSTATUS(status)) {
 		return 1;
 	}
=20

