From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvsadm: catch the original errno from netlink answer
Date: Sat,  5 Aug 2017 14:38:28 +0300
Message-ID: <20170805113828.9951-1-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Emanuele Rocca <ema@wikimedia.org>

nl_recvmsgs_default() returns NLE_* error codes and not
errno values. As result, attempt to delete virtual service
returns NLE_OBJ_NOTFOUND (12) which matches the ENOMEM value.

Problem as reported by Emanuele Rocca:

ipvsadm -D -t example.org:80
Memory allocation problem

Fix it by providing generic error handler to catch the errno
value as returned in netlink answer. By this way all netlink
commands will get proper error string. The problem is present
only when ipvsadm is compiled with libnl.

ipvsadm -D -t example.org:80
No such service

Reported-by: Emanuele Rocca <ema@wikimedia.org>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 libipvs/libipvs.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 180ea42..1cc46b9 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -74,9 +74,23 @@ static int ipvs_nl_noop_cb(struct nl_msg *msg, void *arg)
 	return NL_OK;
 }
 
+struct cb_err_data {
+	int	err;
+};
+
+static int ipvs_nl_err_cb(struct sockaddr_nl *nla, struct nlmsgerr *nlerr,
+			  void *arg)
+{
+	struct cb_err_data *data = arg;
+
+	data->err = nlerr->error;
+	return -nl_syserr2nlerr(nlerr->error);
+}
+
 int ipvs_nl_send_message(struct nl_msg *msg, nl_recvmsg_msg_cb_t func, void *arg)
 {
 	int err = EINVAL;
+	struct cb_err_data err_data = { .err = 0 };
 
 	sock = nl_socket_alloc();
 	if (!sock) {
@@ -100,12 +114,18 @@ int ipvs_nl_send_message(struct nl_msg *msg, nl_recvmsg_msg_cb_t func, void *arg
 
 	if (nl_socket_modify_cb(sock, NL_CB_VALID, NL_CB_CUSTOM, func, arg) != 0)
 		goto fail_genl;
+	if (nl_socket_modify_err_cb(sock, NL_CB_CUSTOM, ipvs_nl_err_cb,
+				    &err_data) != 0)
+		goto fail_genl;
 
 	if (nl_send_auto_complete(sock, msg) < 0)
 		goto fail_genl;
 
-	if ((err = -nl_recvmsgs_default(sock)) > 0)
+	if (nl_recvmsgs_default(sock) < 0) {
+		if (err_data.err)
+			err = -err_data.err;
 		goto fail_genl;
+	}
 
 	nlmsg_free(msg);
 
-- 
2.9.4

