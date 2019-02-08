From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] ipvs: Use struct_size() helper
Date: Fri, 8 Feb 2019 10:56:48 +0100
Message-ID: <20190208095648.la4ushbjxkqgqzb6@verge.net.au>
References: <20190208004456.GA15845@embeddedor>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1549619811; bh=4iiox4Kt9PGuWxnqzfkvo074yaByLgoMV8mjvP/ryZg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Psc6I4DFHwwya6AqCfb33NuJXK1Mkx+rlogwf5X8mPA/FYtNE/vNcLkb4p/JjW1S1
         r6awqVSDY/xs/xWAN0pzOCbL5DEDvRqqRbX0Azw0igdvddk1NF8dUYID8THpu2pn67
         XITtZ7dS/5XptIIHrJCyD9Sc6yZfTzZXQ8s6aZ3k=
Content-Disposition: inline
In-Reply-To: <20190208004456.GA15845@embeddedor>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Thu, Feb 07, 2019 at 06:44:56PM -0600, Gustavo A. R. Silva wrote:
> One of the more common cases of allocation size calculations is finding
> the size of a structure that has a zero-sized array at the end, along
> with memory for some number of elements for that array. For example:
> 
> struct foo {
>     int stuff;
>     struct boo entry[];
> };
> 
> size = sizeof(struct foo) + count * sizeof(struct boo);
> instance = alloc(size, GFP_KERNEL)
> 
> Instead of leaving these open-coded and prone to type mistakes, we can
> now use the new struct_size() helper:
> 
> size = struct_size(instance, entry, count);
> 
> This code was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

Pablo, could you consider applying this?

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 7d6318664eb2..bcd9112f47d9 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2734,8 +2734,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  		int size;
>  
>  		get = (struct ip_vs_get_services *)arg;
> -		size = sizeof(*get) +
> -			sizeof(struct ip_vs_service_entry) * get->num_services;
> +		size = struct_size(get, entrytable, get->num_services);
>  		if (*len != size) {
>  			pr_err("length: %u != %u\n", *len, size);
>  			ret = -EINVAL;
> @@ -2776,8 +2775,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  		int size;
>  
>  		get = (struct ip_vs_get_dests *)arg;
> -		size = sizeof(*get) +
> -			sizeof(struct ip_vs_dest_entry) * get->num_dests;
> +		size = struct_size(get, entrytable, get->num_dests);
>  		if (*len != size) {
>  			pr_err("length: %u != %u\n", *len, size);
>  			ret = -EINVAL;
> -- 
> 2.20.1
> 
