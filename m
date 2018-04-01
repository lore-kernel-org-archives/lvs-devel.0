From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next v1] ipvs: fix multiplicative hashing in
 sh/dh/lblc/lblcr algorithms
Date: Sun, 1 Apr 2018 11:11:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1804011037200.1933@ja.home.ssi.bg>
References: <20180331222838.32758-1-vincent@bernat.im>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180331222838.32758-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

On Sun, 1 Apr 2018, Vincent Bernat wrote:

> The sh/dh/lblc/lblcr algorithms are using Knuth's multiplicative
> hashing incorrectly. This results in uneven distribution.

	Good catch.

> To fix this, the result has to be shifted by a constant. In "Lecture
> 21: Hash functions" [1], it is said:
> 
>    In the fixed-point version, The division by 2^q is crucial. The
>    common mistake when doing multiplicative hashing is to forget to do
>    it, and in fact you can find web pages highly ranked by Google that
>    explain multiplicative hashing without this step. Without this
>    division, there is little point to multiplying by a, because ka mod
>    m = (k mod m) * (a mod m) mod m . This is no better than modular
>    hashing with a modulus of m, and quite possibly worse.
> 
> Typing the 2654435761 constant in DuckDuckGo shows many other sources
> to confirm this issue. Moreover, doing the multiplication in the 32bit
> integer space is enough, hence the change from 2654435761UL to
> 2654435761U.
> 
> [1]: https://www.cs.cornell.edu/courses/cs3110/2008fa/lectures/lec21.html
> 
> The following Python program illustrates the bug and its fix:
> 
>     import netaddr
>     import collections
>     import socket
>     import statistics
> 
>     def run(buggy=False):
>         base = netaddr.IPAddress('203.0.113.0')
>         count = collections.defaultdict(int)
>         for offset in range(100):
>             for port in range(10000, 11000):
>                 r = socket.ntohs(port) + socket.ntohl(int(base) + offset)
>                 r *= 2654435761
>                 if buggy:
>                     r %= 1 << 64
>                 else:
>                     r %= 1 << 32
>                     r >>= 24
>                 r &= 255
>                 count[r] += 1
> 
>         print(buggy,
>               statistics.mean(count.values()),
>               statistics.stdev(count.values()))
> 
>     run(True)
>     run(False)
> 
> Its output is:
> 
>     True 25000 765.9416862050705
>     False 390.625 4.681209831891333
> 
> Signed-off-by: Vincent Bernat <vincent@bernat.im>
> ---
>  net/netfilter/ipvs/ip_vs_dh.c    | 4 +++-
>  net/netfilter/ipvs/ip_vs_lblc.c  | 4 +++-
>  net/netfilter/ipvs/ip_vs_lblcr.c | 4 +++-
>  net/netfilter/ipvs/ip_vs_sh.c    | 3 ++-
>  4 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
> index 75f798f8e83b..5638e66dbdd1 100644
> --- a/net/netfilter/ipvs/ip_vs_dh.c
> +++ b/net/netfilter/ipvs/ip_vs_dh.c
> @@ -81,7 +81,9 @@ static inline unsigned int ip_vs_dh_hashkey(int af, const union nf_inet_addr *ad
>  		addr_fold = addr->ip6[0]^addr->ip6[1]^
>  			    addr->ip6[2]^addr->ip6[3];
>  #endif
> -	return (ntohl(addr_fold)*2654435761UL) & IP_VS_DH_TAB_MASK;
> +	return ((ntohl(addr_fold)*2654435761U) >>
> +		(32 - IP_VS_DH_TAB_BITS)) &
> +		IP_VS_DH_TAB_MASK;

	Looks like the '& mask' part is not needed, still,
it does not generate extra code. I see that other code uses
hash_32(val, bits) from include/linux/hash.h but note that it
used different ratio before Linux 4.7, in case someone backports
this patch on old kernels. So, I don't have preference what should
be used, may be return hash_32(ntohl(addr_fold), IP_VS_DH_TAB_BITS)
is better.

Regards
