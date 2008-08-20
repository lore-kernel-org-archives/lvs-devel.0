From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 04/24] IPVS: Change IPVS data structures to support IPv6 addresses
Date: Wed, 20 Aug 2008 18:15:11 +0200
Message-ID: <1219248931-15064-5-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219248938; bh=BGLBcBtUtV5DSjiy6BJhiepRgmQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=q4AXarOq3j95aRLPWvygZIzunzJckr1GrAz1xFPI
	H6/QS3AuS4wkIHUl8EpykvPc1Wq9xIywQVkbZGXvwnzd0g==
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Introduce new 'af' fields into IPVS data structures for specifying an
entry's address family. Convert IP addresses to be of type union
nf_inet_addr. Add extended internal versions of ip_vs_service_user and
struct ip_vs_dest_user (the originals can't be modified as they are part
of the old sockopt interface).

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7312c3d..e41a164 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -21,6 +21,9 @@
 #include <linux/timer.h>
 
 #include <net/checksum.h>
+#include <linux/netfilter.h>		/* for union nf_inet_addr */
+#include <linux/ipv6.h>			/* for struct ipv6hdr */
+#include <net/ipv6.h>			/* for ipv6_addr_copy */
 
 #ifdef CONFIG_IP_VS_DEBUG
 #include <linux/net.h>
@@ -259,9 +262,10 @@ struct ip_vs_conn {
 	struct list_head        c_list;         /* hashed list heads */
 
 	/* Protocol, addresses and port numbers */
-	__be32                   caddr;          /* client address */
-	__be32                   vaddr;          /* virtual address */
-	__be32                   daddr;          /* destination address */
+	u_int16_t               af;		/* address family */
+	union nf_inet_addr       caddr;          /* client address */
+	union nf_inet_addr       vaddr;          /* virtual address */
+	union nf_inet_addr       daddr;          /* destination address */
 	__be16                   cport;
 	__be16                   vport;
 	__be16                   dport;
@@ -305,6 +309,45 @@ struct ip_vs_conn {
 
 
 /*
+ *	Extended internal versions of struct ip_vs_service_user and
+ *	ip_vs_dest_user for IPv6 support.
+ *
+ *	We need these to conveniently pass around service and destination
+ *	options, but unfortunately, we also need to keep the old definitions to
+ *	maintain userspace backwards compatibility for the setsockopt interface.
+ */
+struct ip_vs_service_user_kern {
+	/* virtual service addresses */
+	u_int16_t		af;
+	u_int16_t		protocol;
+	union nf_inet_addr	addr;		/* virtual ip address */
+	__be16			port;
+	u_int32_t		fwmark;		/* firwall mark of service */
+
+	/* virtual service options */
+	char			*sched_name;
+	unsigned		flags;		/* virtual service flags */
+	unsigned		timeout;	/* persistent timeout in sec */
+	__be32			netmask;	/* persistent netmask */
+};
+
+
+struct ip_vs_dest_user_kern {
+	/* destination server address */
+	union nf_inet_addr	addr;
+	__be16			port;
+
+	/* real server options */
+	unsigned		conn_flags;	/* connection flags */
+	int			weight;		/* destination weight */
+
+	/* thresholds for active connections */
+	u_int32_t		u_threshold;	/* upper threshold */
+	u_int32_t		l_threshold;	/* lower threshold */
+};
+
+
+/*
  *	The information about the virtual service offered to the net
  *	and the forwarding entries
  */
@@ -314,8 +357,9 @@ struct ip_vs_service {
 	atomic_t		refcnt;   /* reference counter */
 	atomic_t		usecnt;   /* use counter */
 
+	u_int16_t               af;       /* address family */
 	__u16			protocol; /* which protocol (TCP/UDP) */
-	__be32			addr;	  /* IP address for virtual service */
+	union nf_inet_addr	addr;	  /* IP address for virtual service */
 	__be16			port;	  /* port number for the service */
 	__u32                   fwmark;   /* firewall mark of the service */
 	unsigned		flags;	  /* service status flags */
@@ -342,7 +386,8 @@ struct ip_vs_dest {
 	struct list_head	n_list;   /* for the dests in the service */
 	struct list_head	d_list;   /* for table with all the dests */
 
-	__be32			addr;		/* IP address of the server */
+	u_int16_t		af;		/* address family */
+	union nf_inet_addr	addr;		/* IP address of the server */
 	__be16			port;		/* port number of the server */
 	volatile unsigned	flags;		/* dest status flags */
 	atomic_t		conn_flags;	/* flags to copy to conn */
@@ -366,7 +411,7 @@ struct ip_vs_dest {
 	/* for virtual service */
 	struct ip_vs_service	*svc;		/* service it belongs to */
 	__u16			protocol;	/* which protocol (TCP/UDP) */
-	__be32			vaddr;		/* virtual IP address */
+	union nf_inet_addr	vaddr;		/* virtual IP address */
 	__be16			vport;		/* virtual port number */
 	__u32			vfwmark;	/* firewall mark of service */
 };
-- 
1.5.4.5

