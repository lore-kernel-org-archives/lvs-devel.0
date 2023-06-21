From: Julian Anastasov <ja@ssi.bg>
Subject: Re: vs conntrack changes TCP ports mid-stream
Date: Wed, 21 Jun 2023 21:26:19 +0300 (EEST)
Message-ID: <649aa643-18ca-b758-203e-e674c215799d@ssi.bg>
References: <d3c93e6a-f8a0-5c72-d044-dcec7d8d235c@weltraumschlangen.de>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <d3c93e6a-f8a0-5c72-d044-dcec7d8d235c@weltraumschlangen.de>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Bartscher <sven.bartscher@weltraumschlangen.de>
Cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Wed, 21 Jun 2023, Sven Bartscher wrote:

> I'm forwarding the report from
> https://bugzilla.netfilter.org/show_bug.cgi?id=1669 here, since it was pointed
> out there, that this list would be more appropriate.
> 
> When using an ipvs service in combination with SNAT and a NOTRACK rule,
> specific circumstances can lead to TCP ports of packets being changed
> mid-stream, which results in successful connections that no data can be
> effectively sent over.
> 
> Consider the following example:
> 
> ```
> root@router:~# sysctl net.ipv4.vs.conntrack
> net.ipv4.vs.conntrack = 1
> 
> root@router:~# iptables -t raw -L -n -v
> Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source destination
>    24  1296 CT         tcp  --  enp1s0 *       0.0.0.0/0 10.0.0.1
> tcp dpt:1234 NOTRACK
> 
> root@router:~# iptables -t nat -L -n -v
> Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source destination
> 
> Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source destination
> 
> Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source destination
> 
> Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source destination
>     4   240 SNAT       all  --  *      *       10.0.0.0/24 10.0.1.0/24
> to:10.0.1.1
> 
> Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source destination
> 
> root@router:~# ipvsadm -L -n
> IP Virtual Server version 1.2.1 (size=4096)
> Prot LocalAddress:Port Scheduler Flags
>   -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
> TCP  10.0.0.1:1234 rr
>   -> 10.0.1.2:1234                Masq    1      0          0
>   -> 10.0.1.3:1234                Masq    1      0          0
> ```
> 
> The reals servers are running
> 
> ```
> socat TCP4-LISTEN:1234,fork 'EXEC:sh -c
> echo${IFS}hello;read${IFS}r${IFS}L;sleep${IFS}1'
> ```
> 
> We dump the network traffic between the router and client on the ipvs router
> as follows:
> 
> ```
> root@router:~# tcpdump -pXXni enp1s0 icmp or tcp -w /tmp/ipvs_port_reuse.pcap
> tcpdump: listening on enp1s0, link-type EN10MB (Ethernet), capture size 262144
> bytes
> ^C16 packets captured
> 16 packets received by filter
> 0 packets dropped by kernel
> ```
> 
> While the capture is running, we run the following commands on a client to
> trigger the buggy behavior:
> 
> ```
> root@debian:~# netcat -p 4321 -v 10.0.01 1234
> Connection to 10.0.01 1234 port [tcp/*] succeeded!
> hello
> ^C
> root@debian:~# sleep 60
> root@debian:~# netcat -p 4321 -v 10.0.01 1234
> Connection to 10.0.01 1234 port [tcp/*] succeeded!
> ^C
> root@debian:~#
> ```
> 
> We can see that on the first connection attempt we successfully receive a
> reply with payload from the server and then terminate the connection with
> Ctrl+C. Then we wait 60 seconds, which is necessary for the previous
> connection to move out of the TIME_WAIT state. Afterwards we open another
> connection, reusing the same src port as on the first connection and don't
> receive a reply from the server. The captured traffic shows, that after the
> three-way handshake for the second TCP connection, packets from the router to
> the clients use another server port than the one used for the initiation of
> the connection.

	May be it is due to the bad combination of NOTRACK and SNAT.
You hide only the one direction from Netfilter and Netfilter creates
conntracks only for traffic from real servers, it considers the
traffic from client as unreplied "reply" direction. Due to clash, 
netfilter probably selects different ports and creates multiple conntracks?
I'm not sure about this, it will need more digging to explain while
such port change happens in the middle of connection.

	Also, if IPVS and Netfilter have different view for the 
direction, ip_vs_conn_drop_conntrack() will fail to drop the conntrack
if IPVS has shorter state timeouts.

	I guess, you can not remove conntrack=1 because you need SNAT.
I don't see any other option, you have to remove the NOTRACK rule.
You try to avoid conntracks with it but they are needed for your SNAT 
rule and they are created anyways for the packets from real servers.
NOTRACK for both directions can help only when you don't use SNAT.

Regards

--
Julian Anastasov <ja@ssi.bg>

