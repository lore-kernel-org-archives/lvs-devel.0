From: Emanuele Rocca <ema@wikimedia.org>
Subject: [PATCH] ipvsadm: check if a virtual service exists before attempting removal
Date: Mon, 31 Jul 2017 14:35:55 +0200
Message-ID: <20170731123555.10639-1-ema@wikimedia.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=wikimedia.org; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=u6n/ijef8nrAqMRfgXfZX/QYf1yTc38/q9yhRcmxyDQ=;
        b=UtlYZOmlFkcvU+sNYSRq4/xqh/2jqtqjGxuKnB2k8UE3ImQLlppPUoIGQT2Ifk+Vb9
         szay4FOMfQGn6wQ9O/ByvUQ86Xv7ZxTJlWKkaU+/6diA0JWtYjJ/EB8N8tuYGXhd1vDG
         nzVS8X4c2+77i4lGArd43Chs86mROMCVS5nAE=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Emanuele Rocca <ema@wikimedia.org>

Removing a non-existing service results in a confusing "Memory
allocation problem" error message:

        # ipvsadm -D -t example.org:80
        Memory allocation problem

Check if the given service exists before attempting removal. Inform the
user if the service is not defined.

Signed-off-by: Emanuele Rocca <ema@wikimedia.org>
---
 ipvsadm.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ipvsadm.c b/ipvsadm.c
index 1a28d72..f958b11 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -942,6 +942,11 @@ static int process_options(int argc, char **argv, int reading_stdin)
 		break;
 
 	case CMD_DEL:
+		if (!(ipvs_get_service(ce.svc.fwmark, ce.svc.af, ce.svc.protocol,
+						   ce.svc.addr, ce.svc.port))) {
+			fprintf(stderr, "No such service\n");
+			exit(1);
+		}
 		result = ipvs_del_service(&ce.svc);
 		break;
 
-- 
2.13.3

