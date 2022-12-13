From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipvs: fix type warning in do_div() on 32 bit
Date: Tue, 13 Dec 2022 12:09:28 +0100
Message-ID: <Y5hdaLpctttoNTLx@salvia>
References: <20221213032037.844517-1-kuba@kernel.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20221213032037.844517-1-kuba@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jakub Kicinski <kuba@kernel.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com, pabeni@redhat.com, horms@verge.net.au, ja@ssi.bg, kadlec@netfilter.org, fw@strlen.de, jwiesner@suse.de, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Hi Jakub,

On Mon, Dec 12, 2022 at 07:20:37PM -0800, Jakub Kicinski wrote:
> 32 bit platforms without 64bit div generate the following warning:
> 
> net/netfilter/ipvs/ip_vs_est.c: In function 'ip_vs_est_calc_limits':
> include/asm-generic/div64.h:222:35: warning: comparison of distinct pointer types lacks a cast
>   222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
>       |                                   ^~
> net/netfilter/ipvs/ip_vs_est.c:694:17: note: in expansion of macro 'do_div'
>   694 |                 do_div(val, loops);
>       |                 ^~~~~~
> include/asm-generic/div64.h:222:35: warning: comparison of distinct pointer types lacks a cast
>   222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
>       |                                   ^~
> net/netfilter/ipvs/ip_vs_est.c:700:33: note: in expansion of macro 'do_div'
>   700 |                                 do_div(val, min_est);
>       |                                 ^~~~~~
> 
> first argument of do_div() should be unsigned. We can't just cast
> as do_div() updates it as well, so we need an lval.
> Make val unsigned in the first place, all paths check that the value
> they assign to this variables are non-negative already.

Your patch is very similar to what Julian posted:

https://patchwork.ozlabs.org/project/netfilter-devel/patch/20221212195845.101844-1-ja@ssi.bg/

Thanks.
