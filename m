From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/5] netfilter: ipvs: Fix space before '[' error.
Date: Thu, 19 Apr 2018 10:56:10 +0200
Message-ID: <20180419085614.7437-2-horms@verge.net.au>
References: <20180419085614.7437-1-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1524128186; bh=Zag+0YpZvMph78QS1qJ9CXwJpHxcwes5pQsjY6EJzs0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=mMLCEkIwtb5vhL6qhNtuINp3bR4pFhK0Ll2Pzfv2wlmGzXuJTN3sucIWfPc6/1lER
         MNivtXsTu7nPifgn7Q1fY9bpqHsdDIUCj7PzcyfOXVHcdcVIF8Jz3KBZusMPocQ7ny
         nkuNCG7gbP+jvpQwPKavgYFp0OU2PnVUlkOBUxjo=
In-Reply-To: <20180419085614.7437-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Simon Horman <horms@verge.net.au>

From: Arvind Yadav <arvind.yadav.cs@gmail.com>

Fix checkpatch.pl error:
ERROR: space prohibited before open square bracket '['.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index bcd9b7bde4ee..569631d2b2a1 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -436,7 +436,7 @@ static bool tcp_state_active(int state)
 	return tcp_state_active_table[state];
 }
 
-static struct tcp_states_t tcp_states [] = {
+static struct tcp_states_t tcp_states[] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }},
@@ -459,7 +459,7 @@ static struct tcp_states_t tcp_states [] = {
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 
-static struct tcp_states_t tcp_states_dos [] = {
+static struct tcp_states_t tcp_states_dos[] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSA }},
-- 
2.11.0

