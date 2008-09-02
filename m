From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 19/24] IVPS: Disable sync daemon for IPv6 connections
Date: Tue,  2 Sep 2008 15:55:50 +0200
Message-ID: <1220363755-9854-20-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363767; bh=v5+avlPzLZfLl3vkeVikuYW4gtg=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=GuuFiw+7Yf87ZbBKrFNklOapyzsmDbTnJYGjf0o3
	uZaVMQvfZEUNFJPO/5/z1qxciw406T67ZVC3Kx1bg2Y8zA==
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
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
index 27bef1d..5a7a817 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1321,7 +1321,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
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

