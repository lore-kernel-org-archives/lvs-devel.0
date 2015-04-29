From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Stop traffic to a destination when setting its
 weight to -1
Date: Wed, 29 Apr 2015 22:15:49 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1504292130100.1650@ja.home.ssi.bg>
References: <1430233841-14944-1-git-send-email-scientist@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1430233841-14944-1-git-send-email-scientist@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yannick Brosseau <scientist@fb.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Tue, 28 Apr 2015, Yannick Brosseau wrote:

> In some situation, we want to reap all the active connections
> to a host that is failing. Setting its weight to zero only stop new
> connections to the destination while still forwarding packets part of
> an active one.
> 
> We need a finer grained version of the sysctl_expire_nodest_conn because
> in most case we want to kept the behavior of only blocking new connexion.
> But if one host destination is failing we want to cut the traffic to
> that one immediately. Sending a RST is preferable than blackholling packets
> in that case.

	IIRC, we send RST only for this case:
"ip_vs_in: packet continues traversal as normal", i.e.
when no destination server is available. The place you
change uses NF_DROP.

	Here is the current situation:

- expire_nodest_conn=1 && weight=0 && cp != NULL => create
new cp to any available dest, expire old cp, forward packet

- cp != NULL && any weight && dest present (IP_VS_DEST_F_AVAILABLE
is set) => forward, even if weight=0

- cp != NULL && dest removed (IP_VS_DEST_F_AVAILABLE not set) =>
NF_DROP and expire old cp depending on expire_nodest_conn

	Can you confirm that the only goal of this change is
to allow per-destination expire_nodest_conn flag, i.e.
the benefit is when expire_nodest_conn=0 to use weight=-1,
so that traffic to be dropped? That is all I see in this
change, right? So, the same is achieved if destination
is removed and expire_nodest_conn=1 is used?

>  	/* set the dest status flags */
> -	dest->flags |= IP_VS_DEST_F_AVAILABLE;
> +	if (atomic_read(&dest->weight) >= 0) {
> +		dest->flags |= IP_VS_DEST_F_AVAILABLE;
> +	} else {
> +		dest->flags &= ~IP_VS_DEST_F_AVAILABLE;
> +	}

	Note that IP_VS_DEST_F_AVAILABLE is not checked
by all schedulers, only by ones that can hold dest after
it is removed (LBLC, LBLCR). IIRC, the check for DH scheduler
is not needed. As result, some schedulers need to be fixed
to check properly the negative weight, for example, LC
has atomic_read(&dest->weight) == 0 check. May be all
places that use dest->weight should be checked for
possible problem.

Regards

--
Julian Anastasov <ja@ssi.bg>
