From: Jordan Rife <jrife@google.com>
Subject: [PATCH net v6 2/3] net: prevent rewrite of msg_name and msg_namelen
 in sock_sendmsg()
Date: Tue, 26 Sep 2023 15:05:04 -0500
Message-ID: <20230926200505.2804266-3-jrife@google.com>
References: <20230926200505.2804266-1-jrife@google.com>
Mime-Version: 1.0
Return-path: <stable-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1695758714; x=1696363514; darn=vger.kernel.org;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=Y896tdbpANmEYjOJHc8XK7Iynz1k/9wM577XVZiXiEc=;
        b=EFRwWR00l+HS09aReiShHLlPm3py4L1Mu3puJ7tgZJ+1QIGrKZzLe3fJcHFF1nvwhO
         awRtdL7kpEMEqSQprzmbBWQ1XX4Ij73uWBwt4xXip2CS0MRANBpCzmoXT2cz5mJaT+OU
         q+pAX6ljYtHHuLC0QV7x6+67gft8AbB9bnov+cO73xHamTpGxxQYubT79EJeMTBepeT3
         WPCPzaBOBd9RoMjqcwTsbci+oVW+1H1MmQGQMpaqhVq5erjenzObgr2eHdPBwkK1QJl2
         NIhShmRV86RdgfgqZrTq6qNkrAi4RN7U2Kdvh00we1Bk5cfuahxO2Y5i5Ysad+ivARKP
         0E5A==
In-Reply-To: <20230926200505.2804266-1-jrife@google.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org
Cc: dborkman@kernel.org, horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, santosh.shilimkar@oracle.com, ast@kernel.org, rdna@fb.com, linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, lvs-devel@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net, daan.j.demeyer@gmail.com, Jordan Rife <jrife@google.com>, stable@vger.kernel.org

Callers of sock_sendmsg(), and similarly kernel_sendmsg(), in kernel
space may observe their value of msg_name change in cases where BPF
sendmsg hooks rewrite the send address. This has been confirmed to break
NFS mounts running in UDP mode and has the potential to break other
systems.

Soon, support will be added for BPF sockaddr hooks for Unix sockets
which introduces the ability to modify the msg->msg_namelen value.

This patch:

1) Creates a new function called __sock_sendmsg() with same logic as the
   old sock_sendmsg() function.
2) Replaces calls to sock_sendmsg() made by __sys_sendto() and
   __sys_sendmsg() with __sock_sendmsg() to avoid an unnecessary copy,
   as these system calls are already protected.
3) Makes a copy of msg->msg_name and to insulate callers.
4) Makes a copy of msg->msg_namelen to insulate callers in anticipation
   of the aforementioned change to support Unix sockets.

Link: https://lore.kernel.org/netdev/20230912013332.2048422-1-jrife@google.com/
Link: https://lore.kernel.org/bpf/202309231339.L2O0CrMU-lkp@intel.com/T/#m181770af51156bdaa70fd4a4cb013ba11f28e101
Fixes: 1cedee13d25a ("bpf: Hooks for sys_sendmsg")
Cc: stable@vger.kernel.org
Signed-off-by: Jordan Rife <jrife@google.com>
---
 net/socket.c | 31 +++++++++++++++++++++++++------
 1 file changed, 25 insertions(+), 6 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index c8b08b32f097e..107a257a75186 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -737,6 +737,14 @@ static inline int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg)
 	return ret;
 }
 
+static int __sock_sendmsg(struct socket *sock, struct msghdr *msg)
+{
+	int err = security_socket_sendmsg(sock, msg,
+					  msg_data_left(msg));
+
+	return err ?: sock_sendmsg_nosec(sock, msg);
+}
+
 /**
  *	sock_sendmsg - send a message through @sock
  *	@sock: socket
@@ -747,10 +755,21 @@ static inline int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg)
  */
 int sock_sendmsg(struct socket *sock, struct msghdr *msg)
 {
-	int err = security_socket_sendmsg(sock, msg,
-					  msg_data_left(msg));
+	struct sockaddr_storage *save_addr = (struct sockaddr_storage *)msg->msg_name;
+	int save_addrlen = msg->msg_namelen;
+	struct sockaddr_storage address;
+	int ret;
 
-	return err ?: sock_sendmsg_nosec(sock, msg);
+	if (msg->msg_name) {
+		memcpy(&address, msg->msg_name, msg->msg_namelen);
+		msg->msg_name = &address;
+	}
+
+	ret = __sock_sendmsg(sock, msg);
+	msg->msg_name = save_addr;
+	msg->msg_namelen = save_addrlen;
+
+	return ret;
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
@@ -1138,7 +1157,7 @@ static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (sock->type == SOCK_SEQPACKET)
 		msg.msg_flags |= MSG_EOR;
 
-	res = sock_sendmsg(sock, &msg);
+	res = __sock_sendmsg(sock, &msg);
 	*from = msg.msg_iter;
 	return res;
 }
@@ -2174,7 +2193,7 @@ int __sys_sendto(int fd, void __user *buff, size_t len, unsigned int flags,
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	msg.msg_flags = flags;
-	err = sock_sendmsg(sock, &msg);
+	err = __sock_sendmsg(sock, &msg);
 
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -2538,7 +2557,7 @@ static int ____sys_sendmsg(struct socket *sock, struct msghdr *msg_sys,
 		err = sock_sendmsg_nosec(sock, msg_sys);
 		goto out_freectl;
 	}
-	err = sock_sendmsg(sock, msg_sys);
+	err = __sock_sendmsg(sock, msg_sys);
 	/*
 	 * If this is sendmmsg() and sending to current destination address was
 	 * successful, remember it.
-- 
2.42.0.515.g380fc7ccd1-goog

