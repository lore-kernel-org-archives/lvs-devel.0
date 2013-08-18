From: "Ryan O'Hara" <rohara@redhat.com>
Subject: [PATCH] libipvs: Fix memory leak
Date: Sun, 18 Aug 2013 11:43:02 -0500
Message-ID: <1376844182-4437-1-git-send-email-rohara@redhat.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Henrique Mecking <henriquemecking@gmail.com>, Ryan O'Hara <rohara@redhat.com>

From: Henrique Mecking <henriquemecking@gmail.com>

If malloc fails, free allocated memory before returning NULL.

Signed-off-by: Ryan O'Hara <rohara@redhat.com>
---
 libipvs/libipvs.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/libipvs/libipvs.c b/libipvs/libipvs.c
index 2b066d2..1c9e066 100644
--- a/libipvs/libipvs.c
+++ b/libipvs/libipvs.c
@@ -668,8 +668,10 @@ struct ip_vs_get_services *ipvs_get_services(void)
 		return NULL;
 	len = sizeof(*getk) +
 		sizeof(struct ip_vs_service_entry_kern) * ipvs_info.num_services;
-	if (!(getk = malloc(len)))
+	if (!(getk = malloc(len))) {
+		free(get);
 		return NULL;
+	}
 
 	ipvs_func = ipvs_get_services;
 	getk->num_services = ipvs_info.num_services;
@@ -853,8 +855,10 @@ ipvs_nl_dest_failure:
 	}
 
 	len = sizeof(*dk) + sizeof(struct ip_vs_dest_entry_kern) * svc->num_dests;
-	if (!(dk = malloc(len)))
+	if (!(dk = malloc(len))) {
+		free(d);
 		return NULL;
+	}
 
 	dk->fwmark = svc->fwmark;
 	dk->protocol = svc->protocol;
-- 
1.8.1.4

