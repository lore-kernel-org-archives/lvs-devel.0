From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/4] ipvs: allow rescheduling after RST
Date: Mon,  7 Mar 2016 12:03:33 +0900
Message-ID: <1457319814-8027-4-git-send-email-horms@verge.net.au>
References: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1457319820; bh=kfd5Vlx+LorJTIp7Uit9ekxh4dMgYECVxnXd244rSlA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=JUeLihlbDmGI5pWpe2ge26Jtccs4AaTw7UpDNvTvWmzUDrq7Sm4CV6MLrTUXxcwRf
	 8kxum/GgVQFskHTE1o2iWXu1RInuHRxk267k6CA1paLpgrtLEEmSPbfCx1P10W/tcw
	 p4QZvm58ZHBup3bpIyzoIrITWkI4HQjkbJnJGQLY=
In-Reply-To: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

"RFC 5961, 4.2. Mitigation" describes a mechanism to request
client to confirm with RST the restart of TCP connection
before resending its SYN. As result, IPVS can see SYNs for
existing connection in CLOSE state. Add check to allow
rescheduling in this state.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4da560005b0e..b9a4082afa3a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1089,6 +1089,7 @@ static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
 	switch (cp->protocol) {
 	case IPPROTO_TCP:
 		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
+		       (cp->state == IP_VS_TCP_S_CLOSE) ||
 			((conn_reuse_mode & 2) &&
 			 (cp->state == IP_VS_TCP_S_FIN_WAIT) &&
 			 (cp->flags & IP_VS_CONN_F_NOOUTPUT));
-- 
2.1.4

