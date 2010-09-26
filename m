From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: [patch] ipvs: Keep track of backlog connections
Date: Sun, 26 Sep 2010 16:31:49 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1009261629240.609@titan.stealer.net>
References: <20100926133101.GA9004@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100926133101.GA9004@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Venkata Mohan Reddy Koppula <mohanreddykv@gmail.com>

On Sun, 26 Sep 2010, Simon Horman wrote:

> here is an updated though as yet untested version of your patch from Julian
> to take into account recent changes. In particualr, the ip_vs_sync.c
> portion is no longer needed as only the flags in the first 16 bits are
> synced now. It applies against Patrick McHardy's nf-next-2.6 tree.
> 
> You mentioned in your original post that you would work on an ipvsadm
> patch for this feature. Have you had time to do so?
> 
> Also, are you in a position to test this? If not I can do so.

Hi,

I've tested your patch with the below addition to ipvsadm and it works 
correctly. 

Sven

From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] Show backlog connections

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 ipvsadm.c                 |   51 ++++++++++++++++++++++++++++++--------------
 libipvs/ip_vs.h           |    4 +++
 libipvs/ip_vs_nl_policy.c |    1 +
 libipvs/libipvs.c         |    3 ++
 4 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 8557d21..54ae110 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -181,7 +181,8 @@ static const char* cmdnames[] = {
 #define OPT_SYNCID		0x080000
 #define OPT_EXACT		0x100000
 #define OPT_ONEPACKET		0x200000
-#define NUMBER_OF_OPT		22
+#define OPT_BACKLOGCONN		0x400000
+#define NUMBER_OF_OPT		23
 
 static const char* optnames[] = {
 	"numeric",
@@ -206,6 +207,7 @@ static const char* optnames[] = {
 	"syncid",
 	"exact",
 	"ops",
+	"backlog-conn",
 };
 
 /*
@@ -218,21 +220,21 @@ static const char* optnames[] = {
  */
 static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 {
-	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops */
-/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' '},
-/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' '},
-/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x'},
-/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x'},
-/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x'},
-/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
-/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops, blc */
+/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x'},
+/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x'},
+/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', ' '},
+/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x'},
+/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x'},
+/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
+/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
 };
 
 /* printing format flags */
@@ -245,6 +247,7 @@ static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
 #define FMT_PERSISTENTCONN	0x0020
 #define FMT_NOSORT		0x0040
 #define FMT_EXACT		0x0080
+#define FMT_BACKLOGCONN		0x0100
 
 #define SERVICE_NONE		0x0000
 #define SERVICE_ADDR		0x0001
@@ -282,6 +285,7 @@ enum {
 	TAG_PERSISTENTCONN,
 	TAG_SORT,
 	TAG_NO_SORT,
+	TAG_BACKLOGCONN,
 };
 
 /* various parsing helpers & parsing functions */
@@ -421,6 +425,8 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 		{ "exact", 'X', POPT_ARG_NONE, NULL, 'X', NULL, NULL },
 		{ "ipv6", '6', POPT_ARG_NONE, NULL, '6', NULL, NULL },
 		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
+		{ "backlog-conn", '\0', POPT_ARG_NONE, NULL,
+		  TAG_BACKLOGCONN, NULL, NULL },
 		{ NULL, 0, 0, NULL, 0, NULL, NULL }
 	};
 
@@ -647,6 +653,10 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
 			set_option(options, OPT_ONEPACKET);
 			ce->svc.flags |= IP_VS_SVC_F_ONEPACKET;
 			break;
+		case TAG_BACKLOGCONN:
+			set_option(options, OPT_BACKLOGCONN);
+			*format |= FMT_BACKLOGCONN;
+			break;
 		default:
 			fail(2, "invalid option `%s'",
 			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
@@ -1396,6 +1406,11 @@ static void print_title(unsigned int format)
 		       "  -> RemoteAddress:Port\n",
 		       "Prot LocalAddress:Port",
 		       "Weight", "PersistConn", "ActiveConn", "InActConn");
+	else if (format & FMT_BACKLOGCONN)
+		printf("%-33s %-9s %-11s %-10s %-10s\n"
+		       "  -> RemoteAddress:Port\n",
+		       "Prot LocalAddress:Port",
+		       "Weight", "BacklogConn", "ActiveConn", "InActConn");
 	else if (!(format & FMT_RULE))
 		printf("Prot LocalAddress:Port Scheduler Flags\n"
 		       "  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn\n");
@@ -1539,6 +1554,10 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 			printf("  -> %-28s %-9u %-11u %-10u %-10u\n", dname,
 			       e->weight, e->persistconns,
 			       e->activeconns, e->inactconns);
+		} else if (format & FMT_BACKLOGCONN) {
+			printf("  -> %-28s %-9u %-11u %-10u %-10u\n", dname,
+			       e->weight, e->backlogconns,
+			       e->activeconns, e->inactconns);
 		} else
 			printf("  -> %-28s %-7s %-6d %-10u %-10u\n",
 			       dname, fwd_name(e->conn_flags),
diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
index 843c51a..4c2c265 100644
--- a/libipvs/ip_vs.h
+++ b/libipvs/ip_vs.h
@@ -277,6 +277,8 @@ struct ip_vs_dest_entry {
 	struct ip_vs_stats_user stats;
 	u_int16_t		af;
 	union nf_inet_addr	addr;
+
+	u_int32_t		backlogconns;	/* backlog connections */
 };
 
 /* The argument to IP_VS_SO_GET_DESTS */
@@ -455,6 +457,8 @@ enum {
 	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */
 
 	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
+
+	IPVS_DEST_ATTR_BACKLOG_CONNS,	/* backlog connections */
 	__IPVS_DEST_ATTR_MAX,
 };
 
diff --git a/libipvs/ip_vs_nl_policy.c b/libipvs/ip_vs_nl_policy.c
index c80083e..d06a490 100644
--- a/libipvs/ip_vs_nl_policy.c
+++ b/libipvs/ip_vs_nl_policy.c
@@ -40,6 +40,7 @@ struct nla_policy ipvs_dest_policy[IPVS_DEST_ATTR_MAX + 1] = {
 	[IPVS_DEST_ATTR_INACT_CONNS]	= { .type = NLA_U32 },
 	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
 	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
+	[IPVS_DEST_ATTR_BACKLOG_CONNS]	= { .type = NLA_U32 },
 };
 
 struct nla_policy ipvs_stats_policy[IPVS_STATS_ATTR_MAX + 1] = {
diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 979d5bd..e06f9fa 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -748,6 +748,8 @@ static int ipvs_dests_parse_cb(struct nl_msg *msg, void *arg)
 	d->entrytable[i].l_threshold = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_L_THRESH]);
 	d->entrytable[i].activeconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_ACTIVE_CONNS]);
 	d->entrytable[i].inactconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_INACT_CONNS]);
+	if (dest_attrs[IPVS_DEST_ATTR_BACKLOG_CONNS])
+		d->entrytable[i].backlogconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_BACKLOG_CONNS]);
 	d->entrytable[i].persistconns = nla_get_u32(dest_attrs[IPVS_DEST_ATTR_PERSIST_CONNS]);
 	d->entrytable[i].af = d->af;
 
@@ -853,6 +855,7 @@ ipvs_nl_dest_failure:
 		       sizeof(struct ip_vs_dest_entry_kern));
 		d->entrytable[i].af = AF_INET;
 		d->entrytable[i].addr.ip = d->entrytable[i].__addr_v4;
+		d->entrytable[i].backlogconns = 0;
 	}
 	free(dk);
 	return d;
