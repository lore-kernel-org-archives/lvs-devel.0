From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Wed, 16 Apr 2008 12:10:52 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804161051400.2944@u.domain.uli>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
 <200804151541.17117.j.stubbs@linkthink.co.jp> <200804161035.12575.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804161035.12575.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: LVS Devel <lvs-devel@vger.kernel.org>


	Hello,

On Wed, 16 Apr 2008, Jason Stubbs wrote:

> On Tuesday 15 April 2008 15:41:17 Jason Stubbs wrote:
> > I am also not certain of how traffic control will handle this. This
> > patch may be causing traffic to be accounted for twice depending on when
> > tcp_output is actually run.
> 
> I got confused between TCP congestion control and qdiscs here. Congestion 
> control is before netfilter and thus unaffected. Qdiscs run directly on 
> interfaces after netfilter has completed and so is also unaffected.

	Yes, QoS is before (ingress) and after (egress) any IP hooks.
No TCP and sockets (skb->sk) when playing with IPVS. When IPVS runs
you should take care for such issues:

- do not play with packets accounted for sockets (skb->sk != NULL).
There was check you removed. Please, reconsider.

- ability to throttle IPVS traffic with netfilter modules. How
we can benefit from such modules, can they protect us, can we avoid
IPVS scheduling on overload (such modules should work before IPVS conn
scheduling, which should be true if you schedule in POST_ROUTING).
Was true for LOCAL_IN scheduling.

- any work before input routing is dangerous (eg. PRE_ROUTING).
There can be spoofed or looped traffic. For example, it is safer
to work with replies, OTOH handling requests before input routing
should be considered dangerous.

- one thing should be checked: what state is shown in Netfilter
when UDP and TCP packets are scheduled. I see that at POST_ROUTING
ipv4_confirm() is called, then __nf_conntrack_confirm() calls
nf_ct_get() which should work with translated addresses (by IPVS).
You should see that netfilter correctly marks traffic as confirmed.
Also, you can confirm that states are properly set by applying
NEW rules for requests and then only ESTABLISHED,RELATED in
FORWARD. I think, you once tested it with -m state rules but
make sure it works after recent (any new) changes because this
is essential part. It is interesting what is -m state in Netfilter when
no replies are forwarded for LVS-DR setups, replies go directly
from real server to client. Are you sure long established connections
do not timeout shorter due to bad state in netfilter? May be
conntrack_tcp will be confused that only one direction works?

- when testing LVS-NAT make sure client does not see directly the
internal hosts. This can happen when testing on LAN. It is possible
something to work on LAN but not when client is out of LAN because
sometimes packets do not flow as expected but client and real servers
still talk successfully by avoiding IPVS box. No reply traffic passes
IPVS box and nothing is REJECT-ed in FORWARD. But it should be
noticed by broken TCP connections, I think.

- there are setups that use LVS-DR but replies come in IPVS box
because it is gateway for the real servers. This is useful feature
because VIP is preserved in packet allowing virtual hosts to work
by IP. It means replies should be passed in IPVS box with the help
from forward_shared patch.

- ICMP generation: when VIP is not configured as IP address
icmp_send() currently will use some local address as source for
the ICMP error sent to client. Even if this is not a big problem for 
clients out of LAN, on some setups when non-Linux clients are on LAN
this can be confusing, there are expectations that multiple 
subnets share single LAN without a problem (clients know only
the VIP subnet, for example). But this is more an icmp_send() problem.

Regards

--
Julian Anastasov <ja@ssi.bg>
