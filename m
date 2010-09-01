From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.6.36-rc2 RFC] ipvs: Netfilter connection tracking
 changes
Date: Wed, 1 Sep 2010 13:30:06 +0900
Message-ID: <20100901043006.GB15123@verge.net.au>
References: <Pine.LNX.4.58.1009010142350.21284@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.1009010142350.21284@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Hannes Eder <heder@google.com>

Hi Julian,

On Wed, Sep 01, 2010 at 02:22:12AM +0300, Julian Anastasov wrote:
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
> - new sysctl flag "snat_reroute". Recent kernels use
> ip_route_me_harder() to route LVS-NAT responses properly by
> VIP when there are multiple paths to client. But setups
> that do not have alternative default routes can skip this
> routing lookup by using snat_reroute=0.
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
> needed because we add IPIP header and we want the original conntrack
> to be preserved, not destroyed. The transmitted IPIP packets
> can reuse same conntrack, so we do not set skb->ipvs_property
> 
> - try to destroy conntrack when the IPVS connection is destroyed.
> It is not fatal if conntrack disappears before that, it depends
> on the used timers.
> 
> Fix problems from long time:
> 
> - add skb->ip_summed = CHECKSUM_NONE for the LVS-TUN transmitters
> 
> Fix problems only in 2.6.36-rc:
> 
> - when altering PASV response in ip_vs_ftp we should check with
> nfct_nat(ct) if NAT is enabled for conntrack before calling
> nf_nat_mangle_tcp_packet. This avoids possible crash when
> iptable_nat is not loaded.
> 
> - do not create expectation in ip_vs_ftp when PORT command is
> forwarded, leave it to nf_conntrack_ftp.c:help(). This
> avoids packet drops because nf_ct_expect_related() fails in help().
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	Simon, this patch is against 2.6.36-rc2, I tested it
> for IPv4. In fact, it is ready for inclusion in net-next but
> I'm not sure if it applies properly.

I can fix that if you prefer.

> After first comments we can
> move the discussion to netdev. The snat_reroute part can be
> separated, if needed at all.

I'd prefer a separate patch.

> Also, IP_VS_CONN_F_NFCT can be
> added to ipvsadm as real server option.

I can handle ipvsadm patches these days.
I can even make the patch if you'd prefer.

> The two problems
> in ip_vs_ftp can be also fixed in next 2.6.36-rc kernels.

Yes, as they are regressions since 2.6.35 please break those changes out
into one or two separate patches so they can be submitted for inclusion in
2.6.36.

> May be Hannes Eder can comment if he can see these problems.
> But I worry that this full patch is needed for 2.6.36
> because not all systems use netfilter conntrack and are
> not tuned for many conntracks. Now 2.6.36 can come as
> surprise to them because IPVS requires Netfilter connection
> tracking support.

Unfortunately I think its too late to get the bulk of this into 2.6.36.
Are you concerned about a performance problem? Even when
Hannes's new features aren't used? Is the snat_reroute flag a
solution/workaround? If so we could try to get that into 2.6.36,
although I'm not sure how well it would be received.
