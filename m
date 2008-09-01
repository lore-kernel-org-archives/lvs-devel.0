From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 19/25] IVPS: Disable sync daemon for IPv6 connections
Date: Mon,  1 Sep 2008 14:56:16 +0200
Message-ID: <1220273782-19901-20-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220273828; bh=6ppY8KWVK89bzALdihNnPi6O3+0=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=oLChyYhQ5ZoiC3TCJBF+zh4S3nFk1O0pGyF1+mSi
	HRaj0EwaKlHvhivieKp5eg1NiSWwB1BX0JZnnK55/jGusg==
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com, Julius Volz <juliusv@google.com>

Disable the sync daemon for IPv6 connections, works only with IPv4 for now.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 2725b93..141454d 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1318,7 +1318,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 * encorage the standby servers to update the connections timeout
 	 */
 	atomic_inc(&cp->in_pkts);
-	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	if (af == AF_INET &&
+	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
 	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
-- 
1.5.4.5

