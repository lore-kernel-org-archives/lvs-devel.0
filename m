From: Julius Volz <juliusv@google.com>
Subject: [PATCH 1/2] IPVS: Add genetlink interface definitions to ip_vs.h
Date: Wed,  9 Jul 2008 17:11:56 +0200
Message-ID: <1215616317-11386-2-git-send-email-juliusv@google.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1215616325; bh=2sADe2RX7xHK79TcaQ5Dau0ydbk=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=rGVjEi6XP6FgR46AxS8VKRK5WatKsfvpZl9EEn8X
	jW1F+y/EMkGEkeJFtdRWOdLYvcqw+IIB427z7In2gUIc1g==
In-Reply-To: <1215616317-11386-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: vbusam@google.com, horms@verge.net.au, kaber@trash.net, davem@davemloft.net, Julius Volz <juliusv@google.com>

Add IPVS Generic Netlink interface definitions to include/linux/ip_vs.h.

This depends on this patch I sent yesterday:
"IPVS: Move userspace definitions to include/linux/ip_vs.h"

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 168 insertions(+), 0 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index 2d4eb68..83ed646 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -245,4 +245,172 @@ struct ip_vs_daemon_user {
 	int			syncid;
 };
 
+/*
+ *
+ * IPVS Generic Netlink interface definitions
+ *
+ */
+
+/* Generic Netlink family info */
+
+#define IPVS_GENL_NAME		"IPVS"
+#define IPVS_GENL_VERSION	0x1
+
+struct ip_vs_flags {
+	__be32 flags;
+	__be32 mask;
+};
+
+/* Generic Netlink command attributes */
+enum {
+	IPVS_CMD_UNSPEC = 0,
+
+	/* SET commands */
+	IPVS_CMD_ADD_SERVICE,		/* add or modify service */
+	IPVS_CMD_EDIT_SERVICE,		/* add or modify service */
+	IPVS_CMD_DEL_SERVICE,		/* delete service */
+	IPVS_CMD_ADD_DEST,		/* add or modify destination */
+	IPVS_CMD_EDIT_DEST,		/* add or modify destination */
+	IPVS_CMD_DEL_DEST,		/* delete destination */
+	IPVS_CMD_FLUSH,			/* flush all services and dests */
+	IPVS_CMD_SET_TIMEOUT,		/* set TCP and UDP timeouts */
+	IPVS_CMD_START_DAEMON,		/* start sync daemon */
+	IPVS_CMD_STOP_DAEMON,		/* stop sync daemon */
+	IPVS_CMD_ZERO,			/* zero all counters and stats */
+
+	/* GET commands */
+	IPVS_CMD_GET_INFO,		/* get general IPVS info */
+	IPVS_CMD_GET_SERVICES,		/* get list of all services */
+	IPVS_CMD_GET_SERVICE,		/* get info about specific service */
+	IPVS_CMD_GET_DESTS,		/* get list of all service dests */
+	IPVS_CMD_GET_TIMEOUT,		/* get TCP and UDP timeouts */
+	IPVS_CMD_GET_DAEMONS,		/* get sync daemon status */
+	__IPVS_CMD_MAX,
+};
+
+#define IPVS_CMD_MAX (__IPVS_CMD_MAX - 1)
+
+/*
+ * Attributes used in the first level of commands that maintain multiple entries
+ * of the same element type (services, destinations, sync daemons)
+ */
+enum {
+	IPVS_ENTRY_ATTR_UNSPEC = 0,
+	IPVS_ENTRY_ATTR_SERVICE,	/* nested service attribute */
+	IPVS_ENTRY_ATTR_DEST,		/* nested destination attribute */
+	IPVS_ENTRY_ATTR_DAEMON,		/* nested sync daemon attribute */
+	__IPVS_ENTRY_ATTR_MAX,
+};
+
+#define IPVS_ENTRY_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)
+
+/*
+ * Attributes used to describe a service
+ *
+ * Used inside nested attribute IPVS_ENTRY_ATTR_SERVICE
+ */
+enum {
+	IPVS_SVC_ATTR_UNSPEC = 0,
+	IPVS_SVC_ATTR_AF,		/* address family */
+	IPVS_SVC_ATTR_PROTOCOL,		/* virtual service protocol */
+	IPVS_SVC_ATTR_ADDR,		/* virtual service address */
+	IPVS_SVC_ATTR_PORT,		/* virtual service port */
+	IPVS_SVC_ATTR_FWMARK,		/* firewall mark of service */
+
+	IPVS_SVC_ATTR_SCHED_NAME,	/* name of scheduler */
+	IPVS_SVC_ATTR_FLAGS,		/* virtual service flags */
+	IPVS_SVC_ATTR_TIMEOUT,		/* persistent timeout */
+	IPVS_SVC_ATTR_NETMASK,		/* persistent netmask */
+
+	IPVS_SVC_ATTR_STATS,		/* nested attribute for service stats */
+	__IPVS_SVC_ATTR_MAX,
+};
+
+#define IPVS_SVC_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)
+
+/*
+ * Attributes used to describe a destination (real server)
+ *
+ * Used inside nested attribute IPVS_ENTRY_ATTR_DEST
+ */
+enum {
+	IPVS_DEST_ATTR_UNSPEC = 0,
+	IPVS_DEST_ATTR_ADDR,		/* real server address */
+	IPVS_DEST_ATTR_PORT,		/* real server port */
+
+	IPVS_DEST_ATTR_FWD_METHOD,	/* forwarding method */
+	IPVS_DEST_ATTR_WEIGHT,		/* destination weight */
+
+	IPVS_DEST_ATTR_U_THRESH,	/* upper threshold */
+	IPVS_DEST_ATTR_L_THRESH,	/* lower threshold */
+
+	IPVS_DEST_ATTR_ACTIVE_CONNS,	/* active connections */
+	IPVS_DEST_ATTR_INACT_CONNS,	/* inactive connections */
+	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */
+
+	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
+	__IPVS_DEST_ATTR_MAX,
+};
+
+#define IPVS_DEST_ATTR_MAX (__IPVS_DEST_ATTR_MAX - 1)
+
+/*
+ * Attributes describing a sync daemon
+ *
+ * Used inside nested attribute IPVS_ENTRY_ATTR_DAEMON
+ */
+enum {
+	IPVS_DAEMON_ATTR_UNSPEC = 0,
+	IPVS_DAEMON_ATTR_STATE,		/* sync daemon state (master/backup) */
+	IPVS_DAEMON_ATTR_MCAST_IFN,	/* multicast interface name */
+	IPVS_DAEMON_ATTR_SYNC_ID,	/* SyncID we belong to */
+	__IPVS_DAEMON_ATTR_MAX,
+};
+
+#define IPVS_DAEMON_ATTR_MAX (__IPVS_DAEMON_ATTR_MAX - 1)
+
+/*
+ * Attributes used to describe service or destination entry statistics
+ *
+ * Used inside nested attributes IPVS_SVC_ATTR_STATS and IPVS_DEST_ATTR_STATS
+ */
+enum {
+	IPVS_STATS_ATTR_UNSPEC = 0,
+	IPVS_STATS_ATTR_CONNS,		/* connections scheduled */
+	IPVS_STATS_ATTR_INPKTS,		/* incoming packets */
+	IPVS_STATS_ATTR_OUTPKTS,	/* outgoing packets */
+	IPVS_STATS_ATTR_INBYTES,	/* incoming bytes */
+	IPVS_STATS_ATTR_OUTBYTES,	/* outgoing bytes */
+
+	IPVS_STATS_ATTR_CPS,		/* current connection rate */
+	IPVS_STATS_ATTR_INPPS,		/* current in packet rate */
+	IPVS_STATS_ATTR_OUTPPS,		/* current out packet rate */
+	IPVS_STATS_ATTR_INBPS,		/* current in byte rate */
+	IPVS_STATS_ATTR_OUTBPS,		/* current out byte rate */
+	__IPVS_STATS_ATTR_MAX,
+};
+
+#define IPVS_STATS_ATTR_MAX (__IPVS_STATS_ATTR_MAX - 1)
+
+/* Attributes used in IPVS_CMD_SET_TIMEOUT and IPVS_CMD_GET_TIMEOUT commands */
+enum {
+	IPVS_TIMEOUT_ATTR_UNSPEC = 0,
+	IPVS_TIMEOUT_ATTR_TCP,		/* TCP connection timeout */
+	IPVS_TIMEOUT_ATTR_TCP_FIN,	/* TCP FIN wait timeout */
+	IPVS_TIMEOUT_ATTR_UDP,		/* UDP timeout */
+	__IPVS_TIMEOUT_ATTR_MAX,
+};
+
+#define IPVS_TIMEOUT_ATTR_MAX (__IPVS_TIMEOUT_ATTR_MAX - 1)
+
+/* Attributes used in response to IPVS_CMD_GET_INFO command */
+enum {
+	IPVS_INFO_ATTR_UNSPEC = 0,
+	IPVS_INFO_ATTR_VERSION,		/* IPVS version number */
+	IPVS_INFO_ATTR_CONN_TAB_SIZE,	/* size of connection hash table */
+	__IPVS_INFO_ATTR_MAX,
+};
+
+#define IPVS_INFO_ATTR_MAX (__IPVS_INFO_ATTR_MAX - 1)
+
 #endif	/* _IP_VS_H */
-- 
1.5.4.5

