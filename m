From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 8/8] IPVS: Backup, adding version 0 sending capabilities
Date: Thu, 25 Nov 2010 10:46:58 +0900
Message-ID: <1290649618-18955-9-git-send-email-horms@verge.net.au>
References: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290649618-18955-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Simon Horman <horms@verge.net.au>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

This patch adds a sysclt net.ipv4.vs.sync_version
that can be used to send sync msg in version 0 or 1 format.

sync_version value is logical,
     Value 1 (default) New version
           0 Plain old version

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |    2 +
 net/netfilter/ipvs/ip_vs_ctl.c  |   28 ++++++++-
 net/netfilter/ipvs/ip_vs_sync.c |  134 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 163 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a715f3d..d858264 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -883,7 +883,9 @@ extern int sysctl_ip_vs_conntrack;
 extern int sysctl_ip_vs_snat_reroute;
 extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
+extern int sysctl_ip_vs_sync_ver;
 
+extern void ip_vs_sync_switch_mode(int mode);
 extern struct ip_vs_service *
 ip_vs_service_get(int af, __u32 fwmark, __u16 protocol,
 		  const union nf_inet_addr *vaddr, __be16 vport);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a5bd002..d12a13c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -92,7 +92,7 @@ int sysctl_ip_vs_nat_icmp_send = 0;
 int sysctl_ip_vs_conntrack;
 #endif
 int sysctl_ip_vs_snat_reroute = 1;
-
+int sysctl_ip_vs_sync_ver = 1;		/* Default version of sync proto */
 
 #ifdef CONFIG_IP_VS_DEBUG
 static int sysctl_ip_vs_debug_level = 0;
@@ -1536,6 +1536,25 @@ proc_do_sync_threshold(ctl_table *table, int write,
 	return rc;
 }
 
+static int
+proc_do_sync_mode(ctl_table *table, int write,
+		     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = table->data;
+	int val = *valp;
+	int rc;
+
+	rc = proc_dointvec(table, write, buffer, lenp, ppos);
+	if (write && (*valp != val)) {
+		if ((*valp < 0) || (*valp > 1)) {
+			/* Restore the correct value */
+			*valp = val;
+		} else {
+			ip_vs_sync_switch_mode(val);
+		}
+	}
+	return rc;
+}
 
 /*
  *	IPVS sysctl table (under the /proc/sys/net/ipv4/vs/)
@@ -1602,6 +1621,13 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.procname	= "sync_version",
+		.data		= &sysctl_ip_vs_sync_ver,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_do_sync_mode,
+	},
 #if 0
 	{
 		.procname	= "timeout_established",
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index df5abf0..c1c167a 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -5,6 +5,18 @@
  *              high-performance and highly available server based on a
  *              cluster of servers.
  *
+ * Version 1,   is capable of handling both version 0 and 1 messages.
+ *              Version 0 is the plain old format.
+ *              Note Version 0 receivers will just drop Ver 1 messages.
+ *              Version 1 is capable of handle IPv6, Persistence data,
+ *              time-outs, and firewall marks.
+ *              In ver.1 "ip_vs_sync_conn_options" will be sent in netw. order.
+ *              Ver. 0 can be turned on by sysctl -w net.ipv4.vs.sync_version=0
+ *
+ * Definitions  Message: is a complete datagram
+ *              Sync_conn: is a part of a Message
+ *              Param Data is an option to a Sync_conn.
+ *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  * ip_vs_sync:  sync connection info from master load balancer to backups
@@ -15,6 +27,8 @@
  *	Alexandre Cassen	:	Added SyncID support for incoming sync
  *					messages filtering.
  *	Justin Ossevoort	:	Fix endian problem on sync message size.
+ *	Hans Schillstrom	:	Added Version 1: i.e. IPv6,
+ *					Persistence support, fwmark and time-out.
  */
 
 #define KMSG_COMPONENT "IPVS"
