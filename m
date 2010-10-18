From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 00/12] ipvs: changes for local server and local client
Date: Mon, 18 Oct 2010 10:42:27 +0200
Message-ID: <201010181042.27654.hans.schillstrom@ericsson.com>
References: <alpine.LFD.2.00.1010171607550.20665@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010171607550.20665@ja.ssi.bg>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

Hi Julian

On Sunday 17 October 2010 15:12:21 Julian Anastasov wrote:
>
>  	Hello,
>
>  	The following patches fix some bugs (patch 1 and 2),
> add support for NAT to local real server, add handlers in
> LOCAL_OUT to properly schedule connections from local clients.
> Currently, patch 9 and 10 add these handlers in LOCAL_OUT
> without any configuration, i.e. we add code in OUTPUT hook
> which is not good for the performance of non-IPVS traffic.
> May be some config option that enables support for DNAT
> to local servers and for local clients can help for this.
>
>  	The patches are against recent nf-next and require
> the "ipvs: IPv6 tunnel mode" patch. They are tested
> and can be applied to nf-next after review/comments.
>
> What works:
>
> - NAT to local real server, even with different port, from local
> or remote client
>
> - local client:
>  	- NAT, DR, TUN
>
>  	- from LOCAL_OUT, needs client to bind socket
>  	to non-VIP address before connecting if DR/TUN servers are
>  	used because the output routing before OUTPUT hook
>  	selects VIP as source address ignoring any preferred source
>  	addresses, even if the local route is replaced.
>
> Not tested: IPv6. I'll need help here from people with IPv6 setups.
>

I can help you with some IPv6 testing this week.

I would be nice to change the IPv6 address print format from %pI6 to %pI6c to get a more compact debug output.

> Remaining problems:
>
> - IPv6 defragmentation: still not implemented, we rely on netfilter defrag
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
> --
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
