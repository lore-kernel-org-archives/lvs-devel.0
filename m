From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: autoload ipvs on genl access
Date: Thu, 21 Oct 2021 21:24:34 +0300 (EEST)
Message-ID: <c473dd-51ee-4358-4496-61c9c75f875@ssi.bg>
References: <20211021130255.4177-1-linux@weissschuh.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-1673610927-1634840677=:8245"
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20211021130255.4177-1-linux@weissschuh.net>
List-ID: <lvs-devel.vger.kernel.org>
To: =?UTF-8?Q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1673610927-1634840677=:8245
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Thu, 21 Oct 2021, Thomas Weißschuh wrote:

> The kernel provides the functionality to automatically load modules
> providing genl families. Use this to remove the need for users to
> manually load the module.
> 
> Signed-off-by: Thomas Weißschuh <linux@weissschuh.net>

	Looks good to me for -next tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 29ec3ef63edc..0ff94c66641f 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -48,6 +48,8 @@
>  
>  #include <net/ip_vs.h>
>  
> +MODULE_ALIAS_GENL_FAMILY(IPVS_GENL_NAME);
> +
>  /* semaphore for IPVS sockopts. And, [gs]etsockopt may sleep. */
>  static DEFINE_MUTEX(__ip_vs_mutex);
>  
> 
> base-commit: d9aaaf223297f6146d9d7f36caca927c92ab855a
> -- 
> 2.33.1

Regards
---1463811672-1673610927-1634840677=:8245--
