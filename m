From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/3] ipvs: don't alter conntrack in OPS mode
Date: Wed, 20 Apr 2016 12:46:34 +1000
Message-ID: <1461120394-5548-4-git-send-email-horms@verge.net.au>
References: <1461120394-5548-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1461120407; bh=8J9mxkYgA7S558gf5CMN52M6kNXVWV/afmP0RdCAQVY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ZaYkNxY5l8m40g6f9wkpfG8hDoolVSkzXdMyGTL3LCnZEb5apPI7eEUqjICvXZmtd
	 ZsZPubbGPLJ40jhvRqzIw6hPmRtHMHJGfnsXMcqb8sBesbWgOiA8EIU1CVuzKglDzS
	 h/3v5hZWqhP/ufbYCcxlqfl2OUR39iXOhLZxIHaY=
In-Reply-To: <1461120394-5548-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Marco Angaroni <marcoangaroni@gmail.com>, Simon Horman <horms@verge.net.au>

From: Marco Angaroni <marcoangaroni@gmail.com>

When using OPS mode in conjunction with SIP persistent-engine, packets
originating from the same ip-address/port could be balanced to different
real servers, and (to properly handle SIP responses) OPS connections
are created in the in-out direction too, where ip_vs_update_conntrack()
is called to modify the reply tuple.

As a result, there can be collision of conntrack tuples, causing random
packet drops, as explained below:

conntrack1: orig=CIP->VIP, reply=RIP1->CIP
conntrack2: orig=RIP2->CIP, reply=CIP->VIP

Tuple CIP->VIP is both in orig of conntrack1 and reply of conntrack2.
The collision triggers packet drop inside nf_conntrack processing.

In addition, the current implementation deletes the conntrack object at
every expire of an OPS connection (once every forwarded packet), to have
it recreated from scratch at next packet traversing IPVS.

Since in OPS mode, by definition, we don't expect any associated
response, the choices implemented in this patch are:
a) don't call nf_conntrack_alter_reply() for OPS connections inside
   ip_vs_update_conntrack().
b) don't delete the conntrack object at OPS connection expire.

The result is that created conntrack objects for each tuple CIP->VIP,
RIP-N->CIP, etc. are left in UNREPLIED state and not modified by IPVS
OPS connection management. This eliminates packet drops and leaves
a single conntrack object for each tuple packets are sent from.

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 3 ++-
 net/netfilter/ipvs/ip_vs_nfct.c | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index dd75d4120099..292365ffa4f0 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -836,7 +836,8 @@ static void ip_vs_conn_expire(unsigned long data)
 		if (cp->control)
 			ip_vs_control_del(cp);
 
-		if (cp->flags & IP_VS_CONN_F_NFCT) {
+		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
+		    !(cp->flags & IP_VS_CONN_F_ONE_PACKET)) {
 			/* Do not access conntracks during subsys cleanup
 			 * because nf_conntrack_find_get can not be used after
 			 * conntrack cleanup for the net.
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 30434fb133df..f04fd8df210b 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -93,6 +93,10 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
 		return;
 
+	/* Never alter conntrack for OPS conns (no reply is expected) */
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		return;
+
 	/* Alter reply only in original direction */
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		return;
-- 
2.7.0.rc3.207.g0ac5344

