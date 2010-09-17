From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] ipvs: Netfilter connection tracking changes
Date: Fri, 17 Sep 2010 14:28:19 +0200
Message-ID: <4C935EE3.5070207@trash.net>
References: <Pine.LNX.4.58.1009162342590.6976@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.1009162342590.6976@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Am 16.09.2010 22:46, schrieb Julian Anastasov:
> 
> 	Add more code to IPVS to work with Netfilter connection
> tracking and fix some problems.
> 
> - Allow IPVS to be compiled without connection tracking as in
> 2.6.35 and before. This can avoid keeping conntracks for all
> IPVS connections because this costs memory. ip_vs_ftp still
> depends on connection tracking and NAT as implemented for 2.6.36.
> 
> - Add sysctl var "conntrack" to enable connection tracking for
> all IPVS connections. For loaded IPVS directors it needs
> tuning of nf_conntrack_max limit.
> 
> - Add IP_VS_CONN_F_NFCT connection flag to request the connection
> to use connection tracking. This allows user space to provide this
> flag, for example, in dest->conn_flags. This can be useful to
> request connection tracking per real server instead of forcing it
> for all connections with the "conntrack" sysctl. This flag is
> set currently only by ip_vs_ftp and of course by "conntrack" sysctl.
> 
> - Add ip_vs_nfct.c file to hold all connection tracking code,
> by this way main code should not depend of netfilter conntrack
> support.
> 
> - Return back the ip_vs_post_routing handler as in 2.6.35 and use
> skb->ipvs_property=1 to allow IPVS to work without connection
> tracking
> 
> Connection tracking:
> 
> - most of the code is already in 2.6.36-rc
> 
> - alter conntrack reply tuple for LVS-NAT connections when first packet
> from client is forwarded and conntrack state is NEW or RELATED.
> Additionally, alter reply for RELATED connections from real server,
> again for packet in original direction.
> 
> - add IP_VS_XMIT_TUNNEL to confirm conntrack (without altering
> reply) for LVS-TUN early because we want to call nf_reset. It is
> needed because we add IPIP header and the original conntrack
> should be preserved, not destroyed. The transmitted IPIP packets
> can reuse same conntrack, so we do not set skb->ipvs_property.
> 
> - try to destroy conntrack when the IPVS connection is destroyed.
> It is not fatal if conntrack disappears before that, it depends
> on the used timers.
> 
> Fix problems from long time:
> 
> - add skb->ip_summed = CHECKSUM_NONE for the LVS-TUN transmitters

This one doesn't compile cleanly with CONFIG_IP_VS_NFCT=n:

  CC [M]  net/netfilter/ipvs/ip_vs_ftp.o
net/netfilter/ipvs/ip_vs_ftp.c: In function 'ip_vs_ftp_out':
net/netfilter/ipvs/ip_vs_ftp.c:242: error: implicit declaration of
function 'ip_vs_nfct_expect_related'

Please fix this and resend.
