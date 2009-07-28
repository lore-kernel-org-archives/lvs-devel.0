From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] IPVS: use pr_fmt
Date: Tue, 28 Jul 2009 09:55:20 -0700
Message-ID: <1248800120.6163.74.camel@Joe-Laptop.home>
References: <20090728160145.12503.61834.stgit@jazzy.zrh.corp.google.com>
	 <20090728160536.12503.82355.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090728160536.12503.82355.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hannes Eder <heder@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>

On Tue, 2009-07-28 at 18:06 +0200, Hannes Eder wrote:
> While being at it cleanup whitespace.
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index e01cc2d..99f09ab 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -99,47 +99,47 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
>  	return &buf[*idx - len];
>  }
>  
> -#define IP_VS_DBG_BUF(level, msg...)			\
> -    do {						\
> -	    char ip_vs_dbg_buf[160];			\
> -	    int ip_vs_dbg_idx = 0;			\
> -	    if (level <= ip_vs_get_debug_level())	\
> -		    printk(KERN_DEBUG "IPVS: " msg);	\
> -    } while (0)
[]
> +#define IP_VS_DBG_BUF(level, msg...)				\
> +	do {							\
> +		char ip_vs_dbg_buf[160];			\
> +		int ip_vs_dbg_idx = 0;				\
> +		if (level <= ip_vs_get_debug_level())		\
> +			pr_debug(msg);				\

I think you should keep printk(KERN_DEBUG...) here and elsewhere.
Unless DEBUG is #defined, this won't print anything.


