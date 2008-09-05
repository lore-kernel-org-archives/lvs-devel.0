From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 1/2] ipvs: load balance IPv4 connections from a local process
Date: Fri, 5 Sep 2008 13:02:44 +0200
Message-ID: <f4845fc0809050402x5552f526pc8511026d7faa359@mail.gmail.com>
References: <20080905013609.GD14128@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220612568; bh=wMzFumwQOJVriFCKbz7fhHnjrzs=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=dJo3Y/lyyTU4gFp6Qm5eAWgwyZBUPO44
	C5OVUSJG7XxA50towAMk162QPpDrgpWWV02Xq2bNp6H5jjX4oTOGjA==
In-Reply-To: <20080905013609.GD14128@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

On Fri, Sep 5, 2008 at 3:36 AM, Simon Horman <horms@verge.net.au> wrote:
> @@ -1244,11 +1278,12 @@ ip_vs_in(unsigned int hooknum, struct sk
>        ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
>
>        /*
> -        *      Big tappo: only PACKET_HOST (neither loopback nor mcasts)
> -        *      ... don't know why 1st test DOES NOT include 2nd (?)
> +        *      Big tappo: only PACKET_HOST, including loopback for local client
> +        *      Don't handle local packets on IPv6 for now
>         */
> -       if (unlikely(skb->pkt_type != PACKET_HOST
> -                    || skb->dev->flags & IFF_LOOPBACK || skb->sk)) {
> +       if (unlikely(skb->pkt_type != PACKET_HOST ||
> +                    (af == AF_INET6 || (skb->dev->flags & IFF_LOOPBACK ||
> +                                        skb->sk)))) {

Hm, shouldn't this be (af == AF_INET6 && ...) instead of "||"? The
current expression just NF_ACCEPTs _any_ incoming IPv6 packets, even
non-local ones.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
