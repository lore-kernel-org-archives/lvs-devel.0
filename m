From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] ipvs: reduce stack usage for sockopt data
Date: Wed, 23 Jul 2014 10:30:46 +0300
Message-ID: <1406100646-4830-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, Andrey Utkin <andrey.krieger.utkin@gmail.com>, David Binderman <dcb314@hotmail.com>

Use macros and union to reserve the required stack space for
sockopt data. Now the tables for commands should be more safe
to extend. The checks added for readability are optimized by
compiler, others warn at compile time if command uses too much
stack or exceeds the storage of set_arglen and get_arglen.

As Dan Carpenter points out, we can run for unprivileged user,
so we can silent some error messages.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
CC: Dan Carpenter <dan.carpenter@oracle.com>
CC: Andrey Utkin <andrey.krieger.utkin@gmail.com>
CC: David Binderman <dcb314@hotmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 102 +++++++++++++++++++++++------------------
 1 file changed, 57 insertions(+), 45 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 581a658..9d6ed75 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2266,28 +2266,34 @@ static int ip_vs_set_timeout(struct net *net, struct ip_vs_timeout_user *u)
 }
 
 
-#define SET_CMDID(cmd)		(cmd - IP_VS_BASE_CTL)
-#define SERVICE_ARG_LEN		(sizeof(struct ip_vs_service_user))
-#define SVCDEST_ARG_LEN		(sizeof(struct ip_vs_service_user) +	\
-				 sizeof(struct ip_vs_dest_user))
-#define TIMEOUT_ARG_LEN		(sizeof(struct ip_vs_timeout_user))
-#define DAEMON_ARG_LEN		(sizeof(struct ip_vs_daemon_user))
-#define MAX_ARG_LEN		SVCDEST_ARG_LEN
+#define SET_CMDID(cmd)			(cmd - IP_VS_BASE_CTL)
+#define IP_VS_SET_CMDID(c, t)		[SET_CMDID(c)] = sizeof(t),
+#define IP_VS_SET_CMDID_LEN(c, t)	t field_ ## c;
+
+struct ip_vs_svcdest_user {
+	struct ip_vs_service_user	s;
+	struct ip_vs_dest_user		d;
+};
+
+#define IP_VS_SET_CMDID_TABLE(e)					\
+	e(IP_VS_SO_SET_ADD,		struct ip_vs_service_user)	\
+	e(IP_VS_SO_SET_EDIT,		struct ip_vs_service_user)	\
+	e(IP_VS_SO_SET_DEL,		struct ip_vs_service_user)	\
+	e(IP_VS_SO_SET_ADDDEST,		struct ip_vs_svcdest_user)	\
+	e(IP_VS_SO_SET_DELDEST,		struct ip_vs_svcdest_user)	\
+	e(IP_VS_SO_SET_EDITDEST,	struct ip_vs_svcdest_user)	\
+	e(IP_VS_SO_SET_TIMEOUT,		struct ip_vs_timeout_user)	\
+	e(IP_VS_SO_SET_STARTDAEMON,	struct ip_vs_daemon_user)	\
+	e(IP_VS_SO_SET_STOPDAEMON,	struct ip_vs_daemon_user)	\
+	e(IP_VS_SO_SET_ZERO,		struct ip_vs_service_user)
 
 static const unsigned char set_arglen[SET_CMDID(IP_VS_SO_SET_MAX)+1] = {
-	[SET_CMDID(IP_VS_SO_SET_ADD)]		= SERVICE_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_EDIT)]		= SERVICE_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_DEL)]		= SERVICE_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_FLUSH)]		= 0,
-	[SET_CMDID(IP_VS_SO_SET_ADDDEST)]	= SVCDEST_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_DELDEST)]	= SVCDEST_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_EDITDEST)]	= SVCDEST_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_TIMEOUT)]	= TIMEOUT_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_STARTDAEMON)]	= DAEMON_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_STOPDAEMON)]	= DAEMON_ARG_LEN,
-	[SET_CMDID(IP_VS_SO_SET_ZERO)]		= SERVICE_ARG_LEN,
+	IP_VS_SET_CMDID_TABLE(IP_VS_SET_CMDID)
 };
 
