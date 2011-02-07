From: Dan Carpenter <error27@gmail.com>
Subject: [patch] IPVS: precedence bug in ip_vs_sync_switch_mode()
Date: Mon, 7 Feb 2011 11:38:55 +0300
Message-ID: <20110207083855.GD4384@bicker>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:date:from:to:cc:subject:message-id:mime-version
         :content-type:content-disposition:user-agent;
        bh=w0cok/sZCVN1I1WzHWfso/Tf7IHurMuYsPT8K8Z0V48=;
        b=L1SsCDpJKnpPgsz+u1qBoNLbXuvvGpVP78NGUCeRXI5lb4uIua+RJcbdR4ItXHnre1
         dpBGGT+P5hKnv9BqkqQfAXEr3hdzKTd7wWykZKsvv4kf40C4GSeKDk/arvz0RwIr8rb4
         OijjE8nhm1tGDb8hBSLckKqX7plcMxb+2blpc=
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, hans.schillstrom@ericsson.com, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org

'!' has higher precedence than '&'.  IP_VS_STATE_MASTER is 0x1 so
the original code is equivelent to if (!ipvs->sync_state) ...

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2a2a836..d1b7298 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -392,7 +392,7 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ipvs->sync_state & IP_VS_STATE_MASTER)
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
 		return;
 	if (mode == ipvs->sysctl_sync_ver || !ipvs->sync_buff)
 		return;
