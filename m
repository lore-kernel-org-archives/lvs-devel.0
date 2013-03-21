From: Krzysztof Gajdemski <songo@debian.org.pl>
Subject: [PATCH 1/2] ipvsadm: Fix wrong format of -o option in FMT_RULE
 listing
Date: Thu, 21 Mar 2013 11:40:06 +0100
Message-ID: <20130321104006.GB9563@debian.org.pl>
References: <cover.1363823448.git.songo@debian.org.pl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1363823448.git.songo@debian.org.pl>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>

'ipvsadm -S' listed one-packet scheduling option in wrong format
('ops' instead of '--ops' or '-o') preventing any service with OPS
feature from restoring using 'ipvsadm -R'.  Now we use '-o' which
works well with save/restore commands.

Signed-off-by: Krzysztof Gajdemski <songo@debian.org.pl>
---
 ipvsadm.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 9afd125..587bfc1 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1487,7 +1487,7 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 		if (se->pe_name[0])
 			printf(" pe %s", se->pe_name);
 		if (se->flags & IP_VS_SVC_F_ONEPACKET)
-			printf(" ops");
+			printf(" -o");
 	} else if (format & FMT_STATS) {
 		printf("%-33s", svc_name);
 		print_largenum(se->stats.conns, format);
-- 
1.7.10.4

