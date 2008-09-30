From: juliusv@google.com (Julius Volz)
Subject: Making conntrack like packets DNATed by IPVS
Date: Tue, 30 Sep 2008 14:21:59 +0200
Message-ID: <20080930122158.GA31253@google.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1222777329; bh=9+csuDmVbyM1UkIz9k8RqmiHrsg=;
	h=DomainKey-Signature:Date:To:Cc:Subject:Message-ID:MIME-Version:
	 Content-Type:Content-Disposition:User-Agent:From; b=TqCKhNe46xrNOP
	b5jjoz0XwbZzmbKcpcMGLMrick5jmfsjlZ5XudinqoAXxn3wytIt0sY9RbnudKKnJO6
	x1mRw==
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org
Cc: vbusam@google.com, jengelh@medozas.de, horms@verge.net.au, lvs-devel@vger.kernel.org, ja@ssi.bg

Hi,

I'm still stuck trying to get IPVS/NAT to work together with Netfilter
conntrack/Netfilter SNAT. First, I removed the Netfilter hook function
in IPVS that prevented further processing in POSTROUTING. Then, I made
IPVS reflect its own DNAT changes in the skb->nfct tuples just before
IPVS injects the packet back into LOCAL_OUT:

======================
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 958abf3..96d24b5 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1429,13 +1429,13 @@ static struct nf_hook_ops ip_vs_ops[] __read_mostly = {
 		.priority       = 99,
 	},
 	/* Before the netfilter connection tracking, exit from POST_ROUTING */
-	{
+	/*{
 		.hook		= ip_vs_post_routing,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET,
 		.hooknum        = NF_INET_POST_ROUTING,
 		.priority       = NF_IP_PRI_NAT_SRC-1,
-	},
+	},*/
 #ifdef CONFIG_IP_VS_IPV6
 	/* After packet filtering, forward packet through VS/DR, VS/TUN,
 	 * or VS/NAT(change destination), so that filtering rules can be
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 02ddc2b..de7feb5 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -24,6 +24,7 @@
 #include <net/ip6_route.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
+#include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
@@ -360,6 +361,21 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
+	if (skb->nfct) {
+		struct nf_conn *ct = (struct nf_conn*)skb->nfct;
+
+		ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3.ip = cp->daddr.ip;
+		ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u.tcp.port = cp->dport;
+
+		ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip = cp->daddr.ip;
+		ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u.tcp.port = cp->dport;
+
+		/* Netfilter SNAT was already marked done in LOCAL_IN, but
+		 * somehow, the packet still contains the original source IP,
+		 * so we want it to be done again in POSTROUTING */
+		clear_bit(IPS_SRC_NAT_DONE_BIT, &ct->status);
+	}
+
 	/* check if it is a connection of no-client-port */
 	if (unlikely(cp->flags & IP_VS_CONN_F_NO_CPORT)) {
 		__be16 _pt, *p;

======================

The Netfilter SNAT rule is simply:

$ iptables -t -nat -A POSTROUTING -o eth1 -j SNAT -to <director IP>

The SYN and SYN/ACK packets of a new connection get handled correctly by
IPVS and even get SNATed correctly. The ACK to the SYN/ACK still gets
handled correctly by IPVS but is NF_DROPed in POSTROUTING in
__nf_conntrack_confirm() as a result of a check finding the associated
conntrack tuple already in the nf_conntrack_hash (meaning, the
connection has already been confirmed). If I understand it correctly, we
shouldn't be entering that function for the ACK packet anyways, so
I'm doing something very wrong...

A packet trace on the director looks like this:

CIP: client IP
VIP: virtual service IP
DIP: director (load balancer) IP
RIP: real server (backend) IP

11:28:51.431221 IP <CIP>.49988 > <VIP>.80: S 1151908514:1151908514(0) win 5840 <mss 1460,sackOK,timestamp 74963354 0,nop,wscale 7>
11:28:51.432294 IP <DIP>.49988 > <RIP>.80: S 1151908514:1151908514(0) win 5840 <mss 1460,sackOK,timestamp 74963354 0,nop,wscale 7>
11:28:51.432822 IP <RIP>.80 > <DIP>.49988: S 1508888076:1508888076(0) ack 1151908515 win 5792 <sackOK,timestamp 7468557 74963354,mss 1460,nop,wscale 4>
11:28:51.434159 IP <VIP>.80 > <CIP>.49988: S 1508888076:1508888076(0) ack 1151908515 win 5792 <sackOK,timestamp 7468557 74963354,mss 1460,nop,wscale 4>
11:28:51.434253 IP <CIP>.49988 > <VIP>.80: . ack 1 win 46 <nop,nop,timestamp 74963362 7468557>
(the above packet is dropped in POSTROUTING...)
11:28:52.029604 IP <CIP>.49988 > <VIP>.80: P 1:3(2) ack 1 win 46 <nop,nop,timestamp 74963957 7468557>
11:28:52.237975 IP <CIP>.49988 > <VIP>.80: P 1:3(2) ack 1 win 46 <nop,nop,timestamp 74964165 7468557>
...

The various places in Netfilter at which tuples are created, modified,
checked, inserted, etc. are kind of confusing to me and I'm missing the
necessary Netfilter internals knowledge to understand and handle this
correctly. I'd be glad if someone could give me a pointer into the right
direction or help out in any other way!

Thanks,
Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
