From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] ipvs: Restrict connection table size via Kconfig
Date: Mon, 8 Sep 2008 16:13:54 +0200
Message-ID: <f4845fc0809080713u3da3d7d7g5df8810a19c9306c@mail.gmail.com>
References: <alpine.LNX.2.00.0809081332270.18192@titan.stealer.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220883235; bh=JRDKeTKwF0FP3GO9lRVv+6xS6CY=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=A1OiT5My1Ds+UUqy+V+ajeCaOaj0OvDp
	a8lfHss9dfgTb04jghMmF8HX5U0VBFDFBv7yiEyrey/IfENhRNwbuw==
In-Reply-To: <alpine.LNX.2.00.0809081332270.18192@titan.stealer.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Sven Wegener <sven.wegener@stealer.net>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

On Mon, Sep 8, 2008 at 1:38 PM, Sven Wegener wrote:
> Instead of checking the value in include/net/ip_vs.h, we can just
> restrict the range in our Kconfig file. This will prevent values outside
> of the range early.
>
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  include/net/ip_vs.h   |   10 +---------
>  net/ipv4/ipvs/Kconfig |    3 ++-
>  2 files changed, 3 insertions(+), 10 deletions(-)
>
> Don't know if we really should remove the check in ip_vs.h, but to some
> part we should trust our own code.

Seems ok!

> Based on lvs-next.
>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 1b13cef..38f4f69 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -621,16 +621,8 @@ extern void ip_vs_init_hash_table(struct list_head *table, int rows);
>  #ifndef CONFIG_IP_VS_TAB_BITS
>  #define CONFIG_IP_VS_TAB_BITS   12
>  #endif
> -/* make sure that IP_VS_CONN_TAB_BITS is located in [8, 20] */
> -#if CONFIG_IP_VS_TAB_BITS < 8
> -#define IP_VS_CONN_TAB_BITS    8
> -#endif
> -#if CONFIG_IP_VS_TAB_BITS > 20
> -#define IP_VS_CONN_TAB_BITS    20
> -#endif
> -#if 8 <= CONFIG_IP_VS_TAB_BITS && CONFIG_IP_VS_TAB_BITS <= 20
> +
>  #define IP_VS_CONN_TAB_BITS    CONFIG_IP_VS_TAB_BITS
> -#endif
>  #define IP_VS_CONN_TAB_SIZE     (1 << IP_VS_CONN_TAB_BITS)
>  #define IP_VS_CONN_TAB_MASK     (IP_VS_CONN_TAB_SIZE - 1)
>
> diff --git a/net/ipv4/ipvs/Kconfig b/net/ipv4/ipvs/Kconfig
> index 794cecb..de6004d 100644
> --- a/net/ipv4/ipvs/Kconfig
> +++ b/net/ipv4/ipvs/Kconfig
> @@ -41,7 +41,8 @@ config        IP_VS_DEBUG
>
>  config IP_VS_TAB_BITS
>        int "IPVS connection table size (the Nth power of 2)"
> -       default "12"
> +       range 8 20
> +       default 12
>        ---help---
>          The IPVS connection hash table uses the chaining scheme to handle
>          hash collisions. Using a big IPVS connection hash table will greatly

Reviewed-by: Julius Volz <juliusv@google.com>

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
