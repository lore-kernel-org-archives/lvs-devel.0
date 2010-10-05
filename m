From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: [patch v4] ipvs: IPv6 tunnel mode
Date: Tue, 5 Oct 2010 12:14:56 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC02D1B4D7@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Language: en-US
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "horms@verge.net.au" <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Julius Volz <juliusv@google.com>, Wensong Zhang <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>

Hi
 a new try with Julians comments included.
Dest changed, and a new mail client that doesn't wrap lines.

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
i.e. use ip6_route_output() to look up the route cache and
then use ipv6_dev_get_saddr(...) to set the source address of the
encapsulated packet.

Additionally, cache the results in new destination
fields: dst_cookie and dst_saddr and properly check the
returned dst from ip6_route_output. We now add xfrm_lookup
call only for the tunneling method where the source address
is a local one.

Original patch by Hans Schillstrom.
Check dst state and cache results for IPv6 by Julian Anastasov.

Tested-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

* v1

  This is Julian's patch with a slightly edited version of the description
  from Hans's original patch.

* v2

  Updated changelog as per commends from Julian

* v3

  Flowi dest address used as destination instead of rt6_info in ip_vs_tunnel_xmit_v6()
  rt6_info somtimes contains a netw address insted of a tunnel

* v4

  Update destination as recommended from Julian
  i.e. use &cp->daddr.in6

Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
Tested-by: Hans Schillstrom <hans.schillstrom@ericsson.com>


diff -urp net-next-2.6-e548833-nfct_snat_reroute/linux/include/net/ip_vs.h linux/include/net/ip_vs.h
--- net-next-2.6-e548833-nfct_snat_reroute/linux/include/net/ip_vs.h    2010-09-16 09:03:48.000000000 +0300
+++ linux/include/net/ip_vs.h   2010-09-22 10:50:18.548963467 +0300
@@ -509,6 +509,10 @@ struct ip_vs_dest {
        spinlock_t              dst_lock;       /* lock of dst_cache */
        struct dst_entry        *dst_cache;     /* destination cache entry */
        u32                     dst_rtos;       /* RT_TOS(tos) for dst */
+       u32                     dst_cookie;
+#ifdef CONFIG_IP_VS_IPV6
+       struct in6_addr         dst_saddr;
+#endif

        /* for virtual service */
        struct ip_vs_service    *svc;           /* service it belongs to */
diff -urp net-next-2.6-e548833-nfct_snat_reroute/linux/net/netfilter/ipvs/ip_vs_xmit.c linux/net/netfilter/ipvs/ip_vs_xmit.c
--- net-next-2.6-e548833-nfct_snat_reroute/linux/net/netfilter/ipvs/ip_vs_xmit.c        2010-09-16 09:02:25.000000000 +0300
+++ linux/net/netfilter/ipvs/ip_vs_xmit.c       2010-09-22 16:29:43.271964521 +0300
@@ -26,6 +26,7 @@
 #include <net/route.h>                  /* for ip_route_output */
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/addrconf.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
@@ -37,26 +38,27 @@
  *      Destination cache to speed up outgoing route lookup
  */
 static inline void
-__ip_vs_dst_set(struct ip_vs_dest *dest, u32 rtos, struct dst_entry *dst)
+__ip_vs_dst_set(struct ip_vs_dest *dest, u32 rtos, struct dst_entry *dst,
+               u32 dst_cookie)
 {
        struct dst_entry *old_dst;

        old_dst = dest->dst_cache;
        dest->dst_cache = dst;
        dest->dst_rtos = rtos;
+       dest->dst_cookie = dst_cookie;
        dst_release(old_dst);
 }

 static inline struct dst_entry *
-__ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos, u32 cookie)
+__ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 {
        struct dst_entry *dst = dest->dst_cache;

        if (!dst)
                return NULL;
-       if ((dst->obsolete
-            || (dest->af == AF_INET && rtos != dest->dst_rtos)) &&
-           dst->ops->check(dst, cookie) == NULL) {
+       if ((dst->obsolete || rtos != dest->dst_rtos) &&
+           dst->ops->check(dst, dest->dst_cookie) == NULL) {
                dest->dst_cache = NULL;
                dst_release(dst);
                return NULL;
@@ -66,15 +68,16 @@ __ip_vs_dst_check(struct ip_vs_dest *des
 }

 static struct rtable *
-__ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
+__ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_conn *cp, u32 rtos)
 {
+       struct net *net = dev_net(skb->dev);
        struct rtable *rt;                      /* Route to the other host */
        struct ip_vs_dest *dest = cp->dest;

        if (dest) {
                spin_lock(&dest->dst_lock);
                if (!(rt = (struct rtable *)
-                     __ip_vs_dst_check(dest, rtos, 0))) {
+                     __ip_vs_dst_check(dest, rtos))) {
                        struct flowi fl = {
                                .oif = 0,
                                .nl_u = {
@@ -84,13 +87,13 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp
                                                .tos = rtos, } },
                        };

-                       if (ip_route_output_key(&init_net, &rt, &fl)) {
+                       if (ip_route_output_key(net, &rt, &fl)) {
                                spin_unlock(&dest->dst_lock);
                                IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
                                             &dest->addr.ip);
                                return NULL;
                        }
-                       __ip_vs_dst_set(dest, rtos, dst_clone(&rt->dst));
+                       __ip_vs_dst_set(dest, rtos, dst_clone(&rt->dst), 0);
                        IP_VS_DBG(10, "new dst %pI4, refcnt=%d, rtos=%X\n",
                                  &dest->addr.ip,
                                  atomic_read(&rt->dst.__refcnt), rtos);
@@ -106,7 +109,7 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp
                                        .tos = rtos, } },
                };

