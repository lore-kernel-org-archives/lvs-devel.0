From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 02/26] IPVS: Change IPVS data structures to support IPv6 addresses.
Date: Wed, 11 Jun 2008 19:11:45 +0200
Message-ID: <1213204329-10973-3-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213204334; bh=Ps5zU1jVgn48j25QhmI5IzP+z3I=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=uEwZGsFZiw5nCQ7Oidl7D0zB3JsZJEWLDA+gFmxl
	TS2vj8ocVTSJhvfZUAoo/rR5cGZwNXduPUD4A8+d79Tdyw==
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com

From: Vince Busam <vbusam@google.com>

Introduce new 'af' fields into IPVS structures for specifying an entry's
address family. Make IP addresses a union holding both an IPv4 and an IPv6
address. In kernel-internal structs, have the union only hold IPv4
addresses if no IPv6 support is enabled to save some space.

Bump IPVS version to 0x020000 because of this change.

Signed-off-by: Vince Busam <vbusam@google.com>

 1 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9a51eba..b7b181e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -11,7 +11,12 @@
 
 #include <linux/sysctl.h>	/* For ctl_path */
 
-#define IP_VS_VERSION_CODE	0x010201
+#ifdef __KERNEL__
+#include <linux/in6.h>		/* For struct in6_addr */
+#include <linux/ipv6.h>		/* For struct ipv6hdr */
+#endif	/* __KERNEL */
+
+#define IP_VS_VERSION_CODE	0x020000
 #define NVERSION(version)			\
 	(version >> 16) & 0xFF,			\
 	(version >> 8) & 0xFF,			\
@@ -95,6 +100,20 @@
 #define IP_VS_SCHEDNAME_MAXLEN	16
 #define IP_VS_IFNAME_MAXLEN	16
 
+union ip_vs_addr_user {
+	__be32			v4;
+	struct in6_addr		v6;
+};
+
+#ifdef CONFIG_IP_VS_IPV6
+#define ip_vs_addr		ip_vs_addr_user
+#define ip_vs_copy_addr(a, b)	do { (a) = (b); } while (0)
+#else
+union ip_vs_addr {
+	__be32			v4;
+};
+#define ip_vs_copy_addr(a, b)	do { (a).v4 = (b).v4; } while (0)
+#endif
 
 /*
  *	The struct ip_vs_service_user and struct ip_vs_dest_user are
@@ -102,8 +121,9 @@
  */
 struct ip_vs_service_user {
 	/* virtual service addresses */
+	u_int16_t		af;
 	u_int16_t		protocol;
-	__be32			addr;		/* virtual ip address */
+	union ip_vs_addr_user	addr;		/* virtual ip address */
 	__be16			port;
 	u_int32_t		fwmark;		/* firwall mark of service */
 
@@ -117,7 +137,8 @@ struct ip_vs_service_user {
 
 struct ip_vs_dest_user {
 	/* destination server address */
-	__be32			addr;
+	u_int16_t		af;
+	union ip_vs_addr_user	addr;
 	__be16			port;
 
 	/* real server options */
@@ -165,8 +186,9 @@ struct ip_vs_getinfo {
 /* The argument to IP_VS_SO_GET_SERVICE */
 struct ip_vs_service_entry {
 	/* which service: user fills in these */
+	u_int16_t		af;
 	u_int16_t		protocol;
-	__be32			addr;		/* virtual address */
+	union ip_vs_addr_user	addr;		/* virtual address */
 	__be16			port;
 	u_int32_t		fwmark;		/* firwall mark of service */
 
@@ -185,7 +207,8 @@ struct ip_vs_service_entry {
 
 
 struct ip_vs_dest_entry {
-	__be32			addr;		/* destination address */
+	u_int16_t		af;
+	union ip_vs_addr_user	addr;		/* destination address */
 	__be16			port;
 	unsigned		conn_flags;	/* connection flags */
 	int			weight;		/* destination weight */
@@ -205,8 +228,9 @@ struct ip_vs_dest_entry {
 /* The argument to IP_VS_SO_GET_DESTS */
 struct ip_vs_get_dests {
 	/* which service: user fills in these */
+	u_int16_t		af;
 	u_int16_t		protocol;
-	__be32			addr;		/* virtual address */
+	union ip_vs_addr_user	addr;		/* virtual address */
 	__be16			port;
 	u_int32_t		fwmark;		/* firwall mark of service */
 
@@ -472,9 +496,10 @@ struct ip_vs_conn {
 	struct list_head        c_list;         /* hashed list heads */
 
 	/* Protocol, addresses and port numbers */
-	__be32                   caddr;          /* client address */
-	__be32                   vaddr;          /* virtual address */
-	__be32                   daddr;          /* destination address */
+	u_int16_t               af;		/* address family */
+	union ip_vs_addr         caddr;          /* client address */
+	union ip_vs_addr         vaddr;          /* virtual address */
+	union ip_vs_addr         daddr;          /* destination address */
 	__be16                   cport;
 	__be16                   vport;
 	__be16                   dport;
@@ -527,8 +552,9 @@ struct ip_vs_service {
 	atomic_t		refcnt;   /* reference counter */
 	atomic_t		usecnt;   /* use counter */
 
+	u_int16_t               af;       /* address family */
 	__u16			protocol; /* which protocol (TCP/UDP) */
-	__be32			addr;	  /* IP address for virtual service */
+	union ip_vs_addr	addr;	  /* IP address for virtual service */
 	__be16			port;	  /* port number for the service */
 	__u32                   fwmark;   /* firewall mark of the service */
 	unsigned		flags;	  /* service status flags */
@@ -555,7 +581,8 @@ struct ip_vs_dest {
 	struct list_head	n_list;   /* for the dests in the service */
 	struct list_head	d_list;   /* for table with all the dests */
 
-	__be32			addr;		/* IP address of the server */
+	u_int16_t		af;		/* address family */
+	union ip_vs_addr	addr;		/* IP address of the server */
 	__be16			port;		/* port number of the server */
 	volatile unsigned	flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
@@ -579,7 +606,7 @@ struct ip_vs_dest {
 	/* for virtual service */
 	struct ip_vs_service	*svc;		/* service it belongs to */
 	__u16			protocol;	/* which protocol (TCP/UDP) */
-	__be32			vaddr;		/* virtual IP address */
+	union ip_vs_addr	vaddr;		/* virtual IP address */
 	__be16			vport;		/* virtual port number */
 	__u32			vfwmark;	/* firewall mark of service */
 };
-- 
1.5.3.6

