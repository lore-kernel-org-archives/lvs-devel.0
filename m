From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/26] net/bpfilter: split __bpfilter_process_sockopt
Date: Thu, 23 Jul 2020 08:08:44 +0200
Message-ID: <20200723060908.50081-3-hch@lst.de>
References: <20200723060908.50081-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=jnNftkdWuHutn0l5/V2Gz6Qvt1s8tXbdDMQLxkwuHBo=; b=AHWMVgl+gZI3ppeRUJG22CnuN2
        mXsqGUtHr7hHIshIeM0BR3FDFu7P8hUJdDKWEDjaeFBPFzHAKS1/J2NqqrgVWAiWy0PDBIJV6MaAk
        gPot77jPYt8McodlLqHe4rYj1xwXIh3dwL7d5dP2a47D69tnzjzBjxRqbyL4qtqPcLy6LsSPLTz8/
        YOabKmimQamGM4cxDNfekHWNUuwVnDebo84hbzn4arDbH1CmgtyNxmN2OFQxyAhRHpoT37cldfrc6
        Ax/DteamlOzerpb/bK5cMQkwL7vWGfqduGUdI9Ez5lzvt3eBZC1+o7Ayqr6UYOa2Jd5AGGDGAZ45S
        4D3R2EfQ==;
In-Reply-To: <20200723060908.50081-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

Split __bpfilter_process_sockopt into a low-level send request routine and
the actual setsockopt hook to split the init time ping from the actual
setsockopt processing.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/bpfilter/bpfilter_kern.c | 51 +++++++++++++++++++-----------------
 1 file changed, 27 insertions(+), 24 deletions(-)

diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
index 3bac5820062af1..78d561f2c54da7 100644
--- a/net/bpfilter/bpfilter_kern.c
+++ b/net/bpfilter/bpfilter_kern.c
@@ -31,48 +31,51 @@ static void __stop_umh(void)
 		shutdown_umh();
 }
 
-static int __bpfilter_process_sockopt(struct sock *sk, int optname,
-				      char __user *optval,
-				      unsigned int optlen, bool is_set)
+static int bpfilter_send_req(struct mbox_request *req)
 {
-	struct mbox_request req;
 	struct mbox_reply reply;
 	loff_t pos;
 	ssize_t n;
-	int ret = -EFAULT;
 
-	req.is_set = is_set;
-	req.pid = current->pid;
-	req.cmd = optname;
-	req.addr = (uintptr_t)optval;
-	req.len = optlen;
 	if (!bpfilter_ops.info.tgid)
-		goto out;
+		return -EFAULT;
 	pos = 0;
-	n = kernel_write(bpfilter_ops.info.pipe_to_umh, &req, sizeof(req),
+	n = kernel_write(bpfilter_ops.info.pipe_to_umh, req, sizeof(*req),
 			   &pos);
-	if (n != sizeof(req)) {
+	if (n != sizeof(*req)) {
 		pr_err("write fail %zd\n", n);
-		__stop_umh();
-		ret = -EFAULT;
-		goto out;
+		goto stop;
 	}
 	pos = 0;
 	n = kernel_read(bpfilter_ops.info.pipe_from_umh, &reply, sizeof(reply),
 			&pos);
 	if (n != sizeof(reply)) {
 		pr_err("read fail %zd\n", n);
-		__stop_umh();
-		ret = -EFAULT;
-		goto out;
+		goto stop;
 	}
-	ret = reply.status;
-out:
-	return ret;
+	return reply.status;
+stop:
+	__stop_umh();
+	return -EFAULT;
+}
+
+static int bpfilter_process_sockopt(struct sock *sk, int optname,
+				    char __user *optval, unsigned int optlen,
+				    bool is_set)
+{
+	struct mbox_request req = {
+		.is_set		= is_set,
+		.pid		= current->pid,
+		.cmd		= optname,
+		.addr		= (uintptr_t)optval,
+		.len		= optlen,
+	};
+	return bpfilter_send_req(&req);
 }
 
 static int start_umh(void)
 {
+	struct mbox_request req = { .pid = current->pid };
 	int err;
 
 	/* fork usermode process */
@@ -82,7 +85,7 @@ static int start_umh(void)
 	pr_info("Loaded bpfilter_umh pid %d\n", pid_nr(bpfilter_ops.info.tgid));
 
 	/* health check that usermode process started correctly */
-	if (__bpfilter_process_sockopt(NULL, 0, NULL, 0, 0) != 0) {
+	if (bpfilter_send_req(&req) != 0) {
 		shutdown_umh();
 		return -EFAULT;
 	}
@@ -103,7 +106,7 @@ static int __init load_umh(void)
 	mutex_lock(&bpfilter_ops.lock);
 	err = start_umh();
 	if (!err && IS_ENABLED(CONFIG_INET)) {
-		bpfilter_ops.sockopt = &__bpfilter_process_sockopt;
+		bpfilter_ops.sockopt = &bpfilter_process_sockopt;
 		bpfilter_ops.start = &start_umh;
 	}
 	mutex_unlock(&bpfilter_ops.lock);
-- 
2.27.0