+union ip_vs_set_arglen { IP_VS_SET_CMDID_TABLE(IP_VS_SET_CMDID_LEN) };
+#define MAX_SET_ARGLEN	sizeof(union ip_vs_set_arglen)
+
 static void ip_vs_copy_usvc_compat(struct ip_vs_service_user_kern *usvc,
 				  struct ip_vs_service_user *usvc_compat)
 {
@@ -2325,7 +2331,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 {
 	struct net *net = sock_net(sk);
 	int ret;
-	unsigned char arg[MAX_ARG_LEN];
+	unsigned char arg[MAX_SET_ARGLEN];
 	struct ip_vs_service_user *usvc_compat;
 	struct ip_vs_service_user_kern usvc;
 	struct ip_vs_service *svc;
@@ -2333,16 +2339,15 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	struct ip_vs_dest_user_kern udest;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	BUILD_BUG_ON(sizeof(arg) > 255);
 	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
 		return -EINVAL;
-	if (len < 0 || len >  MAX_ARG_LEN)
-		return -EINVAL;
 	if (len != set_arglen[SET_CMDID(cmd)]) {
-		pr_err("set_ctl: len %u != %u\n",
-		       len, set_arglen[SET_CMDID(cmd)]);
+		IP_VS_DBG(1, "set_ctl: len %u != %u\n",
+			  len, set_arglen[SET_CMDID(cmd)]);
 		return -EINVAL;
 	}
 
@@ -2606,49 +2611,56 @@ __ip_vs_get_timeouts(struct net *net, struct ip_vs_timeout_user *u)
 }
 
 
-#define GET_CMDID(cmd)		(cmd - IP_VS_BASE_CTL)
-#define GET_INFO_ARG_LEN	(sizeof(struct ip_vs_getinfo))
-#define GET_SERVICES_ARG_LEN	(sizeof(struct ip_vs_get_services))
-#define GET_SERVICE_ARG_LEN	(sizeof(struct ip_vs_service_entry))
-#define GET_DESTS_ARG_LEN	(sizeof(struct ip_vs_get_dests))
-#define GET_TIMEOUT_ARG_LEN	(sizeof(struct ip_vs_timeout_user))
-#define GET_DAEMON_ARG_LEN	(sizeof(struct ip_vs_daemon_user) * 2)
+#define GET_CMDID(cmd)			(cmd - IP_VS_BASE_CTL)
+#define IP_VS_GET_CMDID(c, t)		[GET_CMDID(c)] = sizeof(t),
+#define IP_VS_GET_CMDID_LEN(c, t)	t field_ ## c;
+
+struct ip_vs_version_user {
+	char	v[64];
+};
+
+struct ip_vs_daemon_user2 {
+	struct ip_vs_daemon_user	d1, d2;
+};
+
+#define IP_VS_GET_CMDID_TABLE(e)					\
+	e(IP_VS_SO_GET_VERSION,		struct ip_vs_version_user)	\
+	e(IP_VS_SO_GET_INFO,		struct ip_vs_getinfo)		\
+	e(IP_VS_SO_GET_SERVICES,	struct ip_vs_get_services)	\
+	e(IP_VS_SO_GET_SERVICE,		struct ip_vs_service_entry)	\
+	e(IP_VS_SO_GET_DESTS,		struct ip_vs_get_dests)		\
+	e(IP_VS_SO_GET_TIMEOUT,		struct ip_vs_timeout_user)	\
+	e(IP_VS_SO_GET_DAEMON,		struct ip_vs_daemon_user2)
 
 static const unsigned char get_arglen[GET_CMDID(IP_VS_SO_GET_MAX)+1] = {
-	[GET_CMDID(IP_VS_SO_GET_VERSION)]	= 64,
-	[GET_CMDID(IP_VS_SO_GET_INFO)]		= GET_INFO_ARG_LEN,
-	[GET_CMDID(IP_VS_SO_GET_SERVICES)]	= GET_SERVICES_ARG_LEN,
-	[GET_CMDID(IP_VS_SO_GET_SERVICE)]	= GET_SERVICE_ARG_LEN,
-	[GET_CMDID(IP_VS_SO_GET_DESTS)]		= GET_DESTS_ARG_LEN,
-	[GET_CMDID(IP_VS_SO_GET_TIMEOUT)]	= GET_TIMEOUT_ARG_LEN,
-	[GET_CMDID(IP_VS_SO_GET_DAEMON)]	= GET_DAEMON_ARG_LEN,
+	IP_VS_GET_CMDID_TABLE(IP_VS_GET_CMDID)
 };
 
+union ip_vs_get_arglen { IP_VS_GET_CMDID_TABLE(IP_VS_GET_CMDID_LEN) };
+#define MAX_GET_ARGLEN	sizeof(union ip_vs_get_arglen)
+
 static int
 do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
-	unsigned char arg[128];
+	unsigned char arg[MAX_GET_ARGLEN];
 	int ret = 0;
 	unsigned int copylen;
 	struct net *net = sock_net(sk);
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	BUG_ON(!net);
+	BUILD_BUG_ON(sizeof(arg) > 255);
 	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX)
 		return -EINVAL;
 
-	if (*len < get_arglen[GET_CMDID(cmd)]) {
-		pr_err("get_ctl: len %u < %u\n",
-		       *len, get_arglen[GET_CMDID(cmd)]);
-		return -EINVAL;
-	}
