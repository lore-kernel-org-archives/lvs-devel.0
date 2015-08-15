From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 00/12] ipvs: Add icmp scheduling
Date: Sat, 15 Aug 2015 18:18:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1508151815580.20236@ja.home.ssi.bg>
References: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1439412430-1702375-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team@fb.com, alexgartrell@gmail.com


	Hello,

On Wed, 12 Aug 2015, Alex Gartrell wrote:

> The configuration of ipvs at Facebook is relatively straightforward.  All
> ipvs instances bgp advertise a set of VIPs and the network prefers the
> nearest one or uses ECMP in the event of a tie.  For the uninitiated, ECMP
> deterministically and statelessly load balances by hashing the packet
> (usually a 5-tuple of protocol, saddr, daddr, sport, and dport) and using
> that number as an index (basic hash table type logic).
> 
> The problem is that ICMP packets (which contain really important
> information like whether or not an MTU has been exceeded) will get a
> different hash value and may end up at a different ipvs instance.  With no
> information about where to route these packets, they are dropped, creating
> ICMP black holes and breaking Path MTU discovery.  Suddenly, my mom's
> pictures can't load and I'm fielding midday calls that I want nothing to do
> with.
> 
> To address this, this patch set introduces the ability to schedule icmp
> packets which is gated by a sysctl net.ipv4.vs.schedule_icmp.  If set to 0,
> the old behavior is maintained -- otherwise ICMP packets are scheduled.
> 
> Alex Gartrell (12):
>   ipvs: pull out ip_vs_try_to_schedule function
>   ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
>   ipvs: Add hdr_flags to iphdr
>   ipvs: drop inverse argument to conn_{in,out}_get
>   ipvs: Make ip_vs_schedule aware of inverse iph'es
>   ipvs: add schedule_icmp sysctl
>   ipvs: Use outer header in ip_vs_bypass_xmit_v6
>   ipvs: attempt to schedule icmp packets
>   ipvs: ensure that ICMP cannot be sent in reply to ICMP
>   ipvs: support scheduling inverse and icmp TCP packets
>   ipvs: support scheduling inverse and icmp UDP packets
>   ipvs: support scheduling inverse and icmp SCTP packets

	What is missing in this patchset is a change to ip_vs_sh.c

Patch 1:
	- we always provide offset 0 here:
IP_VS_DBG_PKT(7, af, pp, skb, 0, "unhandled fragment");

	We may need to add 'offset' field to struct ip_vs_iphdr,
so that we can provide valid offset to the IP_VS_DBG_PKT and
IP_VS_DBG_RL_PKT macros. We do not provide inverse flag to the
pp->debug_packet handler but it is not so fatal.

Patch 2:

- ip_vs_out_icmp_v6: first args of ip_vs_fill_iph_skb_off can be on
same line

- ip_vs_in_icmp: any good reason the ip_vs_fill_iph_skb_off call to
be moved early? Better to keep it at the ip_vs_fill_ip4hdr's place.
It is still before the conn_in_get call.

- ip_vs_in_icmp: this line should not be removed:
	"-	offset = ciph.len;"

	because offset is used later as arg to ip_vs_icmp_xmit.
	offset provides offset to header but we later need to
	skip this header and to reach the ports in transport header.

- ip_vs_in_icmp_v6: we better to rename offs_ciph to offset and
later to use it where 'writable' is used, then code will look like
ip_vs_in_icmp

Patch 3:

- breaks compilation of net/netfilter/ipvs/ip_vs_pe_sip.c and
net/netfilter/xt_ipvs.c

- do not forget that net/netfilter/xt_ipvs.c has calls to
ip_vs_fill_iph_skb and conn_out_get, include it in your .config
for building:
	make net/netfilter/ipvs/ net/netfilter/xt_ipvs.o

- ip_vs_fill_iph_skb_off: if we later add more flags? Should we
provide instead just a hdr_flags arg with IP_VS_HDR_* mask?

- ip_vs_out_icmp_v6: first args for ip_vs_fill_iph_skb_icmp
should be on same line

- ip_vs_in_icmp_v6: first args for ip_vs_fill_iph_skb_icmp
should be on same line

- ip_vs_in_icmp_v6: I now see that this check from
commit 2f74713d1436 ("ipvs: Complete IPv6 fragment handling for IPVS")
'(hooknum == NF_INET_LOCAL_OUT) ? 0 : 1' is simply wrong for
local clients, we should always use 'true' instead of
(hooknum != NF_INET_LOCAL_OUT).

Patch 4:

- breaks compilation of net/netfilter/xt_ipvs.c

- ip_vs_schedule: first hunk shows that we provide inverse=1
to conn_in_get. This is the only odd place that does such
inverse check. May be we can change the bit before and after
conn_in_get?:

	if (!skb->dev || skb->dev->flags & IFF_LOOPBACK) {
		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
		cp = pp->conn_in_get(svc->af, skb, iph);
		iph->hdr_flags ^= IP_VS_HDR_INVERSE;
		if (cp) {
			IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
				      "Not scheduling reply for existing "
				      "connection");
			__ip_vs_conn_put(cp);
			return NULL;
		}
	}

Patch 5:

- ip_vs_schedule: we should provide iph->offset as arg to IP_VS_DBG_PKT

Patch 6: OK

Patch 7: OK

Patch 8:

- ip_vs_in_icmp: may be we can avoid 2nd !cp check as follows?:
	if (!cp) {
		int v;

		if (!sysctl_schedule_icmp(net_ipvs(net)))
			return NF_ACCEPT;
		if (!ip_vs_try_to_schedule(AF_INET, skb, pd, &v, &cp, &ciph))
			return v;
		new_cp = true;
	}

- same for ip_vs_in_icmp_v6

Patch 9: OK

Patch 10:

- use {} after else if the 'if' part has {}

Patch 11:

- use {} after else if the 'if' part has {}

Patch 12:

- use {} after else if the 'if' part has {}

Regards

--
Julian Anastasov <ja@ssi.bg>
