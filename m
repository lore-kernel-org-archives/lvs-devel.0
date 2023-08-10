From: Sishuai Gong <sishuai.system@gmail.com>
Subject: Re: Race over table->data in proc_do_sync_threshold()
Date: Thu, 10 Aug 2023 11:05:52 -0400
Message-ID: <8D17F8D2-BF68-4BA4-8590-7DE1E71872A6@gmail.com>
References: <B6988E90-0A1E-4B85-BF26-2DAF6D482433@gmail.com>
 <b4854287-cb97-27fb-053f-e52179c05e97@ssi.bg>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3731.700.6\))
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1691679964; x=1692284764;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=hcINWyJSy8FttTW3PogPL++09l+HfsTCOWsOuolO/bE=;
        b=KyIlz0OeO6bMm1ooGIrzCXWAgefelU5mc6aRrLiEWtXG1HD2SvOhso0K0vqfzIAkJ4
         mSgx4E7yHLk9vJkGD+opdVHi5uksB8nWwBYacPtUTK7uGWp0OBnc1SrPtceSQCC+LqyH
         ZG2ACq3+klOjJZNzun7K3inI6PlIPhrYj46tcUGwcBGhYqi3xMgrzOOHLtOkpWN985rv
         IglUYR/JZ5MNf4zOIk83SldvSBJeUW/UWYON0mP6W4GK0BfpyR4tRlcC/jMb6L5Vslzy
         sXKsnxzWAVsKbYd6Iv1rp3x/VBS+S3nMDSi3Ev2os3OOqec5vdBDu6RX9Gw2IRvJ9yAz
         imhg==
In-Reply-To: <b4854287-cb97-27fb-053f-e52179c05e97@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org

Hello,

I am not familiar with the code but I would like to give it a try :).

It seems to me that replacing the second memcpy with WRITE_ONCE()=20
is not necessary as long as we still hold the lock. Otherwise is this =
close
to what you suggest?

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c =
b/net/netfilter/ipvs/ip_vs_ctl.c
index 62606fb44d02..b4e22e30b896 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1876,6 +1876,7 @@ static int
 proc_do_sync_threshold(struct ctl_table *table, int write,
                       void *buffer, size_t *lenp, loff_t *ppos)
 {
+      struct netns_ipvs *ipvs =3D table->extra2;
        int *valp =3D table->data;
        int val[2];
        int rc;
@@ -1885,6 +1886,7 @@ proc_do_sync_threshold(struct ctl_table *table, =
int write,
                .mode =3D table->mode,
        };

+      mutex_lock(&ipvs->sync_mutex);
        memcpy(val, valp, sizeof(val));
        rc =3D proc_dointvec(&tmp, write, buffer, lenp, ppos);
        if (write) {
@@ -1894,6 +1896,7 @@ proc_do_sync_threshold(struct ctl_table *table, =
int write,
                else
                        memcpy(valp, val, sizeof(val));
        }
+      mutex_unlock(&ipvs->sync_mutex);
        return rc;
 }

@@ -4321,6 +4324,7 @@ static int __net_init =
ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
        ipvs->sysctl_sync_threshold[0] =3D DEFAULT_SYNC_THRESHOLD;
        ipvs->sysctl_sync_threshold[1] =3D DEFAULT_SYNC_PERIOD;
        tbl[idx].data =3D &ipvs->sysctl_sync_threshold;
+      tbl[idx].extra2 =3D ipvs;
        tbl[idx++].maxlen =3D sizeof(ipvs->sysctl_sync_threshold);
        ipvs->sysctl_sync_refresh_period =3D =
DEFAULT_SYNC_REFRESH_PERIOD;
        tbl[idx++].data =3D &ipvs->sysctl_sync_refresh_period;

> On Aug 10, 2023, at 2:20 AM, Julian Anastasov <ja@ssi.bg> wrote:
>=20
>=20
> Hello,
>=20
> On Wed, 9 Aug 2023, Sishuai Gong wrote:
>=20
>> Hi,
>>=20
>> We observed races over (struct ctl_table *) table->data when two =
threads
>> are running proc_do_sync_threshold() in parallel, as shown below:
>>=20
>> Thread-1 Thread-2
>> memcpy(val, valp, sizeof(val)); memcpy(valp, val, sizeof(val));
>>=20
>> This race probably would mess up table->data. Is it better to add a =
lock?
>=20
> We can put mutex_lock(&ipvs->sync_mutex) before the first
> memcpy and to use two WRITE_ONCE instead of the second memcpy. But
> this requires extra2 =3D ipvs in ip_vs_control_net_init_sysctl():
>=20
> tbl[idx].data =3D &ipvs->sysctl_sync_threshold;
> + tbl[idx].extra2 =3D ipvs;
>=20
> Will you provide patch?
>=20
> Regards
>=20
> --
> Julian Anastasov <ja@ssi.bg>


