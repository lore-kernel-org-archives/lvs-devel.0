From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Mon, 10 Jun 2013 23:52:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306102247410.1972@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg> <20130610151257.GB19108@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130610151257.GB19108@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 10 Jun 2013, Alexander Frolkin wrote:

> Hi,
> 
> Attached is a patch for sloppy TCP and SCTP against the upstream kernel.

	Please post patches inline, not as attached file.
Refer to Documentation/email-clients.txt for details about
your email client.

	The check for initial sSR state should be in
set_tcp_state() and set_sctp_state() because ip_vs_set_state()
can be called also from ip_vs_leave(). For example:

	int old_state;

	old_state = (cp->state != IP_VS_TCP_S_NONE) ?
		    cp->state : IP_VS_TCP_S_SYN_RECV;
	new_state = 
		pd->tcp_state_table[state_off+state_idx].next_state[old_state];

	But may be we can do it in a simple way: both
tables tcp_states[] and tcp_states_dos[] can be changed
for INPUT and INPUT-ONLY - the sNO column to contain
sES for the "ack" case, it happens only for sloppy mode:

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 50a1594..6b2c6d6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -401,7 +401,7 @@ static struct tcp_states_t tcp_states [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }},
 /*fin*/ {{sCL, sCW, sSS, sTW, sTW, sTW, sCL, sCW, sLA, sLI, sTW }},
-/*ack*/ {{sCL, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
+/*ack*/ {{sES, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sSR }},
 
 /*	OUTPUT */
@@ -415,7 +415,7 @@ static struct tcp_states_t tcp_states [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }},
 /*fin*/ {{sCL, sFW, sSS, sTW, sFW, sTW, sCL, sCW, sLA, sLI, sTW }},
-/*ack*/ {{sCL, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
+/*ack*/ {{sES, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 
@@ -424,7 +424,7 @@ static struct tcp_states_t tcp_states_dos [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSA }},
 /*fin*/ {{sCL, sCW, sSS, sTW, sTW, sTW, sCL, sCW, sLA, sLI, sSA }},
-/*ack*/ {{sCL, sES, sSS, sSR, sFW, sTW, sCL, sCW, sCL, sLI, sSA }},
+/*ack*/ {{sES, sES, sSS, sSR, sFW, sTW, sCL, sCW, sCL, sLI, sSA }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 
 /*	OUTPUT */
@@ -438,7 +438,7 @@ static struct tcp_states_t tcp_states_dos [] = {
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSA, sES, sES, sSR, sSA, sSA, sSA, sSA, sSA, sSA, sSA }},
 /*fin*/ {{sCL, sFW, sSS, sTW, sFW, sTW, sCL, sCW, sLA, sLI, sTW }},
-/*ack*/ {{sCL, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
+/*ack*/ {{sES, sES, sSS, sES, sFW, sTW, sCL, sCW, sCL, sLI, sES }},
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 

	When you post the patch inline I'll comment
about some styling problems.

> checkpatch.pl throws up errors, but they refer to stuff that was there
> before, not my changes.
> 
> I've added a bit of code to set the initial state for a sloppy TCP
> connection.  I have a template (in the patch) for a similar bit of code
> for SCTP, but I'm hoping that someone can help me work out what the
> initial state should be, since I know next to nothing about SCTP...

	We have to check what states should be changed
for SCTP, I'll think more tomorrow. There should be changes
for the 'STATE : IP_VS_SCTP_S_NONE' case.

Regards

--
Julian Anastasov <ja@ssi.bg>
