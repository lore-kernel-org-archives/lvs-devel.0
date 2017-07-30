From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] netfilter: ipvs: Fix space before '[' error.
Date: Sun, 30 Jul 2017 12:29:25 +0530
Message-ID: <3b2fae111371a2abd12d6838e825452a3c9bd4fa.1501397734.git.arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=PT9nePDPCVJkhTchqgrSkGP3FR44Gpp06mlPX6BTlEk=;
        b=Jl7IUxZ3m4wTcZ1RA4ZQyjxc4UzV2bEsa5OBvBS4oFZoduYlNaSSfGK0nf1uYfKSQv
         MZiLrjaXS66XtaqLEqEq78u1cYXMlfEucHLHNvSOEs/TRQnTqkvkZQl4xwdvYd40qoIb
         Eordw8sUr14JRg0GvYGd1DeVBtp5vOyw4VspuOgdrcxznKCF1AzmPrKqmrmKlkKAWIHi
         jCxcc578nsyusp5yPrMw2g4mv1re4wXAqA9B4iaE/MQddekWTZt+5ltwS99HodkXQUB/
         /3u1EGfBOZA03c72PNAvoFzw7SydrlL6ILz45BZyOHCc/h9BHF5yKT1mrfE2+fZeFEwx
         5Oeg==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.ne
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

Fix checkpatch.pl error:
ERROR: space prohibited before open square bracket '['.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 12dc8d5..4fc17fc 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -439,7 +439,7 @@ static bool tcp_state_active(int state)
 	return tcp_state_active_table[state];
 }
 
-static struct tcp_states_t tcp_states [] = {
+static struct tcp_states_t tcp_states[] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSR }},
@@ -462,7 +462,7 @@ static struct tcp_states_t tcp_states [] = {
 /*rst*/ {{sCL, sCL, sCL, sSR, sCL, sCL, sCL, sCL, sLA, sLI, sCL }},
 };
 
-static struct tcp_states_t tcp_states_dos [] = {
+static struct tcp_states_t tcp_states_dos[] = {
 /*	INPUT */
 /*        sNO, sES, sSS, sSR, sFW, sTW, sCL, sCW, sLA, sLI, sSA	*/
 /*syn*/ {{sSR, sES, sES, sSR, sSR, sSR, sSR, sSR, sSR, sSR, sSA }},
-- 
2.7.4

