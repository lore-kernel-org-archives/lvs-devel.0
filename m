From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/6] move ipvs to PRE/POSTROUTING
Date: Fri, 18 Apr 2008 10:14:29 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804180937220.2843@u.domain.uli>
References: <200804151540.04006.j.stubbs@linkthink.co.jp>
 <Pine.LNX.4.58.0804161051400.2944@u.domain.uli> <200804171225.54424.j.stubbs@linkthink.co.jp>
 <200804171559.47753.j.stubbs@linkthink.co.jp>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <200804171559.47753.j.stubbs@linkthink.co.jp>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LVS Devel <lvs-devel@vger.kernel.org>


	Hello,

On Thu, 17 Apr 2008, Jason Stubbs wrote:

> On further investigation, the behaviour is the same regardless of whether it 
> is a VIP or a real host. When a SYN_SENT state exists traffic doesn't flow. 
> However, if there is no state and an ACK (no SYN) packet arrives, an 
> ESTABLISHED entry is created such as:

	This conntrack does not look good, dst=192.168.1.3 in
original direction is RIP instead of VIP.

	Your fw rules are not strict enough, you are using:

iptables -t filter -A FORWARD -d 192.168.0.7 -i eth0 -j ACCEPT
iptables -t filter -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -P FORWARD REJECT

	Can you replace first rule to allow traffic to VIP:VPORT
only for NEW. Most users don't allow traffic to any port, they
specify NEW for explicit ports, others are disabled. By this
way we can see if conntrack has valid directions. I suspect
conntracks are not properly confirmed which happens at
POST_ROUTING:NF_IP_PRI_CONNTRACK_CONFIRM. For the original
request we exit with NF_STOLEN and the forwarded request goes
to POST_ROUTING via dst_output call. Somewhere original destination
in conntrack is replaced (or wrongly set).

	You can also see the NFCT patch, it plays with conntrack
in the hard way but you can see how IPVS tries to keep conntracks
in good shape.

http://www.ssi.bg/~ja/nfct/
http://www.ssi.bg/~ja/nfct/ipvs-nfct-2.6.24-1.diff

> ipv4     2 tcp      6 431996 ESTABLISHED src=192.168.0.104 dst=192.168.1.3 
> sport=20001 dport=80 packets=1 bytes=54 [UNREPLIED] src=192.168.1.3 
> dst=192.168.0.104 sport=80 dport=20001 packets=0 bytes=0 mark=0 use=1
> 
> After this the connection can complete normally. I wonder if this is not a bug 
> in conntrack handling? It doesn't seem right to me.

	loose flag has different prurpose:

/* If it is set to zero, we disable picking up already established
   connections. */
static int nf_ct_tcp_loose __read_mostly = 1;

	I hope conntracks are not created per-packet? You have to
check how the conntrack looks in the different cases when playing
with nf_ct_tcp_loose. Addresses before [UNREPLIED] is the original
direction and data for the reply direction is the second part of
addresses. Also, tcp_conntracks[][][] looks valid for SS state
in the original direction, it will not switch to sES for invalid
senders (may be until tcp_loose is set?).

	I remember that for NFCT patch tests some packets
were dropped due to TCP SEQ number problems after ip_vs_ftp mangled
the IP addresses in FTP commands. Then I used

echo 1 > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_be_liberal

to solve it because ip_vs_ftp and tcp conntrack do not work
perfectly together.

Regards

--
Julian Anastasov <ja@ssi.bg>
