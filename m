From: Raphael Vallazza <raphael@endian.com>
Subject: Re: [PATCH] Transparent proxy support for LVS with localnode and realservers (WORKING)
Date: Sun, 20 Jan 2008 10:41:51 +0100
Message-ID: <59D1E185-12C3-43E5-AD63-F56583E4BBB3@endian.com>
References: <C704FCFC-455C-4CFC-AB8C-51604D3CF844@endian.com> <Pine.LNX.4.58.0801182328060.2854@u.domain.uli>
Mime-Version: 1.0 (Apple Message framework v915)
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0801182328060.2854@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"; delsp="yes"
To: Julian Anastasov <ja@ssi.bg>

Hello,

>> I tried it on some test boxes and it seems to work pretty well, i'll
>> do some stress testing in the next few days. I could send you a setup
>> example if you like...
>
> 	Yes, can you explain with example (nodes, packets they send) what
> happens with LOCAL_IN handling and what with PRE_ROUTING for your  
> setup?


This is my current setup:
VIP (Node1): 192.168.66.1
Node1/Director+Realserver: 192.168.254.1
Node2/Realserver: 192.168.254.2
CIP: 192.168.66.150

Node1 and Node2 have squid running on port 8080. On Node1  
(192.168.66.1) IPVS has a service
configured in DR mode using fwmark that balances traffic to  
192.168.254.1 (local) and 192.168.254.2 (direct routing).


>> The patch if for 2.6.22, but also applies on 2.6.24.
>>
>> What's your opinion? :)
>
> 	I'm not sure that working before routing is acceptable for
> most of the cases. Below are some notes for other parts of your
> discussion and there are some things to check:
>
> - when IPVS wants to reply with ICMP error icmp_send() is called which
> should be called after routing (port unreachable, need to fragment).
> The result: no error would be sent.
>
> - Current kernels are not helpful for VIP-less directors, the ICMP
> errors are not sent if VIP is not a local IP address.
>
> - now IPVS exits POST_ROUTING chain to avoid NAT processing in  
> netfilter.
> Long time ago the problem was that ip_vs_ftp mangles FTP data and it  
> was
> disaster to pass IPVS packets in netfilter's hands. Now after many
> changes in latest kernels I'm not sure what happens if netfilter sees
> IPVS traffic in POST_ROUTING. Such change require testing of ip_vs_ftp
> in both passive and active LVS-NAT mode, with different length of
> IP address:port representation in FTP commands. It is the best test  
> for
> IPVS to see if netfilter additionally changes FTP packets leading to
> wrong payload. Other tests include testing fragmentation (output  
> device
> with lower MTU in different forwarding methods, both for in->out and
> out->in traffic).
>
> - some users use local routes to deliver selected traffic for IPVS
> scheduling. I think, this was one of the ways to route traffic to
> real servers with transparent proxy support. I don't know your setup
> and how exactly you are using transparent proxy.
>
> 	http://www.ssi.bg/~ja/LVS.txt has some outdated information
> in different areas but it can be helpful:
>
> - why IPVS uses specific hooks, what is the motivation
>
> - gaols, such as:
>
> 	- IPVS traffic should be under QoS control (ingress)
>
> 	- IPVS traffic should be under routing control. It seems
> 	with your change IPVS will be the first module I see that
> 	will avoid input route for packets. It does not look very good.
>
> 	- IPVS traffic should be under firewall control (after filter)
>
> 	- IPVS scheduling by firewall mark
>
> 	I see that handling at PRE_ROUTING is faster but it works for
> limited set of conditions: no MTU differences, no routing validation,
> no ICMP errors. If DNAT is a problem, why? Are you using DNAT rules?

Ok, i understand your concerns. Hopefully there is a better solution  
for my setup...

In order to get transparent proxy working i have to DNAT/REDIRECT the  
traffic with destination port 80 to destination localhost:8080, and  
this is the problem:
- If i DNAT the packets on Node1, then it only works on localnode,  
because Node2 replies to the client with source port 8080 instead of  
80 (Node2 is not aware that Node1 NATed the packets)
- If i use Node1 as gateway instead of setting direct routes on Node2  
then Node1 rejects the packets, because it recieves packets from Node2  
with source ip 192.168.66.1, the same IP Node1 has.

Example of DNAT problem:

* Destination localnode (works):
- Client: sends 192.168.66.150 -> 100.100.100.100:80
- Node 1: DNAT packet to 127.0.0.1:8080
- IPVS: intercepts the connection and accepts the packet
- Squid recieves the packet
- Node 1: reply to Client 192.168.66.150 with source port  
192.168.66.1:80

* Destination Node 2:
- Client: sends 192.168.66.150 -> 100.100.100.100:80
- Node 1: DNAT packet to 127.0.0.1:8080
- IPVS: intercepts the connection and sends it to Node 2 via direct  
routing
- Node 2: DNAT packet from 192.168.66.1:8080 to 127.0.0.1:8080 (i use  
DNAT to solve the arp issues)
- Squid recieves the packet
- Node 2: reply to Client 192.168.66.150 with source port  
192.168.66.1:8080 (wrong port, Node 1 DNATed the packet!)

The only solution i've found was the PREROUTING one, this way DNAT can  
be done on the realserver (either Node1 or Node2) and it works on both  
nodes.

I hope the example is clear.

Thanks,
Raphael

-- 

:: e n d i a n
:: open source - open minds

:: raphael vallazza
:: phone +39 0471 631763  :: fax +39 0471 631764
:: http://www.endian.com  :: raphael (AT) endian.com
