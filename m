From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 2/9] IPVS: Backup, Adding structs for new sync format
Date: Fri, 12 Nov 2010 08:34:54 +0100
Message-ID: <1289547301-28015-2-git-send-email-hans.schillstrom@ericsson.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

New structs defined for version 1 of sync.

 * ip_vs_sync_v4       Ipv4 base format struct
 * ip_vs_sync_v6       Ipv6 base format struct

*v3
  Minor changes in comments
  [ horms@verge.net.au: minor documentation, spelling and whitespace changes ]

*v2
  ip_vs_sync_pe_opt removed due to new option/param handling.
  Julians comments with options casuses this change

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_sync.c |  154 ++++++++++++++++++++++++++++++++++++---
 1 files changed, 142 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 90ed9b3..0cfeeee 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -43,11 +43,13 @@
 #define IP_VS_SYNC_GROUP 0xe0000051    /* multicast addr - 224.0.0.81 */
 #define IP_VS_SYNC_PORT  8848          /* multicast port */
 
+#define SYNC_PROTO_VER  1		/* Protocol version in header */
 
 /*
  *	IPVS sync connection entry
+ *	Version 0, i.e. original version.
  */
-struct ip_vs_sync_conn {
+struct ip_vs_sync_conn_v0 {
 	__u8			reserved;
 
 	/* Protocol, addresses and port numbers */
@@ -71,40 +73,157 @@ struct ip_vs_sync_conn_options {
 	struct ip_vs_seq        out_seq;        /* outgoing seq. struct */
 };
 
+/*
+     Sync Connection format (sync_conn)
+
+       0                   1                   2                   3
+       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |    Type       |    Protocol   | Ver.  |        Size           |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                             Flags                             |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |            State              |         cport                 |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |            vport              |         dport                 |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                             fwmark                            |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                             timeout  (in sec.)                |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                              ...                              |
+      |                        IP-Addresses  (v4 or v6)               |
+      |                              ...                              |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+  Optional Parameters.
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      | Param. Type    | Param. Length |   Param. data                |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               |
+      |                              ...                              |
+      |                               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                               | Param Type    | Param. Length |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                           Param  data                         |
+      |         Last Param data should be padded for 32 bit alignment |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+*/
+
+/*
+ *  Type 0, IPv4 sync connection format
+ */
+struct ip_vs_sync_v4 {
+	__u8			type;
+	__u8			protocol;       /* Which protocol (TCP/UDP) */
+	__be16			ver_size;	/* Version msb 4 bits */
+	/* Flags and state transition */
+	__be32                  flags;          /* status flags */
+	__be16                  state;          /* state info 	*/
+	/* Protocol, addresses and port numbers */
+	__be16			cport;
+	__be16			vport;
+	__be16			dport;
+	__be32			fwmark;		/* Firewall mark from skb */
+	__be32			timeout;	/* cp timeout */
+	__be32			caddr;          /* client address */
+	__be32			vaddr;          /* virtual address */
+	__be32		        daddr;          /* destination address */
+	/* The sequence options start here */
+	/* PE data padded to 32bit alignment after seq. options */
+};
+/*
+ * Type 2 messages IPv6
+ */
+struct ip_vs_sync_v6 {
+	__u8			type;
+	__u8			protocol;       /* Which protocol (TCP/UDP) */
+	__be16			ver_size;	/* Version msb 4 bits */
+	/* Flags and state transition */
+	__be32                  flags;          /* status flags */
+	__be16                  state;          /* state info 	*/
+	/* Protocol, addresses and port numbers */
+	__be16			cport;
+	__be16          	vport;
+	__be16          	dport;
+	__be32			fwmark;		/* Firewall mark from skb */
+	__be32			timeout;	/* cp timeout */
+	struct in6_addr        	caddr;          /* client address */
+	struct in6_addr    	vaddr;          /* virtual address */
+	struct in6_addr         daddr;          /* destination address */
+	/* The sequence options start here */
+	/* PE data padded to 32bit alignment after seq. options */
+};
+
+union ip_vs_sync_conn {
+	struct ip_vs_sync_v4	v4;
+	struct ip_vs_sync_v6	v6;
+};
+
+/* Bits in Type field in above */
+#define STYPE_INET6		0
+#define STYPE_OPT_DATA		7
+#define STYPE_F_INET6		(1 << STYPE_INET6)
+#define STYPE_F_OPT_DATA	(1 << STYPE_OPT_DATA)
+
+#define SVER_SHIFT		12		/* Shift to get version */
+#define SVER_MASK		0x0fff		/* Mask to strip version */
+
+#define IPVS_OPT_SEQ_DATA	1
+#define IPVS_OPT_PE_DATA	2
+#define IPVS_OPT_PE_NAME	3
+
+#define IPVS_OPT_F_SEQ_DATA	(1 << (IPVS_OPT_SEQ_DATA-1))
+#define IPVS_OPT_F_PE_DATA	(1 << (IPVS_OPT_PE_DATA))
+#define IPVS_OPT_F_PE_NAME	(1 << (IPVS_OPT_PE_NAME))
+
 struct ip_vs_sync_thread_data {
 	struct socket *sock;
 	char *buf;
 };
 
-#define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn))
+/* Version 0 definition of packet sizes */
+#define SIMPLE_CONN_SIZE  (sizeof(struct ip_vs_sync_conn_v0))
 #define FULL_CONN_SIZE  \
-(sizeof(struct ip_vs_sync_conn) + sizeof(struct ip_vs_sync_conn_options))
+(sizeof(struct ip_vs_sync_conn_v0) + sizeof(struct ip_vs_sync_conn_options))
 
 
 /*
-  The master mulitcasts messages to the backup load balancers in the
-  following format.
+  The master mulitcasts messages (Datagrams) to the backup load balancers
+  in the following format.
+
+ Version 1:
+  Note, first byte should be Zero, so ver 0 receivers will drop the packet.
 
        0                   1                   2                   3
        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-      |  Count Conns  |    SyncID     |            Size               |
+      |      0        |    SyncID     |            Size               |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |  Count Conns  |    Version    |    Reserved, set to Zero      |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                                                               |
       |                    IPVS Sync Connection (1)                   |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                            .                                  |
-      |                            .                                  |
+      ~                            .                                  ~
       |                            .                                  |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
       |                                                               |
       |                    IPVS Sync Connection (n)                   |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+
+ Version 0 Header
+       0                   1                   2                   3
+       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |  Count Conns  |    SyncID     |            Size               |
+      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+      |                    IPVS Sync Connection (1)                   |
 */
 
 #define SYNC_MESG_HEADER_LEN	4
 #define MAX_CONNS_PER_SYNCBUFF	255 /* nr_conns in ip_vs_sync_mesg is 8 bit */
 
+/* Version 0 header */
 struct ip_vs_sync_mesg {
 	__u8                    nr_conns;
 	__u8                    syncid;
@@ -113,6 +232,17 @@ struct ip_vs_sync_mesg {
 	/* ip_vs_sync_conn entries start here */
 };
 
+/* Version 1 header */
+struct ip_vs_sync_mesg_v2 {
+	__u8			reserved;	/* must be zero */
+	__u8                    syncid;
+	__u16                   size;
+	__u8                    nr_conns;
+	__s8                    version;	/* SYNC_PROTO_VER  */
+	__u16			spare;
+	/* ip_vs_sync_conn entries start here */
+};
+
 /* the maximum length of sync (sending/receiving) message */
 static int sync_send_mesg_maxlen;
 static int sync_recv_mesg_maxlen;
@@ -239,7 +369,7 @@ get_curr_sync_buff(unsigned long time)
 void ip_vs_sync_conn(struct ip_vs_conn *cp)
 {
 	struct ip_vs_sync_mesg *m;
-	struct ip_vs_sync_conn *s;
+	struct ip_vs_sync_conn_v0 *s;
 	int len;
 
 	spin_lock(&curr_sb_lock);
@@ -254,7 +384,7 @@ void ip_vs_sync_conn(struct ip_vs_conn *cp)
 	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
 		SIMPLE_CONN_SIZE;
 	m = curr_sb->mesg;
-	s = (struct ip_vs_sync_conn *)curr_sb->head;
+	s = (struct ip_vs_sync_conn_v0 *)curr_sb->head;
 
 	/* copy members */
 	s->protocol = cp->protocol;
@@ -306,7 +436,7 @@ ip_vs_conn_fill_param_sync(int af, int protocol,
 static void ip_vs_process_message(const char *buffer, const size_t buflen)
 {
 	struct ip_vs_sync_mesg *m = (struct ip_vs_sync_mesg *)buffer;
-	struct ip_vs_sync_conn *s;
+	struct ip_vs_sync_conn_v0 *s;
 	struct ip_vs_sync_conn_options *opt;
 	struct ip_vs_conn *cp;
 	struct ip_vs_protocol *pp;
@@ -343,7 +473,7 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
 			IP_VS_ERR_RL("bogus conn in sync message\n");
 			return;
 		}
-		s = (struct ip_vs_sync_conn *) p;
+		s = (struct ip_vs_sync_conn_v0 *) p;
 		flags = ntohs(s->flags) | IP_VS_CONN_F_SYNC;
 		flags &= ~IP_VS_CONN_F_HASHED;
 		if (flags & IP_VS_CONN_F_SEQ_MASK) {
@@ -851,7 +981,7 @@ int start_sync_thread(int state, char *mcast_ifn, __u8 syncid)
 
 	IP_VS_DBG(7, "%s(): pid %d\n", __func__, task_pid_nr(current));
 	IP_VS_DBG(7, "Each ip_vs_sync_conn entry needs %Zd bytes\n",
-		  sizeof(struct ip_vs_sync_conn));
+		  sizeof(struct ip_vs_sync_conn_v0));
 
 	if (state == IP_VS_STATE_MASTER) {
 		if (sync_master_thread)
-- 
1.7.2.3

