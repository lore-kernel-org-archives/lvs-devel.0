From: Sishuai Gong <sishuai.system@gmail.com>
Subject: [PATCH] ipvs: fix racy memcpy in proc_do_sync_threshold
Date: Thu, 10 Aug 2023 15:12:42 -0400
Message-ID: <B556FD7B-3190-4C8F-BA83-FC5C147FEAE1@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3731.700.6\))
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1691694774; x=1692299574;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:from:from:to:cc:subject:date:message-id
         :reply-to;
        bh=rWkaYMWSb/KD5Br6avTVtAWU2rBiWnpQY//6EhOGYR0=;
        b=OmdzBnQds3G8UGSSvoHalQ1f326gF+qt2Z6Pe5mPG84d8YX+Z0SddxrpQzjpCKh3OR
         nn9Cf+CRLj625gI9Ny8NQKE/giIety39NbdXCK12NcdVnbbyMAgLrJa3+9VSI7uZFL3g
         DXu+wUZneLWlF3NnAxZSQIA5ryhPowjGiFKE0khyrf9tP8uNaE1GdiRXXO8FdQGlZ2d5
         ObNKa+VN+R1yhUrkh8A1fJ8I67tCmRMxwcTQ5mrMP9WVKT8qijt/PDi1EUs5UeFbjI09
         t4s+nRToXnOWxUE8HkCTyuwLBVKylRtzJPzVWtP2a4nDaa1cdhPLzTbFdnBptiz6zat5
         pU2A==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: ja@ssi.bg, horms@verge.net.au
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org

When two threads run proc_do_sync_threshold() in parallel,
data races could happen between the two memcpy():

Thread-1			Thread-2
memcpy(val, valp, sizeof(val));
				memcpy(valp, val, sizeof(val));

This race might mess up the (struct ctl_table *) table->data,
so we add a mutex lock to serilize them, as discussed in [1].

[1] =
https://archive.linuxvirtualserver.org/html/lvs-devel/2023-08/msg00031.htm=
l

Signed-off-by: Sishuai Gong <sishuai.system@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c =
b/net/netfilter/ipvs/ip_vs_ctl.c
index 62606fb44d02..4bb0d90eca1c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1876,6 +1876,7 @@ static int
 proc_do_sync_threshold(struct ctl_table *table, int write,
 		       void *buffer, size_t *lenp, loff_t *ppos)
 {
+	struct netns_ipvs *ipvs =3D table->extra2;
 	int *valp =3D table->data;
 	int val[2];
 	int rc;
@@ -1885,6 +1886,7 @@ proc_do_sync_threshold(struct ctl_table *table, =
int write,
 		.mode =3D table->mode,
 	};
=20
+	mutex_lock(&ipvs->sync_mutex);
 	memcpy(val, valp, sizeof(val));
 	rc =3D proc_dointvec(&tmp, write, buffer, lenp, ppos);
 	if (write) {
@@ -1894,6 +1896,7 @@ proc_do_sync_threshold(struct ctl_table *table, =
int write,
 		else
 			memcpy(valp, val, sizeof(val));
 	}
+	mutex_unlock(&ipvs->sync_mutex);
 	return rc;
 }
=20
@@ -4321,6 +4324,7 @@ static int __net_init =
ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	ipvs->sysctl_sync_threshold[0] =3D DEFAULT_SYNC_THRESHOLD;
 	ipvs->sysctl_sync_threshold[1] =3D DEFAULT_SYNC_PERIOD;
 	tbl[idx].data =3D &ipvs->sysctl_sync_threshold;
+	tbl[idx].extra2 =3D ipvs;
 	tbl[idx++].maxlen =3D sizeof(ipvs->sysctl_sync_threshold);
 	ipvs->sysctl_sync_refresh_period =3D =
DEFAULT_SYNC_REFRESH_PERIOD;
 	tbl[idx++].data =3D &ipvs->sysctl_sync_refresh_period;
--=20
2.39.2 (Apple Git-143)

