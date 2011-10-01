From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/2] IPVS: secure_tcp does provide alternate state timeouts
Date: Sat,  1 Oct 2011 12:34:18 +0900
Message-ID: <1317440059-31112-2-git-send-email-horms@verge.net.au>
References: <1317440059-31112-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1317440059-31112-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

* Also reword the test to make it read more easily (to me)

Signed-off-by: Simon Horman <horms@verge.net.au>

---

Julian, I don't see that IPVS currently implements alternate
timeouts for secure_tcp. Am I missing something?
---
 Documentation/networking/ipvs-sysctl.txt |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 1dcdd49..13610e3 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -140,13 +140,11 @@ nat_icmp_send - BOOLEAN
 secure_tcp - INTEGER
         0  - disabled (default)
 
-        The secure_tcp defense is to use a more complicated state
-        transition table and some possible short timeouts of each
-        state. In the VS/NAT, it delays the entering the ESTABLISHED
-        until the real server starts to send data and ACK packet
-        (after 3-way handshake).
+	The secure_tcp defense is to use a more complicated TCP state
+	transition table. For VS/NAT, it also delays entering the
+	TCP ESTABLISHED state until the three way handshake is completed.
 
-        The value definition is the same as that of drop_entry or
+        The value definition is the same as that of drop_entry and
         drop_packet.
 
 sync_threshold - INTEGER
-- 
1.7.5.4