-               if (ip_route_output_key(&init_net, &rt, &fl)) {
+               if (ip_route_output_key(net, &rt, &fl)) {
                        IP_VS_DBG_RL("ip_route_output error, dest: %pI4\n",
                                     &cp->daddr.ip);
                        return NULL;
@@ -117,62 +120,79 @@ __ip_vs_get_out_rt(struct ip_vs_conn *cp
 }

 #ifdef CONFIG_IP_VS_IPV6
+
+static struct dst_entry *
+__ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
+                       struct in6_addr *ret_saddr, int do_xfrm)
+{
+       struct dst_entry *dst;
+       struct flowi fl = {
+               .oif = 0,
+               .nl_u = {
+                       .ip6_u = {
+                               .daddr = *daddr,
+                       },
+               },
+       };
+
+       dst = ip6_route_output(net, NULL, &fl);
+       if (dst->error)
+               goto out_err;
+       if (!ret_saddr)
+               return dst;
+       if (ipv6_addr_any(&fl.fl6_src) &&
+           ipv6_dev_get_saddr(net, ip6_dst_idev(dst)->dev,
+                              &fl.fl6_dst, 0, &fl.fl6_src) < 0)
+               goto out_err;
+       if (do_xfrm && xfrm_lookup(net, &dst, &fl, NULL, 0) < 0)
+               goto out_err;
+       ipv6_addr_copy(ret_saddr, &fl.fl6_src);
+       return dst;
+
+out_err:
+       dst_release(dst);
+       IP_VS_DBG_RL("ip6_route_output error, dest: %pI6\n", daddr);
+       return NULL;
+}
+
 static struct rt6_info *
-__ip_vs_get_out_rt_v6(struct ip_vs_conn *cp)
+__ip_vs_get_out_rt_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
+                     struct in6_addr *ret_saddr, int do_xfrm)
 {
+       struct net *net = dev_net(skb->dev);
        struct rt6_info *rt;                    /* Route to the other host */
        struct ip_vs_dest *dest = cp->dest;
+       struct dst_entry *dst;

        if (dest) {
                spin_lock(&dest->dst_lock);
-               rt = (struct rt6_info *)__ip_vs_dst_check(dest, 0, 0);
+               rt = (struct rt6_info *)__ip_vs_dst_check(dest, 0);
                if (!rt) {
-                       struct flowi fl = {
-                               .oif = 0,
-                               .nl_u = {
-                                       .ip6_u = {
-                                               .daddr = dest->addr.in6,
-                                               .saddr = {
-                                                       .s6_addr32 =
-                                                               { 0, 0, 0, 0 },
-                                               },
-                                       },
-                               },
-                       };
+                       u32 cookie;

-                       rt = (struct rt6_info *)ip6_route_output(&init_net,
-                                                                NULL, &fl);
-                       if (!rt) {
+                       dst = __ip_vs_route_output_v6(net, &dest->addr.in6,
+                                                     &dest->dst_saddr,
+                                                     do_xfrm);
+                       if (!dst) {
                                spin_unlock(&dest->dst_lock);
-                               IP_VS_DBG_RL("ip6_route_output error, dest: %pI6\n",
-                                            &dest->addr.in6);
                                return NULL;
                        }
-                       __ip_vs_dst_set(dest, 0, dst_clone(&rt->dst));
-                       IP_VS_DBG(10, "new dst %pI6, refcnt=%d\n",
-                                 &dest->addr.in6,
+                       rt = (struct rt6_info *) dst;
+                       cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+                       __ip_vs_dst_set(dest, 0, dst_clone(&rt->dst), cookie);
+                       IP_VS_DBG(10, "new dst %pI6, src %pI6, refcnt=%d\n",
+                                 &dest->addr.in6, &dest->dst_saddr,
                                  atomic_read(&rt->dst.__refcnt));
                }
+               if (ret_saddr)
+                       ipv6_addr_copy(ret_saddr, &dest->dst_saddr);
                spin_unlock(&dest->dst_lock);
        } else {
-               struct flowi fl = {
-                       .oif = 0,
-                       .nl_u = {
-                               .ip6_u = {
-                                       .daddr = cp->daddr.in6,
-                                       .saddr = {
-                                               .s6_addr32 = { 0, 0, 0, 0 },
-                                       },
-                               },
-                       },
-               };
-
-               rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
-               if (!rt) {
-                       IP_VS_DBG_RL("ip6_route_output error, dest: %pI6\n",
-                                    &cp->daddr.in6);
+               dst = __ip_vs_route_output_v6(net, &cp->daddr.in6, ret_saddr,
+                                             do_xfrm);
+               if (!dst)
                        return NULL;
-               }
+               rt = (struct rt6_info *) dst;
        }

        return rt;
@@ -248,6 +268,7 @@ int
 ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
                  struct ip_vs_protocol *pp)
 {
+       struct net *net = dev_net(skb->dev);
        struct rtable *rt;                      /* Route to the other host */
        struct iphdr  *iph = ip_hdr(skb);
        u8     tos = iph->tos;
@@ -263,7 +284,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, s

        EnterFunction(10);

-       if (ip_route_output_key(&init_net, &rt, &fl)) {
+       if (ip_route_output_key(net, &rt, &fl)) {
                IP_VS_DBG_RL("%s(): ip_route_output error, dest: %pI4\n",
                             __func__, &iph->daddr);
                goto tx_error_icmp;
@@ -313,25 +334,18 @@ int
 ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
                     struct ip_vs_protocol *pp)
 {
+       struct net *net = dev_net(skb->dev);
+       struct dst_entry *dst;
        struct rt6_info *rt;                    /* Route to the other host */
        struct ipv6hdr  *iph = ipv6_hdr(skb);
        int    mtu;
-       struct flowi fl = {
-               .oif = 0,
-               .nl_u = {
-                       .ip6_u = {
-                               .daddr = iph->daddr,
-                               .saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
-       };

        EnterFunction(10);

-       rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
-       if (!rt) {
-               IP_VS_DBG_RL("%s(): ip6_route_output error, dest: %pI6\n",
-                            __func__, &iph->daddr);
+       dst = __ip_vs_route_output_v6(net, &iph->daddr, NULL, 0);
+       if (!dst)
                goto tx_error_icmp;
-       }
+       rt = (struct rt6_info *) dst;

        /* MTU checking */
        mtu = dst_mtu(&rt->dst);
@@ -397,7 +411,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, stru
                IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
        }

-       if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(iph->tos))))
+       if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(iph->tos))))
                goto tx_error_icmp;

        /* MTU checking */
