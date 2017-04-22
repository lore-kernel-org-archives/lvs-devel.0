From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PROBLEM: IPVS incorrectly reverse-NATs traffic to LVS host
Date: Sat, 22 Apr 2017 20:06:10 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1704221417080.1974@ja.home.ssi.bg>
References: <CAEo=OUnG+Bn04XaEkwHpL2bt6bEZXP_F6RSa9HDN=VjXdOxpoQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CAEo=OUnG+Bn04XaEkwHpL2bt6bEZXP_F6RSa9HDN=VjXdOxpoQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Moriarty <nick.moriarty@york.ac.uk>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Wed, 12 Apr 2017, Nick Moriarty wrote:

> Hi,
> 
> I've experienced a problem in how traffic returning to an LVS host is
> handled in certain circumstances.  Please find a bug report below - if
> there's any further information you'd like, please let me know.
> 
> [1.] One line summary of the problem:
> IPVS incorrectly reverse-NATs traffic to LVS host
> 
> [2.] Full description of the problem/report:
> When using IPVS in direct-routing mode, normal traffic from the LVS
> host to a back-end server is sometimes incorrectly NATed on the way
> back into the LVS host.  Using tcpdump shows that the return packets
> have the correct source IP, but by the time it makes it back to the
> application, it's been changed.
> 
> To reproduce this, a configuration such as the following will work:
> - Set up an LVS system with a VIP serving UDP to a backend DNS server
> using the direct-routing method in IPVS
> - Make an outgoing UDP request to the VIP from the LVS system itself
> (this causes a connection to be added to the IPVS connection table)
> - The request should succeed as normal
> - Note the UDP source port used
> - Within 5 minutes (before the UDP connection entry expires), make an
> outgoing UDP request directly to the backend DNS server
> - The request will fail as the reply is incorrectly modified on its
> way back and appears to return from the VIP
> 
> Monitoring the above sequence with tcpdump verifies that the returned
> packet (as it enters the host) is from the DNS IP, even though the
> application sees the VIP.
> 
> If an outgoing request direct to the DNS server is made from a port
> not in the connection table, everything is fine.

	Thanks for the detailed report! I think, I fixed the
problem. Let me know if you are able to test the appended fix.

> I expect that somewhere, something (e.g. functionality for IPVS MASQ
> responses) is applying IPVS connection
> information to incoming traffic, matching a DROUTE rule, and treating
> it as NAT traffic.

	Yep, that is what happens.

================================================================

[PATCH net] ipvs: SNAT packet replies only for NATed connections

We do not check if packet from real server is for NAT
connection before performing SNAT. This causes problems
for setups that use DR/TUN and allow local clients to
access the real server directly, for example:

- local client in director creates IPVS-DR/TUN connection
CIP->VIP and the request packets are routed to RIP.
Talks are finished but IPVS connection is not expired yet.

- second local client creates non-IPVS connection CIP->RIP
with same reply tuple RIP->CIP and when replies are received
on LOCAL_IN we wrongly assign them for the first client
connection because RIP->CIP matches the reply direction.

The problem is more visible to local UDP clients but in rare
cases it can happen also for TCP or remote clients when the
real server sends the reply traffic via the director.

So, better to be more precise for the reply traffic.
As replies are not expected for DR/TUN connections, better
to not touch them.

Reported-by: Nick Moriarty <nick.moriarty@york.ac.uk>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index db40050..ee44ed5 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -849,10 +849,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 {
 	unsigned int verdict = NF_DROP;
 
-	if (IP_VS_FWD_METHOD(cp) != 0) {
-		pr_err("shouldn't reach here, because the box is on the "
-		       "half connection in the tun/dr module.\n");
-	}
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+		goto ignore_cp;
 
 	/* Ensure the checksum is correct */
 	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
@@ -886,6 +884,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	else
 		ip_vs_update_conntrack(skb, cp, 0);
+
+ignore_cp:
 	verdict = NF_ACCEPT;
 
 out:
@@ -1385,8 +1385,11 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	 */
 	cp = pp->conn_out_get(ipvs, af, skb, &iph);
 
-	if (likely(cp))
+	if (likely(cp)) {
+		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+			goto ignore_cp;
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
+	}
 
 	/* Check for real-server-started requests */
 	if (atomic_read(&ipvs->conn_out_counter)) {
@@ -1444,9 +1447,15 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 			}
 		}
 	}
+
+out:
 	IP_VS_DBG_PKT(12, af, pp, skb, iph.off,
 		      "ip_vs_out: packet continues traversal as normal");
 	return NF_ACCEPT;
+
+ignore_cp:
+	__ip_vs_conn_put(cp);
+	goto out;
 }
 
 /*
-- 
2.9.3

Regards

--
Julian Anastasov <ja@ssi.bg>
