From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and
 realservers (WORKING)
Date: Sat, 19 Jan 2008 00:26:53 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0801182328060.2854@u.domain.uli>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Raphael Vallazza <raphael@endian.com>
Cc: LVS Devel <lvs-devel@vger.kernel.org>, Wensong Zhang <wensong@linux-vs.org>, Horms <horms@verge.net.au>


	Hello,

On Thu, 10 Jan 2008, Raphael Vallazza wrote:

> Hello,
> 
> i wrote a very simple patch for ipvs that enables a kernel config  
> option that allows to choose where IPVS intercepts incoming  
> connections. These are the options:
> - LOCAL_IN (default: works as usual)
> - PRE_ROUTING (puts LVS input right after the mangle PREROUTING and  
> before the nat PREROUTING chain)
> 
> By selecting the PRE_ROUTING option transparent proxying is possible  
> (i've tried in DR and NAT mode), because packets are sent to real  
> servers before NAT, this way the realserver can do a DNAT/REDIRECT  
> etc. to send the packets to the proxy application. This also works for  
> the localnode, because packets go thru the PREROUTING after LVS, and  
> ther could be DNATed/REDIRECTed.

> I tried it on some test boxes and it seems to work pretty well, i'll  
> do some stress testing in the next few days. I could send you a setup  
> example if you like...

	Yes, can you explain with example (nodes, packets they send) what
happens with LOCAL_IN handling and what with PRE_ROUTING for your setup?

> The patch if for 2.6.22, but also applies on 2.6.24.
> 
> What's your opinion? :)

	I'm not sure that working before routing is acceptable for
most of the cases. Below are some notes for other parts of your
discussion and there are some things to check:

- when IPVS wants to reply with ICMP error icmp_send() is called which
should be called after routing (port unreachable, need to fragment).
The result: no error would be sent.

- Current kernels are not helpful for VIP-less directors, the ICMP
errors are not sent if VIP is not a local IP address.

- now IPVS exits POST_ROUTING chain to avoid NAT processing in netfilter.
Long time ago the problem was that ip_vs_ftp mangles FTP data and it was
disaster to pass IPVS packets in netfilter's hands. Now after many
changes in latest kernels I'm not sure what happens if netfilter sees
IPVS traffic in POST_ROUTING. Such change require testing of ip_vs_ftp
in both passive and active LVS-NAT mode, with different length of
IP address:port representation in FTP commands. It is the best test for
IPVS to see if netfilter additionally changes FTP packets leading to
wrong payload. Other tests include testing fragmentation (output device
with lower MTU in different forwarding methods, both for in->out and
out->in traffic).

- some users use local routes to deliver selected traffic for IPVS
scheduling. I think, this was one of the ways to route traffic to
real servers with transparent proxy support. I don't know your setup
and how exactly you are using transparent proxy.

	http://www.ssi.bg/~ja/LVS.txt has some outdated information
in different areas but it can be helpful:

- why IPVS uses specific hooks, what is the motivation

- gaols, such as:

	- IPVS traffic should be under QoS control (ingress)

	- IPVS traffic should be under routing control. It seems
	with your change IPVS will be the first module I see that
	will avoid input route for packets. It does not look very good.

	- IPVS traffic should be under firewall control (after filter)

	- IPVS scheduling by firewall mark

	I see that handling at PRE_ROUTING is faster but it works for
limited set of conditions: no MTU differences, no routing validation,
no ICMP errors. If DNAT is a problem, why? Are you using DNAT rules?

Regards

--
Julian Anastasov <ja@ssi.bg>
