From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs 1/2] ipvs: Do tcp/udp checksumming prior to tunnel
 xmit
Date: Fri, 25 Jul 2014 07:30:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407250651190.1554@ja.home.ssi.bg>
References: <1406097465-8180-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1407231054180.5114@ja.home.ssi.bg> <B3481EE3D901EA4983A2D2CFBA42F3AA700E2782@PRN-MBX01-3.TheFacebook.com> <alpine.LFD.2.11.1407240116400.2125@ja.home.ssi.bg>
 <alpine.LFD.2.11.1407240915400.1538@ja.home.ssi.bg> <20140724152921.44d4e3bd@agartrell-SH67H>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140724152921.44d4e3bd@agartrell-SH67H>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: "horms@verge.net.au" <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, kernel-team <Kernel-team@fb.com>


	Hello,

On Thu, 24 Jul 2014, Alex Gartrell wrote:

> So I've found a patch that addresses the problem in what I suspect is the
> right way.
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 6f70bdd..ea7ef5e 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -486,6 +486,7 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
>         if (ret == NF_ACCEPT) {
>                 nf_reset(skb);
>                 skb_forward_csum(skb);
> +               skb->encapsulation = 1;
>         }
>         return ret;
>  }
> 
> Empirically, this solves my problem :) I believe it solves the problem more
> generally as well.
> 
> Digging deeper into the v6 case (FB <3's v6)
> 
> ip_vs_tunnel_xmit_v6
> -> ip6_local_out
> -> __ip6_local_out
> -> dst_output
> -> dst_output_sk
> -> skb_dst(skb)->output (= ip6_output)
> -> ip6_finish_output
> -> ip6->finish_output2
> -> neigh_direct_output
> -> dev_queue_xmit
> -> __dev_queue_xmit
> -> dev_hard_start
> 
> And then we run into this:
> 
>         /* If encapsulation offload request, verify we are testing
>          * hardware encapsulation features instead of standard
>          * features for the netdev
>          */
>         if (skb->encapsulation)
>                 features &= dev->hw_enc_features;
> 
> This essentially strips out NETIF_F_ALL_CSUM, so we end up invoking
> skb_checksum_help below.

	For the case with missing NETIF_F_ALL_CSUM bits
skb_checksum_help() does not care for skb->encapsulation,
it works only by checking skb->csum_* fields. The
skb_set_inner_transport_header() and skb_set_transport_header()
calls simply update the header pointers for the drivers
that have NETIF_F_ALL_CSUM bits set.

	What is your driver? I have to check why do you
have problem when NETIF_F_ALL_CSUM is not set. Is it
missing the NETIF_F_IP_CSUM (v4) and NETIF_F_IPV6_CSUM (v6) bits?

	Also, can you clarify again which test has
the problem with broken csums? All 3 tests? Or it
depends on enabled HW csums?

>         /* If packet is not checksummed and device does not
>          * support checksumming for this protocol, complete
>          * checksumming here.
>          */
>         if (skb->ip_summed == CHECKSUM_PARTIAL) {
>                 if (skb->encapsulation)
>                         skb_set_inner_transport_header(skb,
>                                 skb_checksum_start_offset(skb));
>                 else
>                         skb_set_transport_header(skb,
>                                 skb_checksum_start_offset(skb));
>                 if (!(features & NETIF_F_ALL_CSUM) &&
>                      skb_checksum_help(skb))
>                         goto out_kfree_skb;
>         }
> 
> Does this seem like a reasonable approach to you, Julian?

	Exactly, I was referring to this place. For IPv4
we do the same as your change in ip_vs_tunnel_xmit_prepare,
only that it is via iptunnel_handle_offloads() which in
addition to setting skb->encapsulation adds SKB_GSO_IPIP bit
for GSO purposes but skb_checksum_help() is called again
in dev_hard_start_xmit().

	Don't forget that the devices with NETIF_F_ALL_CSUM set
need skb_reset_inner_headers() call, they use the
skb->inner_* fields. What I have done in the patch is
just to copy the handling from ip*_tunnel*.c. When
NETIF_F_ALL_CSUM is not set we call skb_checksum_help() and
then the device driver detects CHECKSUM_NONE, not
CHECKSUM_PARTIAL.

Regards

--
Julian Anastasov <ja@ssi.bg>
