From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch] ipvs: Use atomic operations atomicly
Date: Sat, 19 Sep 2009 19:51:23 +1000
Message-ID: <20090919095122.GA480@verge.net.au>
References: <20090828023722.GA12136@verge.net.au>
 <4A9BC082.3090804@trash.net>
 <20090901015909.GA12252@verge.net.au>
 <4A9E6B62.8080208@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9E6B62.8080208@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, ?? shin hong <hongshin@gmail.com>, David Miller <davem@davemloft.net>

[ re-post with CC list ]

On Wed, Sep 02, 2009 at 02:56:02PM +0200, Patrick McHardy wrote:
> Simon Horman wrote:
> > On Mon, Aug 31, 2009 at 02:22:26PM +0200, Patrick McHardy wrote:
> >> It seems that proc_do_sync_threshold() should check whether this value
> >> is zero. The current checks also look racy since incorrect values are
> >> first updated, then overwritten again.
> > 
> > I'm wondering if an approach along the lines of the following is valid.
> > The idea is that the value in the ctl_table is essentially a scratch
> > value that is used by the parser and then copied into ip_vs_sync_threshold
> > if it is valid.
> 
> Even simpler would be to use a temporary buffer on the stack for copying
> the values from userspace and then copy them to the final buffer after
> validation.

Do you mean something like what I have done using read_table in
the new patch below?

> > I'm concerned that there are atomicity issues
> > surrounding writing ip_vs_sync_threshold while there might be readers.
> 
> That might be a problem if they are required to be "synchronized".

I don't think that the sychronisation needs extend beyond their
use in this snippet.

> 
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1362,8 +1362,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
> >  	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
> >  	    (((cp->protocol != IPPROTO_TCP ||
> >  	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
> > -	      (pkts % sysctl_ip_vs_sync_threshold[1]
> > -	       == sysctl_ip_vs_sync_threshold[0])) ||
> > +	      (pkts % ip_vs_sync_threshold[1] == ip_vs_sync_threshold[0])) ||
> >  	     ((cp->protocol == IPPROTO_TCP) && (cp->old_state != cp->state) &&
> >  	      ((cp->state == IP_VS_TCP_S_FIN_WAIT) ||
> >  	       (cp->state == IP_VS_TCP_S_CLOSE_WAIT) ||
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index fba2892..8a9ff21 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -76,6 +76,11 @@ static atomic_t ip_vs_dropentry = ATOMIC_INIT(0);
> >  /* number of virtual services */
> >  static int ip_vs_num_services = 0;
> >  
> > +/* threshold handling */
> > +static int ip_vs_sync_threshold_min = 0;
> > +static int ip_vs_sync_threshold_max = INT_MAX;
> > +int ip_vs_sync_threshold[2] = { 3, 50 };
> > +
> 
> min should be 1 I guess or you still need to manually check
> that ip_vs_sync_threshold[1] != 0 to avoid a division be zero.

I think that the check that val[0] < val[1] ensures this.

Something that I noticed while putting this new patch together,
should the code be checking the value of rc and only assigning  values if
its 0. If so, I probably needs to be changed in a few places.

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index fba2892..c33ef7d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -76,6 +76,9 @@ static atomic_t ip_vs_dropentry = ATOMIC_INIT(0);
 /* number of virtual services */
 static int ip_vs_num_services = 0;
 
+static int ip_vs_sync_threshold_min = 0;
+static int ip_vs_sync_threshold_max = INT_MAX;
+
 /* sysctl variables */
 static int sysctl_ip_vs_drop_entry = 0;
 static int sysctl_ip_vs_drop_packet = 0;
@@ -1520,18 +1523,17 @@ static int
 proc_do_sync_threshold(ctl_table *table, int write, struct file *filp,
 		       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
+	struct ctl_table read_table;
 	int *valp = table->data;
 	int val[2];
 	int rc;
 
-	/* backup the value first */
-	memcpy(val, valp, sizeof(val));
+	memcpy(&read_table, table, sizeof(read_table));
+	read_table.data = &val;
 
-	rc = proc_dointvec(table, write, filp, buffer, lenp, ppos);
-	if (write && (valp[0] < 0 || valp[1] < 0 || valp[0] >= valp[1])) {
-		/* Restore the correct value */
+	rc = proc_dointvec_minmax(&read_table, write, filp, buffer, lenp, ppos);
+	if (write && (val[0] >= val[1]))
 		memcpy(valp, val, sizeof(val));
-	}
 	return rc;
 }
 
@@ -1698,6 +1700,8 @@ static struct ctl_table vs_vars[] = {
 		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
 		.mode		= 0644,
 		.proc_handler	= proc_do_sync_threshold,
+		.extra1		= &ip_vs_sync_threshold_min,
+		.extra2		= &ip_vs_sync_threshold_max,
 	},
 	{
 		.procname	= "nat_icmp_send",