@@ -472,7 +486,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, s
                IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
        }

-       rt = __ip_vs_get_out_rt_v6(cp);
+       rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
        if (!rt)
                goto tx_error_icmp;

@@ -557,7 +571,6 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
        struct iphdr  *old_iph = ip_hdr(skb);
        u8     tos = old_iph->tos;
        __be16 df = old_iph->frag_off;
-       sk_buff_data_t old_transport_header = skb->transport_header;
        struct iphdr  *iph;                     /* Our new IP header */
        unsigned int max_headroom;              /* The extra header space needed */
        int    mtu;
@@ -572,7 +585,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
                goto tx_error;
        }

-       if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(tos))))
+       if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(tos))))
                goto tx_error_icmp;

        tdev = rt->dst.dev;
@@ -616,7 +629,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, s
                old_iph = ip_hdr(skb);
        }

-       skb->transport_header = old_transport_header;
+       skb->transport_header = skb->network_header;

        /* fix old IP header checksum */
        ip_send_check(old_iph);
@@ -670,9 +683,9 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
                     struct ip_vs_protocol *pp)
 {
        struct rt6_info *rt;            /* Route to the other host */
+       struct in6_addr saddr;          /* Source for tunnel */
        struct net_device *tdev;        /* Device to other host */
        struct ipv6hdr  *old_iph = ipv6_hdr(skb);
-       sk_buff_data_t old_transport_header = skb->transport_header;
        struct ipv6hdr  *iph;           /* Our new IP header */
        unsigned int max_headroom;      /* The extra header space needed */
        int    mtu;
@@ -687,17 +700,17 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
                goto tx_error;
        }

