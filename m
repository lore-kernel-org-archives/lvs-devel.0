From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 1/2] IPVS Bug IPv6 extension header handling faulty.
Date: Fri, 2 Mar 2012 13:18:17 +0100
Message-ID: <201203021318.18715.hans@schillstrom.com>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com> <201202230834.24254.hans@schillstrom.com> <alpine.LFD.2.00.1202231012260.1481@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1202231012260.1481@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Hello Julian
On Thursday, February 23, 2012 10:03:52 Julian Anastasov wrote:
> 
> 	In the case after calling ip_vs_lookup_real_service
> is it correct to reject non-first fragment with
> ICMPV6_PORT_UNREACH, is that allowed? May be we should
> avoid sending ICMP errors to non-first fragment, what
> is the right thing to do?
> 

I have big problems with some "corner cases" with ICMPv6
the localhost thing makes it real hard to determine where to send ...

From a good source I've heard that this is your thing :-)

I'm testing ICMPv6 packet to big right now. 
mtu 1500 on incoming iface eth0  and mtu 1460 on outgoing (eth0)

For some reason the mtu check in ip_vs_nat_xmit_v6() does not hit,
	/* MTU checking */
	mtu = dst_mtu(&rt->dst);
	if (skb->len > mtu && !skb_is_gso(skb)) {

instead we got an ICMP from the stack that hits hook "NF_INET_LOCAL_OUT"
-> IPVS: Incoming ICMPv6 hooknr:3 (2,0) 1001::1->2003::3:0:13
And then everything get screwed up 

It works if you got a tunnel, and with some tricks to localhost  VS/DR and VS/TUN

I don't really know how to solve this issue,
- should we force a pmtu discovery for new dst:s ?
- try do fix every possible combination in ip_vs_in_icmp_v6() ?

ip_vs_in_icmp_v6() will be a monster if we try to solve every thing there
But if we can set a localhost flag in the cp it would help a lot.

I started with the "local RS" VS/DR and VS/TUN case and made some hack in it

	/*
	 * The embedded headers contain source and dest in reverse order
	 * if not from localhost
	 */
	cp = pp->conn_in_get(AF_INET6, skb, &ciph,
			     (hooknum == NF_INET_LOCAL_OUT) ? 0 :1);

	if (!cp)
		return NF_ACCEPT;
	/* VS/TUN, VS/DR and LOCALNODE just let it go */
	if (hooknum == NF_INET_LOCAL_OUT && IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
		return NF_ACCEPT;


--- Here is some logs etc. ---

With this plain setup:
Tester 2003::3:0:13  --> router --> (eth1)-ipvs-(eth0) <--> RS-nat at 2003::1:0:5

IPVS details 

UDP  [1001::1]:5001 rr
  -> [2003::1:0:5]:5001           Masq    1      0          0         


~ # ifconfig 
eth0      Link encap:Ethernet  HWaddr 00:00:00:01:01:01  
          inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::200:ff:fe01:101/64 Scope:Link
          inet6 addr: 2003::1:0:1/96 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1

eth1      Link encap:Ethernet  HWaddr 00:00:02:01:01:01  
          inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::200:2ff:fe01:101/64 Scope:Link
          inet6 addr: 2003::2:0:1/96 Scope:Global
          inet6 addr: 1001::1/128 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1


Packet from tester to ipvs 
12:28:20.157968 00:00:02:01:01:11 > 00:00:02:01:01:01, ethertype IPv6 (0x86dd), length 1510: 2003::3:0:13 > 1001::1: frag (0|1448) 38668 > commplex-link: UDP, length 1470
12:28:20.157975 00:00:02:01:01:11 > 00:00:02:01:01:01, ethertype IPv6 (0x86dd), length 92: 2003::3:0:13 > 1001::1: frag (1448|30)

As you can see ICMP goes to the RS and not as expected to the "tester"
12:28:20.354056 00:00:00:01:01:01 > 00:00:00:01:01:05, ethertype IPv6 (0x86dd), length 1294: 1001::1 > 2003::1:0:5: ICMP6, packet too big, mtu 1460, length 1240


[  264.644538] IPVS: Fragment recv prop:0
[  264.644538] IPVS: Enter: ip_vs_out, /opt/src/ericsson/Evip/kvm/net-next.git/net/netfilter/ipvs/ip_vs_core.c line 1095
[  264.648538] IPVS: lookup/out UDP [2003::3:0:13]:38668->[1001::1]:5001 not hit
[  264.652538] ip_vs_out: packet continues traversal as normal: UDP [2003::3:0:13]:38668->[1001::1]:5001 next-hdr=17 frag.id=0xf8fbd64a
[  264.652539] IPVS: lookup/in UDP [2003::3:0:13]:38668->[1001::1]:5001 not hit
[  264.656539] IPVS: lookup service: fwm 0 UDP [1001::1]:5001 hit
[  264.656539] IPVS: ip_vs_rr_schedule(): Scheduling...
[  264.656539] IPVS: RR: server [2003::1:0:5]:5001 activeconns 0 refcnt 1 weight 1
[  264.660539] IPVS: Bind-dest UDP c:[2003::3:0:13]:38668 v:[1001::1]:5001 d:[2003::1:0:5]:5001 fwd:M s:0 conn->flags:100 conn->refcnt:1 dest->refcnt:2
[  264.660539] IPVS: Schedule fwd:M c:[2003::3:0:13]:38668 v:[1001::1]:5001 d:[2003::1:0:5]:5001 conn->flags:140 conn->refcnt:2
[  264.664539] Incoming packet: UDP [2003::3:0:13]:38668->[1001::1]:5001 next-hdr=17 frag.id=0xf8fbd64a
[  264.668540] IPVS: Enter: ip_vs_nat_xmit_v6, /opt/src/ericsson/Evip/kvm/net-next.git/net/netfilter/ipvs/ip_vs_xmit.c line 640
[  264.668540] IPVS: new dst 2003:0000:0000:0000:0000:0001:0000:0005, src 2003:0000:0000:0000:0000:0001:0000:0001, refcnt=2
Here it goes wrong
[  264.672540] IPVS: Incoming ICMPv6 3(2,0) 1001::1->2003::3:0:13
[  264.672540] IPVS: ICMPv6 [2003::3:0:13]:38668->[1001::1]:5001 pr:17  io:48 len:96
[  264.676540] Checking incoming ICMPv6 for: UDP [2003::3:0:13]:38668->[1001::1]:5001 next-hdr=17 frag.id=0xf8fbd64a
[  264.704542] IPVS: lookup/in UDP [2003::3:0:13]:38668->[1001::1]:5001 hit
[  264.704542] IPVS: Enter: ip_vs_icmp_xmit_v6, /opt/src/ericsson/Evip/kvm/net-next.git/net/netfilter/ipvs/ip_vs_xmit.c line 1273
[  264.708542] IPVS: *** 1001::1->2003::3:0:13 nh:58 type/code:2/0
[  264.708542] IPVS: *** 2003::3:0:13->1001::1 nh:44 proto:17 offs:40/96
[  264.712542] IPVS: *** spprt:38668 -> dport:5001
[  264.712542] IPVS: ip_vs_nat_icmp_v6() changed port 38668 to 5001
[  264.712542] Forwarding altered incoming ICMPv6: UDP [2003::1:0:5]:5001->[1001::1]:5001 next-hdr=17 frag.id=0xf8fbd64a
[  264.716542] IPVS: Incoming ICMPv6 3(135,0) fe80::200:ff:fe01:101->ff02::1:ff00:5
[  264.716543] IPVS: Leave: ip_vs_icmp_xmit_v6, /opt/src/ericsson/Evip/kvm/net-next.git/net/netfilter/ipvs/ip_vs_xmit.c line 1375
[  264.720543] ip_vs_nat_xmit_v6(): frag needed for: UDP [2003::3:0:13]:38668->[1001::1]:5001 next-hdr=17 frag.id=0xf8fbd64a
[  264.724543] IPVS: Leave: ip_vs_nat_xmit_v6, /opt/src/ericsson/Evip/kvm/net-next.git/net/netfilter/ipvs/ip_vs_xmit.c line 739

Regards
Hans Schillstrom
