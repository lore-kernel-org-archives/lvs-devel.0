From: Jordan Rife <jrife@google.com>
Subject: [PATCH net v6 3/3] net: prevent address rewrite in kernel_bind()
Date: Tue, 26 Sep 2023 15:05:05 -0500
Message-ID: <20230926200505.2804266-4-jrife@google.com>
References: <20230926200505.2804266-1-jrife@google.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1695758716; x=1696363516; darn=vger.kernel.org;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=iUWT+ccHYSlqR7Gmrnq8A76xPWnK8wJVTcz3EkgFwkk=;
        b=fHvz/oXfN/BEP2dph9JC3zX7RplJK25pHOYQ4k6IYY2hH90LJ9R8h6X9CBSdVPWzOA
         zZ/uFcKpr7u4eQsd5O2ZSK+xcQXrOywBXajCGjcm0whNsAFfSsrd738LczlzCSllqloF
         pEzhSw4I1X44/guUCDwGqfzt9QuibRzEndhzaLrYP7lK6AG64NG8oc2alRg7CkTJ7JOZ
         bOx/0fu4TVsqxt+gD/reQgOiiGqTXzlYIgCQRXfciGybYOOS7c1U9Q1SAtvzHOyiSP4G
         taSxv0/UENApCkCQ7xsaAMjZBN1Pgu/eEuwoYJpS59T8gWm6HkncOggfOM07dVhLywpq
         HUEA==
In-Reply-To: <20230926200505.2804266-1-jrife@google.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org
Cc: dborkman@kernel.org, horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, santosh.shilimkar@oracle.com, ast@kernel.org, rdna@fb.com, linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, lvs-devel@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net, daan.j.demeyer@gmail.com, Jordan Rife <jrife@google.com>, stable@vger.kernel.org, Willem de Bruijn <willemb@google.com>

Similar to the change in commit 0bdf399342c5("net: Avoid address
overwrite in kernel_connect"), BPF hooks run on bind may rewrite the
address passed to kernel_bind(). This change

1) Makes a copy of the bind address in kernel_bind() to insulate
   callers.
2) Replaces direct calls to sock->ops->bind() in net with kernel_bind()

Link: https://lore.kernel.org/netdev/20230912013332.2048422-1-jrife@google.com/
Fixes: 4fbac77d2d09 ("bpf: Hooks for sys_bind")
Cc: stable@vger.kernel.org
Reviewed-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Jordan Rife <jrife@google.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 4 ++--
 net/rds/tcp_connect.c           | 2 +-
 net/rds/tcp_listen.c            | 2 +-
 net/socket.c                    | 7 ++++++-
 4 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 6e4ed1e11a3b7..4174076c66fa7 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1439,7 +1439,7 @@ static int bind_mcastif_addr(struct socket *sock, struct net_device *dev)
 	sin.sin_addr.s_addr  = addr;
 	sin.sin_port         = 0;
 
-	return sock->ops->bind(sock, (struct sockaddr*)&sin, sizeof(sin));
+	return kernel_bind(sock, (struct sockaddr *)&sin, sizeof(sin));
 }
 
 static void get_mcast_sockaddr(union ipvs_sockaddr *sa, int *salen,
@@ -1546,7 +1546,7 @@ static int make_receive_sock(struct netns_ipvs *ipvs, int id,
 
 	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->bcfg, id);
 	sock->sk->sk_bound_dev_if = dev->ifindex;
-	result = sock->ops->bind(sock, (struct sockaddr *)&mcast_addr, salen);
+	result = kernel_bind(sock, (struct sockaddr *)&mcast_addr, salen);
 	if (result < 0) {
 		pr_err("Error binding to the multicast addr\n");
 		goto error;
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index d788c6d28986f..a0046e99d6df7 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -145,7 +145,7 @@ int rds_tcp_conn_path_connect(struct rds_conn_path *cp)
 		addrlen = sizeof(sin);
 	}
 
-	ret = sock->ops->bind(sock, addr, addrlen);
+	ret = kernel_bind(sock, addr, addrlen);
 	if (ret) {
 		rdsdebug("bind failed with %d at address %pI6c\n",
 			 ret, &conn->c_laddr);
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 014fa24418c12..53b3535a1e4a8 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -306,7 +306,7 @@ struct socket *rds_tcp_listen_init(struct net *net, bool isv6)
 		addr_len = sizeof(*sin);
 	}
 
-	ret = sock->ops->bind(sock, (struct sockaddr *)&ss, addr_len);
+	ret = kernel_bind(sock, (struct sockaddr *)&ss, addr_len);
 	if (ret < 0) {
 		rdsdebug("could not bind %s listener socket: %d\n",
 			 isv6 ? "IPv6" : "IPv4", ret);
diff --git a/net/socket.c b/net/socket.c
index 107a257a75186..3408bd6bb1e5a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3518,7 +3518,12 @@ static long compat_sock_ioctl(struct file *file, unsigned int cmd,
 
 int kernel_bind(struct socket *sock, struct sockaddr *addr, int addrlen)
 {
-	return READ_ONCE(sock->ops)->bind(sock, addr, addrlen);
+	struct sockaddr_storage address;
+
+	memcpy(&address, addr, addrlen);
+
+	return READ_ONCE(sock->ops)->bind(sock, (struct sockaddr *)&address,
+					  addrlen);
 }
 EXPORT_SYMBOL(kernel_bind);
 
-- 
2.42.0.515.g380fc7ccd1-goog