-       rt = __ip_vs_get_out_rt_v6(cp);
+       rt = __ip_vs_get_out_rt_v6(skb, cp, &saddr, 1);
        if (!rt)
                goto tx_error_icmp;

        tdev = rt->dst.dev;

        mtu = dst_mtu(&rt->dst) - sizeof(struct ipv6hdr);
-       /* TODO IPv6: do we need this check in IPv6? */
-       if (mtu < 1280) {
+       if (mtu < IPV6_MIN_MTU) {
                dst_release(&rt->dst);
-               IP_VS_DBG_RL("%s(): mtu less than 1280\n", __func__);
+               IP_VS_DBG_RL("%s(): mtu less than %d\n", __func__,
+                            IPV6_MIN_MTU);
                goto tx_error;
        }
        if (skb_dst(skb))
@@ -730,7 +743,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
                old_iph = ipv6_hdr(skb);
        }

-       skb->transport_header = old_transport_header;
+       skb->transport_header = skb->network_header;

        skb_push(skb, sizeof(struct ipv6hdr));
        skb_reset_network_header(skb);
@@ -750,8 +763,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
        be16_add_cpu(&iph->payload_len, sizeof(*old_iph));
        iph->priority           =       old_iph->priority;
        memset(&iph->flow_lbl, 0, sizeof(iph->flow_lbl));
-       iph->daddr              =       rt->rt6i_dst.addr;
-       iph->saddr              =       cp->vaddr.in6; /* rt->rt6i_src.addr; */
+       ipv6_addr_copy(&iph->daddr, &cp->daddr.in6);
+       ipv6_addr_copy(&iph->saddr, &saddr);
        iph->hop_limit          =       old_iph->hop_limit;

        /* Another hack: avoid icmp_send in ip_fragment */
@@ -791,7 +804,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struc

        EnterFunction(10);

-       if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(iph->tos))))
+       if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(iph->tos))))
                goto tx_error_icmp;

        /* MTU checking */
@@ -843,7 +856,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, st

        EnterFunction(10);

-       rt = __ip_vs_get_out_rt_v6(cp);
+       rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
        if (!rt)
                goto tx_error_icmp;

@@ -919,7 +932,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, str
         * mangle and send the packet here (only for VS/NAT)
         */

-       if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(ip_hdr(skb)->tos))))
+       if (!(rt = __ip_vs_get_out_rt(skb, cp, RT_TOS(ip_hdr(skb)->tos))))
                goto tx_error_icmp;

        /* MTU checking */
@@ -993,7 +1006,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb,
         * mangle and send the packet here (only for VS/NAT)
         */

-       rt = __ip_vs_get_out_rt_v6(cp);
+       rt = __ip_vs_get_out_rt_v6(skb, cp, NULL, 0);
        if (!rt)
                goto tx_error_icmp;

--
