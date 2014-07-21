From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 3/5] net/netfilter/ipvs/ip_vs_ctl.c: drop argument range
 check just before the check for equality
Date: Mon, 21 Jul 2014 23:01:56 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407212253100.2358@ja.home.ssi.bg>
References: <1405697638-23767-1-git-send-email-andrey.krieger.utkin@gmail.com> <alpine.LFD.2.11.1407182339160.2273@ja.home.ssi.bg> <CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANZNk83dJCXAWrQ+i5rh=sdUuiiD5ZhzDua-rjJpBZCzzNGDJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, dcb314@hotmail.com, David Miller <davem@davemloft.net>, kadlec@blackhole.kfki.hu, Patrick McHardy <kaber@trash.net>, pablo@netfilter.org, Simon Horman <horms@verge.net.au>, wensong@linux-vs.org


	Hello,

On Sat, 19 Jul 2014, Andrey Utkin wrote:

> 2014-07-18 23:48 GMT+03:00 Julian Anastasov <ja@ssi.bg>:
> >         The above check ensures the set_arglen[] value (some
> > struct size) does not exceed the arg[MAX_ARG_LEN] space. You can check
> > commit 04bcef2a83f40c ("ipvs: Add boundary check on ioctl arguments")
> > for more info.
> 
> Thanks for info.
> What about static check at compilation time?
> 
> #if (DAEMON_ARG_LEN > MAX_ARG_LEN) \
>  || (SERVICE_ARG_LEN > MAX_ARG_LEN) \
>  || (SVCDEST_ARG_LEN > MAX_ARG_LEN)
> #error MAX_ARG_LEN exceeded in set_arglen table
> #endif

	I prefer this to be fixed once and for all.
Here is my attempt, it appears to work. I use union
to get the max size to use for stack space. checkpatch.pl
is noisy... Let me know if you have a better idea.

ipvs: reduce stack usage for sockopt data

Use macros and union to reserve the required stack space for
sockopt data. Now the tables for commands should be more safe
to extend. The checks added for readability are optimized by
compiler or warn at compile time if command uses too much stack.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 98 ++++++++++++++++++++++++------------------
 1 file changed, 55 insertions(+), 43 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 581a658..08c3389 100644
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
@@ -2333,13 +2339,12 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	struct ip_vs_dest_user_kern udest;
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
+	BUILD_BUG_ON(sizeof(arg) > 256);
 	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_SET_MAX)
 		return -EINVAL;
-	if (len < 0 || len >  MAX_ARG_LEN)
-		return -EINVAL;
 	if (len != set_arglen[SET_CMDID(cmd)]) {
 		pr_err("set_ctl: len %u != %u\n",
 		       len, set_arglen[SET_CMDID(cmd)]);
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
+	BUILD_BUG_ON(sizeof(arg) > 256);
 	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (cmd < IP_VS_BASE_CTL || cmd > IP_VS_SO_GET_MAX)
 		return -EINVAL;
 
-	if (*len < get_arglen[GET_CMDID(cmd)]) {
-		pr_err("get_ctl: len %u < %u\n",
-		       *len, get_arglen[GET_CMDID(cmd)]);
-		return -EINVAL;
-	}
-
 	copylen = get_arglen[GET_CMDID(cmd)];
-	if (copylen > 128)
+	if (*len < (int) copylen || *len < 0) {
+		pr_err("get_ctl: len %d < %u\n", *len, copylen);
 		return -EINVAL;
+	}
 
 	if (copy_from_user(arg, user, copylen) != 0)
 		return -EFAULT;
-- 
1.9.0


Regards

--
Julian Anastasov <ja@ssi.bg>
