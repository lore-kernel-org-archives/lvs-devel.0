From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] ipvs: count pre-established TCP states as active
Date: Thu,  7 Jul 2016 20:40:40 +0200
Message-ID: <1467916840-17005-2-git-send-email-horms@verge.net.au>
References: <1467916840-17005-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1467916845; bh=Ovyep+o0Ar4dWw+S4VOMnckOUztEOYIrCONLKIwx8Rg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PUW4TYxeC/kORNsJXc38FqxvHPi5vxYGojLjQ00IYsy3Z5FwXsEp3PgKcHj9LPZzF
	 bC3LBeg/n1bhjNmcsIPEoaH1Xv5OmXs4+hD0ApTfp6qJXqEUrDpGWYGPlOOM7MgOda
	 6GiTSKqmGhOISMq+Ass0dghrr10XTwTc1E2Mbvyo=
In-Reply-To: <1467916840-17005-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Michal Kubecek <mkubecek@suse.cz>, Simon Horman <horms@verge.net.au>

From: Michal Kubecek <mkubecek@suse.cz>

Some users observed that "least connection" distribution algorithm doesn't
handle well bursts of TCP connections from reconnecting clients after
a node or network failure.

This is because the algorithm counts active connection as worth 256
inactive ones where for TCP, "active" only means TCP connections in
ESTABLISHED state. In case of a connection burst, new connections are
handled before previous ones have finished the three way handshaking so
that all are still counted as "inactive", i.e. cheap ones. The become
"active" quickly but at that time, all of them are already assigned to one
real server (or few), resulting in highly unbalanced distribution.

Address this by counting the "pre-established" states as "active".

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index d7024b2ed769..5117bcb7d2f0 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -395,6 +395,20 @@ static const char *const tcp_state_name_table[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_LAST]		=	"BUG!",
 };
 
+static const bool tcp_state_active_table[IP_VS_TCP_S_LAST] = {
+	[IP_VS_TCP_S_NONE]		=	false,
+	[IP_VS_TCP_S_ESTABLISHED]	=	true,
+	[IP_VS_TCP_S_SYN_SENT]		=	true,
+	[IP_VS_TCP_S_SYN_RECV]		=	true,
+	[IP_VS_TCP_S_FIN_WAIT]		=	false,
+	[IP_VS_TCP_S_TIME_WAIT]		=	false,
+	[IP_VS_TCP_S_CLOSE]		=	false,
+	[IP_VS_TCP_S_CLOSE_WAIT]	=	false,
+	[IP_VS_TCP_S_LAST_ACK]		=	false,
+	[IP_VS_TCP_S_LISTEN]		=	false,
+	[IP_VS_TCP_S_SYNACK]		=	true,
+};
+
 #define sNO IP_VS_TCP_S_NONE
 #define sES IP_VS_TCP_S_ESTABLISHED
 #define sSS IP_VS_TCP_S_SYN_SENT
@@ -418,6 +432,13 @@ static const char * tcp_state_name(int state)
 	return tcp_state_name_table[state] ? tcp_state_name_table[state] : "?";
 }
 
+static bool tcp_state_active(int state)
+{
+	if (state >= IP_VS_TCP_S_LAST)
+		return false;
+	return tcp_state_active_table[state];
+}
+
 static struct tcp_states_t tcp_states [] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
@@ -540,12 +561,12 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 
 		if (dest) {
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
-			    (new_state != IP_VS_TCP_S_ESTABLISHED)) {
+			    !tcp_state_active(new_state)) {
 				atomic_dec(&dest->activeconns);
 				atomic_inc(&dest->inactconns);
 				cp->flags |= IP_VS_CONN_F_INACTIVE;
 			} else if ((cp->flags & IP_VS_CONN_F_INACTIVE) &&
-				   (new_state == IP_VS_TCP_S_ESTABLISHED)) {
+				   tcp_state_active(new_state)) {
 				atomic_inc(&dest->activeconns);
 				atomic_dec(&dest->inactconns);
 				cp->flags &= ~IP_VS_CONN_F_INACTIVE;
-- 
2.7.0.rc3.207.g0ac5344

