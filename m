From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 24/26] IPVS: Add IPv6 support to userspace interface.
Date: Wed, 11 Jun 2008 21:55:32 -0400
Message-ID: <48508214.6080306@hp.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-25-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-25-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: "Julius R. Volz" <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au, davem@davemloft.net, vbusam@google.com

Julius R. Volz wrote:
> +#ifdef CONFIG_IP_VS_IPV6
> +		struct in6_addr zero_addr = { .s6_addr32 = {0, 0, 0, 0} };
> +		if (usvc->af == AF_INET6 && !usvc->fwmark &&
> +		    ipv6_addr_equal(&usvc->addr.v6,&zero_addr) && !usvc->port) {
> +			ret = ip_vs_zero_all();
> +			goto out_unlock;
> +		}

You can change this ipv6_addr_equal() to ipv6_addr_any(&usvc->addr.v6) 
and get rid of the zero_addr variable mess.

-Brian
