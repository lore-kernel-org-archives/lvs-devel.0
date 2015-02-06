From: Alexey Andriyanov <alan@al-an.info>
Subject: [PATCH] ipvs: fix inability to remove a mixed-family RS
Date: Fri, 06 Feb 2015 22:32:20 +0300
Message-ID: <54D516C4.8080504@al-an.info>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=al-an.info; s=mail; t=1423251140;
	bh=DuCs4k2AwdQxKkUa/9z94R0I0VeJ+5iCil1G0IFhBUI=;
	h=Message-ID:Date:From:User-Agent:MIME-Version:To:Subject:
	 Content-Type:Content-Transfer-Encoding;
	b=V2nNd1aHXhVg6vRTDL/t6lu0qhjlUNPjGJbwgyAaPfo7LcEFumDzAFGF2Zi2EcM5d
	 8z6z1T2zqUgJ0zTfL2LgSRi5IjqnCW3gu6z8wEp4rkRifm++JTFCFxFSd4DySC7c/w
	 3PQ9iQwgd0xnXdFOAI1Zy2gE6h3NRxkUqzdR/pPM=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

The current code prevents any operation with a mixed-family dest
unless IP_VS_CONN_F_TUNNEL flag is set. The problem is that it's impossible
for the client to follow this rule, because ip_vs_genl_parse_dest does
not even read the destination conn_flags when cmd = IPVS_CMD_DEL_DEST
(need_full_dest = 0).

Also, not every client can pass this flag when removing a dest. ipvsadm,
for example, does not support the "-i" command line option together with
the "-d" option.

This change disables any checks for mixed-family on IPVS_CMD_DEL_DEST command.

Signed-off-by: Alexey Andriyanov <alan@al-an.info>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ac7ba68..5b373c3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3400,7 +3400,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
                if (udest.af == 0)
                        udest.af = svc->af;
 
-               if (udest.af != svc->af) {
+               if (udest.af != svc->af && cmd != IPVS_CMD_DEL_DEST) {
                        /* The synchronization protocol is incompatible
                         * with mixed family services
                         */
-- 
1.7.9.5

