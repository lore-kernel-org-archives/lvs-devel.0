From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 18/26] IPVS: Add functions for getting/creating IPv6 connections.
Date: Wed, 11 Jun 2008 21:55:41 -0400
Message-ID: <4850821D.4080707@hp.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-19-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-19-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> +	INIT_LIST_HEAD(&cp->c_list);
> +	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
> +	cp->af		   = AF_INET6;
> +	cp->protocol	   = proto;
> +	cp->caddr.v6	   = *caddr;
> +	cp->cport	   = cport;
> +	cp->vaddr.v6	   = *vaddr;
> +	cp->vport	   = vport;
> +	cp->daddr.v6	   = *daddr;

ipv6_addr_copy().

-Brian
