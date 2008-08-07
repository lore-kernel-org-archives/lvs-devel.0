From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 1/2] IPVS: Add genetlink interface definitions to ip_vs.h
Date: Thu,  7 Aug 2008 16:43:38 +0200
Message-ID: <1218120219-1117-2-git-send-email-juliusv@google.com>
References: <1218120219-1117-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1218120227; bh=QH/Ih3y9wpPde+RUP25eQXF57i0=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=rRFEjciqXkOx/RP6E6tlQdecs5Gs7701znkWMBke
	lmcCrCWVMF8tVEl2p6wZCuvxK2knnPiGQmo7yrOsW4A8yg==
In-Reply-To: <1218120219-1117-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: julius.volz@gmail.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com, Julius Volz <juliusv@google.com>

Add IPVS Generic Netlink interface definitions to include/linux/ip_vs.h.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 160 insertions(+), 0 deletions(-)

diff --git a/include/linux/ip_vs.h b/include/linux/ip_vs.h
index ec6eb49..0f434a2 100644
--- a/include/linux/ip_vs.h
+++ b/include/linux/ip_vs.h
@@ -242,4 +242,164 @@ struct ip_vs_daemon_user {
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
+	IPVS_CMD_NEW_SERVICE,		/* add service */
+	IPVS_CMD_SET_SERVICE,		/* modify service */
+	IPVS_CMD_DEL_SERVICE,		/* delete service */
+	IPVS_CMD_GET_SERVICE,		/* get service info */
+
+	IPVS_CMD_NEW_DEST,		/* add destination */
+	IPVS_CMD_SET_DEST,		/* modify destination */
+	IPVS_CMD_DEL_DEST,		/* delete destination */
+	IPVS_CMD_GET_DEST,		/* get destination info */
+
+	IPVS_CMD_NEW_DAEMON,		/* start sync daemon */
+	IPVS_CMD_DEL_DAEMON,		/* stop sync daemon */
+	IPVS_CMD_GET_DAEMON,		/* get sync daemon status */
+
+	IPVS_CMD_SET_CONFIG,		/* set config settings */
+	IPVS_CMD_GET_CONFIG,		/* get config settings */
+
+	IPVS_CMD_SET_INFO,		/* only used in GET_INFO reply */
+	IPVS_CMD_GET_INFO,		/* get general IPVS info */
+
+	IPVS_CMD_ZERO,			/* zero all counters and stats */
+	IPVS_CMD_FLUSH,			/* flush services and dests */
+
+	__IPVS_CMD_MAX,
+};
+
+#define IPVS_CMD_MAX (__IPVS_CMD_MAX - 1)
+
+/* Attributes used in the first level of commands */
+enum {
+	IPVS_CMD_ATTR_UNSPEC = 0,
+	IPVS_CMD_ATTR_SERVICE,		/* nested service attribute */
+	IPVS_CMD_ATTR_DEST,		/* nested destination attribute */
+	IPVS_CMD_ATTR_DAEMON,		/* nested sync daemon attribute */
+	IPVS_CMD_ATTR_TIMEOUT_TCP,	/* TCP connection timeout */
+	IPVS_CMD_ATTR_TIMEOUT_TCP_FIN,	/* TCP FIN wait timeout */
+	IPVS_CMD_ATTR_TIMEOUT_UDP,	/* UDP timeout */
+	__IPVS_CMD_ATTR_MAX,
+};
+
+#define IPVS_CMD_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)
+
+/*
+ * Attributes used to describe a service
+ *
+ * Used inside nested attribute IPVS_CMD_ATTR_SERVICE
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
+ * Used inside nested attribute IPVS_CMD_ATTR_DEST
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
+ * Used inside nested attribute IPVS_CMD_ATTR_DAEMON
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

