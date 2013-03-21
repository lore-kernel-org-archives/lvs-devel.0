From: Krzysztof Gajdemski <songo@debian.org.pl>
Subject: [PATCH 2/2] ipvsadm: Show 'ops' flag regardless of service
 persistence
Date: Thu, 21 Mar 2013 11:40:14 +0100
Message-ID: <20130321104014.GC9563@debian.org.pl>
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

In print_service_entry() 'ops' option is displayed only for services
which have the IP_VS_SVC_F_PERSISTENT flag set. However, it should be
displayed for any VS with one-packet scheduling because OPS can be
also used without persistence.

Signed-off-by: Krzysztof Gajdemski <songo@debian.org.pl>
---
 ipvsadm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ipvsadm.c b/ipvsadm.c
index 587bfc1..45a71af 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1517,9 +1517,9 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
 					printf(" mask %i", se->netmask);
 			if (se->pe_name[0])
 				printf(" pe %s", se->pe_name);
-			if (se->flags & IP_VS_SVC_F_ONEPACKET)
-				printf(" ops");
 		}
+		if (se->flags & IP_VS_SVC_F_ONEPACKET)
+			printf(" ops");
 	}
 	printf("\n");
 
-- 
1.7.10.4
