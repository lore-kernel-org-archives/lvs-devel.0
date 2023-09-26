From: Jordan Rife <jrife@google.com>
Subject: [PATCH net v6 1/3] net: replace calls to sock->ops->connect() with kernel_connect()
Date: Tue, 26 Sep 2023 15:05:03 -0500
Message-ID: <20230926200505.2804266-2-jrife@google.com>
References: <20230926200505.2804266-1-jrife@google.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1695758712; x=1696363512; darn=vger.kernel.org;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=3bPJjIsPmHmwi+Eu0+GyNZUXrMn22SrOLV+oVGGBzwU=;
        b=QdxdKR018VDb7P3I3YlQobzqnoLNRUnnCyIuGMfXhO9cqkO5AeiTcdqria2tHKPDqw
         wo2i8J7WCXOfI8amssYt0W3+RqJXhJ27F8F6YRyBmXzo+o5Tcqao8vUjxqMoJvjYzjnv
         lLX4BP13ETlo2B5wYSw+8IX5XvhhkPZBXnx/nAzM35gjVDFiCq0SWSspZDiifpEpPlxa
         cCfnM7yNy67zdgarNHxXAmptNAZm42yEhLU5QVXf1DNqnaKk8EBQqYedhkiEBJyFtvzH
         QgB25oVoXgBNvKH7Syx7latiVYRf7ARFpU/eqy6j21L/5jxx+q68OK265WvrHn54JYpl
         F2pA==
In-Reply-To: <20230926200505.2804266-1-jrife@google.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org
Cc: dborkman@kernel.org, horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, santosh.shilimkar@oracle.com, ast@kernel.org, rdna@fb.com, linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, lvs-devel@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net, daan.j.demeyer@gmail.com, Jordan Rife <jrife@google.com>, stable@vger.kernel.org, Willem de Bruijn <willemb@google.com>

commit 0bdf399342c5 ("net: Avoid address overwrite in kernel_connect")
ensured that kernel_connect() will not overwrite the address parameter
in cases where BPF connect hooks perform an address rewrite. This change
replaces direct calls to sock->ops->connect() in net with kernel_connect()
to make these call safe.

Link: https://lore.kernel.org/netdev/20230912013332.2048422-1-jrife@google.com/
Fixes: d74bad4e74ee ("bpf: Hooks for sys_connect")
Cc: stable@vger.kernel.org
Reviewed-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Jordan Rife <jrife@google.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 4 ++--
 net/rds/tcp_connect.c           | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index da5af28ff57b5..6e4ed1e11a3b7 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1505,8 +1505,8 @@ static int make_send_sock(struct netns_ipvs *ipvs, int id,
 	}
 
 	get_mcast_sockaddr(&mcast_addr, &salen, &ipvs->mcfg, id);
-	result = sock->ops->connect(sock, (struct sockaddr *) &mcast_addr,
-				    salen, 0);
+	result = kernel_connect(sock, (struct sockaddr *)&mcast_addr,
+				salen, 0);
 	if (result < 0) {
 		pr_err("Error connecting to the multicast addr\n");
 		goto error;
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index f0c477c5d1db4..d788c6d28986f 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -173,7 +173,7 @@ int rds_tcp_conn_path_connect(struct rds_conn_path *cp)
 	 * own the socket
 	 */
 	rds_tcp_set_callbacks(sock, cp);
-	ret = sock->ops->connect(sock, addr, addrlen, O_NONBLOCK);
+	ret = kernel_connect(sock, addr, addrlen, O_NONBLOCK);
 
 	rdsdebug("connect to address %pI6c returned %d\n", &conn->c_faddr, ret);
 	if (ret == -EINPROGRESS)
-- 
2.42.0.515.g380fc7ccd1-goog

