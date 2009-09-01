From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvs: Use atomic operations atomicly
Date: Tue, 1 Sep 2009 11:59:12 +1000
Message-ID: <20090901015909.GA12252@verge.net.au>
References: <20090828023722.GA12136@verge.net.au> <4A9BC082.3090804@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9BC082.3090804@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?utf-8?B?7ZmN7Iug?= shin hong <hongshin@gmail.com>, David Miller <davem@davemloft.net>

On Mon, Aug 31, 2009 at 02:22:26PM +0200, Patrick McHardy wrote:
> Simon Horman wrote:
> > A pointed out by Shin Hong, IPVS doesn't always use atomic operatio=
ns
> > in an atomic manner. While this seems unlikely to be manifest in
> > strange behaviour, it seems appropriate to clean this up.
> >=20
> > Cc: =ED=99=8D=EC=8B=A0 shin hong <hongshin@gmail.com>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> Applied, thanks.
>=20
> >  	if (af =3D=3D AF_INET &&
> >  	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
> >  	    (((cp->protocol !=3D IPPROTO_TCP ||
> >  	       cp->state =3D=3D IP_VS_TCP_S_ESTABLISHED) &&
> > -	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
> > +	      (pkts % sysctl_ip_vs_sync_threshold[1]
>=20
> It seems that proc_do_sync_threshold() should check whether this valu=
e
> is zero. The current checks also look racy since incorrect values are
> first updated, then overwritten again.

Hi,

I'm wondering if an approach along the lines of the following is valid.
The idea is that the value in the ctl_table is essentially a scratch
value that is used by the parser and then copied into ip_vs_sync_thresh=
old
if it is valid. I'm concerned that there are atomicity issues
surrounding writing ip_vs_sync_threshold while there might be readers.

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 98978e7..28d0c4f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -774,8 +774,8 @@ extern int ip_vs_leave(struct ip_vs_service *svc, s=
truct sk_buff *skb,
 extern int sysctl_ip_vs_cache_bypass;
 extern int sysctl_ip_vs_expire_nodest_conn;
 extern int sysctl_ip_vs_expire_quiescent_template;
-extern int sysctl_ip_vs_sync_threshold[2];
 extern int sysctl_ip_vs_nat_icmp_send;
+extern int ip_vs_sync_threshold[2];
 extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
=20
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index b95699f..f3572b6 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1362,8 +1362,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *sk=
b,
 	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol !=3D IPPROTO_TCP ||
 	       cp->state =3D=3D IP_VS_TCP_S_ESTABLISHED) &&
-	      (pkts % sysctl_ip_vs_sync_threshold[1]
-	       =3D=3D sysctl_ip_vs_sync_threshold[0])) ||
+	      (pkts % ip_vs_sync_threshold[1] =3D=3D ip_vs_sync_threshold[0])=
) ||
 	     ((cp->protocol =3D=3D IPPROTO_TCP) && (cp->old_state !=3D cp->st=
ate) &&
 	      ((cp->state =3D=3D IP_VS_TCP_S_FIN_WAIT) ||
 	       (cp->state =3D=3D IP_VS_TCP_S_CLOSE_WAIT) ||
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
index fba2892..8a9ff21 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -76,6 +76,11 @@ static atomic_t ip_vs_dropentry =3D ATOMIC_INIT(0);
 /* number of virtual services */
 static int ip_vs_num_services =3D 0;
=20
+/* threshold handling */
+static int ip_vs_sync_threshold_min =3D 0;
+static int ip_vs_sync_threshold_max =3D INT_MAX;
+int ip_vs_sync_threshold[2] =3D { 3, 50 };
+
 /* sysctl variables */
 static int sysctl_ip_vs_drop_entry =3D 0;
 static int sysctl_ip_vs_drop_packet =3D 0;
@@ -85,7 +90,7 @@ static int sysctl_ip_vs_am_droprate =3D 10;
 int sysctl_ip_vs_cache_bypass =3D 0;
 int sysctl_ip_vs_expire_nodest_conn =3D 0;
 int sysctl_ip_vs_expire_quiescent_template =3D 0;
-int sysctl_ip_vs_sync_threshold[2] =3D { 3, 50 };
+static int sysctl_ip_vs_sync_threshold[2];
 int sysctl_ip_vs_nat_icmp_send =3D 0;
=20
=20
@@ -1521,17 +1526,12 @@ proc_do_sync_threshold(ctl_table *table, int wr=
ite, struct file *filp,
 		       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp =3D table->data;
-	int val[2];
 	int rc;
=20
-	/* backup the value first */
-	memcpy(val, valp, sizeof(val));
-
-	rc =3D proc_dointvec(table, write, filp, buffer, lenp, ppos);
-	if (write && (valp[0] < 0 || valp[1] < 0 || valp[0] >=3D valp[1])) {
-		/* Restore the correct value */
-		memcpy(valp, val, sizeof(val));
-	}
+	rc =3D proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	if (write && (valp[0] < valp[1]))
+		memcpy(ip_vs_sync_threshold, valp,
+		       sizeof(ip_vs_sync_threshold));
 	return rc;
 }
=20
@@ -1698,6 +1698,8 @@ static struct ctl_table vs_vars[] =3D {
 		.maxlen		=3D sizeof(sysctl_ip_vs_sync_threshold),
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_do_sync_threshold,
+		.extra1		=3D &ip_vs_sync_threshold_min,
+		.extra2		=3D &ip_vs_sync_threshold_max,
 	},
 	{
 		.procname	=3D "nat_icmp_send",
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs=
_sync.c
index e177f0d..d3322fb 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -438,7 +438,7 @@ static void ip_vs_process_message(const char *buffe=
r, const size_t buflen)
=20
 		if (opt)
 			memcpy(&cp->in_seq, opt, sizeof(*opt));
-		atomic_set(&cp->in_pkts, sysctl_ip_vs_sync_threshold[0]);
+		atomic_set(&cp->in_pkts, ip_vs_sync_threshold[0]);
 		cp->state =3D state;
 		cp->old_state =3D cp->state;
 		/*