@@ -392,6 +406,121 @@ get_curr_sync_buff(unsigned long time)
 }
 
 /*
+ * Switch mode from sending version 0 or 1
+ *  - must handle sync_buf
+ */
+void ip_vs_sync_switch_mode(int mode) {
+
+	if (!ip_vs_sync_state & IP_VS_STATE_MASTER)
+		return;
+	if (mode == sysctl_ip_vs_sync_ver || !curr_sb)
+		return;
+
+	spin_lock_bh(&curr_sb_lock);
+	/* Buffer empty ? then let buf_create do the job  */
+	if ( curr_sb->mesg->size <=  sizeof(struct ip_vs_sync_mesg)) {
+		kfree(curr_sb);
+		curr_sb = NULL;
+	} else {
+		spin_lock_bh(&ip_vs_sync_lock);
+		if (ip_vs_sync_state & IP_VS_STATE_MASTER)
+			list_add_tail(&curr_sb->list, &ip_vs_sync_queue);
+		else
+			ip_vs_sync_buff_release(curr_sb);
+		spin_unlock_bh(&ip_vs_sync_lock);
+	}
+	spin_unlock_bh(&curr_sb_lock);
+}
+
+/*
+ * Create a new sync buffer for Version 0 proto.
+ */
+static inline struct ip_vs_sync_buff * ip_vs_sync_buff_create_v0(void)
+{
+	struct ip_vs_sync_buff *sb;
+	struct ip_vs_sync_mesg_v0 *mesg;
+
+	if (!(sb=kmalloc(sizeof(struct ip_vs_sync_buff), GFP_ATOMIC)))
+		return NULL;
+
+	if (!(sb->mesg=kmalloc(sync_send_mesg_maxlen, GFP_ATOMIC))) {
+		kfree(sb);
+		return NULL;
+	}
+	mesg = (struct ip_vs_sync_mesg_v0 *)sb->mesg;
+	mesg->nr_conns = 0;
+	mesg->syncid = ip_vs_master_syncid;
+	mesg->size = 4;
+	sb->head = (unsigned char *)mesg + 4;
+	sb->end = (unsigned char *)mesg + sync_send_mesg_maxlen;
+	sb->firstuse = jiffies;
+	return sb;
+}
+
+/*
+ *      Version 0 , could be switched in by sys_ctl.
+ *      Add an ip_vs_conn information into the current sync_buff.
+ */
+void ip_vs_sync_conn_v0(struct ip_vs_conn *cp)
+{
+	struct ip_vs_sync_mesg_v0 *m;
+	struct ip_vs_sync_conn_v0 *s;
+	int len;
+
+	if (unlikely(cp->af != AF_INET))
+		return;
+	/* Do not sync ONE PACKET */
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		return;
+
+	spin_lock(&curr_sb_lock);
+	if (!curr_sb) {
+		if (!(curr_sb=ip_vs_sync_buff_create_v0())) {
+			spin_unlock(&curr_sb_lock);
+			pr_err("ip_vs_sync_buff_create failed.\n");
+			return;
+		}
+	}
+
+	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
+		SIMPLE_CONN_SIZE;
+	m = (struct ip_vs_sync_mesg_v0 *)curr_sb->mesg;
+	s = (struct ip_vs_sync_conn_v0 *)curr_sb->head;
+
+	/* copy members */
+	s->reserved = 0;
+	s->protocol = cp->protocol;
+	s->cport = cp->cport;
+	s->vport = cp->vport;
+	s->dport = cp->dport;
+	s->caddr = cp->caddr.ip;
+	s->vaddr = cp->vaddr.ip;
+	s->daddr = cp->daddr.ip;
+	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
+	s->state = htons(cp->state);
+	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
+		struct ip_vs_sync_conn_options *opt =
+			(struct ip_vs_sync_conn_options *)&s[1];
+		memcpy(opt, &cp->in_seq, sizeof(*opt));
+	}
+
+	m->nr_conns++;
+	m->size += len;
+	curr_sb->head += len;
+
+	/* check if there is a space for next one */
+	if (curr_sb->head + FULL_CONN_SIZE > curr_sb->end) {
+		sb_queue_tail(curr_sb);
+		curr_sb = NULL;
+	}
+	spin_unlock(&curr_sb_lock);
+
+	/* synchronize its controller if it has */
+	if (cp->control)
+		ip_vs_sync_conn(cp->control);
+}
+
+/*
  *      Add an ip_vs_conn information into the current sync_buff.
  *      Called by ip_vs_in.
  *      Sending Version 1 messages
@@ -403,6 +532,11 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 	__u8 *p;
 	unsigned int len, pe_name_len, pad;
 
+	/* Handle old version of the protocol */
+	if (sysctl_ip_vs_sync_ver == 0) {
+		ip_vs_sync_conn_v0(cp);
+		return;
+	}
 	/* Do not sync ONE PACKET */
 	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
 		goto control;
-- 
1.7.2.3

