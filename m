From: Jason Stubbs <j.stubbs@linkthink.co.jp>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Thu, 17 Apr 2008 12:25:54 +0900
Message-ID: <200804171225.54424.j.stubbs@linkthink.co.jp>
References: <200804151540.04006.j.stubbs@linkthink.co.jp> <200804161035.12575.j.stubbs@linkthink.co.jp> <Pine.LNX.4.58.0804161051400.2944@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0804161051400.2944@u.domain.uli>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: LVS Devel <lvs-devel@vger.kernel.org>

(No need to CC me anymore, please)

On Wednesday 16 April 2008 18:10:52 Julian Anastasov wrote:
> No TCP and sockets (skb->sk) when playing with IPVS. When IPVS runs
> you should take care for such issues:
>
> - do not play with packets accounted for sockets (skb->sk !=3D NULL).
> There was check you removed. Please, reconsider.

With this check restored, the director can't access the virtual server.=
 I=20
haven't found any solid documentation, but skb->sk seems to be the loca=
l=20
socket that the packet is tied to? Is there some badness that can happe=
n by=20
allowing these packets to be LVS'd?

> - ability to throttle IPVS traffic with netfilter modules. How
> we can benefit from such modules, can they protect us, can we avoid
> IPVS scheduling on overload (such modules should work before IPVS con=
n
> scheduling, which should be true if you schedule in POST_ROUTING).
> Was true for LOCAL_IN scheduling.

Are you referring to ipt_RECENT here? That module tested ok.

> - any work before input routing is dangerous (eg. PRE_ROUTING).
> There can be spoofed or looped traffic. For example, it is safer
> to work with replies, OTOH handling requests before input routing
> should be considered dangerous.

I hadn't really considered this... I can't see anything that could be=20
dangerous looking through ip_vs_out and ip_vs_out_icmp. With current LV=
S,=20
rp_filter should prevent spoofed packets from getting through as the VI=
P is=20
on a local interface. I guess with VIP-less director + LVS-NAT, spoofed=
=20
packets would need to be be handled with a rule such as:

iptables -t raw -I PREROUTING -i ${EXT_DEV} -s ${VIP} -j DROP

> - one thing should be checked: what state is shown in Netfilter
> when UDP and TCP packets are scheduled. I see that at POST_ROUTING
> ipv4_confirm() is called, then __nf_conntrack_confirm() calls
> nf_ct_get() which should work with translated addresses (by IPVS).
> You should see that netfilter correctly marks traffic as confirmed.
> Also, you can confirm that states are properly set by applying
> NEW rules for requests and then only ESTABLISHED,RELATED in
> FORWARD. I think, you once tested it with -m state rules but
> make sure it works after recent (any new) changes because this
> is essential part.

Yep, this all still works.

> It is interesting what is -m state in Netfilter when=20
> no replies are forwarded for LVS-DR setups, replies go directly
> from real server to client. Are you sure long established connections
> do not timeout shorter due to bad state in netfilter? May be
> conntrack_tcp will be confused that only one direction works?

This is currently working, but shouldn't be. When forwarding to a regul=
ar=20
server via the LVS box, a conntrack entry in the SYN_SENT state is set =
up and=20
no further traffic is allowed. When forwarding for a VIP, traffic is fl=
owing=20
through regardless of whether there's a conntrack entry or not. It must=
 be=20
something that ip_vs_out is doing so I'll look into it a little more an=
d try=20
to fix it.

> - when testing LVS-NAT make sure client does not see directly the
> internal hosts. This can happen when testing on LAN. It is possible
> something to work on LAN but not when client is out of LAN because
> sometimes packets do not flow as expected but client and real servers
> still talk successfully by avoiding IPVS box. No reply traffic passes
> IPVS box and nothing is REJECT-ed in FORWARD. But it should be
> noticed by broken TCP connections, I think.

I've set net.ipv4.conf.all.send_redirects=3D0 and am using host routes =
to make=20
sure the traffic is going where I intend it to. The client and real ser=
ver=20
are on two separate LANs connected by both a regular router and the LVS=
 test=20
box.

> - there are setups that use LVS-DR but replies come in IPVS box
> because it is gateway for the real servers. This is useful feature
> because VIP is preserved in packet allowing virtual hosts to work
> by IP. It means replies should be passed in IPVS box with the help
> from forward_shared patch.

I can't say anything for sure until I've fixed the above bug, but connt=
rack=20
_should_ work fine with LVS-DR when the director is also the gateway.

> - ICMP generation: when VIP is not configured as IP address
> icmp_send() currently will use some local address as source for
> the ICMP error sent to client. Even if this is not a big problem for
> clients out of LAN, on some setups when non-Linux clients are on LAN
> this can be confusing, there are expectations that multiple
> subnets share single LAN without a problem (clients know only
> the VIP subnet, for example). But this is more an icmp_send() problem=
=2E

Yep, you're right. However, with my patch the director doesn't appear t=
o be=20
the virtual server (aka no arp replies) so clients should be expecting =
this=20
possibility. For my patch to be useful in this case, I'd need to allow =
for=20
the VIP being bound to a local interface.

Thanks for reviewing by the way. It's definitely giving me more confide=
nce.

--=20
Jason Stubbs <j.stubbs@linkthink.co.jp>
LINKTHINK INC.
=E6=9D=B1=E4=BA=AC=E9=83=BD=E6=B8=8B=E8=B0=B7=E5=8C=BA=E6=A1=9C=E3=83=B6=
=E4=B8=98=E7=94=BA22-14 N.E.S S=E6=A3=9F 3F
TEL 03-5728-4772  FAX 03-5728-4773
