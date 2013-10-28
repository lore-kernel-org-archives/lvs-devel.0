From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs 2/2] net: ipvs: sctp: do not recalc sctp checksum
 when not needed
Date: Mon, 28 Oct 2013 10:11:47 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1310280930050.1490@ssi.bg>
References: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com> <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org


	Hello,

On Fri, 25 Oct 2013, Daniel Borkmann wrote:

> +	/* Only update csum if we really have to */
> +	if (sctph->source != cp->vport || payload_csum) {
> +		sctph->source = cp->vport;
> +		sctp_nat_csum(skb, sctph, sctphoff);
> +	}

	The 'if' check for snat_handler should be:

	if (sctph->source != cp->vport || payload_csum ||
	    skb->ip_summed == CHECKSUM_PARTIAL) {

	Because we can see CHECKSUM_PARTIAL from virtual devices,
not only from LOCAL_OUT. That is why I removed the '!skb->dev'
check.

	The 'else' part should be:

	} else {
		skb->ip_summed = CHECKSUM_UNNECESSARY;
	}

> +	/* Only update csum if we really have to */
> +	if (sctph->dest != cp->dport || payload_csum) {
> +		sctph->dest = cp->dport;
> +		sctp_nat_csum(skb, sctph, sctphoff);
> +	}

	The 'else' part for dnat_handler should be:

	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
		skb->ip_summed = CHECKSUM_UNNECESSARY;  
	}
         
	Because:
        
- CHECKSUM_COMPLETE: we should not see it for SCTP, in fact
the small set of drivers that support SCTP offloading return
CHECKSUM_UNNECESSARY on correctly received SCTP csum

- CHECKSUM_PARTIAL: we can see it from local stack or
received from virtual drivers. Checks in the 'if' part
will decide whether it is ok to keep CHECKSUM_PARTIAL for
the output

- CHECKSUM_NONE: packet was with unknown checksum. As we
recalculate the sum for IP header in all cases, it should
be safe to use CHECKSUM_UNNECESSARY. We can forward
wrong checksum in this case (without cp->app).

- CHECKSUM_UNNECESSARY: csum was valid on receive

	The 'if' part for dnat_handler can be:

	if (sctph->dest != cp->dport || payload_csum ||
	    (skb->ip_summed == CHECKSUM_PARTIAL &&
	     !(skb_dst(skb)->dev->features & NETIF_F_SCTP_CSUM))) {

	I.e. we keep CHECKSUM_PARTIAL only if the new device
supports offloading.

	One thing to note: 'lo' does not seem to include
NETIF_F_SCTP_CSUM, so full checksum is calculated.

Regards

--
Julian Anastasov <ja@ssi.bg>
