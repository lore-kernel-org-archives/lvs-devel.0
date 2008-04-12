From: Julian Anastasov <ja@ssi.bg>
Subject: Re: moving ipvs() to POST/PREROUTING
Date: Sat, 12 Apr 2008 12:07:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804121021110.2942@u.domain.uli>
References: <200804111400.12331.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804111400.12331.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jason Stubbs <j.stubbs@linkthink.co.jp>
Cc: LVS Devel <lvs-devel@vger.kernel.org>


	Hello,

On Fri, 11 Apr 2008, Jason Stubbs wrote:

> Greetings,
> 
> Ok, things are mostly working now. The patch is a little messy as in there's 
> old comments remaining and function names are left as is, but hopefully 
> reviewable. If it's not, I'll split it up and add appropriate comments...

	Your changes will break existing setups. I'll recommend
you to start by reading http://www.ssi.bg/~ja/LVS.txt. I just updated
it with some 2.6 info as it was too old document. There you can
see some requirements and motivation why IPVS uses specific hooks and
priority.

	I think, for such changes there are many things to be considered
and carefully tested:

- all forwarding methods can be tested on LAN, even LVS-TUN
- forwarding of related ICMP traffic (ICMP errors) in both directions,
for all methods
- ICMP generation to both sides (client and real server): when there is no 
real server, when skb is longer than PMTU.
- scheduling by nfmark
- firewall: at least basic packet fields matching
- ip_vs_ftp testing (LVS-NAT) when netfilter ftp module is in
effect: test if double NAT happens resulting in broken packets (TCP 
sequence numbers or payload) when payload is changed if IP:PORT
strings in FTP commands have different length (VIP and RIP).

	Note that there are many new changes in Netfilter and
Networking after IPVS was included in early 2.6. Even I already don't know 
what happens in latest kernels for POST_ROUTING, with fragmentation, etc. 
May be some things work by luck because IPVS tries to work closely with 
Netfilter without breaking things. That is why a careful testing is needed
for any new changes if such changes are planned for inclusion in kernel.

> With local node, 127.0.0.1 doesn't work but an IP address on a local interface 
> does. When the address is 127.0.0.1, the SYN makes it all the way through 
> INPUT, but the SYN/ACK doesn't come into OUTPUT. Something to investigate 
> further... Also, null_xmit doesn't work as ipvs_in is being done in 
> POSTROUTING, so I've simple aliased LOCAL to MASQ for the time being.

	LOCAL replaced with MASQ? Such changes can not be accepted for 
inclusion, they break existing setups just because something does not 
work in your new way to handle things. You should always remember that 
there must be a reason some code to exist. If you really want to modify 
IPVS I'll recommend you to create some short document that explains:

- how do you plan out->in (ip_vs_in) and in->out (ip_vs_out) packets
to traverse netfilter hooks, when addresses, ports and payload are
modified (ip_vs_ftp)

- what setups you are going to break because you consider them as
not used anymore

- use defines/configuration options to preserve old handling for
existing setups.

	If your changes are not planned for inclusion you can do
whatever you want, of course.

> What I haven't tested:
> * LVS-TUN
> * ICMP for LVS-NAT

	You can test if related ICMP errors are forwarded by
adding REJECT-with-ICMP rules in client and real server.

> * IP_VS_CONN_F_BYPASS - what is this?

	IP_VS_CONN_F_BYPASS is used for transparent proxy setups when
real server (cache server) is not present and we should forward the 
traffic to original destination. The idea is request still to be served.
In such case IPVS traffic uses the original destination instead of real 
server.

> I realized I haven't explained at all why I chose POST/PRE as the hook points. 
> Firstly the cropped output from a LOG target in every mangle table for the 
> SYN SYN/ACK of a LVS-NAT connection:
> 
> PREROUTING IN=eth0 OUT= SRC=192.168.0.104 DST=192.168.0.SYN
> FORWARD IN=eth0 OUT=eth0 SRC=192.168.0.104 DST=192.168.0.7 SYN
> POSTROUTING IN= OUT=eth0 SRC=192.168.0.104 DST=192.168.0.7 SYN
> POSTROUTING IN= OUT=eth1 SRC=192.168.0.104 DST=192.168.1.3 SYN
> 
> PREROUTING IN=eth1 OUT= SRC=192.168.0.7 DST=192.168.0.104 ACK SYN
> FORWARD IN=eth1 OUT=eth0 SRC=192.168.0.7 DST=192.168.0.104 ACK SYN
> POSTROUTING IN= OUT=eth0 SRC=192.168.0.7 DST=192.168.0.104 ACK SYN
> 
> 192.168.0.104 is the client, 192.168.0.7 is the VIP and 192.168.1.3 is the 
> real server. Other than the second POSTROUTING entry on the SYN side, 
> netfilter isn't dealing with the real server's IP at all. This will 
> theoretically make writing firewall rules much easier and also limits what 
> netfilter's conntracking has to deal with.
> 
> Actually, I don't know why the second POSTROUTING entry is there at all. It 
> seems that after the packet is injected into the end of POSTROUTING, a 
> routing decision is being made again and POSTROUTING is rerun. Preferable the 
> packet would go straight out the appropriate interface after ipvs_in is run.

	Not sure what happens, it is a good idea to put some printk()s
in netfilter (eg. hooks) when testing IPVS changes.

> Similar behaviour happens with a local node:
> 
> PREROUTING IN=eth0 OUT= SRC=192.168.0.104 DST=192.168.0.7 SYN
> FORWARD IN=eth0 OUT=eth0 SRC=192.168.0.104 DST=192.168.0.7 SYN
> POSTROUTING IN= OUT=eth0 SRC=192.168.0.104 DST=192.168.0.7 SYN
> POSTROUTING IN= OUT=lo SRC=192.168.0.104 DST=192.168.0.5 SYN
> PREROUTING IN=lo OUT= SRC=192.168.0.104 DST=192.168.0.5 SYN
> INPUT IN=lo OUT= SRC=192.168.0.104 DST=192.168.0.5 SYN
> 
> OUTPUT IN= OUT=eth0 SRC=192.168.0.7 DST=192.168.0.104 ACK SYN
> POSTROUTING IN= OUT=eth0 SRC=192.168.0.7 DST=192.168.0.104 ACK SYN
> 
> 192.168.0.5 is an IP local to the director. I had to add the ipvs_out hooks to 
> the beginning of OUTPUT as the local reply never hits PREROUTING. Again with 
> the above, I'd prefer the POST/PRE/INPUT disappear.

	Why? I don't think it is possible without changes in Netfilter.
There are some issues that prevent IPVS to benefit from Netfilter
connection tracking:

- Netfilter's NAT and routing are not in single place (hook), difficult to
handle LVS-DR
- Netfilter can re-route sometimes (eg. after mangle), it can cause
properly routed LVS-DR traffic to fail.
- Double NAT for ip_vs_ftp

> Anyway, that's pretty much my intention. Is there any problem with essentially 
> hiding the real servers from netfilter? Is there a way to get the packet out 
> of the netfilter loop earlier?

	IPVS traffic should not be NAT-ed by Netfilter. This double-NAT
leads to broken packets as I already mentioned above.

	What I do not understand is what is the end goal for your
changes? Speed or IPVS traffic to fully benefit from Netfilter features?
Or some setup does not work?

Regards

--
Julian Anastasov <ja@ssi.bg>
