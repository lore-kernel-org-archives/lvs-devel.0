From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v4.1] ipvs: IPv6 tunnel mode
Date: Tue, 19 Oct 2010 10:40:24 +0200
Message-ID: <4CBD5978.7020108@trash.net>
References: <20101016075837.GB2027@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101016075837.GB2027@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Julius Volz <juliusv@google.com>, Wensong Zhang <wensong@linux-vs.org>, =?ISO-8859-1?Q?Hans_Schillstr=F6?= =?ISO-8859-1?Q?m?= <hans.schillstrom@ericsson.com>

Am 16.10.2010 09:58, schrieb Simon Horman:
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> ipvs: IPv6 tunnel mode
> 
> IPv6 encapsulation uses a bad source address for the tunnel.
> i.e. VIP will be used as local-addr and encap. dst addr.
> Decapsulation will not accept this.
> 
> Example
> LVS (eth1 2003::2:0:1/96, VIP 2003::2:0:100)
>    (eth0 2003::1:0:1/96)
> RS  (ethX 2003::1:0:5/96)
> 
> tcpdump
> 2003::2:0:100 > 2003::1:0:5:
> IP6 (hlim 63, next-header TCP (6) payload length: 40)
>  2003::3:0:10.50991 > 2003::2:0:100.http: Flags [S], cksum 0x7312
> (correct), seq 3006460279, win 5760, options [mss 1440,sackOK,TS val
> 1904932 ecr 0,nop,wscale 3], length 0
> 
> In Linux IPv6 impl. you can't have a tunnel with an any cast address
> receiving packets (I have not tried to interpret RFC 2473)
> To have receive capabilities the tunnel must have:
>  - Local address set as multicast addr or an unicast addr
>  - Remote address set as an unicast addr.
>  - Loop back addres or Link local address are not allowed.
> 
> This causes us to setup a tunnel in the Real Server with the
> LVS as the remote address, here you can't use the VIP address since it's
> used inside the tunnel.
> 
> Solution
> Use outgoing interface IPv6 address (match against the destination).
> i.e. use ip6_route_output() to look up the route cache and
> then use ipv6_dev_get_saddr(...) to set the source address of the
> encapsulated packet.
> 
> Additionally, cache the results in new destination
> fields: dst_cookie and dst_saddr and properly check the
> returned dst from ip6_route_output. We now add xfrm_lookup
> call only for the tunneling method where the source address
> is a local one.
> 
> Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> ---
> 
> Original patch by Hans Schillstrom.
> Check dst state and cache results for IPv6 by Julian Anastasov.
> Subsequent revisions made by Hans Schillstrom:
> 
> * v1
>     
>   This is Julian's patch with a slightly edited version of the description
>   from Hans's original patch.
> 
> * v2
>     
>   Updated changelog as per commends from Julian
> 
> * v3
>     
>   Flowi dest address used as destination instead of rt6_info in
> +ip_vs_tunnel_xmit_v6()
>   rt6_info somtimes contains a netw address insted of a tunnel
> 
> * v4
>     
>   Update destination as recommended from Julian
>   i.e. use &cp->daddr.in6
> 
> * v4.1 Simon Horman
>   Fix patch corruption
> 
> Patrick, please consider this for nf-next-2.6

Applied, thanks.

