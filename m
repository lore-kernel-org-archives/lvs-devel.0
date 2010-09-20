From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC][PATCH] ipvs: IPv6 tunnel mode
Date: Mon, 20 Sep 2010 12:13:09 +0200
Message-ID: <1284977589.25529.203.camel@seasc0214.dyn.rnd.as.sw.ericsson.se>
References: <Pine.LNX.4.58.1009181704560.8786@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.1009181704560.8786@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>

Tunnel mode for IPv6 doesn't work.

IPv6 encapsulation uses a bad source address for the tunnel.
i.e. VIP will be used as local-addr and encap. dst addr.
Decapsulation will not accept this.

Example
LVS (eth1 2003::2:0:1/96, VIP 2003::2:0:100)
    (eth0 2003::1:0:1/96)
RS  (ethX 2003::1:0:5/96)     

tcpdump
 2003::2:0:100 > 2003::1:0:5: 
 IP6 (hlim 63, next-header TCP (6) payload length: 40) 
  2003::3:0:10.50991 > 2003::2:0:100.http: Flags [S], cksum 0x7312
(correct), seq 3006460279, win 5760, options [mss 1440,sackOK,TS val
1904932 ecr 0,nop,wscale 3], length 0


In Linux IPv6 impl. you can't have a tunnel with an any cast address
receiving packets (I have not tried to interpret RFC 2473)
To have receive capabilities the tunnel must have:
  - Local address set as multicast addr or an unicast addr
  - Remote address set as an unicast addr.
  - Loop back addres or Link local address are not allowed.

This causes us to setup a tunnel in the Real Server with the
LVS as the remote address, here you can't use the VIP address since it's
used inside the tunnel.

Solution
Use outgoing interface IPv6 address (match against the destination).
i.e. use ipv6_dev_get_saddr(...) to set the source address of the
encapsulated package.

However this lookup cost some cpu time to do, so there is some speed
enhancements to this patch
 
a) Cache the result
b) Static configuration i.e. used a static configured address
   (since the tunnel in RS use a static address remote address)

Here follows the patch without any enhancements mention above.

Signed-off-by: hans.schillstrom@ericsson.com

---

--- linux-2.6.35.next/net/netfilter/ipvs/ip_vs_xmit.c       2010-08-13
12:18:12.000000000 +0200
+++ linux-2.6.35.x/net/netfilter/ipvs/ip_vs_xmit.c  2010-09-20
11:38:50.000000000 +0200

@@ -688,10 +702,25 @@
        rt = __ip_vs_get_out_rt_v6(cp);
        if (!rt)
                goto tx_error_icmp;

        tdev = rt->dst.dev;
+       /* Lookup source address for the tunnel */
+        if (likely(ipv6_addr_any(&rt->rt6i_src.addr))) {
+                struct net *net = dev_net(skb->dev);
+                int err = ipv6_dev_get_saddr(net, tdev,
+                                         &rt->rt6i_dst.addr,
+                                         0,
+                                         &rt->rt6i_src.addr);
+                /* RFC 2473 Ch 8. IPv6 Tunnel Error Processing and
Reporting
+                 *   Both tunnel header and tunnel packet problems are
reported
+                 *   to the tunnel entry-point node.
+                 */
+                if (err) {
+                        goto tx_error_icmp;
+                }
+        }

        mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
        /* TODO IPv6: do we need this check in IPv6? */
        if (mtu < 1280) {
                dst_release(&rt->dst);
@@ -747,11 +776,11 @@
        iph->payload_len        =       old_iph->payload_len;
        be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
        iph->priority           =       old_iph->priority;
        memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
        iph->daddr              =       rt->rt6i_dst.addr;
-       iph->saddr              =       cp->vaddr.in6; /*
rt->rt6i_src.addr; */
+       iph->saddr              =       rt->rt6i_src.addr;
        iph->hop_limit          =       old_iph->hop_limit;

        /* Another hack: avoid icmp_send in ip_fragment */
        skb->local_df = 1;
--


